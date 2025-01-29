// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IMockBiomapperLogWrite} from "./IMockBiomapperLogWrite.sol";
import {IBiomapperRead} from "@biomapper-sdk/core/IBiomapperRead.sol";

/// @notice Mock contract implementing `BiomapperLog` contract interfaces.
///
/// @notice It is constructed as part of the `MockBiomapper`, but it is also
/// possible to construct and use the `MockBiomapperLog` independently.
///
/// @notice When used in conjunction with `MockBiomapper`, the interactions with
/// the corresponding `MockBiomapper` will drive the `MockBiomapperLog` state
/// accordingly, so there is no need to separately control
/// the `MockBiomapperLog` state.
///
/// @notice When deployed independently, use the `IMockBiomapperLogWrite`
/// interface to drive the state.
contract MockBiomapperLog is IBiomapperRead, IMockBiomapperLogWrite {
    uint256 public generationsHead;
    uint256 public generationsTail;
    mapping(uint256 => Generation) public generationsList;

    mapping(address => uint256) public biomappingsHeads;
    mapping(address => uint256) public biomappingsTails;
    mapping(address => mapping(uint256 => Biomapping)) public biomappingsLists;

    mapping(address => mapping(uint256 => uint256))
        public generationBiomappings;

    /// @inheritdoc IBiomapperRead
    function biomappingsHead(
        address account
    ) external view override returns (uint256) {
        return biomappingsHeads[account];
    }

    /// @inheritdoc IBiomapperRead
    function biomappingsTail(
        address account
    ) external view override returns (uint256) {
        return biomappingsTails[account];
    }

    /// @inheritdoc IBiomapperRead
    function biomappingsListItem(
        address account,
        uint256 ptr
    ) external view override returns (Biomapping memory) {
        return biomappingsLists[account][ptr];
    }

    /// @inheritdoc IBiomapperRead
    function generationsListItem(
        uint256 ptr
    ) external view override returns (Generation memory) {
        return generationsList[ptr];
    }

    /// @inheritdoc IBiomapperRead
    function generationBiomapping(
        address account,
        uint256 generationPtr
    ) external view override returns (uint256) {
        return generationBiomappings[account][generationPtr];
    }

    /// @inheritdoc IMockBiomapperLogWrite
    function initGeneration(bytes32 generation) public {
        uint256 prevPtr = generationsHead;
        require(
            prevPtr != block.number,
            "initializing a generation twice in a single block is disallowed"
        );

        Generation storage newGeneration = generationsList[block.number];

        newGeneration.generation = generation;
        newGeneration.prevPtr = prevPtr;

        generationsHead = block.number;

        if (prevPtr == 0) {
            generationsTail = block.number;
        } else {
            generationsList[prevPtr].nextPtr = block.number;
        }
    }

    /// @inheritdoc IMockBiomapperLogWrite
    function biomap(address account) public {
        uint256 generationPtr = generationsHead;
        require(generationPtr != 0, "generation must be initialized");

        uint256 prevPtr = biomappingsHeads[account];

        Biomapping storage newBiomapping = biomappingsLists[account][
            block.number
        ];

        newBiomapping.generationPtr = generationPtr;
        newBiomapping.prevPtr = prevPtr;

        biomappingsHeads[account] = block.number;

        if (prevPtr == 0) {
            biomappingsTails[account] = block.number;
        } else {
            biomappingsLists[account][prevPtr].nextPtr = block.number;
        }

        generationBiomappings[account][generationPtr] = block.number;
    }
}
