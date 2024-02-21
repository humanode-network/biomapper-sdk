// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @dev Interface for the `BiomapperLog` contract.
/// @notice View historical biomapping state for a given account,
/// and overall generation changes.
///
/// #### Examples
///
/// A loop through all generations.
///
/// ```solidity
/// uint256 generation = BiomapperLog.generationsHead();
///
/// while (true) {
/// 	// Do something with a generation.
///
///     generation = BiomapperLog
///         .generationsListItem({ptr: generation})
///         .prevPtr;
///
///     if (generation == 0) {
///         // It was the oldest generation.
///       break;
///     }
/// }
/// ```
///
/// Generations could also be searched from oldest to current.
///
/// ```solidity
/// uint256 generation = BiomapperLog.generationsTail();
///
/// while (true) {
///     // Do something with a generation.
///
///     generation = BiomapperLog
///         .generationsListItem({ptr: generation})
///         .nextPtr;
///
///     if (generation == 0) {
///         // It was the current generation.
///         break;
///     }
/// }
/// ```
interface IBiomapperLogRead {
    /// @notice Structure representing a biomapper generation.
    ///
    /// Pointer of {Generation} is a number of block that contains a 'generation change' transaction.
    struct Generation {
        /// @notice A salted hash of some deployment data.
        /// Deprecated, do not use.
        bytes32 generation; // Deprecated field
        /// @notice Block number of the previous generation.
        uint256 prevPtr;
        /// @notice Block number of the next generation.
        uint256 nextPtr;
    }

    /// @notice Structure representing a biomapping.
    ///
    /// Pointer of {Biomapping} is a number of block that contains a 'prove uniqueness' transaction.
    struct Biomapping {
        /// @notice Pointer to the generation that has this biomapping.
        uint256 generationPtr;
        /// @notice Block number of the previous biomapping.
        uint256 prevPtr;
        /// @notice Block number of the next biomapping.
        uint256 nextPtr;
    }

    /// @notice Returns the most recent biomapping pointer for a given account address.
    /// @param account The address of the requested account.
    /// @return The block number in which the most recent biomap occurred, or 0 if the account was never biomapped.
    function biomappingsHead(address account) external view returns (uint256);

    /// @notice Returns the oldest biomapping pointer for a given account address.
    /// @param account The address of the requested account.
    /// @return The block number in which the oldest biomap occurred, or 0 if the account was never biomapped.
    function biomappingsTail(address account) external view returns (uint256);

    /// @notice Returns the biomapping struct for a given biomapping pointer and account address.
    /// @param account The address of the requested account.
    /// @param ptr The biomapping pointer of the requested biomapping.
    /// @return The {Biomapping} structure.
    ///
    /// See {generationsListItem}.
    function biomappingsListItem(
        address account,
        uint256 ptr
    ) external view returns (Biomapping memory);

    /// @notice Returns the biomapping pointer for a given account address and generation pointer.
    /// @param account The address of the requested account.
    /// @param generationPtr The pointer of the requested generation.
    /// @return The block number in which the requested user was biomapped in the requested generation, or 0 if there was no biomapping.
    function generationBiomapping(
        address account,
        uint256 generationPtr
    ) external view returns (uint256);

    /// @notice Returns the block number in which the current generation began.
    /// @return The block number in which the current generation began.
    function generationsHead() external view returns (uint256);

    /// @notice Returns the block number in which the oldest generation began.
    /// @return The block number in which the oldest generation began.
    function generationsTail() external view returns (uint256);

    /// @notice Returns the generation struct for a given generation pointer.
    ///
    /// #### Examples
    ///
    /// Obtaining previous generation pointer:
    ///
    /// ```solidity
    /// previousGeneration = BiomapperLog
    ///     .generationsListItem({ptr: generation})
    ///     .prevPtr;
    /// ```
    ///
    /// @param ptr The pointer of the requested generation.
    /// @return The {Generation} structure.
    function generationsListItem(
        uint256 ptr
    ) external view returns (Generation memory);
}
