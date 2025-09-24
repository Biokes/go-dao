// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.26;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20("MockToken", "MKT") {}
