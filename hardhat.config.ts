import "dotenv/config";
import "@nomicfoundation/hardhat-foundry";
import {HardhatUserConfig} from "hardhat/types";

const config: HardhatUserConfig = {
  // These compiler settings must match foundry.toml to avoid unexpected issues
  solidity: {
    compilers: [
      {
        version: "0.8.22",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
    ],
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
    },
    localhost: {
      url: "http://localhost:8545",
      chainId : 61337,
    },
  },
  paths: {
    sources: "src"
  },
};

export default config;
