// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165Upgradeable } from "@openzeppelin/contracts-diamond/utils/introspection/IERC165Upgradeable.sol";
import { AddressUpgradeable } from "@openzeppelin/contracts-diamond/utils/AddressUpgradeable.sol";

import { IPaymentsV2, PriceType } from "src/interfaces/IPaymentsV2.sol";
import { IPaymentsReceiverV2 } from "src/interfaces/IPaymentsReceiverV2.sol";

import { LibMeta } from "src/libraries/LibMeta.sol";
import { PaymentsBase } from "src/payments/PaymentsBase.sol";
import { PaymentsStorage } from "src/payments/PaymentsStorage.sol";

/**
 * @title Payments V2 contract.
 * @dev This facet exposes functionality to allow complex payments with additional metadata handling.
 */
abstract contract PaymentsV2 is PaymentsBase, IPaymentsV2 {
    using AddressUpgradeable for address;

    /**
     * @inheritdoc IPaymentsV2
     */
    function makeStaticERC20Payment(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmount,
        bytes calldata _data
    ) external override nonReentrant {
        _requireReceiverV2(_recipient);
        _sendERC20(_recipient, _paymentERC20, _paymentAmount, _paymentAmount, PriceType.STATIC, address(0), _data);
    }

    /**
     * @inheritdoc IPaymentsV2
     */
    function makeStaticGasTokenPayment(
        address _recipient,
        uint256 _paymentAmount,
        bytes calldata _data
    ) external payable override nonReentrant {
        _requireReceiverV2(_recipient);
        _sendGasToken(_recipient, _paymentAmount, _paymentAmount, PriceType.STATIC, address(0), _data);
    }

    /**
     * @inheritdoc IPaymentsV2
     */
    function makeERC20PaymentByPriceType(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20,
        bytes calldata _data
    ) external override nonReentrant {
        _requireReceiverV2(_recipient);
        _makeERC20PaymentByPriceType(
            _recipient, _paymentERC20, _paymentAmountInPricedToken, _priceType, _pricedERC20, _data
        );
    }

    /**
     * @inheritdoc IPaymentsV2
     */
    function makeUsdPaymentByPricedToken(
        address _recipient,
        address _usdToken,
        uint256 _paymentAmountInPricedToken,
        address _pricedERC20,
        bytes calldata _data
    ) external override nonReentrant {
        _requireReceiverV2(_recipient);
        _makeUsdPaymentByPricedToken(_recipient, _usdToken, _paymentAmountInPricedToken, _pricedERC20, _data);
    }

    /**
     * @inheritdoc IPaymentsV2
     */
    function makeGasTokenPaymentByPriceType(
        address _recipient,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20,
        bytes calldata _data
    ) external payable override nonReentrant {
        _requireReceiverV2(_recipient);
        _makeGasTokenPaymentByPriceType(_recipient, _paymentAmountInPricedToken, _priceType, _pricedERC20, _data);
    }

    function _acceptERC20WithData(
        address _recipient,
        address _paymentERC20,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20,
        bytes memory _data
    ) internal override {
        IPaymentsReceiverV2(_recipient).acceptERC20WithData(
            LibMeta._msgSender(),
            _paymentERC20,
            _paymentAmount,
            _paymentAmountInPricedToken,
            _priceType,
            _pricedERC20,
            _data
        );
    }

    function _acceptGasTokenWithData(
        address _recipient,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20,
        bytes memory _data
    ) internal override {
        // Assume that the invoker of this hook validated the msg.value is correct
        IPaymentsReceiverV2(_recipient).acceptGasTokenWithData{ value: _paymentAmount }(
            LibMeta._msgSender(), _paymentAmount, _paymentAmountInPricedToken, _priceType, _pricedERC20, _data
        );
    }

    function _requireReceiverV2(address _recipient) internal view {
        if (!_recipient.isContract()) {
            revert PaymentsStorage.NonPaymentsReceiverRecipient(_recipient);
        }
        try IERC165Upgradeable(_recipient).supportsInterface(type(IPaymentsReceiverV2).interfaceId) returns (
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
