// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockBiomapperLog} from "./MockBiomapperLog.sol";
import {ICheckUniqueness} from "@biomapper-sdk/core/ICheckUniqueness.sol";
import {IGenerationChangeEvents} from "@biomapper-sdk/events/IGenerationChangeEvents.sol";
import {IProveUniquenessEvents} from "@biomapper-sdk/events/IProveUniquenessEvents.sol";

/// @notice Mock contract implementing interfaces for Biomapper contract functionality.
contract MockBiomapper is
    ICheckUniqueness,
    IGenerationChangeEvents,
    IProveUniquenessEvents
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
        _MOCK_BIOMAPPER_LOG.initGeneration();
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

    /// @notice Initializes a new generation.
    function initGeneration() external {
        require(
            _currentGeneration != block.number,
            "initializing a generation twice in a single block is disallowed"
        );

        _currentGeneration = block.number;

        _MOCK_BIOMAPPER_LOG.initGeneration();

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

    /// @notice Creates a new biomapping for the specified account.
    /// @param account The address of the account to biomap.
    /// @param biotoken The biotoken to map to the account.
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
