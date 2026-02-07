require("@nomicfoundation/hardhat-ethers");
require("dotenv").config();

const PRIVATE_KEY = process.env.XAVI_PRIVATE_KEY || "";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    xrplevm: {
      url: "https://rpc.xrplevm.org",
      chainId: 1440000,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
  },
};
