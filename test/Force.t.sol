// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {ForceFactory} from "../src/Force/ForceFactory.sol";
import {Force} from "../src/Force/Force.sol";
import {ForceExploit} from "../src/Force/ForceExploit.sol";

contract ForceTest is Test {
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
        ForceFactory forceFactory = new ForceFactory();
        ethernaut.registerLevel(forceFactory);

        // Get a new level instance
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(forceFactory);
        Force forceInstance = Force(payable(levelAddress));

        // Simulate exploit

        ForceExploit exploit = new ForceExploit();
        exploit.exploit{value: 1 wei}(payable(address(forceInstance)));

        // Submit level

        bool levelSuccessFullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();

        assert(levelSuccessFullyPassed);
    }
}
