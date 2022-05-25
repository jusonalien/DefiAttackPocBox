require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  solidity: "0.8.4",
  networks: {
    // hardhat: {
    //   forking: {
    //     url: "https://bsc-mainnet.nodereal.io/v1/1005333b090f46aa9edb747e3fa5235a",
    //     blockNumber: 17832800
    //   }
    // },
    hardhat: {
      forking: {
        url: "https://bsc-mainnet.nodereal.io/v1/1005333b090f46aa9edb747e3fa5235a",
        blockNumber: 18073756
      }
    }
  }
};
