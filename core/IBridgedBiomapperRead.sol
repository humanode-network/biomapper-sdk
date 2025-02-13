// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Interface for the `BridgedBiomapper` contract.
/// @notice View bridged historical biomapping state for a given account,
/// and overall generation changes.
///
/// A bridging tx is a transaction included in a block at the bridged chain that imports data from Humanode chain.
///
/// Bridging tx point corresponds to a number of the block at the bridged chain in which a bridging tx is included.
///
/// A bridging tx contains a set of generations and _potentially_ biomappings at Humanode chain.
/// The generations set can contain up to one generation that is "_being bridged_" and zero or more historical generations.
///
/// A historical generation is a generation that is included in the bridging tx while not being the latest generation at Humanode chain.
///
/// A historical generation does not create corresponding `GenerationBridgingTxPoint` or `BiomappingBridgingTxPoint`,
/// however it does create the `Generation` and (if needed) `Biomapping`.
interface IBridgedBiomapperRead {
    /// @notice Describes a generation on Humanode chain.
    /// @dev Stored in a map where key is a block number at Humanode chain.
    /// Allows navigating through generations via `prevPtr` and `nextPtr`.
    /// Allows locating `GenerationBridgingTxPoint` via `generationBridgingTxPointPtr`.
    ///
    /// A new key is populated by the bridging tx for the generation _being bridged_ and
    /// for each historical generations that occurred prior to the generation _being bridged_
    /// if the corresponding `Generation` is not present at the bridged chain.
    /// For historical generations `generationBridgingTxPointPtr` will be zero.
    ///
    /// #### Fields
    /// | Name | Type | Description |
    /// | ---- | ---- | ----------- |
    /// | generationBridgingTxPointPtr | uint256 | The block number at the bridged chain when this generation was ported from Humanode chain to this chain. Zero if this generation was bridged as a non-target generation (historical) in the bridging tx. |
    /// | prevPtr | uint256 | The block number at Humanode chain that points to the previous generation. Zero if this generation is the oldest generation at Humanode chain. |
    /// | nextPtr | uint256 | The block number at Humanode chain that points to the next generation. Zero if this generation is the newest _known_ (bridged) generation at Humanode chain. |
    struct Generation {
        /// The block number at the bridged chain when this generation was ported from Humanode chain to this chain.
        /// Zero if this generation was bridged as a non-target generation (historical) in the bridging tx.
        uint256 generationBridgingTxPointPtr;
        /// The block number at Humanode chain that points to the previous generation.
        /// Zero if this generation is the oldest generation at Humanode chain.
        uint256 prevPtr;
        /// The block number at Humanode chain that points to the next generation.
        /// Zero if this generation is the newest _known_ (bridged) generation at Humanode chain.
        uint256 nextPtr;
    }

    /// @notice Describes a point in time (block number at the bridged chain) when a generation was bridged from Humanode chain.
    /// @dev Stored in a map where key is a block number at the bridged chain.
    /// Allows navigating through generation bridging tx points via `prevPtr` and `nextPtr`.
    /// Allows locating `Generation` via `generationPtr`.
    ///
    /// A new key is populated by the bridging tx when it is determined that the
    /// `Generation` _being bridged_ (i.e. non-historical) is not present at the bridged chain.
    ///
    /// #### Fields
    /// | Name | Type | Description |
    /// | ---- | ---- | ----------- |
    /// | generationPtr | uint256 | The block number at Humanode chain corresponding to when the generation was initialized. Never zero. |
    /// | prevPtr | uint256 | The block number at the bridged chain that points to the previous generation bridging tx point. Zero if this generation bridging tx point is the oldest point at the bridged chain. |
    /// | nextPtr | uint256 | The block number at the bridged chain that points to the next generation bridging tx point. Zero if this generation bridging tx point is the newest point at the bridged chain. |
    struct GenerationBridgingTxPoint {
        /// The block number at Humanode chain corresponding to when the generation was initialized. Never zero.
        uint256 generationPtr;
        /// The block number at the bridged chain that points to the previous generation bridging tx point.
        /// Zero if this generation bridging tx point is the oldest point at the bridged chain.
        uint256 prevPtr;
        /// The block number at the bridged chain that points to the next generation bridging tx point.
        /// Zero if this generation bridging tx point is the newest point at the bridged chain.
        uint256 nextPtr;
    }

