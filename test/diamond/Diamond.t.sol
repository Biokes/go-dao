// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.28;

// import "forge-std/Test.sol";
// import "../../src/erc20Diamond/Diamond.sol";
// import "../../src/erc20Diamond/facets/ERC20Facet.sol";
// import "../../src/erc20Diamond/DiamondCutInterface.sol";
// import "../../src/erc20Diamond/DiamondLoupeInterface.sol";

// contract DiamondTest is Test {
//     ERC20Diamond public diamond;
//     ERC20Facet public erc20Facet;

//     address public owner;
//     address public user1;
//     address public user2;

//     function setUp() public {
//         owner = address(this);
//         user1 = makeAddr("user1");
//         user2 = makeAddr("user2");

//         // Deploy the diamond
//         diamond = new ERC20Diamond();

//         // Deploy the ERC20Facet
//         erc20Facet = new ERC20Facet();

//         // Add ERC20Facet to diamond
//         IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

//         bytes4[] memory selectors = new bytes4[](10);
//         selectors[0] = ERC20Facet.name.selector;
//         selectors[1] = ERC20Facet.symbol.selector;
//         selectors[2] = ERC20Facet.decimals.selector;
//         selectors[3] = ERC20Facet.totalSupply.selector;
//         selectors[4] = ERC20Facet.balanceOf.selector;
//         selectors[5] = ERC20Facet.allowance.selector;
//         selectors[6] = ERC20Facet.approve.selector;
//         selectors[7] = ERC20Facet.transfer.selector;
//         selectors[8] = ERC20Facet.transferFrom.selector;
//         selectors[9] = ERC20Facet.mint.selector;

//         cut[0] = IDiamondCut.FacetCut({
//             facetAddress: address(erc20Facet),
//             action: IDiamondCut.FacetCutAction.Add,
//             functionSelectors: selectors
//         });

//         diamond.diamondCut(cut, address(0), "");
//     }

//     function testDiamondDeployment() public {
//         assertTrue(
//             address(diamond) != address(0),
//             "Diamond should be deployed"
//         );
//     }

//     function testTokenBasics() public {
//         string memory name = diamond.name();
//         string memory symbol = diamond.symbol();
//         uint8 decimals_ = diamond.decimals();
//         uint256 totalSupply = diamond.totalSupply();

//         assertEq(name, "RAFIK NAME SERVICE TOKEN", "Token name should match");
//         assertEq(symbol, "RNST", "Token symbol should match");
//         assertEq(decimals_, 18, "Decimals should be 18");
//         assertEq(
//             totalSupply,
//             1000000 * 10 ** 18,
//             "Total supply should be 1M tokens"
//         );
//     }

//     function testInitialBalance() public {
//         uint256 ownerBalance = diamond.balanceOf(owner);
//         assertEq(
//             ownerBalance,
//             1000000 * 10 ** 18,
//             "Owner should have all initial tokens"
//         );
//     }

//     function testTransfer() public {
//         uint256 transferAmount = 1000 * 10 ** 18;

//         // Transfer tokens from owner to user1
//         bool success = diamond.transfer(user1, transferAmount);
//         assertTrue(success, "Transfer should succeed");

//         assertEq(
//             diamond.balanceOf(user1),
//             transferAmount,
//             "User1 should receive tokens"
//         );
//         assertEq(
//             diamond.balanceOf(owner),
//             1000000 * 10 ** 18 - transferAmount,
//             "Owner balance should decrease"
//         );
//     }

//     function testApproveAndTransferFrom() public {
//         uint256 approveAmount = 500 * 10 ** 18;
//         uint256 transferAmount = 300 * 10 ** 18;

//         // Approve user2 to spend tokens
//         bool approveSuccess = diamond.approve(user2, approveAmount);
//         assertTrue(approveSuccess, "Approve should succeed");

//         assertEq(
//             diamond.allowance(owner, user2),
//             approveAmount,
//             "Allowance should be set"
//         );

