//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.28;
import {DiamondLibrary} from "./libs/DiamondLibrary.sol";

contract ERC20Diamond{
    DiamondLibrary.DiamondStorage public token;
    mapping (bytes4=> address) facetsAddress;
    
}