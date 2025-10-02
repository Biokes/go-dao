//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;


interface ISwap{
    event SwapExecuted(address caller, uint ethSwapped, uint amountRecieved);
    function swapEthToToken() external payable;

}