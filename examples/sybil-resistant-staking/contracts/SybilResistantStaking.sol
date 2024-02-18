// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IBiomapperLogRead} from "@biomapper-sdk/core/IBiomapperLogRead.sol";
import {BiomapperLogLib} from "@biomapper-sdk/libraries/BiomapperLogLib.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SybilResistantStaking {
    using SafeERC20 for IERC20;
    using BiomapperLogLib for IBiomapperLogRead;

    IERC20 public immutable STAKING_TOKEN;
    IERC20 public immutable REWARD_TOKEN;
    address public immutable REWARD_TOKEN_VAULT;
    uint256 public immutable PERCENT_MULTIPLIER;
    IBiomapperLogRead public immutable BIOMAPPER_LOG;

    mapping(address => uint256) public amountDeposited;
    mapping(address => uint256) public depositedAt;

    constructor(
        address stakingTokenAddress,
        address rewardTokenAddress,
        address rewardTokenVault,
        uint256 percentMultiplier,
        address biomapperLogAddress
    ) {
        STAKING_TOKEN = IERC20(stakingTokenAddress);
        REWARD_TOKEN = IERC20(rewardTokenAddress);
        REWARD_TOKEN_VAULT = rewardTokenVault;
        PERCENT_MULTIPLIER = percentMultiplier;
        BIOMAPPER_LOG = IBiomapperLogRead(biomapperLogAddress);
    }

    modifier mustBeUnique() {
        require(BIOMAPPER_LOG.isUnique(msg.sender), "User is not unique");
        _;
    }

    event Deposited(address who, uint256 amount);
    event Withdrawn(address who, uint256 stakedAmount, uint256 rewardAmount);

    function deposit(uint256 amount) external {
        require(amountDeposited[msg.sender] == 0, "User already has a deposit");

        amountDeposited[msg.sender] = amount;
        depositedAt[msg.sender] = block.number;

        STAKING_TOKEN.safeTransferFrom(msg.sender, address(this), amount);

        emit Deposited(msg.sender, amount);
    }

    function withdraw() external {
        require(amountDeposited[msg.sender] == 0, "User has no deposit");

        uint256 stakedAmount = amountDeposited[msg.sender];

        uint256 rewardAmount = (stakedAmount *
            BIOMAPPER_LOG.countBiomappedBlocks({
                who: msg.sender,
                fromBlock: depositedAt[msg.sender]
            }) *
            PERCENT_MULTIPLIER) / 100;

        amountDeposited[msg.sender] = 0;
        depositedAt[msg.sender] = 0;

        STAKING_TOKEN.safeTransfer(msg.sender, stakedAmount);

        REWARD_TOKEN.safeTransferFrom({
            from: REWARD_TOKEN_VAULT,
            to: msg.sender,
            value: rewardAmount
        });

        emit Withdrawn(msg.sender, stakedAmount, rewardAmount);
    }
}
