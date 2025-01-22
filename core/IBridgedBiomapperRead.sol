// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// The interface.
//
// A bridging tx is a transaction included in a block at the BridgingTxPoint chain that imports data from Humanode chain.
//
// Bridging tx point corresponds to a number of the block at the BridgingTxPoint chain in which a bridging tx is included.
//
// A bridging tx contains a set of generations and _potentially_ biomappings at Humanode chain.
// The generations set can contain up to one generation that is "_being bridged_" and zero or more historical generations.
//
// A historical generation is a generation that is included in the bridging tx while not being the latest generation at Humanode chain.
//
// A historical generation does not create corresponding `GenerationBridgingTxPoint` or `BiomappingBridgingTxPoint`,
// however it does create the `Generation` and (if needed) `Biomapping`.
interface IBridgedBiomapperRead {
    // Describes a generation on Humanode chain.
    // Stored in a map where key is a block number at Humanode chain.
    // Allows navigating through generations via `prevPtr` and `nextPtr`.
    // Allows locating `GenerationBridgingTxPoint` via `generationBridgingTxPointPtr`.
    //
    // A new key is populated by the bridging tx for the generation _being bridged_ and
    // for each historical generations that occurred prior to the generation _being bridged_
    // if the corresponding `Generation` is not present at the BridgingTxPoint chain.
    // For historical generations `generationBridgingTxPointPtr` will be zero.
    struct Generation {
        // The block number at the BridgingTxPoint chain when this generation was ported
        // from Humanode chain to this chain.
        // Zero if this generation was bridged as a non-target generation (historical) in the bridging tx.
        uint256 generationBridgingTxPointPtr;
        // The block number at Humanode chain that points to the previous generation.
        // Zero if this generation is the oldest generation at Humanode chain.
        uint256 prevPtr;
        // The block number at Humanode chain that points to the next generation.
        // Zero if this generation is the newest _known_ (bridged) generation at Humanode chain.
        uint256 nextPtr;
    }

    // Describes a point in time (block number at the BridgingTxPoint chain) when a generation was bridged from Humanode chain.
    // Stored in a map where key is a block number at the BridgingTxPoint chain.
    // Allows navigating through generation bridging tx points via `prevPtr` and `nextPtr`.
    // Allows locating `Generation` via `generationPtr`.
    //
    // A new key is populated by the bridging tx when it is determined that the
    // `Generation` _being bridged_ (i.e. non-historical) is not present at the BridgingTxPoint chain.
    struct GenerationBridgingTxPoint {
        // The block number at Humanode chain corresponding to when the generation was initialized.
        // Never zero.
        uint256 generationPtr;
        // The block number at the BridgingTxPoint chain that points to the previous generation bridging tx point.
        // Zero if this generation bridging tx point is the oldest point at the BridgingTxPoint chain.
        uint256 prevPtr;
        // The block number at the BridgingTxPoint chain that points to the next generation bridging tx point.
        // Zero if this generation bridging tx point is the newest point at the BridgingTxPoint chain.
        uint256 nextPtr;
    }

    // Describes a biomapping on Humanode chain.
    // Stored in a double map where the keys are an account and a block number at Humanode chain.
    // Allows navigating through biomappings within a given account via `prevPtr` and `nextPtr`.
    // Allows locating `Generation` via `generationPtr`.
    // Allows locating `BiomappingBridgingTxPoint` via `biomappingBridgingTxPointPtr`.
    //
    // A new key is populated by the bridging tx for the generation _being bridged_ and
    // for each historical generations that occurred prior to the generation _being bridged_
    // if the bridging tx indicates that the account in the bridging tx has the biomapping in a given generation
    // and the corresponding `Biomapping` is not present at the BridgingTxPoint chain.
    struct Biomapping {
        // The block number at Humanode chain that corresponds to generation in which biomapping has occurred.
        // Never zero.
        uint256 generationPtr;
        // The block number at the BridgingTxPoint chain when biomapping was ported
        // from Humanode chain to this chain.
        // Zero if this biomapping corresponds to a generation than was bridged as a non-target generation (historical) in the bridging tx.
        uint256 biomappingBridgingTxPointPtr;
        // The block number at Humanode chain that points to the previous biomapping for the corresponding account.
        // Zero if this biomapping is the oldest biomapping for the corresponding account at Humanode chain.
        uint256 prevPtr;
        // The block number at Humanode chain that points to the next biomapping for the corresponding account.
        // Zero if this biomapping is the newest _known_ (bridged) biomapping for the corresponding account at Humanode chain.
        uint256 nextPtr;
    }

