// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Donation_Dao} from "../src/Donation.sol";

contract CounterTest is Test {
    Donation_Dao public dao;

    function setUp() public {
        dao = new Donation_Dao();
    }

    function test_userCanCreateCampaigns() public {
        assertEq(0, dao.getTotalCampaigns());
        dao.createNewCampaign("campaign title", "campaign description", 50, 1000000);
        assertEq(1, dao.getTotalCampaigns());
    }

    function test_invalidCreationFails() public {
        assertEq(0, dao.getTotalCampaigns());
        vm.expectRevert(bytes("Title cannot be blank"));
        dao.createNewCampaign("", "", 2 ether, 0);
        assertEq(0, dao.getTotalCampaigns());
        vm.expectRevert(bytes("Description cannot be blank"));
        dao.createNewCampaign("Title", "", 2 ether, 0);
        assertEq(0, dao.getTotalCampaigns());
        vm.expectRevert(bytes("Target price must be greater than 0"));
        dao.createNewCampaign("Title", "description", 0, 0);
        assertEq(0, dao.getTotalCampaigns());
        vm.expectRevert(bytes("validity time must be in future"));
        dao.createNewCampaign("Title", "description", 2, 0);
        assertEq(0, dao.getTotalCampaigns());
        dao.createNewCampaign("campaign title", "campaign description", 50, 1000000);
        assertEq(1,dao.getTotalCampaigns());
    }
}
