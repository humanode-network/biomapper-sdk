import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-viem";

import "./chai-setup";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
};

export default config;
