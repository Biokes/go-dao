// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Donation_Dao} from "../src/Donation.sol";

contract CounterScript is Script {
    Donation_Dao public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        counter = new Donation_Dao();
        vm.stopBroadcast();
    }
}
