// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICheckUniqueness} from "@biomapper-sdk/core/ICheckUniqueness.sol";

/// @dev Usage examples for the `Biomapper` contract.
/// @notice Here are the usage examples for the `Biomapper` contract.
///
/// `Biomapper` manages the biomappings in the current generation and
/// ensures address uniqueness.
///
/// ### Note
///
/// If you are viewing this though the documentation, you should instead open
/// the full source code of this file to see the contents of the functions.
contract BiomapperExamples {
    /// @notice Assume this is the address of the `Biomapper` contract.
    /// You can find the actual address in the documentation.
    address public immutable BIOMAPPER_CONTRACT_ADDRESS;

    /// @notice A simple uniqueness check.
    /// @dev Go to the source code if you are viewing this though
    /// the documentation.
    function example1() external view {
        address addressToCheck = 0x1111111111111111111111111111111111111111;
        bool isUnique = ICheckUniqueness(BIOMAPPER_CONTRACT_ADDRESS).isUnique(
            addressToCheck
        );
    }
}
