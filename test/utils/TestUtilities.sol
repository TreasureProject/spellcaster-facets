// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { StringsUpgradeable } from "@openzeppelin/contracts-diamond/utils/StringsUpgradeable.sol";
import { ECDSAUpgradeable } from "@openzeppelin/contracts-diamond/utils/cryptography/ECDSAUpgradeable.sol";

import { Test } from "forge-std/Test.sol";

abstract contract TestUtilities is Test {
    using StringsUpgradeable for uint256;

    // Hex representation of 0123456789abcdef used for character lookup
    bytes32 internal constant ALPHANUMERIC_HEX = 0x3031323334353637383961626364656600000000000000000000000000000000;

    function toString(uint256 _val) internal pure returns (string memory) {
        return _val.toString();
    }

    function _roleBytes(string memory _roleName) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_roleName));
    }

    function namehash(bytes memory _domain) internal pure returns (bytes32) {
        return namehash(_domain, 0);
    }

    function namehash(bytes memory _domain, uint256 i) internal pure returns (bytes32) {
        if (_domain.length <= i) {
            return 0x0000000000000000000000000000000000000000000000000000000000000000;
        }

        uint256 _len = labelLength(_domain, i);

        return keccak256(abi.encodePacked(namehash(_domain, i + _len + 1), keccak(_domain, i, _len)));
    }

    function labelLength(bytes memory _domain, uint256 i) private pure returns (uint256) {
        uint256 _len;
        while (i + _len != _domain.length && _domain[i + _len] != 0x2e) {
            _len++;
        }
        return _len;
    }

    function keccak(bytes memory _data, uint256 _offset, uint256 _len) private pure returns (bytes32 _ret) {
        require(_offset + _len <= _data.length, "Out of bounds");
        assembly {
            _ret := keccak256(add(add(_data, 32), _offset), _len)
        }
    }

    // Taken from AddressResolver for tests
    function addressToBytes(address _a) internal pure returns (bytes memory _b) {
        _b = new bytes(20);
        assembly {
            mstore(add(_b, 32), mul(_a, exp(256, 12)))
        }
    }

    // Taken from AddressResolver for tests
    function bytesToAddress(bytes memory _b) internal pure returns (address payable _a) {
        require(_b.length == 20, "Invalid address length");
        assembly {
            _a := div(mload(add(_b, 32)), exp(256, 12))
        }
    }

    /**
     * @dev An optimised function to compute the sha3 of the lower-case
     *      hexadecimal representation of an Ethereum address.
     * @param _addr The address to hash
     * @return _ret The SHA3 hash of the lower-case hexadecimal encoding of the
     *         input address.
     */
    function sha3HexAddress(address _addr) internal pure returns (bytes32 _ret) {
        assembly {
            for { let i := 40 } gt(i, 0) { } {
                i := sub(i, 1)
                mstore8(i, byte(and(_addr, 0xf), ALPHANUMERIC_HEX))
                _addr := div(_addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(_addr, 0xf), ALPHANUMERIC_HEX))
                _addr := div(_addr, 0x10)
            }

            _ret := keccak256(0, 40)
        }
    }

    /**
     * @dev Returns the _domain separator for the current chain.
     */
    function _domainSeparatorV4(
        bytes memory _domainName,
        bytes memory _domainVersion,
        address _receivingContractAddress
    ) internal view returns (bytes32) {
        // Hardcoded name+version to the current version of the forwarder
        // Must pass in the address of the receiving contract because they will build the _domain separator
        //  with their address
        return _buildDomainSeparator(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(_domainName),
            keccak256(_domainVersion),
            _receivingContractAddress
        );
    }

    function _buildDomainSeparator(
        bytes32 _typeHash,
        bytes32 _nameHash,
        bytes32 _versionHash,
        address _receivingContractAddress
    ) private view returns (bytes32) {
        return keccak256(abi.encode(_typeHash, _nameHash, _versionHash, block.chainid, _receivingContractAddress));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this _domain.
     *
     * This hash can be used together with {ECDSAUpgradeable-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 _digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSAUpgradeable.recover(_digest, signature);
     * ```
     */
    function _hashTypedDataV4(
        bytes32 _structHash,
        bytes memory _domainName,
        bytes memory _domainVersion,
        address _receivingContractAddress
    ) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(
            _domainSeparatorV4(_domainName, _domainVersion, _receivingContractAddress), _structHash
        );
    }

    function signHash(uint256 _privateKey, bytes32 _digest) internal pure returns (bytes memory bytes_) {
        (uint8 _v, bytes32 _r, bytes32 _s) = vm.sign(_privateKey, _digest);
        // convert curve to sig bytes for using with ECDSAUpgradeable vs ecrecover
        bytes_ = abi.encodePacked(_r, _s, _v);
    }

    function signHashVRS(
        uint256 _privateKey,
        bytes32 _digest
    ) internal pure returns (uint8 _v, bytes32 _r, bytes32 _s) {
        (_v, _r, _s) = vm.sign(_privateKey, _digest);
    }

    function signHashEth(uint256 _privateKey, bytes32 _digest) internal pure returns (bytes memory bytes_) {
        (uint8 _v, bytes32 _r, bytes32 _s) = vm.sign(_privateKey, ECDSAUpgradeable.toEthSignedMessageHash(_digest));
        // convert curve to sig bytes for using with ECDSAUpgradeable vs ecrecover
        bytes_ = abi.encodePacked(_r, _s, _v);
    }

    function signHashEthVRS(
        uint256 _privateKey,
        bytes32 _digest
    ) internal pure returns (uint8 _v, bytes32 _r, bytes32 _s) {
        (_v, _r, _s) = vm.sign(_privateKey, ECDSAUpgradeable.toEthSignedMessageHash(_digest));
    }
}
