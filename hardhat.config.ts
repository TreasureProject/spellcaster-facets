import "dotenv/config";
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomiclabs/hardhat-ethers";
import 'hardhat-contract-sizer';
import "hardhat-deploy";
import "hardhat-gas-reporter";
import "@nomicfoundation/hardhat-foundry";
import "@nomiclabs/hardhat-etherscan";
import {HardhatUserConfig} from "hardhat/types";

const config: HardhatUserConfig = {
  // These compiler settings must match hardhat.config.ts to avoid unexpected issues
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
    ],
  },
  namedAccounts: {
    deployer: 0,
    otherWallet: 1,
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      blockGasLimit: 29000000,
      live: false,
      saveDeployments: true,
      tags: ["test", "local"],
    },
    localhost: {
      url: "http://localhost:8545",
      chainId : 61337,
      tags: ["local"],
    },
  },
  mocha: {
    timeout: 100000000,
  },
  gasReporter: {
    currency: 'USD',
    enabled: false,
  },
  paths: {
    sources: "src",
    deploy: "script/deploy",
  },
  contractSizer: {
    runOnCompile: true
  },
};

export default config;
