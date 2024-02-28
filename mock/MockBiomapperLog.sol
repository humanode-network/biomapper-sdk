// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IBiomapperLogRead} from "@biomapper-sdk/core/IBiomapperLogRead.sol";

/// @notice Mock contract implementing IBiomapperLogRead interface for testing purposes.
contract MockBiomapperLog is IBiomapperLogRead {
    uint256 public generationsHead;
    uint256 public generationsTail;
    mapping(uint256 => Generation) public generationsList;

    mapping(address => uint256) public biomappingsHeads;
    mapping(address => uint256) public biomappingsTails;
    mapping(address => mapping(uint256 => Biomapping)) public biomappingsLists;

    mapping(address => mapping(uint256 => uint256))
        public generationBiomappings;

    /// @inheritdoc IBiomapperLogRead
    function biomappingsHead(
        address account
    ) external view override returns (uint256) {
        return biomappingsHeads[account];
    }

    /// @inheritdoc IBiomapperLogRead
    function biomappingsTail(
        address account
    ) external view override returns (uint256) {
        return biomappingsTails[account];
    }

    /// @inheritdoc IBiomapperLogRead
    function biomappingsListItem(
        address account,
        uint256 ptr
    ) external view override returns (Biomapping memory) {
        return biomappingsLists[account][ptr];
    }

    /// @inheritdoc IBiomapperLogRead
    function generationsListItem(
        uint256 ptr
    ) external view override returns (Generation memory) {
        return generationsList[ptr];
    }

    /// @inheritdoc IBiomapperLogRead
    function generationBiomapping(
        address account,
        uint256 generationPtr
    ) external view override returns (uint256) {
        return generationBiomappings[account][generationPtr];
    }

    /// @notice Initializes a new generation.
    function initGeneration() external {
        uint256 prevPtr = generationsHead;
        require(
            prevPtr != block.number,
            "initializing a generation twice in a single block is disallowed"
        );

        Generation storage newGeneration = generationsList[block.number];

        newGeneration.prevPtr = prevPtr;

        generationsHead = block.number;

        if (prevPtr == 0) {
            generationsTail = block.number;
        } else {
            generationsList[prevPtr].nextPtr = block.number;
        }
    }

    /// @notice Creates a new biomapping for the specified account.
    /// @param account The address of the account to biomap.
    function biomap(address account) external {
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
