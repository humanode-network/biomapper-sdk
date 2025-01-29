// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IBiomapperRead} from "@biomapper-sdk/core/IBiomapperRead.sol";

/// @notice A utility library for the `Biomapper` contract.
library BiomapperLib {
    /// @notice Determines the uniqueness status of a given address in the current biomapper generation.
    /// The alternative way of using the `Biomapper` contract.
    /// @param biomapper The `Biomapper` contract.
    /// @param who The address to check for uniqueness.
    /// @return A boolean value indicating whether the address is biomapped (true) or not (false).
    function isUnique(
        IBiomapperRead biomapper,
        address who
    ) external view returns (bool) {
        uint256 currentGeneration = biomapper.generationsHead();

        uint256 biomappedAt = biomapper.generationBiomapping({
            account: who,
            generationPtr: currentGeneration
        });

        return biomappedAt != 0;
    }

    /// @notice Counts the number of blocks a user has been biomapped for.
    /// @param biomapper The `Biomapper` contract.
    /// @param who The address to count.
    /// @param fromBlock The starting block number.
    /// @return blocks The number of blocks the user has been biomapped for.
    function countBiomappedBlocks(
        IBiomapperRead biomapper,
        address who,
        uint256 fromBlock
    ) public view returns (uint256 blocks) {
        uint256 generation = biomapper.generationsHead();
        uint256 to = block.number;
        uint256 from;

        while (true) {
            from = biomapper.generationBiomapping({
                account: who,
                generationPtr: generation
            });

            if (from < fromBlock) from = fromBlock;

            assert(to > from);

            blocks += to - from;

            if (from <= fromBlock) break;

            to = generation;

            generation = biomapper
                .generationsListItem({ptr: generation})
                .prevPtr;
        }
    }

    /// @notice Finds the first generation a user was biomapped in.
    /// @param biomapper The `Biomapper` contract.
    /// @param who The address to check.
    /// @return The block number of the first biomapping for the user, or 0 if never biomapped.
    function firstBiomappedGeneration(
        IBiomapperRead biomapper,
        address who
    ) external view returns (uint256) {
        uint256 firstBiomap = biomapper.biomappingsTail({account: who});

        if (firstBiomap == 0) {
            return 0;
        }

        return
            biomapper
                .biomappingsListItem({account: who, ptr: firstBiomap})
                .generationPtr;
    }

    /// @notice Finds the block number of the oldest sequential biomapping for a user.
    /// @param biomapper The `Biomapper` contract.
    /// @param who The address of the user to check.
    /// @return The block number of the oldest sequential biomapping for the user,
    /// or 0 if not biomapped in the current generation.
    function firstSequentialBiomappedGeneration(
        IBiomapperRead biomapper,
        address who
    ) external view returns (uint256) {
        uint256 generation = biomapper.generationsHead();

        uint256 oldestSequentialBiomappedAt;

        while (true) {
            uint256 oldestSequentialBiomappedAtCandidate = biomapper
                .generationBiomapping({
                    account: who,
                    generationPtr: generation
                });

            if (oldestSequentialBiomappedAtCandidate == 0) {
                break;
            }

            oldestSequentialBiomappedAt = oldestSequentialBiomappedAtCandidate;

            generation = biomapper
                .generationsListItem({ptr: generation})
                .prevPtr;

            if (generation == 0) {
                break;
            }
        }

        return oldestSequentialBiomappedAt;
    }
}