    /// @notice Describes a biomapping on Humanode chain.
    /// @dev Stored in a double map where the keys are an account and a block number at Humanode chain.
    /// Allows navigating through biomappings within a given account via `prevPtr` and `nextPtr`.
    /// Allows locating `Generation` via `generationPtr`.
    /// Allows locating `BiomappingBridgingTxPoint` via `biomappingBridgingTxPointPtr`.
    ///
    /// A new key is populated by the bridging tx for the generation _being bridged_ and
    /// for each historical generations that occurred prior to the generation _being bridged_
    /// if the bridging tx indicates that the account in the bridging tx has the biomapping in a given generation
    /// and the corresponding `Biomapping` is not present at the bridged chain.
    ///
    /// #### Fields
    /// | Name | Type | Description |
    /// | ---- | ---- | ----------- |
    /// | generationPtr | uint256 | The block number at Humanode chain that corresponds to generation in which biomapping has occurred. Never zero. |
    /// | biomappingBridgingTxPointPtr | uint256 | The block number at the bridged chain when biomapping was ported from Humanode chain to this chain. Zero if this biomapping corresponds to a generation than was bridged as a non-target generation (historical) in the bridging tx. |
    /// | prevPtr | uint256 | The block number at Humanode chain that points to the previous biomapping for the corresponding account. Zero if this biomapping is the oldest biomapping for the corresponding account at Humanode chain. |
    /// | nextPtr | uint256 | The block number at Humanode chain that points to the next biomapping for the corresponding account. Zero if this biomapping is the newest _known_ (bridged) biomapping for the corresponding account at Humanode chain. |
    struct Biomapping {
        /// The block number at Humanode chain that corresponds to generation in which biomapping has occurred. Never zero.
        uint256 generationPtr;
        /// The block number at the bridged chain when biomapping was ported from Humanode chain to this chain.
        /// Zero if this biomapping corresponds to a generation than was bridged as a non-target generation (historical) in the bridging tx.
        uint256 biomappingBridgingTxPointPtr;
        /// The block number at Humanode chain that points to the previous biomapping for the corresponding account.
        /// Zero if this biomapping is the oldest biomapping for the corresponding account at Humanode chain.
        uint256 prevPtr;
        /// The block number at Humanode chain that points to the next biomapping for the corresponding account.
        /// Zero if this biomapping is the newest _known_ (bridged) biomapping for the corresponding account at Humanode chain.
        uint256 nextPtr;
    }

    /// @notice Describes a point in time (block number at the bridged chain) when a biomapping was bridged from Humanode chain.
    /// @dev Stored in a double map where the keys are an account and a block number at the bridged chain.
    /// Allows navigating through biomapping bridging tx points within a given account via `prevPtr` and `nextPtr`.
    /// Allows locating `GenerationBridgingTxPoint` via `generationBridgingTxPointPtr`.
    /// Allows locating `Biomapping` via `biomappingPtr`.
    ///
    /// A new key is populated by the bridging tx when a `Biomapping` is present for a given account in a non-historical generation.
    ///
    /// #### Fields
    /// | Name | Type | Description |
    /// | ---- | ---- | ----------- |
    /// | generationBridgingTxPointPtr | uint256 | The block number at the bridged chain that corresponds to generation bridging tx point when this biomapping was bridged. Never zero. |
    /// | biomappingPtr | uint256 | The block number at Humanode chain corresponding to when the biomap happened. Never zero. |
    /// | prevPtr | uint256 | The block number at the bridged chain that points to the previous biomapping bridging tx point. Zero if this biomapping bridging tx point is the oldest point at the bridged chain. |
    /// | nextPtr | uint256 | The block number at the bridged chain that points to the next biomapping bridging tx point. Zero if this biomapping bridging tx point is the newest point at the bridged chain. |
    struct BiomappingBridgingTxPoint {
        /// The block number at the bridged chain that corresponds to generation bridging tx point when this biomapping was bridged.
        /// Never zero.
        uint256 generationBridgingTxPointPtr;
        /// The block number at Humanode chain corresponding to when the biomap happened. Never zero.
        uint256 biomappingPtr;
        /// The block number at the bridged chain that points to the previous biomapping bridging tx point.
        /// Zero if this biomapping bridging tx point is the oldest point at the bridged chain.
        uint256 prevPtr;
        /// The block number at the bridged chain that points to the next biomapping bridging tx point.
        /// Zero if this biomapping bridging tx point is the newest point at the bridged chain.
        uint256 nextPtr;
    }

    // `Generation` accessors.

    /// @notice Returns the block number at Humanode chain in which the current generation began.
    /// @return The block number in which the current generation began, 0 if no generations initialized.
    function generationsHead() external view returns (uint256);

