// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "../interfaces/IERC20.sol";
import {DiamondLibrary} from "../libs/DiamondLibrary.sol";


contract ERC20Facet is IERC20 {

    function name() external view override returns (string memory) {
        DiamondLibrary.DiamondStorage storage ds = DiamondLibrary.diamondStorage();
        return ds._name;
    }

    function symbol() external view override returns (string memory) {
        DiamondLibrary.DiamondStorage storage ds = DiamondLibrary.diamondStorage();
        return ds._symbol;
    }

    function decimals() external view override returns (uint8) {
        DiamondLibrary.DiamondStorage storage ds = DiamondLibrary.diamondStorage();
        return ds._decimal;
    }

    function totalSupply() external view override returns (uint256) {
        DiamondLibrary.DiamondStorage storage ds = DiamondLibrary.diamondStorage();
        return ds._totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        DiamondLibrary.DiamondStorage storage ds = DiamondLibrary.diamondStorage();
        return ds._balances[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        DiamondLibrary.DiamondStorage storage ds = DiamondLibrary.diamondStorage();
        return ds._allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        DiamondLibrary.DiamondStorage storage ds = DiamondLibrary.diamondStorage();
        ds._allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        DiamondLibrary.DiamondStorage storage ds = DiamondLibrary.diamondStorage();
        require(to != address(0), "Cannot transfer to zero address");
        require(ds._balances[msg.sender] >= amount, "Insufficient balance");

        ds._balances[msg.sender] -= amount;
        ds._balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        DiamondLibrary.DiamondStorage storage ds = DiamondLibrary.diamondStorage();
        require(to != address(0), "Cannot transfer to zero address");
        require(ds._balances[from] >= amount, "Insufficient balance");
        require(ds._allowances[from][msg.sender] >= amount, "Insufficient allowance");

        ds._balances[from] -= amount;
        ds._balances[to] += amount;
        ds._allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }
    
    function mint(uint256 amount) external {
        DiamondLibrary.DiamondStorage storage ds = DiamondLibrary.diamondStorage();
        ds._totalSupply += amount;
        ds._balances[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(address from, uint256 amount) external {
        DiamondLibrary.DiamondStorage storage ds = DiamondLibrary.diamondStorage();
        require(msg.sender == ds._owner || msg.sender == from, "Only owner or holder can burn");
        require(ds._balances[from] >= amount, "Insufficient balance");

        ds._balances[from] -= amount;
        ds._totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }
}
