// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Donation_Dao {
    enum  Status{ ACTIVE, SUCCESSFUL, REJECTED, FAILED }
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
    mapping(address=> Campaign) public usersCampaigns;
    uint private counter = 0;

    function createNewCampaign(string memory campaignTitle, string memory description, uint target, uint validityPeriod) external {
        validateInputs(campaignTitle, description,target, validityPeriod);
        Campaign memory newCampaign = Campaign({
            title:campaignTitle,
            description:description,
            validityPeriod:validityPeriod,
            goal:target,
            creator: msg.sender,
            id: counter+1001,
            status:Status.ACTIVE,
            totalRaised:0
        });
        usersCampaigns[msg.sender] = newCampaign;
        counter = counter+1;
    }

    function validateInputs(string memory campaignTitle, string memory description, uint goalSet,uint validityPeriod) private pure {
        require(bytes(campaignTitle).length> 0,"Title cannot be blank");
        require(bytes(description).length> 0,"Description cannot be blank");
        require(goalSet >0,"Target price must be greater than 0");
        require(validityPeriod > 0,"validity time must be in future");
    }
    function getTotalCampaigns() external returns(uint){
        return counter;
    }
}