    /// @notice Returns the block number at Humanode chain in which the oldest generation began.
    /// @return The block number in which the oldest generation began, 0 if no generations initialized.
    function generationsTail() external view returns (uint256);

    /// @notice Returns the generation struct for a given generation pointer.
    /// @param ptr The pointer of the requested generation.
    /// @return The {Generation} structure.
    function generationsListItem(
        uint256 ptr
    ) external view returns (Generation memory);

    // `GenerationBridgingTxPoint` accessors.

    /// @notice Returns the block number at bridged chain in which the current generation was bridged.
    /// @return The block number in which the current generation bridged, 0 if no generations bridged.
    function generationsBridgingTxPointsHead() external view returns (uint256);

    /// @notice Returns the block number at bridged chain in which the oldest generation was bridged.
    /// @return The block number in which the oldest generation bridged, 0 if no generations bridged.
    function generationsBridgingTxPointsTail() external view returns (uint256);

    /// @notice Returns the generation bridging tx point struct for a given pointer.
    /// @param ptr The pointer of the requested bridging tx point.
    /// @return The {GenerationBridgingTxPoint} structure.
    function generationsBridgingTxPointsListItem(
        uint256 ptr
    ) external view returns (GenerationBridgingTxPoint memory);

    // `Biomapping` accessors.

    /// @notice Returns the most recent biomapping pointer for a given account address.
    /// @param account The address of the requested account.
    /// @return The block number in which the most recent biomap occurred, or 0 if the account was never bridged.
    function biomappingsHead(address account) external view returns (uint256);

    /// @notice Returns the oldest biomapping pointer for a given account address.
    /// @param account The address of the requested account.
    /// @return The block number in which the oldest biomap occurred, or 0 if the account was never bridged.
    function biomappingsTail(address account) external view returns (uint256);

    /// @notice Returns the {Biomapping} struct for a given biomapping pointer and account address.
    /// @param account The address of the requested account.
    /// @param ptr The biomapping pointer of the requested biomapping.
    /// @return The {Biomapping} structure.
    function biomappingsListItem(
        address account,
        uint256 ptr
    ) external view returns (Biomapping memory);

    // `BiomappingBridgingTxPoint` accessors.

    /// @notice Returns the most recent biomapping bridging tx point for a given account address.
    /// @param account The address of the requested account.
    /// @return The block number in which the most recent biomap was bridged, or 0 if the account was never bridged.
    function biomappingsBridgingTxPointsHead(
        address account
    ) external view returns (uint256);

    /// @notice Returns the oldest biomapping bridging tx point for a given account address.
    /// @param account The address of the requested account.
    /// @return The block number in which the oldest biomap was bridged, or 0 if the account was never bridged.
    function biomappingsBridgingTxPointsTail(
        address account
    ) external view returns (uint256);

    /// @notice Returns the {BiomappingBridgingTxPoint} struct for a given pointer and account address.
    /// @param account The address of the requested account.
    /// @param ptr The pointer of the requested bridging tx point.
    /// @return The {BiomappingBridgingTxPoint} structure.
    function biomappingsBridgingTxPointsListItem(
        address account,
        uint256 ptr
    ) external view returns (BiomappingBridgingTxPoint memory);

    // Secondary indices.

    /// @notice Returns the biomapping pointer for a given account address and generation pointer.
    /// @dev Returns non-zero if the account is known to be biomapped in a given generation.
    /// @param account The address of the requested account.
    /// @param generationPtr The pointer of the requested generation.
    /// @return The block number in which the requested user was biomapped in the requested generation, or 0 if there was no biomapping.
    /// Note: can return zero if biomapped at Humanode chain but the information about it is not bridged yet.
    function lookupBiomappingPtr(
        address account,
        uint256 generationPtr
    ) external view returns (uint256);

    /// @notice Returns the {BiomappingBridgingTxPoint} ptr for a given account address and generation bridged tx point.
    /// @dev Returns non-zero if the account biomapping was bridged in a given generation.
    /// @param account The address of the requested account.
    /// @param generationBridgedTxPointPtr The pointer of the requested generation.
    /// @return The block number in which the requested user was biomapped in the requested generation, or 0 if there was no biomapping.
    /// Note: there is a possibility that the biomapping was bridged as part of a bridge tx where the generation it belonged to is a historical generation, in which case the {Biomapping} will exist, but the [BiomappingBridgedTxPoint](./interface.IBridgedBiomapperRead.html#biomappingbridgingtxpoint) will be absent.
    function lookupBiomappingBridgedTxPointPtr(
        address account,
        uint256 generationBridgedTxPointPtr
    ) external view returns (uint256);
}
