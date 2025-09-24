// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Donation.sol";
import {Donation_Dao} from "../src/Donation.sol";
import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

contract DonationTest is Test {
    Donation_Dao public dao;

    function setUp() public {
        dao = new Donation_Dao();
    }

    function logCampaign(Campaign memory c) private pure {
        console.log("--- Campaign Info ---");
        console.log("ID:", c.id);
        console.log("Title:", c.title);
        console.log("Description:", c.description);
        console.log("Goal:", c.goal);
        console.log("Total Raised:", c.totalRaised);
        console.log("Validity Period:", c.validityPeriod);
        console.log("Status:", uint256(c.status));
        console.log("--- Campaign Info ---");
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
        Campaign memory campaign = dao.createNewCampaign("title", "description", 3, 100000000);
        //  logCampaign(campaign);
        vm.expectRevert(bytes("Title cannot be blank"));
        dao.updateCampaign(campaign.id, "", "");
        vm.expectRevert(bytes("Description cannot be blank"));
        dao.updateCampaign(campaign.id, "title 01", "");
        assertEq(1, dao.getTotalCampaigns());
        //  logCampaign(campaign);
        Campaign memory updatedCampaign = dao.updateCampaign(campaign.id, "title 01", "desc");
        assertEq("title 01", updatedCampaign.title);
        assertEq("desc", updatedCampaign.description);
        assertEq(campaign.totalRaised, updatedCampaign.totalRaised);
        assertEq(campaign.id, updatedCampaign.id);
        assertEq(uint256(campaign.status), uint256(updatedCampaign.status));
        assertEq(campaign.validityPeriod, updatedCampaign.validityPeriod);
        assertEq(campaign.goal, updatedCampaign.goal);
    }

    function test_campaignsCanbeSentEther() public {
        address user101 = address(0x123456);
        vm.prank(user101);
        Campaign memory campaign = dao.createNewCampaign("title", "description", 3 ether, 100000000);
        address user102 = address(0x12345);
        vm.deal(user101, 0 ether);
        vm.prank(user102);
        vm.deal(user102, 1.8 ether);
        dao.donateToCampaign{value: 0.008934 ether}(campaign.id, user101);
        assertEq(address(dao).balance, 0.008934 ether);
    }
}
// TODO
//- Create a new donation campaign ✅
//- Store and manage multiple donation campaigns✅
//- Assign a unique ID to each campaign✅
//- Receive and hold ETH donations from users ✅

//- Track how much each donor has contributed to a campaign
//- Accumulate total donations for each campaign
//- Restrict donations after the campaign deadline
//- Designate a trusted escrow address at deployment
//- Enable the escrow to approve fund release to campaign creator
//- Enable the escrow to reject a campaign
//- Transfer funds to campaign creator when approved by escrow
//- Unlock refund rights to donors if campaign fails or is rejected
//- Allow donors to withdraw their ETH contributions as refunds
//- Emit events for major actions (create, donate, release, refund, reject)
//- Expose campaign data to users (title, goal, deadline, etc.)
//- Report current campaign status (active, successful, failed, rejected)
//- Protect state-changing functions using modifiers (e.g. onlyEscrow)
//- Prevent reentrancy attacks during ETH withdrawals
//- Provide public access to individual donor contributions
//- Automatically update campaign status based on goal or time
