// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ICheckUniqueness} from "@biomapper-sdk/core/interfaces/ICheckUniqueness.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SimpleSybilResistantAirdrop {
    using SafeERC20 for IERC20;

    IERC20 public immutable ERC20_TOKEN;
    address public immutable TOKEN_VAULT;
    uint256 public immutable AMOUNT_PER_USER;
    ICheckUniqueness public immutable BIOMAPPER;

    mapping(address => bool) public isAlreadyClaimed;

    constructor(
        address tokenAddress,
        address tokenVault,
        uint256 amountPerUser,
        address biomapperAddress
    ) {
        ERC20_TOKEN = IERC20(tokenAddress);
        TOKEN_VAULT = tokenVault;
        AMOUNT_PER_USER = amountPerUser;
        BIOMAPPER = ICheckUniqueness(biomapperAddress);
    }

    event Claimed(address who);

    function claim() public {
        require(!isAlreadyClaimed[msg.sender], "User has already claimed");
        require(BIOMAPPER.isUnique(msg.sender), "User is not unique");

        ERC20_TOKEN.safeTransferFrom(TOKEN_VAULT, msg.sender, AMOUNT_PER_USER);

        emit Claimed(msg.sender);
    }
}
