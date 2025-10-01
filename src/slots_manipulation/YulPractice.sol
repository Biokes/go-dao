// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Yul101{
    address public owner;
    bool public isOwned;
    constructor(bool _isOwned){
        isOwned = _isOwned;
        owner=msg.sender;
    }

    function changeOwner(address newOwner) external {
        assembly {
            sstore(owner.slot,newOwner)
        }
    }
}