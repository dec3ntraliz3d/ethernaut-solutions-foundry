// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {KingFactory} from "../src/King/KingFactory.sol";
import {King} from "../src/King/King.sol";
import {KingExploit} from "../src/King/KingExploit.sol";

contract KingTest is Test {
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
        KingFactory kingFactory = new KingFactory();
        ethernaut.registerLevel(kingFactory);

        // Get a new level instance
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            kingFactory
        );
        King kingInstance = King(payable(levelAddress));

        // Simulate exploit
        KingExploit kingExploit = new KingExploit();
        vm.deal(player, 2 ether);
        kingExploit.exploit{value: address(kingInstance).balance}(
            payable(address(kingInstance))
        );
        // Submit level
        bool levelSuccessFullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessFullyPassed);
    }
}
