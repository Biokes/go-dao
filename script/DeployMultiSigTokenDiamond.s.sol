// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../src/multiSigTokenDiamond/Diamond.sol";
import "../src/multiSigTokenDiamond/facets/ERC20Facet.sol";
import "../src/multiSigTokenDiamond/facets/TokenMetaDataFacet.sol";
import "../src/multiSigTokenDiamond/facets/SwapFacet.sol";
import {IDiamondCut} from "../src/multiSigTokenDiamond/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../src/multiSigTokenDiamond/interfaces/IDiamondLoupe.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import {DiamondCutFacet} from "../src/multiSigTokenDiamond/facets/DiamondCutFacet.sol";
import "forge-std/console.sol";
import "forge-std/Script.sol";

contract DeployMultiSigTokenDiamond is Script {
    function run() external {
        uint256 deployerPrivateKey = uint(0x1234567890);
        vm.startBroadcast(deployerPrivateKey);
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        console.log("DiamondCutFacet deployed at: ", address(diamondCutFacet));

        Diamond diamond = new Diamond(address(diamondCutFacet));
        console.log("Diamond deployed at: ", address(diamond));

        RafikTokenFacet erc20Facet = new RafikTokenFacet();
        console.log("RafikTokenFacet deployed at: ", address(erc20Facet));

        TokenMetaDataFacet metadataFacet = new TokenMetaDataFacet();
        console.log("TokenMetaDataFacet deployed at: ", address(metadataFacet));

        SwapFacet swapFacet = new SwapFacet();
        console.log("SwapFacet deployed at: ", address(swapFacet));

        bytes4[] memory erc20Selectors = new bytes4[](10);
        erc20Selectors[0] = RafikTokenFacet.name.selector;
        erc20Selectors[1] = RafikTokenFacet.symbol.selector;
        erc20Selectors[2] = RafikTokenFacet.decimals.selector;
        erc20Selectors[3] = RafikTokenFacet.totalSupply.selector;
        erc20Selectors[4] = RafikTokenFacet.balanceOf.selector;
        erc20Selectors[5] = RafikTokenFacet.allowance.selector;
        erc20Selectors[6] = RafikTokenFacet.approve.selector;
        erc20Selectors[7] = RafikTokenFacet.transfer.selector;
        erc20Selectors[8] = RafikTokenFacet.transferFrom.selector;
        erc20Selectors[9] = RafikTokenFacet.mint.selector;

        bytes4[] memory metadataSelectors = new bytes4[](4);
        metadataSelectors[0] = TokenMetaDataFacet.tokenURI.selector;
        metadataSelectors[1] = TokenMetaDataFacet.setTokenURI.selector;
        metadataSelectors[2] = TokenMetaDataFacet.setSVGImage.selector;
        metadataSelectors[3] = TokenMetaDataFacet.getSVGImage.selector;

        bytes4[] memory swapSelectors = new bytes4[](2);
        swapSelectors[0] = SwapFacet.swapEthToToken.selector;
        swapSelectors[1] = SwapFacet.withdrawEth.selector;

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);

        cuts[0] = IDiamond.FacetCut({
            facetAddress: address(erc20Facet),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: erc20Selectors
        });

        cuts[1] = IDiamond.FacetCut({
            facetAddress: address(metadataFacet),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: metadataSelectors
        });

        cuts[2] = IDiamond.FacetCut({
            facetAddress: address(swapFacet),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: swapSelectors
        });

        IDiamondCut(address(diamond)).facetCut(cuts, address(0), "");

        console.log("All facets added to diamond successfully");
        vm.stopBroadcast();
    }
}
