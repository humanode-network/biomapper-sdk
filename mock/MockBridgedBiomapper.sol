// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IBridgedBiomapperRead} from "@biomapper-sdk/core/IBridgedBiomapperRead.sol";
import {IBridgeBiomappingEvents} from "@biomapper-sdk/events/IBridgeBiomappingEvents.sol";
import {IMockBridgedBiomapperControl} from "./IMockBridgedBiomapperControl.sol";

contract MockBridgedBiomapper is
    IBridgedBiomapperRead,
    IBridgeBiomappingEvents,
    IMockBridgedBiomapperControl
{
    uint256 public generationsHead;
    uint256 public generationsTail;
    mapping(uint256 => Generation) public generationsList;

    uint256 public generationsBridgingTxPointsHead;
    uint256 public generationsBridgingTxPointsTail;
    mapping(uint256 => GenerationBridgingTxPoint)
        public generationBridgingTxPointsList;

    mapping(address => uint256) private _biomappingsHeads;
    mapping(address => uint256) private _biomappingsTails;
    mapping(address => mapping(uint256 => Biomapping)) private _biomappingsList;

    mapping(address => mapping(uint256 => uint256)) private _biomappingPtrs;

    mapping(address => uint256) private _biomappingBridgingTxPointsHeads;
    mapping(address => uint256) private _biomappingBridgingTxPointsTails;
    mapping(address => mapping(uint256 => BiomappingBridgingTxPoint))
        private _biomappingBridgingTxPointsList;

    mapping(address => mapping(uint256 => uint256))
        private _biomappingBridgedTxPointPtrs;

    uint8 public testCaseNumber;

    /// @inheritdoc IMockBridgedBiomapperControl
    function addTestData() external {
        // The first two default Hardhat accounts.
        // Mnemonic: "test test test test test test test test test test test junk"

        // Account 0.
        // Private key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
        address account0 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        // Account 1.
        // Private key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
        address account1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

        // Complete history of account 0 across multiple generations.
        BiomappingData memory biomappingDataGen1000Acc0 = BiomappingData({
            generationPtr: 1000,
            biomappingPtr: 1005
        });
        BiomappingData memory biomappingDataGen2000Acc0 = BiomappingData({
            generationPtr: 2000,
            biomappingPtr: 2006
        });
        BiomappingData memory biomappingDataGen3000Acc0 = BiomappingData({
            generationPtr: 3000,
            biomappingPtr: 0 // no biomapping in generation 3000
        });
        BiomappingData memory biomappingDataGen4000Acc0 = BiomappingData({
            generationPtr: 4000,
            biomappingPtr: 4008
        });
        BiomappingData memory biomappingDataGen5000Acc0 = BiomappingData({
            generationPtr: 5000,
            biomappingPtr: 5009
        });
        BiomappingData memory biomappingDataGen6000Acc0 = BiomappingData({
            generationPtr: 6000,
            biomappingPtr: 6010
        });

        // Complete history of account 1 across multiple generations.
        BiomappingData memory biomappingDataGen1000Acc1 = BiomappingData({
            generationPtr: 1000,
            biomappingPtr: 0
        });
        BiomappingData memory biomappingDataGen2000Acc1 = BiomappingData({
            generationPtr: 2000,
            biomappingPtr: 0
        });
        BiomappingData memory biomappingDataGen3000Acc1 = BiomappingData({
            generationPtr: 3000,
            biomappingPtr: 3101
        });
        BiomappingData memory biomappingDataGen4000Acc1 = BiomappingData({
            generationPtr: 4000,
            biomappingPtr: 0
        });
        BiomappingData memory biomappingDataGen5000Acc1 = BiomappingData({
            generationPtr: 5000,
            biomappingPtr: 5103
        });

        // Account 0 bridges its data during generation 2000.
        //
        // Events:
        // 1. A new generation 1000 is created in the bridged contract.
        // 2. New biomapping 1005 is added for account 0 in generation 1000.
        // 3. New generation 2000 is created.
        // 4. New biomapping 2006 is added in generation 2000.
        //
        // The last bridged generation is 2000.
        // Account 0 is considered biomapped as it has a biomapping in the most recent bridged generation.
        if (testCaseNumber == 0) {
            BiomappingData[] memory biomappingsData = new BiomappingData[](2);
            biomappingsData[0] = biomappingDataGen1000Acc0;
            biomappingsData[1] = biomappingDataGen2000Acc0;

            updateBiomappings(biomappingsData, account0);
        }

        // Account 0 bridges its data during generation 5000, starting from the last bridged generation.
        // The data from the last bridged generation (2000) is present but does not create new entries.
        // No biomapping event occurs in generation 3000.
        //
        // Events:
        // 1. New generation 3000 is created.
        // 2. New generation 4000 is created.
        // 3. New biomapping 4008 is added in generation 4000.
        // 4. New generation 5000 is created.
        // 5. New biomapping 5009 is added in generation 5000.
        //
        // The last bridged generation is 5000.
        // Account 0 is still considered biomapped.
        if (testCaseNumber == 1) {
            BiomappingData[] memory biomappingsData = new BiomappingData[](4);
            biomappingsData[0] = biomappingDataGen2000Acc0;
            biomappingsData[1] = biomappingDataGen3000Acc0;
            biomappingsData[2] = biomappingDataGen4000Acc0;
            biomappingsData[3] = biomappingDataGen5000Acc0;

            updateBiomappings(biomappingsData, account0);
        }

        // Account 1 bridges its data during generation 5000.
        // No new generations are bridged at this stage.
        //
        // Events:
        // 1. New biomapping 3101 is added in generation 3000 for account 1.
        // 2. New biomapping 5103 is added in generation 5000.
        //
        // The last bridged generation is 5000.
        // Both accounts are now considered biomapped.
        if (testCaseNumber == 2) {
            BiomappingData[] memory biomappingsData = new BiomappingData[](5);
            biomappingsData[0] = biomappingDataGen1000Acc1;
            biomappingsData[1] = biomappingDataGen2000Acc1;
            biomappingsData[2] = biomappingDataGen3000Acc1;
            biomappingsData[3] = biomappingDataGen4000Acc1;
            biomappingsData[4] = biomappingDataGen5000Acc1;

            updateBiomappings(biomappingsData, account1);
        }

        // Account 0 bridges its data during generation 6000.
        //
        // Events:
        // 1. New generation 6000 is created.
        // 2. New biomapping 6010 is added in generation 6000.
        //
        // The last bridged generation is 6000.
        // Account 0 remains biomapped, but account 1 is no longer biomapped in the last bridged generation.
        if (testCaseNumber == 3) {
            BiomappingData[] memory biomappingsData = new BiomappingData[](2);
            biomappingsData[0] = biomappingDataGen5000Acc0;
            biomappingsData[1] = biomappingDataGen6000Acc0;

            updateBiomappings(biomappingsData, account0);
        }

        if (testCaseNumber <= 3) {
            testCaseNumber++;
        } else {
            revert("No more test cases");
        }
    }

    /// @inheritdoc IBridgedBiomapperRead
    function generationsListItem(
        uint256 ptr
    ) external view returns (Generation memory) {
        return generationsList[ptr];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function generationsBridgingTxPointsListItem(
        uint256 ptr
    ) external view returns (GenerationBridgingTxPoint memory) {
        return generationBridgingTxPointsList[ptr];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function biomappingsHead(address account) external view returns (uint256) {
        return _biomappingsHeads[account];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function biomappingsTail(address account) external view returns (uint256) {
        return _biomappingsTails[account];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function biomappingsListItem(
        address account,
        uint256 ptr
    ) external view returns (Biomapping memory) {
        return _biomappingsList[account][ptr];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function biomappingsBridgingTxPointsHead(
        address account
    ) external view returns (uint256) {
        return _biomappingBridgingTxPointsHeads[account];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function biomappingsBridgingTxPointsTail(
        address account
    ) external view returns (uint256) {
        return _biomappingBridgingTxPointsTails[account];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function biomappingsBridgingTxPointsListItem(
        address account,
        uint256 ptr
    ) external view returns (BiomappingBridgingTxPoint memory) {
        return _biomappingBridgingTxPointsList[account][ptr];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function lookupBiomappingPtr(
        address account,
        uint256 generationPtr
    ) external view override returns (uint256) {
        return _biomappingPtrs[account][generationPtr];
    }

    /// @inheritdoc IBridgedBiomapperRead
    function lookupBiomappingBridgedTxPointPtr(
        address account,
        uint256 generationPtr
    ) external view override returns (uint256) {
        return _biomappingBridgedTxPointPtrs[account][generationPtr];
    }

    /// @inheritdoc IMockBridgedBiomapperControl
    function updateBiomappings(
        BiomappingData[] memory biomappingsData,
        address account
    ) public {
        uint256 currentGeneration = biomappingsData[0].generationPtr;
        uint256 currentBiomapping;
        uint256 prevGenerationPtr;
        uint256 prevBiomappingPtr;

        bool isGenerationUpdateNeeded = false;

        for (uint256 i = 0; i < biomappingsData.length; i++) {
            prevGenerationPtr = generationsHead;

            currentGeneration = biomappingsData[i].generationPtr;
            currentBiomapping = biomappingsData[i].biomappingPtr;

            if (prevGenerationPtr < currentGeneration) {
                isGenerationUpdateNeeded = true;

                Generation storage newGeneration = generationsList[
                    currentGeneration
                ];
                newGeneration.prevPtr = prevGenerationPtr;

                if (prevGenerationPtr == 0) {
                    generationsTail = currentGeneration;
                } else {
                    generationsList[prevGenerationPtr]
                        .nextPtr = currentGeneration;
                }

                generationsHead = currentGeneration;

                emit NewBridgedGeneration(
                    currentGeneration,
                    80085,
                    0x4ce23b039a5c8a01c1aa5daba5066848085d2cc7da659547125f24cac056d453
                );
            }

            if (
                currentBiomapping != 0 &&
                _biomappingPtrs[account][currentGeneration] == 0
            ) {
                prevBiomappingPtr = _biomappingsHeads[account];

                _biomappingPtrs[account][currentGeneration] = currentBiomapping;

                Biomapping storage newBiomapping = _biomappingsList[account][
                    currentBiomapping
                ];

                newBiomapping.prevPtr = prevBiomappingPtr;

                if (prevBiomappingPtr == 0) {
                    _biomappingsTails[account] = currentBiomapping;
                } else {
                    _biomappingsList[account][prevBiomappingPtr]
                        .nextPtr = currentBiomapping;
                }

                _biomappingsHeads[account] = currentBiomapping;

                newBiomapping.generationPtr = currentGeneration;

                emit NewBridgedBiomapping(
                    account,
                    currentBiomapping,
                    currentGeneration,
                    80085,
                    0x4ce23b039a5c8a01c1aa5daba5066848085d2cc7da659547125f24cac056d453
                );
            }
        }

        if (isGenerationUpdateNeeded) {
            prevGenerationPtr = generationsBridgingTxPointsHead;

            GenerationBridgingTxPoint
                storage newGeneration = generationBridgingTxPointsList[
                    block.number
                ];
            newGeneration.prevPtr = prevGenerationPtr;

            newGeneration.generationPtr = currentGeneration;
            generationsList[currentGeneration]
                .generationBridgingTxPointPtr = block.number;

            if (prevGenerationPtr == 0) {
                generationsBridgingTxPointsTail = block.number;
            } else {
                generationBridgingTxPointsList[prevGenerationPtr]
                    .nextPtr = block.number;
            }

            generationsBridgingTxPointsHead = block.number;
        }

        uint256 _generationsBridgingTxPointsHead = generationsBridgingTxPointsHead;

        if (
            _biomappingBridgedTxPointPtrs[account][
                _generationsBridgingTxPointsHead
            ] == 0
        ) {
            prevBiomappingPtr = _biomappingBridgingTxPointsHeads[account];

            _biomappingBridgedTxPointPtrs[account][
                _generationsBridgingTxPointsHead
            ] = block.number;

            BiomappingBridgingTxPoint
                storage newBiomapping = _biomappingBridgingTxPointsList[
                    account
                ][block.number];
            newBiomapping.prevPtr = prevBiomappingPtr;

            newBiomapping.biomappingPtr = currentBiomapping;
            _biomappingsList[account][currentBiomapping]
                .biomappingBridgingTxPointPtr = block.number;

            if (prevBiomappingPtr == 0) {
                _biomappingBridgingTxPointsTails[account] = block.number;
            } else {
                _biomappingBridgingTxPointsList[account][prevBiomappingPtr]
                    .nextPtr = block.number;
            }

            _biomappingBridgingTxPointsHeads[account] = block.number;

            newBiomapping
                .generationBridgingTxPointPtr = _generationsBridgingTxPointsHead;
        }
    }
}
