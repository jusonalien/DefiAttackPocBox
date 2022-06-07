// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    Decimal,Account,Monetary,
    Types,Interest,
    Storage,Actions
} from "../libraries/LSoloMargin.sol";
interface ISoloMargin {
    struct OperatorArg {
        address operator;
        bool trusted;
    }

    function ownerSetSpreadPremium(
        uint256 marketId,
        Decimal.D256 memory spreadPremium
    ) external;

    function getIsGlobalOperator(address operator) external view returns (bool);

    function getMarketTokenAddress(uint256 marketId)
        external
        view
        returns (address);

    function ownerSetInterestSetter(uint256 marketId, address interestSetter)
        external;

    function getAccountValues(Account.Info memory account)
        external
        view
        returns (Monetary.Value memory, Monetary.Value memory);

    function getMarketPriceOracle(uint256 marketId)
        external
        view
        returns (address);

    function getMarketInterestSetter(uint256 marketId)
        external
        view
        returns (address);

    function getMarketSpreadPremium(uint256 marketId)
        external
        view
        returns (Decimal.D256 memory);

    function getNumMarkets() external view returns (uint256);

    function ownerWithdrawUnsupportedTokens(address token, address recipient)
        external
        returns (uint256);

    function ownerSetMinBorrowedValue(Monetary.Value memory minBorrowedValue)
        external;

    function ownerSetLiquidationSpread(Decimal.D256 memory spread) external;

    function ownerSetEarningsRate(Decimal.D256 memory earningsRate) external;

    function getIsLocalOperator(address owner, address operator)
        external
        view
        returns (bool);

    function getAccountPar(Account.Info memory account, uint256 marketId)
        external
        view
        returns (Types.Par memory);

    function ownerSetMarginPremium(
        uint256 marketId,
        Decimal.D256 memory marginPremium
    ) external;

    function getMarginRatio() external view returns (Decimal.D256 memory);

    function getMarketCurrentIndex(uint256 marketId)
        external
        view
        returns (Interest.Index memory);

    function getMarketIsClosing(uint256 marketId) external view returns (bool);

    function getRiskParams() external view returns (Storage.RiskParams memory);

    function getAccountBalances(Account.Info memory account)
        external
        view
        returns (address[] memory, Types.Par[] memory, Types.Wei[] memory);

    function renounceOwnership() external;

    function getMinBorrowedValue() external view returns (Monetary.Value memory);

    function setOperators(OperatorArg[] memory args) external;

    function getMarketPrice(uint256 marketId) external view returns (address);

    function owner() external view returns (address);

    function isOwner() external view returns (bool);

    function ownerWithdrawExcessTokens(uint256 marketId, address recipient)
        external
        returns (uint256);

    function ownerAddMarket(
        address token,
        address priceOracle,
        address interestSetter,
        Decimal.D256 memory marginPremium,
        Decimal.D256 memory spreadPremium
    ) external;

    function operate(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions
    ) external;

    function getMarketWithInfo(uint256 marketId)
        external
        view
        returns (
            Storage.Market memory,
            Interest.Index memory,
            Monetary.Price memory,
            Interest.Rate memory
        );

    function ownerSetMarginRatio(Decimal.D256 memory ratio) external;

    function getLiquidationSpread() external view returns (Decimal.D256 memory);

    function getAccountWei(Account.Info memory account, uint256 marketId)
        external
        view
        returns (Types.Wei memory);

    function getMarketTotalPar(uint256 marketId)
        external
        view
        returns (Types.TotalPar memory);

    function getLiquidationSpreadForPair(
        uint256 heldMarketId,
        uint256 owedMarketId
    ) external view returns (Decimal.D256 memory);

    function getNumExcessTokens(uint256 marketId)
        external
        view
        returns (Types.Wei memory);

    function getMarketCachedIndex(uint256 marketId)
        external
        view
        returns (Interest.Index memory);

    function getAccountStatus(Account.Info memory account)
        external
        view
        returns (uint8);

    function getEarningsRate() external view returns (Decimal.D256 memory);

    function ownerSetPriceOracle(uint256 marketId, address priceOracle) external;

    function getRiskLimits() external view returns (Storage.RiskLimits memory);

    function getMarket(uint256 marketId)
        external
        view
        returns (Storage.Market memory);

    function ownerSetIsClosing(uint256 marketId, bool isClosing) external;

    function ownerSetGlobalOperator(address operator, bool approved) external;

    function transferOwnership(address newOwner) external;

    function getAdjustedAccountValues(Account.Info memory account)
        external
        view
        returns (Monetary.Value memory, Monetary.Value memory);

    function getMarketMarginPremium(uint256 marketId)
        external
        view
        returns (Decimal.D256 memory);

    function getMarketInterestRate(uint256 marketId)
        external
        view
        returns (Interest.Rate memory);
}