//         // Transfer from owner to user1 using user2's approval
//         vm.prank(user2);
//         bool transferSuccess = diamond.transferFrom(
//             owner,
//             user1,
//             transferAmount
//         );
//         assertTrue(transferSuccess, "TransferFrom should succeed");

//         assertEq(
//             diamond.balanceOf(user1),
//             transferAmount,
//             "User1 should receive tokens"
//         );
//         assertEq(
//             diamond.allowance(owner, user2),
//             approveAmount - transferAmount,
//             "Allowance should decrease"
//         );
//     }

//     function testDiamondLoupe() public {
//         IDiamondLoupe.Facet[] memory facets = diamond.facets();
//         for (uint256 i = 0; i < facets.length; i++) {
//             assertEq(
//                 facets[i].facetAddress,
//                 address(erc20Facet),
//                 "Facet address should match"
//             );
//         }

//         bytes4[] memory selectors = diamond.facetFunctionSelectors(
//             address(erc20Facet)
//         );
//         assertEq(selectors.length, 9, "Should have 9 function selectors");

//         for (uint256 i = 0; i < selectors.length; i++) {
//             address facetAddress = diamond.facetAddress(selectors[i]);
//             assertEq(
//                 facetAddress,
//                 address(erc20Facet),
//                 "Selector should belong to ERC20Facet"
//             );
//         }
//     }

//     function testOnlyOwnerCanCut() public {
//         vm.prank(user1);

//         IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
//         bytes4[] memory selectors = new bytes4[](1);
//         selectors[0] = ERC20Facet.name.selector;

//         cut[0] = IDiamondCut.FacetCut({
//             facetAddress: address(erc20Facet),
//             action: IDiamondCut.FacetCutAction.Add,
//             functionSelectors: selectors
//         });

//         vm.expectRevert("Only owner can cut facets");
//         diamond.diamondCut(cut, address(0), "");
//     }

//     function testFacetMint() public {
//         uint256 mintAmount = 1000 * 10 ** 18;
//         vm.prank(address(erc20Facet));
//         ERC20Facet(address(diamond)).mint(mintAmount);

//         assertEq(
//             diamond.balanceOf(user1),
//             mintAmount,
//             "User1 should have minted tokens"
//         );
//         assertEq(
//             diamond.totalSupply(),
//             1000000 * 10 ** 18 + mintAmount,
//             "Total supply should increase"
//         );
//     }

//     function testZeroAddressTransfer() public {
//         vm.expectRevert("Cannot transfer to zero address");
//         diamond.transfer(address(0), 1000 * 10 ** 18);
//     }

//     function testInsufficientBalance() public {
//         vm.prank(user1);
//         vm.expectRevert("Insufficient balance");
//         diamond.transfer(user2, 1000 * 10 ** 18);
//     }

//     function testAnyoneCanMint() public {
//         uint256 mintAmount = 500 * 10 ** 18;
//         uint256 initialBalance = diamond.balanceOf(user1);
//         uint256 initialSupply = diamond.totalSupply();
        
//         vm.prank(user1);
//         ERC20Facet(address(diamond)).mint(mintAmount);
        
//         assertEq(
//             diamond.balanceOf(user1),
//             initialBalance + mintAmount,
//             "User1 balance should increase by mint amount"
//         );
//         assertEq(
//             diamond.totalSupply(),
//             initialSupply + mintAmount,
//             "Total supply should increase by mint amount"
//         );
//     }

//     function testMintToAddress() public {
//         uint256 mintAmount = 500 * 10 ** 18;
//         uint256 initialBalance = diamond.balanceOf(user2);
//         uint256 initialSupply = diamond.totalSupply();
        
//         vm.prank(user1);
//         ERC20Facet(address(diamond)).mint(mintAmount);
        
//         assertEq(
//             diamond.balanceOf(user2),
//             initialBalance + mintAmount,
//             "User2 balance should increase by mint amount"
//         );
//         assertEq(
//             diamond.totalSupply(),
//             initialSupply + mintAmount,
//             "Total supply should increase by mint amount"
//         );
//     }
// }
