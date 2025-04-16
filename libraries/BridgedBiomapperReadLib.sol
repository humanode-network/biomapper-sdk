// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IBridgedBiomapperRead} from "@biomapper-sdk/core/IBridgedBiomapperRead.sol";

/// @notice A utility library for the `BridgedBiomapper` contract.
library BridgedBiomapperReadLib {
    /// @notice Determines the uniqueness status of a given address in the last known biomapper generation.
    ///
    /// @notice This call does not guarantee uniqueness across generations,
    /// meaning the same person can pass this check more than once (perform a Sybil-attack):
    /// with same biometrics but different account after each generation change.
    /// Ensure you are fully understand the implications of generations and the security guarantees they provide,
    /// and consider explicitly scoping your uniqueness check by a particular generation.
    ///
    /// @param bridgedBiomapperRead The `bridgedBiomapperRead` contract.
    /// @param who The address to check for uniqueness.
    /// @return A boolean value indicating whether the address is biomapped (true) or not (false).
    function isUniqueInLastKnownGeneration(
        IBridgedBiomapperRead bridgedBiomapperRead,
        address who
    ) external view returns (bool) {
        uint256 currentGeneration = bridgedBiomapperRead.generationsHead();

        uint256 biomappedAt = bridgedBiomapperRead.lookupBiomappingPtr({
            account: who,
            generationPtr: currentGeneration
        });

        return biomappedAt != 0;
    }

    /// @notice Counts the number of blocks a user has been biomapped for.
    /// @param bridgedBiomapperRead The `IBridgedBiomapperRead` contract.
    /// @param who The address to count.
    /// @param fromBlock The starting block number.
    /// @return blocks The number of blocks the user has been biomapped for.
    function countBiomappedBlocks(
        IBridgedBiomapperRead bridgedBiomapperRead,
        address who,
        uint256 fromBlock
    ) public view returns (uint256 blocks) {
        uint256 generation = bridgedBiomapperRead.generationsHead();
        uint256 to = block.number;
        uint256 from;

        while (true) {
            from = bridgedBiomapperRead.lookupBiomappingPtr({
                account: who,
                generationPtr: generation
            });

            if (from < fromBlock) from = fromBlock;

            assert(to > from);

            blocks += to - from;

            if (from <= fromBlock) break;

            to = generation;

            generation = bridgedBiomapperRead
                .generationsListItem({ptr: generation})
                .prevPtr;
        }
    }

    /// @notice Finds the first generation a user was biomapped in.
    /// @param bridgedBiomapperRead The `IBridgedBiomapperRead` contract.
    /// @param who The address to check.
    /// @return The block number of the first biomapping for the user, or 0 if never biomapped.
    function firstBiomappedGeneration(
        IBridgedBiomapperRead bridgedBiomapperRead,
        address who
    ) external view returns (uint256) {
        uint256 firstBiomap = bridgedBiomapperRead.biomappingsTail({
            account: who
        });

        if (firstBiomap == 0) {
            return 0;
        }

        return
            bridgedBiomapperRead
                .biomappingsListItem({account: who, ptr: firstBiomap})
                .generationPtr;
    }
}
