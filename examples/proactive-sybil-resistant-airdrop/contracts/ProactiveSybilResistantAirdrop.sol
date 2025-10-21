// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IBiomapperLogRead} from "@biomapper-sdk/core/IBiomapperLogRead.sol";
import {IBiomapperLogAddressesPerGenerationEnumerator} from "@biomapper-sdk/core/IBiomapperLogAddressesPerGenerationEnumerator.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Proactive Sybil-Resistant Airdrop
 * @dev A contract for conducting a Sybil-resistant airdrop by sending tokens to all biomapped users.
 */
contract ProactiveSybilResistantAirdrop {
    using SafeERC20 for IERC20;

    IERC20 public immutable ERC20_TOKEN; // The ERC20 token being airdropped
    address public immutable TOKEN_VAULT; // The address holding the tokens for the airdrop
    uint256 public immutable AMOUNT_PER_USER; // The amount of tokens to send to each user
    IBiomapperLogAddressesPerGenerationEnumerator
        public immutable BIOMAPPER_LOG; // The contract for retrieving unique users list
    uint256 public immutable MAX_USERS_PER_AIRDROP_TICK; // Maximum amount of users to get tokens for each function call
    uint256 public immutable GENERATION_PTR; // Current generation pointer at the moment of contract deployment

    address public nextAccountToGetAirdrop; // The cursor for enumertor
    bool public airdropCompleted; // The completion flag

    /**
     * @dev Constructor to initialize the contract with required parameters.
     * @param tokenAddress The address of the ERC20 token being airdropped.
     * @param tokenVault The address holding the tokens for the airdrop.
     * @param amountPerUser The amount of tokens to send to each user.
     * @param biomapperLogAddress The address of the contract for retrieving unique users list.
     * @param maxUsersPerAirdropTick The address of the contract for checking uniqueness of users.
     */
    constructor(
        address tokenAddress,
        address tokenVault,
        uint256 amountPerUser,
        address biomapperLogAddress,
        uint256 maxUsersPerAirdropTick
    ) {
        ERC20_TOKEN = IERC20(tokenAddress);
        TOKEN_VAULT = tokenVault;
        AMOUNT_PER_USER = amountPerUser;
        BIOMAPPER_LOG = IBiomapperLogAddressesPerGenerationEnumerator(
            biomapperLogAddress
        );
        MAX_USERS_PER_AIRDROP_TICK = maxUsersPerAirdropTick;
        GENERATION_PTR = IBiomapperLogRead(biomapperLogAddress)
            .generationsHead();
    }

    event AirdropIsCompleted();

    /**
     * @dev Send tokens to biomapped users in the set generation, no more than `MAX_USERS_PER_AIRDROP_TICK` users per call.
     * @return needsMoreTicks The list of biomapped accounts is not exhausted, the airdrop is not completed.
     */
    function airdropTick() public returns (bool needsMoreTicks) {
        require(!airdropCompleted, "Airdrop is completed");

        (address nextCursor, address[] memory biomappedAccounts) = BIOMAPPER_LOG
            .listAddressesPerGeneration(
                GENERATION_PTR,
                nextAccountToGetAirdrop,
                MAX_USERS_PER_AIRDROP_TICK
            );

        for (uint index = 0; index < biomappedAccounts.length; index++) {
            ERC20_TOKEN.safeTransferFrom(
                TOKEN_VAULT,
                biomappedAccounts[index],
                AMOUNT_PER_USER
            );
        }

        nextAccountToGetAirdrop = nextCursor;

        if (nextCursor == address(0)) {
            airdropCompleted = true;
            emit AirdropIsCompleted();
            return false;
        }

        return true;
    }

    /**
     * @dev Send tokens to all biomapped users in the set generation.
     * This function may fail due to excessive gas usage, call `airdropTick` in multiple transactions instead.
     */
    function airdrop() external {
        require(!airdropCompleted, "Airdrop is completed");

        while (airdropTick()) {}
    }
}
