// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IMockBridgedBiomapperControl} from "./IMockBridgedBiomapperControl.sol";
import {IBridgedBiomapperRead} from "@biomapper-sdk/core/IBridgedBiomapperRead.sol";

/// @notice Mock contract implementing `BridgedBiomapper` contract interfaces.
contract MockBridgedBiomapper is
    IBridgedBiomapperRead,
    IMockBridgedBiomapperControl
{
    uint256 public generationsHead;
    uint256 public generationsTail;
    mapping(uint256 => Generation) public generationsList;

    mapping(address => uint256) public biomappingsHeads;
    mapping(address => uint256) public biomappingsTails;
    mapping(address => mapping(uint256 => Biomapping)) public biomappingsLists;

    mapping(address => mapping(uint256 => uint256))
        public generationBiomappings;

    /// @inheritdoc IBridgedBiomapperRead
    function biomappingsHead(
        address account
    ) external view override returns (uint256) {
        return biomappingsHeads[account];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function biomappingsTail(
        address account
    ) external view override returns (uint256) {
        return biomappingsTails[account];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function biomappingsListItem(
        address account,
        uint256 ptr
    ) external view override returns (Biomapping memory) {
        return biomappingsLists[account][ptr];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function generationsListItem(
        uint256 ptr
    ) external view override returns (Generation memory) {
        return generationsList[ptr];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function lookupBiomappingPtr(
        address account,
        uint256 generationPtr
    ) external view override returns (uint256) {
        return generationBiomappings[account][generationPtr];
    }

    /// @inheritdoc IMockBridgedBiomapperControl
    function bridge() external {
        revert("TODO");
    }
}
