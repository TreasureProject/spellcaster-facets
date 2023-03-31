
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibSpellcasterGM} from "../libraries/LibSpellcasterGM.sol";

contract SpellcasterGM {
    function addTrustedSigner(address _account) external {
        LibSpellcasterGM.setTrustedSigner(_account, true);
    }
}