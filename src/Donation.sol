 // SPDX-License-Identifier: UNLICENSED
 pragma solidity ^0.8.13;
 import "forge-std/console.sol";

 struct Campaign{
     string title;
     string description;
     uint validityPeriod;
     uint goal;
     uint totalRaised;
     Status status;
     uint id;
 }

 enum  Status{ ACTIVE, SUCCESSFUL, REJECTED, FAILED }
error INVALID_DATA();
 contract Donation_Dao {
     error InvalidID();
     mapping(address=> Campaign[]) public usersCampaigns;
     uint private counter = 0;
     function createNewCampaign(string memory campaignTitle, string memory description,
                                uint target, uint validityPeriod) external returns (Campaign memory){
         validateInputs(campaignTitle, description,target, validityPeriod);
         uint _id = counter++ + 1001;
         Campaign memory newCampaign = Campaign({
             title:campaignTitle,
             description:description,
             validityPeriod:validityPeriod,
             goal:target,
             id: _id,
             status:Status.ACTIVE,
             totalRaised:0
         });
         usersCampaigns[msg.sender].push(newCampaign);
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

     function updateCampaign(uint _id, string memory title, string memory description)  external returns (Campaign memory) {
         require(usersCampaigns[msg.sender].length> 0, "No campaigns found for this user");
         validateUpdate(title,description);
         for(uint i = 0; i < usersCampaigns[msg.sender].length; i++){
             if(usersCampaigns[msg.sender][i].id == _id){
                console.log("Found camapign");
                 usersCampaigns[msg.sender][i].title = title;
                 usersCampaigns[msg.sender][i].description = description;
                 return usersCampaigns[msg.sender][i];
             }
         }
         revert INVALID_DATA();
     }

     function validateUpdate( string memory title, string memory description) pure private{
         require(bytes(title).length> 0,"Title cannot be blank");
         require(bytes(description).length> 0,"Description cannot be blank");
     }

     fallback() external payable {}
     
     receive() external payable {}

     function donateToCampaign(uint campaignId,address owner) external payable{
        require(msg.value > 0, "No ETH sent");
        if(usersCampaigns[owner].length == 0){
            revert INVALID_DATA();
        }
        for(uint loopCounter;loopCounter< usersCampaigns[owner].length;loopCounter++){
            if(usersCampaigns[owner][loopCounter].id == campaignId){
                usersCampaigns[owner][loopCounter].totalRaised += msg.value;
                return;
            }
        }
        revert INVALID_DATA();
     }
 }



