//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FacetInitializable} from "src/utils/FacetInitializable.sol";

import {LibEmitter} from "src/emitter/LibEmitter.sol";
import {LibEmitterStorage} from "src/emitter/LibEmitterStorage.sol";
import {IEmitter} from "src/interfaces/IEmitter.sol";
import {Modifiers} from "src/Modifiers.sol";
import {SupportsMetaTx} from "src/metatx/SupportsMetaTx.sol";

abstract contract EmitterBase is
    FacetInitializable,
    IEmitter,
    Modifiers,
    SupportsMetaTx
{
    function __EmitterBase_init() internal onlyFacetInitializing {
        LibEmitterStorage.layout().currentEmittingId = 1;
    }
}
