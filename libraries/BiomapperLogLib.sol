// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IBiomapperRead} from "@biomapper-sdk/core/IBiomapperRead.sol";

/// @notice A utility library for the `BiomapperLog` contract.
library BiomapperLogLib {
    /// @notice Determines the uniqueness status of a given address in the current biomapper generation.
    /// The alternative way of using the `Biomapper` contract.
    /// @param biomapperLog The `BiomapperLog` contract.
    /// @param who The address to check for uniqueness.
    /// @return A boolean value indicating whether the address is biomapped (true) or not (false).
    function isUnique(
        IBiomapperRead biomapperLog,
        address who
    ) external view returns (bool) {
        uint256 currentGeneration = biomapperLog.generationsHead();

        uint256 biomappedAt = biomapperLog.generationBiomapping({
            account: who,
            generationPtr: currentGeneration
        });

        return biomappedAt != 0;
    }

    /// @notice Counts the number of blocks a user has been biomapped for.
    /// @param biomapperLog The `BiomapperLog` contract.
    /// @param who The address to count.
    /// @param fromBlock The starting block number.
    /// @return blocks The number of blocks the user has been biomapped for.
    function countBiomappedBlocks(
        IBiomapperRead biomapperLog,
        address who,
        uint256 fromBlock
    ) public view returns (uint256 blocks) {
        uint256 generation = biomapperLog.generationsHead();
        uint256 to = block.number;
        uint256 from;

        while (true) {
            from = biomapperLog.generationBiomapping({
                account: who,
                generationPtr: generation
            });

            if (from < fromBlock) from = fromBlock;

            assert(to > from);

            blocks += to - from;

            if (from <= fromBlock) break;

            to = generation;

            generation = biomapperLog
                .generationsListItem({ptr: generation})
                .prevPtr;
        }
    }

    /// @notice Finds the first generation a user was biomapped in.
    /// @param biomapperLog The `BiomapperLog` contract.
    /// @param who The address to check.
    /// @return The block number of the first biomapping for the user, or 0 if never biomapped.
    function firstBiomappedGeneration(
        IBiomapperRead biomapperLog,
        address who
    ) external view returns (uint256) {
        uint256 firstBiomap = biomapperLog.biomappingsTail({account: who});

        if (firstBiomap == 0) {
            return 0;
        }

        return
            biomapperLog
                .biomappingsListItem({account: who, ptr: firstBiomap})
                .generationPtr;
    }

    /// @notice Finds the block number of the oldest sequential biomapping for a user.
    /// @param biomapperLog The `BiomapperLog` contract.
    /// @param who The address of the user to check.
    /// @return The block number of the oldest sequential biomapping for the user,
    /// or 0 if not biomapped in the current generation.
    function firstSequentialBiomappedGeneration(
        IBiomapperRead biomapperLog,
        address who
    ) external view returns (uint256) {
        uint256 generation = biomapperLog.generationsHead();

        uint256 oldestSequentialBiomappedAt;

        while (true) {
            uint256 oldestSequentialBiomappedAtCandidate = biomapperLog
                .generationBiomapping({
                    account: who,
                    generationPtr: generation
                });

            if (oldestSequentialBiomappedAtCandidate == 0) {
                break;
            }

            oldestSequentialBiomappedAt = oldestSequentialBiomappedAtCandidate;

            generation = biomapperLog
                .generationsListItem({ptr: generation})
                .prevPtr;

            if (generation == 0) {
                break;
            }
        }

        return oldestSequentialBiomappedAt;
    }
}
