// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Interface for the `MockBridgedBiomapper` contract.
/// @notice Mock controls for the `MockBridgedBiomapper`.
interface IMockBridgedBiomapperControl {
    /// @notice Bridge the provided extract from the biomapper.
    function bridge() external;
}
