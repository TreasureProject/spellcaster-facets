// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165Upgradeable } from "@openzeppelin/contracts-diamond/utils/introspection/IERC165Upgradeable.sol";
import { IERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";

import { FacetInitializable } from "src/utils/FacetInitializable.sol";
import { LibMeta } from "src/libraries/LibMeta.sol";

import { IPayments, PriceType } from "src/interfaces/IPayments.sol";
import { IPaymentsReceiver } from "src/interfaces/IPaymentsReceiver.sol";
import { IPaymentsReceiverV2 } from "src/interfaces/IPaymentsReceiverV2.sol";
import { PaymentsReceiver } from "src/payments/PaymentsReceiver.sol";
import { PaymentsReceiverStorage } from "src/payments/PaymentsReceiverStorage.sol";

/**
 * @title Payments Receiver V2 contract.
 * @dev This facet extends the PaymentsReceiver contract to include calldata handling for advanced features
 */
contract PaymentsReceiverV2 is PaymentsReceiver, IPaymentsReceiverV2 {
    /**
     * @dev Initialize the facet. Must be called before any other functions.
     */
    function PaymentsReceiverV2_init(address _spellcasterPayments)
        public
        facetInitializer(keccak256("PaymentsReceiverV2"))
    {
        // execute the v1 init function to ensure that the v1 state is initialized
        PaymentsReceiver_init(_spellcasterPayments);
    }

    /**
     * @inheritdoc IPaymentsReceiverV2
     */
    function acceptERC20WithData(
        address _payor,
        address _paymentERC20,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20,
        bytes calldata _data
    ) external {
        emit PaymentReceivedV2(
            _payor, _paymentERC20, _paymentAmount, _paymentAmountInPricedToken, _priceType, _pricedERC20, _data
        );
    }

    /**
     * @inheritdoc IPaymentsReceiverV2
     */
    function acceptGasTokenWithData(
        address _payor,
        uint256 _paymentAmount,
        uint256 _paymentAmountInPricedToken,
        PriceType _priceType,
        address _pricedERC20,
        bytes calldata _data
    ) external payable {
        emit PaymentReceivedV2(
            _payor, address(0), _paymentAmount, _paymentAmountInPricedToken, _priceType, _pricedERC20, _data
        );
    }

    /**
     * @dev Enables external contracts to query if this contract implements the IPaymentsReceiver interface.
     *      Needed for compliant implementation of Spellcaster Payments.
     */
    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return _interfaceId == type(IPaymentsReceiver).interfaceId
            || _interfaceId == type(IPaymentsReceiverV2).interfaceId || _interfaceId == type(IERC165Upgradeable).interfaceId;
    }
}
