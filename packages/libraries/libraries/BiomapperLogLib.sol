// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IBiomapperLogRead} from "@biomapper-sdk/core/interfaces/IBiomapperLogRead.sol";

library BiomapperLogLib {
    function isUnique(
        IBiomapperLogRead biomapperLog,
        address who
    ) external view returns (bool) {
        uint256 currentGeneration = biomapperLog.generationsHead();

        uint256 biomappedAt = biomapperLog.generationBiomapping({
            account: who,
            generationPtr: currentGeneration
        });

        return biomappedAt != 0;
    }

    function firstBiomappedGeneration(
        IBiomapperLogRead biomapperLog,
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

    function firstSequentialBiomappedGeneration(
        IBiomapperLogRead biomapperLog,
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
