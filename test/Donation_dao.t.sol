// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Donation_Dao} from "../src/Donation.sol";

contract CounterTest is Test {
    Donation_Dao public dao;

    function setUp() public {
        dao = new Donation_Dao();
    }
    function testUserCanCreateCampaigns() private {
        dao = new Donation_Dao();
        dao.createNewCampaign("campaign title", "campaign description",1,1000000);
        assertEq(dao.getTotalCampaigns(),1);
    }
}
