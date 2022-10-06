// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {TelephoneFactory} from "../src/Telephone/TelephoneFactory.sol";
import {Telephone} from "../src/Telephone/Telephone.sol";
import {TelephoneExploit} from "../src/Telephone/TelephoneExploit.sol";

contract TelephoneTest is Test {
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
        TelephoneFactory telephoneFactory = new TelephoneFactory();
        ethernaut.registerLevel(telephoneFactory);

        // Get a new level instance
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        Telephone telephoneInstance = Telephone(payable(levelAddress));

        // Simulate exploit

        TelephoneExploit telephoneExploit = new TelephoneExploit(
            address(telephoneInstance)
        );
        telephoneExploit.changeOwner(player);

        // Submit level
        bool levelSuccessFullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessFullyPassed);
    }
}
