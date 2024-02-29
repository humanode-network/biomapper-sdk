// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Interface for the `MockBiomapperLock` contract.
/// @notice Mock access for writing biomapper log.
interface IMockBiomapperLogWrite {
    /// @notice Initializes a new generation.
    function initGeneration() external;

    /// @notice Creates a new biomapping for the specified account.
    /// @param account The address of the account to biomap.
    function biomap(address account) external;
}
