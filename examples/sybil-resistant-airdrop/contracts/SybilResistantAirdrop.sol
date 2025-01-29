// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IBiomapperRead} from "@biomapper-sdk/core/IBiomapperRead.sol";
import {BiomapperLogLib} from "@biomapper-sdk/libraries/BiomapperLogLib.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Simple Sybil-Resistant Airdrop
 * @dev A contract for conducting a Sybil-resistant airdrop of tokens.
 */
contract SybilResistantAirdrop {
    using SafeERC20 for IERC20;
    using BiomapperLogLib for IBiomapperRead;

    IERC20 public immutable ERC20_TOKEN; // The ERC20 token being airdropped
    address public immutable TOKEN_VAULT; // The address holding the tokens for the airdrop
    uint256 public immutable AMOUNT_PER_USER; // The amount of tokens each user can claim
    IBiomapperRead public immutable BIOMAPPER_LOG; // The contract for checking uniqueness of users

    mapping(address => bool) public isAlreadyClaimed; // Mapping to track claimed users

    /**
     * @dev Constructor to initialize the contract with required parameters.
     * @param tokenAddress The address of the ERC20 token being airdropped.
     * @param tokenVault The address holding the tokens for the airdrop.
     * @param amountPerUser The amount of tokens each user can claim.
     * @param biomapperLogAddress The address of the contract for checking uniqueness of users.
     */
    constructor(
        address tokenAddress,
        address tokenVault,
        uint256 amountPerUser,
        address biomapperLogAddress
    ) {
        ERC20_TOKEN = IERC20(tokenAddress);
        TOKEN_VAULT = tokenVault;
        AMOUNT_PER_USER = amountPerUser;
        BIOMAPPER_LOG = IBiomapperRead(biomapperLogAddress);
    }

    /**
     * @dev Emitted when a user successfully claims their tokens.
     * @param who The address of the user who claimed tokens.
     */
    event Claimed(address who);

    /**
     * @dev Allows a user to claim their tokens if they haven't already claimed and are unique.
     */
    function claim() public {
        require(!isAlreadyClaimed[msg.sender], "User has already claimed");
        require(BIOMAPPER_LOG.isUnique(msg.sender), "User is not unique");

        ERC20_TOKEN.safeTransferFrom(TOKEN_VAULT, msg.sender, AMOUNT_PER_USER);

        isAlreadyClaimed[msg.sender] = true;

        emit Claimed(msg.sender);
    }
}
