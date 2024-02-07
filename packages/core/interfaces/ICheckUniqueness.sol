// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface ICheckUniqueness {
    // Check whether the specified address is unique.
    function isUnique(address queriedAddress) external view returns (bool);
}
