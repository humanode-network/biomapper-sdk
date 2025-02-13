// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Interface for the `BridgedBiomapper` contract.
/// @notice Interface for events related to bridging biomappings.
interface IBridgeBiomappingEvents {
    /// @notice New biomapping was bridged.
    /// @param account The address that bridged their biomap.
    /// @param biomappingPtr The block number on the Humanode chain when the biomapping event occurred.
    /// @param generationPtr The block number representing the generation to which this biomapping belongs.
    /// @param referenceHumanodeBlockNumber The block number on the Humanode chain when data was taken.
    /// @param referenceHumanodeBlockHash The block hash on the Humanode chain when data was taken.
    event NewBridgedBiomapping(
        address account,
        uint256 biomappingPtr,
        uint256 generationPtr,
        uint256 referenceHumanodeBlockNumber,
        bytes32 referenceHumanodeBlockHash
    );

    /// @notice New generation was bridged.
    /// @param generationPtr The block number on the Humanode chain when the generation started.
    /// @param referenceHumanodeBlockNumber The block number on the Humanode chain when data was taken.
    /// @param referenceHumanodeBlockHash The block hash on the Humanode chain when data was taken.
    event NewBridgedGeneration(
        uint256 generationPtr,
        uint256 referenceHumanodeBlockNumber,
        bytes32 referenceHumanodeBlockHash
    );
}
