// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibAccessControlRoles} from "../libraries/LibAccessControlRoles.sol";

contract CollectionAccessControlFacet {
    
    function grantCollectionAdmin() external {

    }

    function grantCollectionRoleGranter() external {
        //Check that msg sender is collection owner
        //Or has a signed message from a spellcaster trusted wallet via LibSpellcasterGM.isTrustedSigner
        //If so, call LibAccessControlRoles.grantRoleGranter
        
        //The implementation of checking signatures will follow how MetaTxFacet works. 
        //Extend EIP712, create a CollectionRole struct with the role hash/nonce/assignee instead of the ForwardRequest struct. 
        //Pack assignee+nonce by setting nonce to uint96. Then verify, etc. 
        //You will call LibSpellcasterGM.useNonce(signer, nonce) which will require the nonce is unused and then set it 
    }
}
