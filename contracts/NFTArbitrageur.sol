//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
pragma abicoder v2;

import './DydxFlashLoanBase.sol';
import './interfaces/IWyvernExchange.sol';
import './interfaces/ILooksRareExchange.sol';

import {OrderTypes} from "./libraries/OrderTypes.sol";

import 'hardhat/console.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTArbitrageur is DydxFlashloanBase {
    
    address public constant SoloMargin_address = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address public constant WETH_address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 public constant Loan_amt = 48_266_062_000_000_000_000;
    address public constant Bayc_address = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    address public constant IWyvernExchange_address = 0x7f268357A8c2552623316e2562D90e642bB538E5;
    address public constant MerkleValidator_address = 0xBAf2127B49fC93CbcA6269FAdE0F7F31dF4c88a7;
    address public constant OpenSeaWallet_address = 0x5b3256965e7C3cF26E11FCAf296DfC8807C01073;

    address public constant LooksRareTransferManagerERC721_address = 0xf42aa99F011A1fA7CDA90E5E98b277E306BcA83e;
    address public constant LooksRareStrategyAnyItemFromCollection_address = 0x86F909F70813CdB1Bc733f4D97Dc6b03B8e7E8F3;
    address public constant Null_address = address(0);

    uint256 public constant BAYC_id = 3158;

    IERC20 public constant WETH = IERC20(WETH_address);
    IERC721 public constant BAYC = IERC721(Bayc_address);
    struct MyCustomData {
        address token;
        uint256 repayAmount;
    }

    struct ParOpenSeaAtomicMatch {
        address[14] addrs;
        uint[18] uints;
        uint8[8] feeMethodsSidesKindsHowToCalls;
        uint8[2] vs;
        bytes32[5] rssMetadata;
        bytes calldataBuy;
        bytes replacementPatternBuy;
        bytes staticExtradataBuy;
        bytes calldataSell;
        bytes replacementPatternSell;
        bytes staticExtradataSell;
    }

    struct ParLooksRareMatchBidWithTakerAsk {
        OrderTypes.TakerOrder takerAsk;
        OrderTypes.MakerOrder makerBid;
    }

    struct ParLooksRareMatchAskWithTakerBid {
        OrderTypes.TakerOrder takerBid;
        OrderTypes.MakerOrder makerAsk;
    }


    // ParOpenSeaAtomicMatch memory _atomicMatchPar;
    // ParLooksRareMatchBidWithTakerAsk _looksRareMatchBidWithTakerAsk;


    function initLooksRareMatchBidWithTakerAskParam() internal returns (ParLooksRareMatchBidWithTakerAsk memory){      
        ParLooksRareMatchBidWithTakerAsk memory _looksRareMatchBidWithTakerAsk;
        _looksRareMatchBidWithTakerAsk.takerAsk.isOrderAsk = true;
        _looksRareMatchBidWithTakerAsk.takerAsk.taker = address(this);
        _looksRareMatchBidWithTakerAsk.takerAsk.price = 71_521_000_000_000_000_000;
        _looksRareMatchBidWithTakerAsk.takerAsk.tokenId = BAYC_id;
        _looksRareMatchBidWithTakerAsk.takerAsk.minPercentageToAsk = 8_500; // 85%
        _looksRareMatchBidWithTakerAsk.takerAsk.params = '';

        _looksRareMatchBidWithTakerAsk.makerBid.isOrderAsk = false;
        _looksRareMatchBidWithTakerAsk.makerBid.signer;
        _looksRareMatchBidWithTakerAsk.makerBid.collection = Bayc_address;
        _looksRareMatchBidWithTakerAsk.makerBid.price = 71_521_000_000_000_000_000;
        _looksRareMatchBidWithTakerAsk.makerBid.tokenId = 0;
        _looksRareMatchBidWithTakerAsk.makerBid.amount = 1;
        _looksRareMatchBidWithTakerAsk.makerBid.strategy = LooksRareStrategyAnyItemFromCollection_address;
        _looksRareMatchBidWithTakerAsk.makerBid.currency = WETH_address;
        _looksRareMatchBidWithTakerAsk.makerBid.nonce = 58_348;
        _looksRareMatchBidWithTakerAsk.makerBid.startTime = block.timestamp;
        _looksRareMatchBidWithTakerAsk.makerBid.endTime = block.timestamp;
        _looksRareMatchBidWithTakerAsk.makerBid.minPercentageToAsk = 8_500;
        _looksRareMatchBidWithTakerAsk.makerBid.params = '';
        _looksRareMatchBidWithTakerAsk.makerBid.v = 27;
        _looksRareMatchBidWithTakerAsk.makerBid.r;
        _looksRareMatchBidWithTakerAsk.makerBid.s;
        return _looksRareMatchBidWithTakerAsk;
    }

    function initOpenSeaWyvernExchangeAtomicMatchParam() internal returns (ParOpenSeaAtomicMatch memory){
        
        ParOpenSeaAtomicMatch memory _atomicMatchPar;
        address[14] memory addrs;
        uint[18] memory uints;
        uint8[8] memory feeMethodsSidesKindsHowToCalls;
        uint8[2] memory vs;
        bytes32[5] memory rssMetadata;

        // Buy 
        addrs[0] = IWyvernExchange_address; //  exchange
        addrs[1] = address(this); //  maker 
        addrs[2] = BAYC.ownerOf(BAYC_id); // taker
        uints[0] = 500;  /* Maker relayer fee of the order, unused for taker order. */
        uints[1] = 0;    /* Taker relayer fee of the order, or maximum taker fee for a taker order. */
        uints[2] = 0;    /* Maker protocol fee of the order, unused for taker order. */
        uints[3] = 0;    /* Taker protocol fee of the order, or maximum taker fee for a taker order. */
        addrs[3] = address(0); /* Order fee recipient or zero address for taker order. */
        
        // FeeMethod == start  /* Fee method (protocol token or split fee). */
        feeMethodsSidesKindsHowToCalls[0] = 1;
        // FeeMethod == end

        //SaleKindInterface.Side == start /* Side (buy/sell). */
        feeMethodsSidesKindsHowToCalls[1] = 0;
        //SaleKindInterface.Side == end

        //SaleKindInterface.SaleKind == start /* Kind of sale. */
        feeMethodsSidesKindsHowToCalls[2] = 0;
        //SaleKindInterface.SaleKind == end

        addrs[4] = MerkleValidator_address; /* Target. */

        //AuthenticatedProxy.HowToCall == start  /* HowToCall. */
        feeMethodsSidesKindsHowToCalls[3] = 1; 
        //AuthenticatedProxy.HowToCall == end

        bytes memory calldataBuy = "";  /* Calldata. */

        bytes memory replacementPatternBuy = "";  /* Calldata replacement pattern, or an empty byte array for no replacement. */

        addrs[5] = address(0); /* Static call target, zero-address for no static call. */
        
        bytes memory staticExtradataBuy = "";  /* Static call extra data. */
        
        //ERC20 == start /* Token used to pay for the order, or the zero-address as a sentinel value for Ether. */
        addrs[6] = address(0); 
        //ERC20 == end 

        uints[4] = 10_000_000_000_000_000_000;  /* Base price of the order (in paymentTokens). */
        uints[5] = 0;   /* Auction extra parameter - minimum bid increment for English auctions, starting/ending price difference. */
        uints[6] = 1_653_874_608;  /* Listing timestamp. */
        uints[7] = 0;  /* Expiration timestamp - 0 for no expiry. */
        uints[8] = 50_634_267_543_740_771_331_150_099_031_859_174_533_782_333_460_550_881_954_048_569_800_874_789_539_921;  /* Order salt, used to prevent duplicate hashes. */

        //Sig == start
        vs[0] = 27;
        rssMetadata[0] = "";
        rssMetadata[1] = "";
        //Sig == end
        
        // Sell 
        addrs[7] = IWyvernExchange_address;
        addrs[8] = BAYC.ownerOf(BAYC_id);
        addrs[9] = address(0);
        addrs[10] = OpenSeaWallet_address;
        addrs[11] = MerkleValidator_address;
        addrs[12] = Null_address;
        addrs[13] = Null_address; 

        uints[9] = 500;
        uints[10] = 0;
        uints[11] = 0;
        uints[12] = 0;
        uints[13] = 10_000_000_000_000_000_000;
        uints[14] = 0;
        uints[15] = 1_653_874_617;
        uints[16] = 1_654_135_622;
        uints[17] = 94_021_139_148_080_347_925_509_130_381_059_680_643_771_698_824_882_372_366_782_815_385_985_648_103_610; 
        
        feeMethodsSidesKindsHowToCalls[4] = 1;
        feeMethodsSidesKindsHowToCalls[5] = 1;
        feeMethodsSidesKindsHowToCalls[6] = 0;
        feeMethodsSidesKindsHowToCalls[7] = 1;
        
        bytes memory calldataSell = "";

        bytes memory replacementPatternSell = "";
        
        bytes memory staticExtradataSell = "";
        
        vs[1] = 27;
        rssMetadata[2] = "";
        rssMetadata[3] = "";
        rssMetadata[4] = "";

        _atomicMatchPar.addrs = addrs;
        _atomicMatchPar.uints = uints;
        _atomicMatchPar.feeMethodsSidesKindsHowToCalls = feeMethodsSidesKindsHowToCalls;
        _atomicMatchPar.vs = vs;
        _atomicMatchPar.rssMetadata = rssMetadata;
        _atomicMatchPar.calldataBuy = calldataBuy;
        _atomicMatchPar.replacementPatternBuy = replacementPatternBuy;
        _atomicMatchPar.staticExtradataBuy = staticExtradataBuy;
        _atomicMatchPar.calldataSell = calldataSell;
        _atomicMatchPar.replacementPatternSell = replacementPatternSell;
        _atomicMatchPar.staticExtradataSell = staticExtradataSell;
        return _atomicMatchPar;
    }


    function callFunction(
        address sender,
        Account.Info memory account,
        bytes memory data
    ) public {
        MyCustomData memory mcd = abi.decode(data, (MyCustomData));
        uint256 balOfLoanedToken = IERC20(mcd.token).balanceOf(address(this));
        IWyvernExchange WyvernExchange = IWyvernExchange(IWyvernExchange_address);
        ILooksRareExchange LooksRareExchange = ILooksRareExchange(LooksRareTransferManagerERC721_address);
        
        uint256 NftId = 3158;
        // Note that you can ignore the line below
        // if your dydx account (this contract in this case)
        // has deposited at least ~2 Wei of assets into the account
        // to balance out the collaterization ratio
        require(
            balOfLoanedToken >= mcd.repayAmount,
            "Not enough funds to repay dydx loan!"
        );
        address NFTownerAddress = BAYC.ownerOf(NftId);
        console.log("Now %s owner is $s",NftId, NFTownerAddress);

        ParOpenSeaAtomicMatch memory _atomicMatchPar = initOpenSeaWyvernExchangeAtomicMatchParam();
        WyvernExchange.atomicMatch_(_atomicMatchPar.addrs, 
                                    _atomicMatchPar.uints, 
                                    _atomicMatchPar.feeMethodsSidesKindsHowToCalls, 
                                    _atomicMatchPar.calldataBuy, _atomicMatchPar.calldataSell,
                                    _atomicMatchPar.replacementPatternBuy, _atomicMatchPar.replacementPatternSell, 
                                    _atomicMatchPar.staticExtradataBuy, _atomicMatchPar.staticExtradataSell, 
                                    _atomicMatchPar.vs, 
                                    _atomicMatchPar.rssMetadata);

        NFTownerAddress = BAYC.ownerOf(NftId);
        console.log("After buy Now %s owner is $s",NftId, NFTownerAddress);

        BAYC.setApprovalForAll(LooksRareTransferManagerERC721_address, true);
        ParLooksRareMatchBidWithTakerAsk memory _looksRareMatchBidWithTakerAsk = initLooksRareMatchBidWithTakerAskParam();
        LooksRareExchange.matchBidWithTakerAsk(_looksRareMatchBidWithTakerAsk.takerAsk, _looksRareMatchBidWithTakerAsk.makerBid);
        NFTownerAddress = BAYC.ownerOf(NftId);
        console.log("Now %s owner is $s",NftId, NFTownerAddress);
        uint256 weth_amt = WETH.balanceOf(address(this));
        console.log("Now I Have %s $s",weth_amt);
        // TODO: Encode your logic here
        WETH.transferFrom(address(this), SoloMargin_address, mcd.repayAmount);
        // E.g. arbitrage, liquidate accounts, etc
        //revert("Hello, you haven't encoded your logic");
       
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