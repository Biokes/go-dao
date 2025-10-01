// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IERC20} from "../interfaces/IERC20.sol";
import {MultiSigTokenUtils} from "../libs/multiSigTokenLibrary.sol";

contract RafikTokenFacet is IERC20{
    function name() external view override returns (string memory) {
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
        return ds._name;
    }

    function symbol() external view override returns (string memory) {
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
        return ds._symbol;
    }

    function decimals() external view override returns (uint8) {
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
        return ds._decimal;
    }

    function totalSupply() external view override returns (uint256) {
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
        return ds._totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
        return ds._balances[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
        return ds._allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
        ds._allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
        require(to != address(0), "Cannot transfer to zero address");
        require(ds._balances[msg.sender] >= amount, "Insufficient balance");
        ds._balances[msg.sender] -= amount;
        ds._balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
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
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
        ds._totalSupply += amount;
        ds._balances[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(address from, uint256 amount) external {
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
        require(msg.sender == ds._owner || msg.sender == from, "Only owner or holder can burn");
        require(ds._balances[from] >= amount, "Insufficient balance");

        ds._balances[from] -= amount;
        ds._totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }
}