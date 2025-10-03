//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;


interface ISwap{
    event WithdrawETH(address indexed owner, uint256 timeWIthdrawn);
    event SwapExecuted(address caller, uint ethSwapped, uint amountRecieved);
    function swapEthToToken() external payable;

}