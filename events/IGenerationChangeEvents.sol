// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Interface for the `Biomapper` contract.
/// @notice Interface for events related to the biomapper generation changes.
/// ## Exhaustiveness
/// Contract may emit other events not covered by this interface.
interface IGenerationChangeEvents {
    /// @notice Emitted when the biomapper generation has been changed.
    event GenerationChanged();
}
