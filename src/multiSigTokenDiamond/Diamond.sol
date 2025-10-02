// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import {MultiSigTokenUtils} from "./libs/multiSigTokenLibrary.sol";
import {IDiamondLoupe} from "../multiSigTokenDiamond/interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "../multiSigTokenDiamond/interfaces/IDiamondCut.sol";
import {IDiamond} from "../multiSigTokenDiamond/interfaces/IDiamond.sol";


contract Diamond{
    using MultiSigTokenUtils for MultiSigTokenUtils.DiamondStorage;

    constructor(address diamondFacetCut){
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
        ds._owner = msg.sender;
        bytes4[] memory selectors = new bytes4[](6);
        selectors[0] = IDiamondCut.facetCut.selector;
        selectors[1] = IDiamondLoupe.facets.selector;
        selectors[2] = IDiamondLoupe.facetFunctionSelectors.selector;
        selectors[3] = IDiamondLoupe.facetAddresses.selector;
        selectors[4] = IDiamondLoupe.facetAddress.selector;
        selectors[5] = IDiamondLoupe.supportsInterface.selector;
        IDiamondCut.FacetCut[] memory facet = new IDiamondCut.FacetCut[](1);
        facet[0] = IDiamond.FacetCut({
            facetAddress: diamondFacetCut,
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: selectors
        });
        MultiSigTokenUtils.diamondCut(facet, diamondFacetCut,"");
    }
    receive() external payable {}

    fallback() external payable {
        address facet = MultiSigTokenUtils.facetAddress(msg.sig);
        require(facet != address(0), "Function not found");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}