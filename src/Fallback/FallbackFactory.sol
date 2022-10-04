// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../BaseLevel.sol";
import "./Fallback.sol";

contract FallbackFactory is Level {
    function createInstance(address _player)
        public
        payable
        override
        returns (address)
    {
        _player; // Need to understand this line. Most likely creating a private storage variable of type address
        Fallback instance = new Fallback();
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player)
        public
        override
        returns (bool)
    {
        Fallback instance = Fallback(_instance);
        return instance.owner() == _player && address(instance).balance == 0;
    }
}
