// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import {StakingRewards, IERC20} from "../../src/hackOps/Staking.sol";
import {MockERC20} from "test/hackOps/MockErc20.sol";

contract StakingTest is Test {
    StakingRewards staking;
    MockERC20 stakingToken;
    MockERC20 rewardToken;

    address owner = makeAddr("owner");
    address bob = makeAddr("bob");
    address dso = makeAddr("dso");

    function setUp() public {
        vm.startPrank(owner);
        stakingToken = new MockERC20();
        rewardToken = new MockERC20();
        staking = new StakingRewards(address(stakingToken), address(rewardToken));
        vm.stopPrank();
    }

    function test_alwaysPass() public {
        assertEq(staking.owner(), owner, "Wrong owner set");
        assertEq(address(staking.stakingToken()), address(stakingToken), "Wrong staking token address");
        assertEq(address(staking.rewardsToken()), address(rewardToken), "Wrong reward token address");
        assertTrue(true);
    }

    function test_cannot_stake_amount0() public {
        deal(address(stakingToken), bob, 10e18);
        // start prank to assume user is making subsequent calls
        vm.startPrank(bob);
        IERC20(address(stakingToken)).approve(address(staking), type(uint256).max);
        // we are expecting a revert if we deposit/stake zero
        vm.expectRevert("amount = 0");
        staking.stake(0);
        vm.stopPrank();
    }

    function test_can_stake_successfully() public {
        deal(address(stakingToken), bob, 10e18);
        // start prank to assume user is making subsequent calls
        vm.startPrank(bob);
        IERC20(address(stakingToken)).approve(address(staking), type(uint256).max);
        uint256 _totalSupplyBeforeStaking = staking.totalSupply();
        staking.stake(5e18);
        assertEq(staking.balanceOf(bob), 5e18, "Amounts do not match");
        assertEq(staking.totalSupply(), _totalSupplyBeforeStaking + 5e18, "totalsupply didnt update correctly");
    }

    function test_cannot_withdraw_amount0() public {
        vm.prank(bob);
        vm.expectRevert("amount = 0");
        staking.withdraw(0);
    }

    function test_can_withdraw_deposited_amount() public {
        test_can_stake_successfully();
        uint256 userStakebefore = staking.balanceOf(bob);
        uint256 totalSupplyBefore = staking.totalSupply();
        staking.withdraw(2e18);
        assertEq(staking.balanceOf(bob), userStakebefore - 2e18, "Balance didnt update correctly");
        assertLt(staking.totalSupply(), totalSupplyBefore, "total supply didnt update correctly");
    }

    function test_notify_Rewards() public {
        // check that it reverts if non owner tried to set duration
        vm.expectRevert("not authorized");
        staking.setRewardsDuration(1 weeks);

        // simulate owner calls setReward successfully
        vm.prank(owner);
        staking.setRewardsDuration(1 weeks);
        assertEq(staking.duration(), 1 weeks, "duration not updated correctly");
        // log block.timestamp
        console.log("current time", block.timestamp);
        // move time foward
        vm.warp(block.timestamp + 200);
        // notify rewards
        deal(address(rewardToken), owner, 100 ether);
        vm.startPrank(owner);
        IERC20(address(rewardToken)).transfer(address(staking), 100 ether);

        // trigger revert
        vm.expectRevert("reward rate = 0");
        staking.notifyRewardAmount(1);

        // trigger second revert
        vm.expectRevert("reward amount > balance");
        staking.notifyRewardAmount(200 ether);

        // trigger first type of flow success
        staking.notifyRewardAmount(100 ether);
        assertEq(staking.rewardRate(), uint256(100 ether) / uint256(1 weeks));
        assertEq(staking.finishAt(), uint256(block.timestamp) + uint256(1 weeks));
        assertEq(staking.updatedAt(), block.timestamp);

        // trigger setRewards distribution revert
        vm.expectRevert("reward duration not finished");
        staking.setRewardsDuration(1 weeks);
    }

    function test_notifyRewardAmount_elseBranch() public {
        // Setup: Owner funds reward token and sets initial reward period
        deal(address(rewardToken), owner, 200 ether);
        vm.startPrank(owner);
        rewardToken.transfer(address(staking), 100 ether);
        staking.setRewardsDuration(100);
        staking.notifyRewardAmount(100 ether); // finishAt = now + 100
        vm.stopPrank();

        // Advance time but stay BEFORE finishAt
        vm.warp(block.timestamp + 40); // now at t=40, finishAt=100 → still active

        // Add more rewards while period is still active → triggers ELSE branch
        vm.startPrank(owner);
        rewardToken.transfer(address(staking), 50 ether); // total balance = 150 ether
        staking.notifyRewardAmount(50 ether);
        vm.stopPrank();

        // Verify it used the else branch logic:
        // remainingRewards = (100 - 40) * (100 ether / 100) = 60 ether
        // new rewardRate = (50 ether + 60 ether) / 100 = 1.1 ether per sec
        uint256 expectedRewardRate = (50 ether + 60 ether) / 100;
        assertEq(staking.rewardRate(), expectedRewardRate, "rewardRate incorrect in else branch");

        // Verify finishAt was reset to now + duration
        assertEq(staking.finishAt(), block.timestamp + 100, "finishAt not updated correctly");
    }

    function test_getReward_pays_out_positive_reward() public {
        // Fund tokens
        deal(address(stakingToken), bob, 10e18);
        deal(address(rewardToken), owner, 100 ether);

        // Bob stakes
        vm.startPrank(bob);
        stakingToken.approve(address(staking), type(uint256).max);
        staking.stake(10e18);
        vm.stopPrank();

        // Owner sets rewards
        vm.startPrank(owner);
        rewardToken.transfer(address(staking), 100 ether);
        staking.setRewardsDuration(100);
        staking.notifyRewardAmount(100 ether);
        vm.stopPrank();

        // Advance time to accrue rewards
        vm.warp(block.timestamp + 50);

        // Now call getReward — this will hit lines 84-88 and branch 86 (true)
        uint256 bobBalanceBefore = rewardToken.balanceOf(bob);
        vm.prank(bob);
        staking.getReward();
        assertGt(rewardToken.balanceOf(bob), bobBalanceBefore, "Reward not paid");
    }

    function test_getReward_calls_earned_explicitly() public {
        // Fund tokens
        deal(address(stakingToken), bob, 10e18);
        deal(address(rewardToken), owner, 100 ether);

        // Bob stakes
        vm.startPrank(bob);
        stakingToken.approve(address(staking), type(uint256).max);
        staking.stake(10e18);
        vm.stopPrank();

        // Owner sets up rewards
        vm.startPrank(owner);
        rewardToken.transfer(address(staking), 100 ether);
        staking.setRewardsDuration(100);
        staking.notifyRewardAmount(100 ether);
        vm.stopPrank();
        // Advance time to accrue rewards
        vm.warp(block.timestamp + 50);

        // Explicitly call earned() to check pending reward
        uint256 pending = staking.earned(bob);
        assertGt(pending, 0, "No rewards accrued");

        // Record balance before claim
        uint256 balanceBefore = rewardToken.balanceOf(bob);

        // Claim via getReward()
        vm.startPrank(bob);
        staking.getReward();

        assertEq(rewardToken.balanceOf(bob), balanceBefore + pending, "Reward mismatch");
        assertEq(staking.rewards(bob), 0, "Rewards not cleared after claim");
    }

    function test_view_functions_return_correct_values() public {
        // Setup: Initialize reward period
        deal(address(rewardToken), owner, 100 ether);
        vm.startPrank(owner);
        rewardToken.transfer(address(staking), 100 ether);
        staking.setRewardsDuration(100);
        staking.notifyRewardAmount(100 ether);
        uint256 initialFinishAt = staking.finishAt(); // = block.timestamp + 100
        vm.stopPrank();

        // Test 1: lastTimeRewardApplicable() returns current time when active
        assertEq(staking.lastTimeRewardApplicable(),block.timestamp,"lastTimeRewardApplicable should return current time during active rewards");

        // Add staker BEFORE reward period ends
        deal(address(stakingToken), bob, 10e18);
        vm.startPrank(bob);
        stakingToken.approve(address(staking), type(uint256).max);
        staking.stake(10e18);
        vm.stopPrank();

        // Advance time MID-WAY through reward period (not beyond!)
        vm.warp(block.timestamp + 50); // Now at 50% of reward period

        // Test 2: rewardPerToken() increases with active stakers
        uint256 initialRewardPerToken = staking.rewardPerTokenStored();
        uint256 currentRewardPerToken = staking.rewardPerToken();
        assertTrue(currentRewardPerToken > initialRewardPerToken,"rewardPerToken should increase when rewards accrue with stakers");

        // Test 3: lastTimeRewardApplicable() still returns current time (active period)
        assertEq(staking.lastTimeRewardApplicable(),block.timestamp,"lastTimeRewardApplicable should return current time during active rewards");

        // Advance time BEYOND reward period
        vm.warp(initialFinishAt + 10);

        // Test 4: lastTimeRewardApplicable() returns finishAt when expired
        assertEq(staking.lastTimeRewardApplicable(),initialFinishAt,"lastTimeRewardApplicable should return finishAt after expiration");

        // Test 5: rewardPerToken() stops increasing after expiration
        uint256 finalRewardPerToken = staking.rewardPerToken();
        vm.warp(block.timestamp + 100); // Advance more time
        assertEq(staking.rewardPerToken(), finalRewardPerToken, "rewardPerToken should not increase after reward period ends");
    }
}
