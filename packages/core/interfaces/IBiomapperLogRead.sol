// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IBiomapperLogRead {
    struct Generation {
        bytes32 generation;
        uint256 prevPtr;
        uint256 nextPtr;
    }

    struct Biomapping {
        uint256 generationPtr;
        uint256 prevPtr;
        uint256 nextPtr;
    }

    function biomappingsHead(address account) external view returns (uint256);

    function biomappingsTail(address account) external view returns (uint256);

    function biomappingsListItem(
        address account,
        uint256 ptr
    ) external view returns (Biomapping memory);

    function generationBiomapping(
        address account,
        uint256 generationPtr
    ) external view returns (uint256);

    function generationsHead() external view returns (uint256);

    function generationsTail() external view returns (uint256);

    function generationsListItem(
        uint256 ptr
    ) external view returns (Generation memory);
}
