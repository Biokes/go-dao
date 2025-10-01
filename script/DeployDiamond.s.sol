// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.28;

// import "../src/erc20Diamond/Diamond.sol";
// import "../src/erc20Diamond/facets/ERC20Facet.sol";
// import "../src/erc20Diamond/DiamondCutInterface.sol";
// import "forge-std/Script.sol";
// import "forge-std/console.sol";

// contract DeployDiamond is Script{
//     function run() external {
//         uint256 deployerPrivateKey = uint();
//         vm.startBroadcast(deployerPrivateKey);
//         ERC20Diamond diamond = new ERC20Diamond();
//         console.log("Diamond deployed at:", address(diamond));

//         ERC20Facet erc20Facet = new ERC20Facet();
//         console.log("ERC20Facet deployed at:", address(erc20Facet));

//         IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

//         bytes4[] memory selectors = new bytes4[](1);
//         selectors[0] = ERC20Facet.name.selector;
//         // selectors[1] = ERC20Facet.symbol.selector;
//         // selectors[2] = ERC20Facet.decimals.selector;
//         // selectors[3] = ERC20Facet.totalSupply.selector;
//         // selectors[4] = ERC20Facet.balanceOf.selector;
//         // selectors[5] = ERC20Facet.allowance.selector;
//         // selectors[6] = ERC20Facet.approve.selector;
//         // selectors[7] = ERC20Facet.transfer.selector;
//         // selectors[8] = ERC20Facet.transferFrom.selector;
//         // selectors[9] = ERC20Facet.mint.selector;

//         cut[0] = IDiamondCut.FacetCut({
//             facetAddress: address(erc20Facet),
//             action: IDiamondCut.FacetCutAction.Add,
//             functionSelectors: selectors
//         });
//         diamond.diamondCut(cut, address(0), "");

//         console.log("ERC20Facet added to diamond");
//         string memory name = diamond.name();
//         string memory symbol = diamond.symbol();
//         uint8 decimals_ = diamond.decimals();
//         uint256 totalSupply = diamond.totalSupply();

//         console.log("Token Name:", name);
//         console.log("Token Symbol:", symbol);
//         console.log("Decimals:", decimals_);
//         console.log("Total Supply:", totalSupply);

//         vm.stopBroadcast();
//     }
// }
