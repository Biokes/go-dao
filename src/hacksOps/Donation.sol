    // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";

struct Campaign {
    string title;
    string description;
    uint256 validityPeriod;
    uint256 goal;
    uint256 totalRaised;
    Status status;
    uint256 id;
}

enum Status {
    ACTIVE,
    SUCCESSFUL,
    REJECTED,
    FAILED
}

error INVALID_DATA();

contract Donation_Dao {
    error InvalidID();

    mapping(address => Campaign[]) public usersCampaigns;
    uint256 private counter = 0;

    function createNewCampaign(
        string memory campaignTitle,
        string memory description,
        uint256 target,
        uint256 validityPeriod
    ) external returns (Campaign memory) {
        validateInputs(campaignTitle, description, target, validityPeriod);
        uint256 _id = counter++ + 1001;
        Campaign memory newCampaign = Campaign({
            title: campaignTitle,
            description: description,
            validityPeriod: validityPeriod,
            goal: target,
            id: _id,
            status: Status.ACTIVE,
            totalRaised: 0
        });
        usersCampaigns[msg.sender].push(newCampaign);
        return newCampaign;
    }

    function validateInputs(
        string memory campaignTitle,
        string memory description,
        uint256 goalSet,
        uint256 validityPeriod
    ) private pure {
        require(bytes(campaignTitle).length > 0, "Title cannot be blank");
        require(bytes(description).length > 0, "Description cannot be blank");
        require(goalSet > 0, "Target price must be greater than 0");
        require(validityPeriod > 0, "validity time must be in future");
    }

    function getTotalCampaigns() external view returns (uint256) {
        return counter;
    }

    function updateCampaign(uint256 _id, string memory title, string memory description)
        external
        returns (Campaign memory)
    {
        require(usersCampaigns[msg.sender].length > 0, "No campaigns found for this user");
        validateUpdate(title, description);
        for (uint256 i = 0; i < usersCampaigns[msg.sender].length; i++) {
            if (usersCampaigns[msg.sender][i].id == _id) {
                console.log("Found camapign");
                usersCampaigns[msg.sender][i].title = title;
                usersCampaigns[msg.sender][i].description = description;
                return usersCampaigns[msg.sender][i];
            }
        }
        revert INVALID_DATA();
    }

    function validateUpdate(string memory title, string memory description) private pure {
        require(bytes(title).length > 0, "Title cannot be blank");
        require(bytes(description).length > 0, "Description cannot be blank");
    }

    fallback() external payable {}

    receive() external payable {}

    function donateToCampaign(uint256 campaignId, address owner) external payable {
        require(msg.value > 0, "No ETH sent");
        if (usersCampaigns[owner].length == 0) {
            revert INVALID_DATA();
        }
        for (uint256 loopCounter; loopCounter < usersCampaigns[owner].length; loopCounter++) {
            if (usersCampaigns[owner][loopCounter].id == campaignId) {
                usersCampaigns[owner][loopCounter].totalRaised += msg.value;
                return;
            }
        }
        revert INVALID_DATA();
    }
}
