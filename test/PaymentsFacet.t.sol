// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {ERC1155HolderUpgradeable} from "@openzeppelin/contracts-diamond/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import {AddressUpgradeable} from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

import {TestBase} from "./utils/TestBase.sol";
import {DiamondManager, Diamond, IDiamondCut, FacetInfo} from "./utils/DiamondManager.sol";
import {DiamondUtils} from "./utils/DiamondUtils.sol";
import{ERC20MockDecimals} from "test/mocks/ERC20MockDecimals.sol";

import {LibAccessControlRoles, ADMIN_ROLE, ADMIN_GRANTER_ROLE} from "src/libraries/LibAccessControlRoles.sol";
import {LibMeta} from "src/libraries/LibMeta.sol";

import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";
import {PaymentsFacet} from "src/payments/PaymentsFacet.sol";

import "forge-std/console.sol";

contract PaymentsFacetTest is TestBase, DiamondManager, ERC1155HolderUpgradeable {
    using DiamondUtils for Diamond;
    using AddressUpgradeable for address;

    PaymentsFacet internal _payments;
    MockV3Aggregator internal _ethUsdPriceFeed;
    // Taken from the ETH / USD price feed when this test was written and 1 ETH equaled 1758.71877553 USD
    // This is in 8 decimal places because it's USD
    int256 usdToEthPrice = 175871877553;

    ERC20MockDecimals internal mockUSDC = new ERC20MockDecimals(6);
    ERC20MockDecimals internal mockWETH = new ERC20MockDecimals(18);
    ERC20MockDecimals internal mockMAGIC = new ERC20MockDecimals(18);

    function setUp() public {
        _ethUsdPriceFeed = new MockV3Aggregator(8, usdToEthPrice);
        _payments = new PaymentsFacet();
        _payments.PaymentsFacet_init(address(_ethUsdPriceFeed));
    }

    function testAllowTakePaymentERC20() public {
        
    }

}