// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165Upgradeable } from "@openzeppelin/contracts-diamond/utils/introspection/IERC165Upgradeable.sol";
import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

import { IPayments, PriceType } from "src/interfaces/IPayments.sol";
import { IPaymentsReceiver } from "src/interfaces/IPaymentsReceiver.sol";

import { LibMeta } from "src/libraries/LibMeta.sol";

import { PaymentsBase } from "src/payments/PaymentsBase.sol";
import { PaymentsStorage } from "src/payments/PaymentsStorage.sol";

/**
 * @title Payments V1  contract.
 * @dev This exposes functionality to easily allow users to accept payments in ERC20 tokens or gas tokens (ETH, MATIC, etc.)
 *      Users can also pay in a token amount priced in USD, other ERC20, or gas tokens.
 */
abstract contract PaymentsV1 is PaymentsBase {
    using AddressUpgradeable for address;

    /**
     * @inheritdoc IPayments
     */
    function makeStaticERC20Payment(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmount
    ) external override nonReentrant {
        _requireReceiver(_recipient);
        _sendERC20(_recipient, _paymentERC20, _paymentAmount, _paymentAmount, PriceType.STATIC, address(0), "");
    }

    /**
     * @inheritdoc IPayments
     */
    function makeStaticGasTokenPayment(
        address _recipient,
        uint256 _paymentAmount
    ) external payable override nonReentrant {
        _requireReceiver(_recipient);
        _sendGasToken(_recipient, _paymentAmount, _paymentAmount, PriceType.STATIC, address(0), "");
    }

    /**
     * @inheritdoc IPayments
     */
    function makeERC20PaymentByPriceType(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20
    ) external override nonReentrant {
        _requireReceiver(_recipient);
        _makeERC20PaymentByPriceType(
            _recipient, _paymentERC20, _paymentAmountInPricedToken, _priceType, _pricedERC20, ""
        );
    }

    /**
     * @inheritdoc IPayments
     */
    function makeUsdPaymentByPricedToken(
        address _recipient,
        address _usdToken,
        uint256 _paymentAmountInPricedToken,
        address _pricedERC20
    ) external override nonReentrant {
        _requireReceiver(_recipient);
        _makeUsdPaymentByPricedToken(_recipient, _usdToken, _paymentAmountInPricedToken, _pricedERC20, "");
    }

    /**
     * @inheritdoc IPayments
     */
    function makeGasTokenPaymentByPriceType(
        address _recipient,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20
    ) external payable override nonReentrant {
        _requireReceiver(_recipient);
        _makeGasTokenPaymentByPriceType(_recipient, _paymentAmountInPricedToken, _priceType, _pricedERC20, "");
    }

    function _acceptERC20(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20
    ) internal override {
        // Invoke the receiver's hook
        IPaymentsReceiver(_recipient).acceptERC20(
            LibMeta._msgSender(), _paymentERC20, _paymentAmount, _paymentAmountInPricedToken, _priceType, _pricedERC20
        );
    }

    function _acceptGasToken(
        address _recipient,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20
    ) internal override {
        // Invoke the receiver's hook (also sends the value of the payment without any overpayment)
        IPaymentsReceiver(_recipient).acceptGasToken{ value: _paymentAmount }(
            LibMeta._msgSender(), _paymentAmount, _paymentAmountInPricedToken, _priceType, _pricedERC20
        );
    }

    function _requireReceiver(address _recipient) internal view {
        if (!_recipient.isContract()) {
            revert PaymentsStorage.NonPaymentsReceiverRecipient(_recipient);
        }
        try IERC165Upgradeable(_recipient).supportsInterface(type(IPaymentsReceiver).interfaceId) returns (
            bool isSupported_
        ) {
            if (!isSupported_) {
                revert PaymentsStorage.NonPaymentsReceiverRecipient(_recipient);
            }
        } catch (bytes memory) {
            revert PaymentsStorage.NonPaymentsReceiverRecipient(_recipient);
        }
    }
}
