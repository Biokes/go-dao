// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Donation.sol";
import {Donation_Dao} from "../src/Donation.sol";
import {Test} from "forge-std/Test.sol";

contract DonationTest is Test {
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
        dao.createNewCampaign("", "", 2, 0);
        assertEq(0, dao.getTotalCampaigns());
        vm.expectRevert(bytes("Description cannot be blank"));
        dao.createNewCampaign("Title", "", 2, 0);
        assertEq(0, dao.getTotalCampaigns());
        vm.expectRevert(bytes("Target price must be greater than 0"));
        dao.createNewCampaign("Title", "description", 0, 0);
        assertEq(0, dao.getTotalCampaigns());
        vm.expectRevert(bytes("validity time must be in future"));
        dao.createNewCampaign("Title", "description", 2, 0);
        assertEq(0, dao.getTotalCampaigns());
        dao.createNewCampaign("campaign title", "campaign description", 50, 1000000);
        assertEq(1, dao.getTotalCampaigns());
    }

    function test_donationsCanBeUpdated() public {

        address creator = address(0xABCD);
        vm.prank(creator);
        Campaign memory campaign = dao.createNewCampaign("title", "description", 3, 100000000);
        assertEq(1, dao.getTotalCampaigns());
        vm.prank(creator);
        vm.expectRevert(bytes("Title cannot be blank"));
        dao.updateCampaign(campaign.id, "", "");
        vm.prank(creator);
        vm.expectRevert(bytes("Description cannot be blank"));
        dao.updateCampaign(campaign.id, "title 01", "");
        vm.prank(creator);
        Campaign memory updatedCampaign = dao.updateCampaign(campaign.id, "title 01", "desc");
        assertEq("title 01", updatedCampaign.title);
        assertEq("desc", updatedCampaign.description);
        assert(campaign.creator == updatedCampaign.creator);
        assert(campaign.totalRaised == updatedCampaign.totalRaised);
        assert(campaign.goal == updatedCampaign.goal);
        assert(campaign.id == updatedCampaign.id);
        assert(campaign.status == updatedCampaign.status);
        assert(campaign.validityPeriod == updatedCampaign.validityPeriod);
//        address creator = address(0xABCD);
//        vm.prank(creator);
//        Campaign memory campaign = dao.createNewCampaign("title", "description", 3, 100000000);
//        assertEq(1, dao.getTotalCampaigns());
//        vm.prank(creator);
//        vm.expectRevert(bytes("Title cannot be blank"));
//        dao.updateCampaign(campaign.id, "", "");
//        vm.prank(creator);
//        vm.expectRevert(bytes("Description cannot be blank"));
//        dao.updateCampaign(campaign.id, "title 01", "");
//        assertEq(1,dao.getTotalCampaigns());
//        vm.prank(creator);
//        Campaign memory updatedCampaign = dao.updateCampaign(campaign.id, "title 01", "desc");
//        assertEq("title 01", updatedCampaign.title);
//        assertEq("desc", updatedCampaign.description);
//        assert(campaign.creator==updatedCampaign.creator);
//        assert(campaign.totalRaised==updatedCampaign.totalRaised);
//        assert(campaign.goal==updatedCampaign.goal);
//        assert(campaign.id==updatedCampaign.id);
//        assert(campaign.status== updatedCampaign.status);
//        assert(campaign.validityPeriod==updatedCampaign.validityPeriod);
    }

}
