// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IBiomapperRead} from "@biomapper-sdk/core/IBiomapperRead.sol";

/// @dev Usage examples for the `BiomapperLog` contract.
/// @notice Here are the usage examples for the `BiomapperLog` contract.
///
/// `BiomapperLog` exposes historical state of biomapping and generation
/// changes.
///
/// ### Note
///
/// If you are viewing this though the documentation, you should instead open
/// the full source code of this file to see the contents of the functions.
contract BiomapperLogExamples {
    /// @notice Assume this is the address of the `BiomapperLog` contract.
    /// You can find the actual address in the documentation.
    address public immutable BIOMAPPER_LOG_CONTRACT_ADDRESS;

    /// @notice A loop through all generations.
    /// @dev Go to the source code if you are viewing this though
    /// the documentation.
    function example1() external view {
        // Activate the interface.
        IBiomapperRead biomapperLog = IBiomapperRead(
            BIOMAPPER_LOG_CONTRACT_ADDRESS
        );

        // Take the latest (aka current) generation.
        uint256 generation = biomapperLog.generationsHead();

        while (true) {
            // Do something with a generation.

            // Move to the previous generation - i.e in the newest to oldest
            // direction.
            generation = biomapperLog
                .generationsListItem({ptr: generation})
                .prevPtr;

            // Condition to stop the iteration.
            if (generation == 0) {
                // It was the oldest generation.
                break;
            }
        }
    }

    /// @notice Generations could also be searched from oldest to current.
    /// @dev Go to the source code if you are viewing this though
    /// the documentation.
    function example2() external view {
        // Activate the interface.
        IBiomapperRead biomapperLog = IBiomapperRead(
            BIOMAPPER_LOG_CONTRACT_ADDRESS
        );

        // Take the oldest (aka first) generation.
        uint256 generation = biomapperLog.generationsTail();

        while (true) {
            // Do something with a generation.

            // Move to the next generation - i.e. in the oldest to newest
            // direction.
            generation = biomapperLog
                .generationsListItem({ptr: generation})
                .nextPtr;

            // Condition to stop the iteration.
            if (generation == 0) {
                // It was the current generation.
                break;
            }
        }
    }
}
