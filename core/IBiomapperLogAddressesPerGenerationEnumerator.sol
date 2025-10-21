// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBiomapperLogAddressesPerGenerationEnumerator {
    /**
     * @dev Retrieves all biomapped accounts within a specified generation.
     * @param generationPtr The block number marking the start of the generation to get the list of biomapped accounts.
     * @param cursor The starting index of the page. For the first request, set `cursor` to address(0).
     * @param maxPageSize The maximum number of elements to return in this call (also soft-capped in the contract).
     * @return nextCursor The starting index for the next page of results.
     * @return biomappedAccounts An array of addresses that were biomapped within a specified generation.
     *
     * Notes:
     * - For the first request, set `cursor` to address(0) to start from the beginning of the dataset.
     * - If `nextCursor` is address(0), all available elements have been retrieved, indicating the end of the dataset.
     * - There is a soft cap on the max page size that is implementation-dependent.
     */
    function listAddressesPerGeneration(
        uint256 generationPtr,
        address cursor,
        uint256 maxPageSize
    )
        external
        view
        returns (address nextCursor, address[] memory biomappedAccounts);
}
