// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @dev Interface of `BiomapperLog` contract.
 *
 * Example of loop through all generations:
 *
 * ```solidity
 * uint256 generation = BiomapperLog.generationsHead();
 *
 * while (true) {
 *     // Do something with a generation.
 *
 *     generation = BiomapperLog
 *         .generationsListItem({ptr: generation})
 *         .prevPtr;
 *
 *     if (generation == 0) {
 *         // It was the oldest generation.
 *         break;
 *     }
 * }
 * ```
 *
 * Generations could also be searched from oldest to current.
 * The loop with such ordering:
 *
 * ```solidity
 * uint256 generation = BiomapperLog.generationsTail();
 *
 * while (true) {
 *     // Do something with a generation.
 *
 *     generation = BiomapperLog
 *         .generationsListItem({ptr: generation})
 *         .nextPtr;
 *
 *     if (generation == 0) {
 *         // It was the current generation.
 *         break;
 *     }
 * }
 * ```
 */
interface IBiomapperLogRead {
    /**
     * @dev Structure representing a biomapper generation.
     *
     * Pointer of {Generation} is a number of block that contains a 'generation change' transaction.
     */
    struct Generation {
        /**
         * @dev A salted hash of some deployment data.
         * Do not use.
         */
        bytes32 generation; // Deprecated field
        /**
         * @dev Block number of the previous generation.
         */
        uint256 prevPtr;
        /**
         * @dev Block number of the next generation.
         */

        uint256 nextPtr;
    }

    /**
     * @dev Structure representing a biomapping.
     *
     * Pointer of {Biomapping} is a number of block that contains a 'prove uniqueness' transaction.
     */
    struct Biomapping {
        /**
         * @dev Pointer to the generation that has this biomapping.
         */
        uint256 generationPtr;
        /**
         * @dev Block number of the previous biomapping.
         */
        uint256 prevPtr;
        /**
         * @dev Block number of the next biomapping.
         */
        uint256 nextPtr;
    }

    /**
     * @dev Returns the most recent biomapping pointer for a given account address.
     * @param account The address of the requested account.
     * @return The block number in which the most recent biomap occurred, or 0 if the account was never biomapped.
     */
    function biomappingsHead(address account) external view returns (uint256);

    /**
     * @dev Returns the oldest biomapping pointer for a given account address.
     * @param account The address of the requested account.
     * @return The block number in which the oldest biomap occurred, or 0 if the account was never biomapped.
     */
    function biomappingsTail(address account) external view returns (uint256);

    /**
     * @dev Returns the biomapping struct for a given biomapping pointer and account address.
     * @param account The address of the requested account.
     * @param ptr The biomapping pointer of the requested biomapping.
     * @return The {Biomapping} structure.
     *
     * See {generationsListItem}.
     */
    function biomappingsListItem(
        address account,
        uint256 ptr
    ) external view returns (Biomapping memory);

    /**
     * @dev Returns the biomapping pointer for a given account address and generation pointer.
     * @param account The address of the requested account.
     * @param generationPtr The pointer of the requested generation.
     * @return The block number in which the requested user was biomapped in the requested generation, or 0 if there was no biomapping.
     */
    function generationBiomapping(
        address account,
        uint256 generationPtr
    ) external view returns (uint256);

    /**
     * @dev Returns the block number in which the current generation began.
     * @return The block number in which the current generation began.
     */
    function generationsHead() external view returns (uint256);

    /**
     * @dev Returns the block number in which the oldest generation began.
     * @return The block number in which the oldest generation began.
     */
    function generationsTail() external view returns (uint256);

    /**
     * @dev Returns the generation struct for a given generation pointer.
     * @param ptr The pointer of the requested generation.
     * @return The {Generation} structure.
     *
     * Example of obtaining previous generation pointer:
     *
     * ```solidity
     * previousGeneration = BiomapperLog
     *     .generationsListItem({ptr: generation})
     *     .prevPtr;
     * ```
     */
    function generationsListItem(
        uint256 ptr
    ) external view returns (Generation memory);
}
