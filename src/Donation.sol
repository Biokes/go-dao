// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Donation_Dao {
    struct Campaign{
        string title;
        string description;
        uint target;
        uint validityPeriod;

    }
    mapping(address=> Campaign) public usersCampaigns;
    function createNewCampaign(string memory campaignTitle, string memory description, uint target,uint validityPeriod) public {
        validateInputs(campaignTitle,description,target,validityPeriod);
        Campaign memory newCampaign = Campaign({
            title:campaignTitle,
            description:description,
            target:target,
            validityPeriod:validityPeriod
        });
        usersCampaigns[msg.sender] = newCampaign;
    }
    function validateInputs(string memory campaignTitle, string memory description, uint target,uint validityPeriod) private pure {
        require(bytes(campaignTitle).length> 0,"Title cannot be blank");
        require(bytes(description).length> 0,"Description cannot be blank");
        require(target>0,"Target price must be greater than 0");
        require(validityPeriod > 0,"validity time must be in future");
    }
    function getTotalCampaigns() public pure returns(uint){
        return 0;
    }
}
