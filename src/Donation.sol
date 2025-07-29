// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct Campaign{
    string title;
    string description;
    uint validityPeriod;
    uint goal;
    address creator;
    uint totalRaised;
    Status status;
    uint id;
}

enum  Status{ ACTIVE, SUCCESSFUL, REJECTED, FAILED }

contract Donation_Dao {
    error InvalidID();
    mapping(uint=> Campaign) public usersCampaigns;
    uint private counter = 0;
    function createNewCampaign(string memory campaignTitle, string memory description,
                               uint target, uint validityPeriod) external returns (Campaign memory){
        validateInputs(campaignTitle, description,target, validityPeriod);
        uint id = counter+1001;
        Campaign memory newCampaign = Campaign({
            title:campaignTitle,
            description:description,
            validityPeriod:validityPeriod,
            goal:target,
            creator: msg.sender,
            id: counter,
            status:Status.ACTIVE,
            totalRaised:0
        });
        usersCampaigns[id] = newCampaign;
        uint counterInc= counter+1;
        counter = counterInc;
        return newCampaign;
    }

    function validateInputs(string memory campaignTitle, string memory description,
                            uint goalSet,uint validityPeriod) private pure {
        require(bytes(campaignTitle).length> 0,"Title cannot be blank");
        require(bytes(description).length> 0,"Description cannot be blank");
        require(goalSet >0,"Target price must be greater than 0");
        require(validityPeriod > 0,"validity time must be in future");
    }

    function getTotalCampaigns() external view returns(uint){
        return counter;
    }

    function updateCampaign(uint id, string memory title, string memory description)  external returns (Campaign memory) {
//        require(usersCampaigns[id].creator != address(0), "Invalid data passed");
        require(usersCampaigns[id].creator == msg.sender, "Unauthorised Access");
        validateUpdate(title,description);
        usersCampaigns[id].title= title;
        usersCampaigns[id].description= description;
        return usersCampaigns[id];
    }

    function validateUpdate( string memory title, string memory description) pure public{
        require(bytes(title).length> 0,"Title cannot be blank");
        require(bytes(description).length> 0,"Description cannot be blank");
    }
}

// TODO
//- Create a new donation campaign ✅
//- Store and manage multiple donation campaigns✅
//- Assign a unique ID to each campaign✅

//- Receive and hold ETH donations from users
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