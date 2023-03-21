// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {LibMeta} from "src/libraries/LibMeta.sol";
import {PaymentsStorage, ERC20Info} from "src/payments/PaymentsStorage.sol";

/// @title Library for handling storage interfacing for payments
library LibPayments {
    /**
     * @param _erc20Addr The address of the coin to retrieve info for
     * @return info_ The return struct is storage. This means all state changes to the struct will save automatically,
     *  instead of using a memory copy overwrite
     */
    function getERC20Info(address _erc20Addr) internal view returns (ERC20Info storage info_) {
        info_ = PaymentsStorage.layout().erc20ToInfo[_erc20Addr];
    }

    /**
     * @return priceFeed_ The price feed for the gas token valued in USD
     */
    function getGasTokenUSDPriceFeed() internal view returns (AggregatorV3Interface priceFeed_) {
        priceFeed_ = PaymentsStorage.layout().gasTokenUSDPriceFeed;
    }

    /**
     * @param _erc20Addr The address of the coin to retrieve the price feed for
     * @return priceFeed_ The price feed for the gas token valued in the ERC20 token
     */
    function getGasTokenERC20PriceFeed(address _erc20Addr) internal view returns (AggregatorV3Interface priceFeed_) {
        priceFeed_ = PaymentsStorage.layout().erc20ToInfo[_erc20Addr].gasTokenPricedInERC20Aggregator;
    }

    function getMagicAddress() internal view returns(address magicAddress_) {
        magicAddress_ = PaymentsStorage.layout().magicAddress;
    }

    /**
     * @param _priceFeedAddr The address of the price feed to set
     */
    function setGasTokenUSDPriceFeed(address _priceFeedAddr) internal {
        PaymentsStorage.layout().gasTokenUSDPriceFeed = AggregatorV3Interface(_priceFeedAddr);
    }

    /**
     * @param _erc20Addr The address of the ERC20 token to set the price feed for
     * @param _priceFeedAddr The address of the price feed to set
     */
    function setGasTokenERC20PriceFeed(address _erc20Addr, address _priceFeedAddr) internal {
        PaymentsStorage.layout().erc20ToInfo[_erc20Addr].gasTokenPricedInERC20Aggregator = AggregatorV3Interface(_priceFeedAddr);
    }

    /**
     * @param _magicAddress The address of the $MAGIC token
     */
    function setMagicAddress(address _magicAddress) internal {
        PaymentsStorage.layout().magicAddress = _magicAddress;
    }
}
