// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Interface for the `MockBridgedBiomapper` contract.
/// @notice Mock controls for the `MockBridgedBiomapper`.
interface IMockBridgedBiomapperControl {
    /// @notice The info about one biomapping event.
    ///
    /// #### Fields
    /// | Name | Type | Description |
    /// | ---- | ---- | ----------- |
    /// | generationPtr | uint256 | The generation, Humanode chain block number. |
    /// | biomappingPtr | uint256 | The biomapping, Humanode chain block number. |
    struct BiomappingData {
        /// The generation, Humanode chain block number.
        uint256 generationPtr;
        /// The biomapping, Humanode chain block number.
        uint256 biomappingPtr;
    }

    /// @notice Bridge the generations and biomappings.
    /// @param biomappingsData The info about biomapping events.
    /// @param account The address of the requested account.
    function updateBiomappings(
        BiomappingData[] memory biomappingsData,
        address account
    ) external;

    /// @notice A quick and easy way to add test data to the mock contract, as well as an example of how to add new data.
    ///
    /// @notice The test data represents the history of 2 accounts across 6 generations.
    ///
    /// @dev This function can be executed up to 4 times in different blocks to add test data.
    function addTestData() external;
}
