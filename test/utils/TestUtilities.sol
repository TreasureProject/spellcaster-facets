// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {StringsUpgradeable} from "@openzeppelin/contracts-diamond/utils/StringsUpgradeable.sol";
import {ECDSAUpgradeable} from "@openzeppelin/contracts-diamond/utils/cryptography/ECDSAUpgradeable.sol";

import {Test} from "forge-std/Test.sol";

abstract contract TestUtilities is Test {
    using StringsUpgradeable for uint256;

    // Hex representation of 0123456789abcdef used for character lookup
    bytes32 internal constant ALPHANUMERIC_HEX =
        0x3031323334353637383961626364656600000000000000000000000000000000;

    function toString(uint256 _val) internal pure returns(string memory) {
        return _val.toString();
    }

    function roleBytes(string memory _roleName) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_roleName));
    }

    function namehash(bytes memory domain) internal pure returns (bytes32) {
        return namehash(domain, 0);
    }

    function namehash(bytes memory domain, uint i) internal pure returns (bytes32) {
        if (domain.length <= i)
        return 0x0000000000000000000000000000000000000000000000000000000000000000;

        uint len = labelLength(domain, i);

        return keccak256(abi.encodePacked(namehash(domain, i+len+1), keccak(domain, i, len)));
    }

    function labelLength(bytes memory domain, uint i) private pure returns (uint) {
        uint len;
        while (i+len != domain.length && domain[i+len] != 0x2e) {
        len++;
        }
        return len;
    }

    function keccak(bytes memory data, uint offset, uint len) private pure returns (bytes32 ret) {
        require(offset + len <= data.length);
        assembly {
        ret := keccak256(add(add(data, 32), offset), len)
        }
    }

    // Taken from AddressResolver for tests
    function addressToBytes(address a) internal pure returns (bytes memory b) {
        b = new bytes(20);
        assembly {
            mstore(add(b, 32), mul(a, exp(256, 12)))
        }
    }

    // Taken from AddressResolver for tests
    function bytesToAddress(bytes memory b)
        internal
        pure
        returns (address payable a)
    {
        require(b.length == 20);
        assembly {
            a := div(mload(add(b, 32)), exp(256, 12))
        }
    }

    /**
     * @dev An optimised function to compute the sha3 of the lower-case
     *      hexadecimal representation of an Ethereum address.
     * @param addr The address to hash
     * @return ret The SHA3 hash of the lower-case hexadecimal encoding of the
     *         input address.
     */
    function sha3HexAddress(address addr) internal pure returns (bytes32 ret) {
        assembly {
            for {
                let i := 40
            } gt(i, 0) {

            } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), ALPHANUMERIC_HEX))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), ALPHANUMERIC_HEX))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4(bytes memory _domainName, bytes memory _domainVersion, address _receivingContractAddress) internal view returns (bytes32) {
        // Hardcoded name+version to the current version of the forwarder
        // Must pass in the address of the receiving contract because they will build the domain separator
        //  with their address
        return _buildDomainSeparator(keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        ), keccak256(_domainName), keccak256(_domainVersion), _receivingContractAddress);
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash,
        address _receivingContractAddress
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, _receivingContractAddress));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSAUpgradeable-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSAUpgradeable.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 _structHash, bytes memory _domainName, bytes memory _domainVersion, address _receivingContractAddress) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(_domainName, _domainVersion, _receivingContractAddress), _structHash);
    }

    function signHash(uint256 privateKey, bytes32 digest) internal pure returns(bytes memory bytes_) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        // convert curve to sig bytes for using with ECDSAUpgradeable vs ecrecover
        bytes_ = abi.encodePacked(r, s, v);
    }

    function signHashVRS(uint256 privateKey, bytes32 digest) internal pure returns(uint8 v, bytes32 r, bytes32 s) {
        (v, r, s) = vm.sign(privateKey, digest);
    }

    function signHashEth(uint256 privateKey, bytes32 digest) internal pure returns(bytes memory bytes_) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, ECDSAUpgradeable.toEthSignedMessageHash(digest));
        // convert curve to sig bytes for using with ECDSAUpgradeable vs ecrecover
        bytes_ = abi.encodePacked(r, s, v);
    }

    function signHashEthVRS(uint256 privateKey, bytes32 digest) internal pure returns(uint8 v, bytes32 r, bytes32 s) {
        (v, r, s) = vm.sign(privateKey, ECDSAUpgradeable.toEthSignedMessageHash(digest));
    }
}