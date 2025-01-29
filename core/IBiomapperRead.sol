// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Interface for the `BiomapperLog` contract.
/// @notice View historical biomapping state for a given account,
/// and overall generation changes.
///
/// #### Examples
///
/// See the [BiomapperLogExamples](../../usage/BiomapperLogExamples.sol/contract.BiomapperLogExamples.html).
interface IBiomapperRead {
    /// @notice Structure representing a biomapper generation as an element of a doubly linked list.
    ///
    /// @notice Pointer of {Generation} is a number of block that contains a 'generation change' transaction.
    ///
    /// #### Fields
    /// | Name | Type | Description |
    /// | ---- | ---- | ----------- |
    /// | generation | bytes32 | A salted hash of some deployment data. Deprecated, do not use. |
    /// | prevPtr | uint256 | Block number of the previous generation. 0 for the oldest generation. |
    /// | nextPtr | uint256 | Block number of the next generation. 0 for the current generation. |
    struct Generation {
        /// A salted hash of some deployment data.
        /// Deprecated, do not use.
        bytes32 generation; // Deprecated field
        /// Block number of the previous generation. 0 for the oldest generation.
        uint256 prevPtr;
        /// Block number of the next generation. 0 for the current generation.
        uint256 nextPtr;
    }

    /// @notice Structure representing a biomapping as an element of a doubly linked list.
    ///
    /// @notice Pointer of {Biomapping} is a number of block that contains a 'prove uniqueness' transaction.
    ///
    /// #### Fields
    /// | Name | Type | Description |
    /// | ---- | ---- | ----------- |
    /// | generationPtr | uint256 | Pointer to the generation that has this biomapping. |
    /// | prevPtr | uint256 | Block number of the previous biomapping. 0 for the oldest biomapping. |
    /// | nextPtr | uint256 | Block number of the next biomapping. 0 for the current biomapping. |
    struct Biomapping {
        /// Pointer to the generation that has this biomapping.
        uint256 generationPtr;
        /// Block number of the previous biomapping. 0 for the oldest biomapping.
        uint256 prevPtr;
        /// Block number of the next biomapping. 0 for the current biomapping.
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

    /// @notice Returns the {Biomapping} struct for a given biomapping pointer and account address.
    /// @param account The address of the requested account.
    /// @param ptr The biomapping pointer of the requested biomapping.
    /// @return The {Biomapping} structure.
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
    /// @return The block number in which the current generation began, 0 if no generations initialized.
    function generationsHead() external view returns (uint256);

    /// @notice Returns the block number in which the oldest generation began.
    /// @return The block number in which the oldest generation began, 0 if no generations initialized.
    function generationsTail() external view returns (uint256);

    /// @notice Returns the generation struct for a given generation pointer.
    /// @param ptr The pointer of the requested generation.
    /// @return The {Generation} structure.
    function generationsListItem(
        uint256 ptr
    ) external view returns (Generation memory);
}
