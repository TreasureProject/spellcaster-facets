// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { ERC721Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC721/ERC721Upgradeable.sol";
import { IERC20Upgradeable } from "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";

import { PaymentsReceiver } from "src/payments/PaymentsReceiver.sol";

/**
 * @notice Example consumer of the Spellcaster Payments system. Implementations must implement IPaymentsReceiver.
 *         For simplicity, this contract consumes the base contract PaymentsReceiver, which routes payments into
 *         easy-to-implement functions.
 */
contract SimplePaymentsReceiver is ERC721Upgradeable, PaymentsReceiver {
    uint256 public magicMintPrice = 25 ether;
    uint256 public usdMintPrice = 50;
    address public magicMock = address(0xc0ffee);
    address public ownerMock = address(0xbeef);

    function initialize(address _spellcasterPayments) external {
        PaymentsReceiver.PaymentsReceiver_init(_spellcasterPayments);
        __ERC721_init("MOCKERC721", "ERC721_M");
    }

    function _acceptStaticMagicPayment(address _payor, uint256 _paymentAmount) internal override {
        uint256 _mints = _calculateNumberOfMints(_paymentAmount, false);
        IERC20Upgradeable(magicMock).transfer(ownerMock, _paymentAmount);

        for (uint256 i = 0; i < _mints; i++) {
            _mint(_payor, i);
        }
    }

    function _acceptMagicPaymentPricedInUSD(
        address _payor,
        uint256 _paymentAmount,
        uint256 _priceInUSD
    ) internal override {
        uint256 _mints = _calculateNumberOfMints(_priceInUSD, true);
        IERC20Upgradeable(magicMock).transfer(ownerMock, _paymentAmount);

        for (uint256 i = 0; i < _mints; i++) {
            _mint(_payor, i);
        }
    }

    function _calculateNumberOfMints(uint256 _paymentAmount, bool _isInUSD) internal view returns (uint256) {
        uint256 _pricePerMint = _isInUSD ? usdMintPrice : magicMintPrice;
        if (_paymentAmount % _pricePerMint != 0) {
            revert("Invalid payment amount");
        }
        return _paymentAmount / _pricePerMint;
    }

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        virtual
        override(ERC721Upgradeable, PaymentsReceiver)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }

    function withdrawMagic() external {
        // Don't forget to add the ability to withdraw!
    }
}