    // Describes a point in time (block number at the BridgingTxPoint chain) when a biomapping was bridged from Humanode chain.
    // Stored in a double map where the keys are an account and a block number at the BridgingTxPoint chain.
    // Allows navigating through biomapping bridging tx points within a given account via `prevPtr` and `nextPtr`.
    // Allows locating `GenerationBridgingTxPoint` via `generationBridgingTxPointPtr`.
    // Allows locating `Biomapping` via `biomappingPtr`.
    //
    // A new key is populated by the bridging tx when a `Biomapping` is present for a given account in a non-historical generation.
    struct BiomappingBridgingTxPoint {
        // The block number at the BridgingTxPoint chain that corresponds to generation bridging tx point when this biomapping was bridged.
        // Never zero.
        uint256 generationBridgingTxPointPtr;
        // The block number at Humanode chain corresponding to when the biomap happened.
        // Never zero.
        uint256 biomappingPtr;
        // The block number at the BridgingTxPoint chain that points to the previous biomapping bridging tx point.
        // Zero if this biomapping bridging tx point is the oldest point at the BridgingTxPoint chain.
        uint256 prevPtr;
        // The block number at the BridgingTxPoint chain that points to the next biomapping bridging tx point.
        // Zero if this biomapping bridging tx point is the newest point at the BridgingTxPoint chain.
        uint256 nextPtr;
    }

    // `Generation` accessors.

    // The newest `Generation` ptr.
    function generationsHead() external view returns (uint256);

    // The oldest `Generation` ptr.
    function generationsTail() external view returns (uint256);

    // Get `Generation` by ptr.
    function generationsListItem(
        uint256 ptr
    ) external view returns (Generation memory);

    // `GenerationBridgingTxPoint` accessors.

    // The newest `GenerationBridgingTxPoint` ptr.
    function generationsBridgingTxPointsHead() external view returns (uint256);

    // The oldest `GenerationBridgingTxPoint` ptr.
    function generationsBridgingTxPointsTail() external view returns (uint256);

    // Get `GenerationBridgingTxPoint` by ptr.
    function generationsBridgingTxPointsListItem(
        uint256 ptr
    ) external view returns (GenerationBridgingTxPoint memory);

    // `Biomapping` accessors.

    // The newest `Biomapping` ptr for a given account.
    function biomappingsHead(address account) external view returns (uint256);

    // The oldest `Biomapping` ptr for a given account.
    function biomappingsTail(address account) external view returns (uint256);

    // Get `Biomapping` by ptr for a given account.
    function biomappingsListItem(
        address account,
        uint256 ptr
    ) external view returns (Biomapping memory);

    // `BiomappingsBridgingTxPoint` accessors.

    // The newest `BiomappingsBridgingTxPoint` ptr for a given account.
    function biomappingsBridgingTxPointsHead(
        address account
    ) external view returns (uint256);

    // The oldest `BiomappingsBridgingTxPoint` ptr for a given account.
    function biomappingsBridgingTxPointsTail(
        address account
    ) external view returns (uint256);

    // Get `BiomappingsBridgingTxPoint` by ptr for a given account.
    function biomappingsBridgingTxPointsListItem(
        address account,
        uint256 ptr
    ) external view returns (BiomappingBridgingTxPoint memory);

    // Secondary indices.

    // Get `Biomapping` ptr for a given account in a requested generation.
    // Returns non-zero if the account is known to be biomapped in a given generation.
    // Note: can return zero if biomapped at Humanode chain but the information about it is not bridged yet.
    function lookupBiomappingPtr(
        address account,
        uint256 generationPtr
    ) external view returns (uint256);

    // Get `BiomappingsBridgingTxPoint` ptr for a given account in a requested generation bridged tx point.
    // Returns non-zero if the account biomapping was bridged in a given generation.
    // Note: there is a possibility that the biomapping was bridged as part of a bridge tx where the generation it belonged to is a historical generation, in which case the `Biomapping` will exist, but the `BiomappingBridgedTxPoint` will be absent.
    function lookupBiomappingBridgedTxPointPtr(
        address account,
        uint256 generationBridgedTxPointPtr
    ) external view returns (uint256);
}
