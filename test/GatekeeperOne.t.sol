// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {GatekeeperOneFactory} from "../src/GatekeeperOne/GatekeeperOneFactory.sol";
import {GatekeeperOne} from "../src/GatekeeperOne/GatekeeperOne.sol";
import {GatekeeperOneExploit} from "../src/GatekeeperOne/GatekeeperOneExploit.sol";

contract GatekeeperOneTest is Test {
    Ethernaut ethernaut;
    address player;

    function setUp() public {
        ethernaut = new Ethernaut();
        player = address(uint160(0x1000000000000001));
        vm.label(player, "Player");
    }

    function testExploit() public {
        // Register level with Ethernaut contract
        GatekeeperOneFactory gatekeeperOneFactory = new GatekeeperOneFactory();
        ethernaut.registerLevel(gatekeeperOneFactory);

        // Get a new level instance

        vm.startPrank(player, player); // 2nd parameter here sets tx.origin value
        address levelAddress = ethernaut.createLevelInstance(
            gatekeeperOneFactory
        );
        GatekeeperOne gatekeeperOneInstance = GatekeeperOne(
            payable(levelAddress)
        );

        // Simulate exploit

        GatekeeperOneExploit exploitContract = new GatekeeperOneExploit();
        bytes8 key = bytes8(uint64(uint160(player))); // work backwords from the conditions
        // in gate 3
        exploitContract.exploit(key, gatekeeperOneInstance);

        // Submit level
        bool levelSuccessFullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessFullyPassed);
    }
}
