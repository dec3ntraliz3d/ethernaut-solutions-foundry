// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {ReentranceFactory} from "../src/Reentrance/ReentranceFactory.sol";
import {Reentrance} from "../src/Reentrance/Reentrance.sol";
import {ReentranceExploit} from "../src/Reentrance/ReentranceExploit.sol";

contract ReentranceTest is Test {
    Ethernaut ethernaut;
    address payable player;

    function setUp() public {
        ethernaut = new Ethernaut();
        player = payable(
            address(uint160(uint256(keccak256(abi.encodePacked("player")))))
        );
        vm.label(player, "Player");
        vm.deal(player, 2 ether);
    }

    function testExploit() public {
        // Register level with Ethernaut contract
        ReentranceFactory reentranceFactory = new ReentranceFactory();
        ethernaut.registerLevel(reentranceFactory);

        // Get a new level instance
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            reentranceFactory
        );
        Reentrance reentranceInstance = Reentrance(payable(levelAddress));

        // Simulate exploit
        ReentranceExploit reentranceExploit = new ReentranceExploit(
            reentranceInstance
        );
        reentranceExploit.exploit{value: address(reentranceInstance).balance}();

        // Submit level
        bool levelSuccessFullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessFullyPassed);
    }
}
