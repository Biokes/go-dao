// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.28;

library DiamondLibrary {
    struct ERC20Storage {
        string _name;
        string _symbol;
        uint8 _decimal;
        uint256 _totalSupply;
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        address _owner;
    }
}
