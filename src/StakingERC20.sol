//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin/contracts-diamond/proxy/utils/Initializable.sol";
import {IERC20Upgradeable} from "@openzeppelin/contracts-diamond/token/ERC20/IERC20Upgradeable.sol";
import {StakingStorage} from "./libraries/StakingStorage.sol";
import {IERC20Consumer} from "./interfaces/IERC20Consumer.sol";

struct ERC20TokenStorageData {
    address owner;
    bool stored;
}

struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

struct WithdrawRequest {
    address tokenAddress;
    address reciever;
    uint256 amount;
    uint256 nonce;
    bool stored;
    Signature signature;
}

contract StakingERC20 is Initializable {
    event ERC20Deposited(address _tokenAddress, address _depositor,address _reciever, uint256 _amount);
    event ERC20Withdrawn(address _tokenAddress, address _reciever, uint256 _amount);

    function __StakingERC20_init() internal onlyInitializing {
    }

    function depositERC20(address _tokenAddress, address _reciever, uint256 _amount)
        public
    {
        //Yoink it.
        IERC20Upgradeable(_tokenAddress).transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        //Store it.
        StakingStorage.setERC20TokensStored(_tokenAddress, _reciever, _amount);

        emit ERC20Deposited(_tokenAddress, msg.sender, _reciever, _amount);
    }

    function verifyHash(
        bytes32 _hash,
        Signature calldata signature
    ) internal pure returns (address) {
        bytes32 messageDigest = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
        );

        return ecrecover(messageDigest, signature.v, signature.r, signature.s);
    }

    function withdrawERC20(
        WithdrawRequest[] calldata _withdrawRequests
    ) public {
        for (uint256 i = 0; i < _withdrawRequests.length; i++) {
            WithdrawRequest calldata _withdrawRequest = _withdrawRequests[i];
            address _tokenAddress = _withdrawRequest.tokenAddress;

            uint256 _amountStored = StakingStorage.getERC20TokensStored(_tokenAddress, msg.sender);

            if (_withdrawRequest.stored) {
                //It's stored in the contract
                //Permissioned by chain

                require(
                    _amountStored >= _withdrawRequest.amount,
                    "You don't have enough stored to withdraw."
                );

                StakingStorage.setERC20TokensStored(_tokenAddress, msg.sender, _amountStored - _withdrawRequest.amount);

                //Send it back
                IERC20Upgradeable(_tokenAddress).transfer(
                    msg.sender,
                    _withdrawRequest.amount
                );
                
                emit ERC20Withdrawn( _tokenAddress,  _withdrawRequest.reciever,  _withdrawRequest.amount);
            } else {
                //Not stored
                //Permissioned by admin

                //Compute that sig is correct
                //verifyHash returns the signer of this message.
                //message is a hash of three pieces of data: nonce, tokenAddress, amount, and the user.
                address _signer = verifyHash(keccak256(abi.encodePacked(_withdrawRequest.nonce, _withdrawRequest.tokenAddress, _withdrawRequest.amount, _withdrawRequest.reciever)), _withdrawRequest.signature);

                //Require they are a valid signer.
                require(IERC20Consumer(_tokenAddress).isAdmin(_signer), "Not a valid signed message.");

                //Make sure they aren't using sig twice.
                require(!StakingStorage.getUsedNonce(_withdrawRequest.nonce), "Nonce already used.");

                //Store nonce as used.
                StakingStorage.setUsedNonce(_withdrawRequest.nonce, true);

                //Mint the token
                IERC20Consumer(_tokenAddress).mintFromWorld(_withdrawRequest.reciever, _withdrawRequest.amount);

                emit ERC20Withdrawn( _tokenAddress,  _withdrawRequest.reciever,  _withdrawRequest.amount);
            }
        }
    }
}