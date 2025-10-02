//SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {ISwap} from "../interfaces/ISwap.sol";
import "../../multiSigTokenDiamond/libs/multiSigTokenLibrary.sol";


contract SwapFacet is ISwap{

    function swapEthToToken() external payable{
       uint swappedAmount = MultiSigTokenUtils.swapEthToToken();
       emit SwapExecuted(msg.sender,msg.value, swappedAmount);
    }
    receive()external payable{}

    function withdrawEth() external payable{
        MultiSigTokenUtils.withdrawEth();
    }
}