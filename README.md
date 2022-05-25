# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```


## Fork BSC主网

npx hardhat node --fork https://speedy-nodes-nyc.moralis.io/b234fd772a462ea70ca3ab3b/bsc/mainnet/archive --fork-block-number 17832802


ganache-cli --fork https://speedy-nodes-nyc.moralis.io/b234fd772a462ea70ca3ab3b/bsc/mainnet/archive -l 17832802


ganache-cli --fork https://bsc-mainnet.nodereal.io/v1/1005333b090f46aa9edb747e3fa5235a -l 17832802

## 运行

npx hardhat run --network hardhat scripts/sample-script.js
