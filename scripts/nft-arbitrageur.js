const { signMakerOrder, generateMakerOrderTypedData } = require("@looksrare/sdk");
// const { etherSignTypedData } = require("@looksrare/sdk/dist/sign/");
const { ethers } = require("hardhat");

const { MakerOrder,TakerOrder,SupportedChainId } = require("@looksrare/sdk");
const { BigNumberish, BytesLike } = require("ethers");


async function main() {

    await network.provider.request({
        method: "hardhat_reset",
        params: [{
          forking: {
            jsonRpcUrl: "https://eth-mainnet.nodereal.io/v1/3bcd5b1da993472380b454254c6202b8",
            blockNumber: 14839152
          }
        }]
    })


    // const accounts = await ethers.getSigners();
    // // console.log(accounts);
    // for (const account of accounts) {
    //     console.log(account.address);
    //   }
    const [account] = await ethers.getSigners();
    let makerOrder = {
      isOrderAsk: true, //isOrderAsk
      signer: "0xD0a5Ed6eC27a7CB0530FEE97A0EB84580150A822", // signer
      collection: "0xcE25E60A89F200B1fA40f6c313047FFe386992c3", // collection
      price: "1000000000000000000", //price
      tokenId: "1", //tokenId
      amount: "1", //amount
      strategy: "0x56244Bb70CbD3EA9Dc8007399F61dFC065190031", //strategy
      currency: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", //currency
      nonce: "100", //nonce
      startTime: Math.floor(Date.now() / 1000), //startTime
      endTime: Math.floor(Date.now() / 1000) + 86400, //endTime
      minPercentageToAsk: 8500, //minPercentageToAsk
      params: [], //params
    }
    console.log(await account.getAddress());
    const looks_address = '0x59728544B08AB483533076417FbBB2fD0B17CE3a';
    const looks_address_Rinkeby = '0x1AA777972073Ff66DCFDeD85749bDD555C0665dA';
    // const looks_address_Rinkeby = '';
    // const signerAddress = await account.getAddress();
    // const {domain, type, value} = generateMakerOrderTypedData(signerAddress, SupportedChainId.MAINNET, makerOrder, looks_address);
    // const signature = await  etherSignTypedData(signer.provider, signerAddress, domain, type, value);
    const signature = await signMakerOrder(account, SupportedChainId.MAINNET ,makerOrder,looks_address_Rinkeby);
    
    console.log(ethers.utils.splitSignature(signature));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
