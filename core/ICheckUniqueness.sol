// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @dev Interface of `Biomapper` contract.
/// @notice View the current biomapping state of a given account.
interface ICheckUniqueness {
    /// @notice Determines the uniqueness status of a given address in the current biomapper generation.
    /// @param queriedAddress The address to check for uniqueness.
    /// @return A boolean value indicating whether the address is biomapped (true) or not (false).
    function isUnique(address queriedAddress) external view returns (bool);
}
