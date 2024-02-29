// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockBiomapperLog} from "./MockBiomapperLog.sol";
import {IMockBiomapperControl} from "./IMockBiomapperControl.sol";
import {ICheckUniqueness} from "@biomapper-sdk/core/ICheckUniqueness.sol";
import {IGenerationChangeEvents} from "@biomapper-sdk/events/IGenerationChangeEvents.sol";
import {IProveUniquenessEvents} from "@biomapper-sdk/events/IProveUniquenessEvents.sol";

/// @notice Mock contract implementing `Biomapper` contract interfaces.
///
/// @notice Use this contract is your tests and development stages to emulate
/// the behaviour of the `Biomapper` contract.
///
/// @notice When created, the `MockBiomapper` contract is empty.
/// Use the `biomap` and `initGeneration` calls to drive the mock state
/// as needed. Use `getMockBiomapperLogAddress` to obtain the address of
/// the contract that implements the `BiomapperLog` interfaces.
contract MockBiomapper is
    ICheckUniqueness,
    IGenerationChangeEvents,
    IProveUniquenessEvents,
    IMockBiomapperControl
{
    /// @dev Mapping `account => true` for quick access to unique accounts.
    mapping(uint256 => mapping(address => bool)) private _unique;
    /// @dev Mapping `biotoken => account` for storing biotokens.
    mapping(uint256 => mapping(bytes32 => address)) private _biotokens;

    uint256 private _currentGeneration;

    /// @dev MockBiomapperLog contract instance for logging biomapper events.
    MockBiomapperLog private immutable _MOCK_BIOMAPPER_LOG;

    constructor() {
        _MOCK_BIOMAPPER_LOG = new MockBiomapperLog();
        _MOCK_BIOMAPPER_LOG.initGeneration(0);
    }

    /// @notice Returns the address of the MockBiomapperLog contract instance.
    function getMockBiomapperLogAddress()
        public
        view
        returns (address mockBiomapperLogAddress)
    {
        return address(_MOCK_BIOMAPPER_LOG);
    }

    /// @inheritdoc ICheckUniqueness
    function isUnique(address queriedAddress) external view returns (bool) {
        return _unique[_currentGeneration][queriedAddress];
    }

    /// @inheritdoc IMockBiomapperControl
    function initGeneration() external {
        require(
            _currentGeneration != block.number,
            "initializing a generation twice in a single block is disallowed"
        );

        _currentGeneration = block.number;

        _MOCK_BIOMAPPER_LOG.initGeneration(0);

        emit IGenerationChangeEvents.GenerationChanged();
    }

    /// @notice Sender account is already mapped to a given biotoken.
    /// No further actions required.
    error BiomappingAlreadyExists();

    /// @notice Sender account is already mapped to another biotoken.
    /// User can try again using another account.
    error AccountHasAnotherBiotokenAttached();

    /// @notice Given biotoken is already mapped to `anotherAccount`.
    /// User can use another biotoken with this account.
    error BiotokenAlreadyMappedToAnotherAccount(address anotherAccount);

    /// @inheritdoc IMockBiomapperControl
    function biomap(address account, bytes32 biotoken) external {
        bool isSenderAlreadyMapped = _unique[_currentGeneration][account];
        if (isSenderAlreadyMapped) {
            bool isBiotokenAlreadyMappedToSender = _biotokens[
                _currentGeneration
            ][biotoken] == account;
            if (isBiotokenAlreadyMappedToSender) {
                revert BiomappingAlreadyExists();
            }
            revert AccountHasAnotherBiotokenAttached();
        }

        bool isBiotokenAlreadyMapped = _biotokens[_currentGeneration][
            biotoken
        ] != address(0);
        if (isBiotokenAlreadyMapped) {
            address anotherAccount = _biotokens[_currentGeneration][biotoken];
            revert BiotokenAlreadyMappedToAnotherAccount(anotherAccount);
        }

        _unique[_currentGeneration][account] = true;
        _biotokens[_currentGeneration][biotoken] = account;

        _MOCK_BIOMAPPER_LOG.biomap(account);

        emit IProveUniquenessEvents.NewBiomapping({
            account: account,
            biotoken: biotoken
        });
    }
}
