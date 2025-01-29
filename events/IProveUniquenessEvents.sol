// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Interface for the `Biomapper` contract.
/// @notice Interface for events related to proving uniqueness.
/// ## Exhaustiveness
/// Contract may emit other events not covered by this interface.
interface IProveUniquenessEvents {
    /// @notice Emitted when uniqueness is successfully proven and a new biomapping is added.
    /// @param account The address of the account for which uniqueness is proven.
    /// @param biotoken The biotoken associated with the account.
    event NewBiomapping(address account, bytes32 biotoken);
}
