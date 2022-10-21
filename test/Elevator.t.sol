// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {ElevatorFactory} from "../src/Elevator/ElevatorFactory.sol";
import {Elevator} from "../src/Elevator/Elevator.sol";
import {ElevatorExploit} from "../src/Elevator/ElevatorExploit.sol";

contract ElevatorTest is Test {
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
        ElevatorFactory elevatorFactory = new ElevatorFactory();
        ethernaut.registerLevel(elevatorFactory);

        // Get a new level instance
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            elevatorFactory
        );
        Elevator elevatorInstance = Elevator(payable(levelAddress));

        // Simulate exploit
        ElevatorExploit exploitContract = new ElevatorExploit();
        exploitContract.exploit(elevatorInstance);

        // Submit level
        bool levelSuccessFullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessFullyPassed);
    }
}
