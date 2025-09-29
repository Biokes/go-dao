// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

import {IERC20} from "./IERC20.sol";

// your goal is to drain the MarketPlace of its vault tokens completely
contract MarketPlace {
    IERC20 public vaultTokens;

    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether; // <-- 1e18

    constructor(address vaultToken) {
        vaultTokens = IERC20(vaultToken);
    }

    function isComplete() public view returns (bool) {
        return vaultTokens.balanceOf(address(this)) == 0;
    }

    function drained() public view returns (bool) {
        return address(this).balance == 0;
    }

    function buy(uint256 numTokens) public payable {
        bool s = vaultTokens.transferFrom(msg.sender, address(this), numTokens * PRICE_PER_TOKEN);
        require(s);
        balanceOf[msg.sender] += numTokens;
    }

    function sell(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);
        balanceOf[msg.sender] -= numTokens;
        vaultTokens.transfer(msg.sender, numTokens * PRICE_PER_TOKEN);
    }

    function WithrawFunds() public {
        require(isComplete(), "You can't get your money back");
        (bool s,) = msg.sender.call{value: address(this).balance}("");
        require(s);
    }
}
