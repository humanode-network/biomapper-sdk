// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Interface for the `MockBiomapper` contract.
/// @notice Mock controls.
interface IMockBiomapperControl {
    /// @notice Initializes a new generation.
    function initGeneration() external;

    /// @notice Creates a new biomapping for the specified account.
    /// @param account The address of the account to biomap.
    /// @param biotoken The biotoken to map to the account.
    function biomap(address account, bytes32 biotoken) external;
}
