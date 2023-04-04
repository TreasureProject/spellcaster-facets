// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibSpellcasterGM } from "../libraries/LibSpellcasterGM.sol";
import { ISpellcasterGM } from "../interfaces/ISpellcasterGM.sol";

contract SpellcasterGM is ISpellcasterGM{
    /**
     * @inheritdoc ISpellcasterGM
     */
    function addTrustedSigner(address _account) external {
        LibSpellcasterGM.setTrustedSigner(_account, true);
    }
}
