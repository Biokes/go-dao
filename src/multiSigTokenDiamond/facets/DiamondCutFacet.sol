// SPDX-License-Idetifier: UNLICENSED;
pragma solidity ^0.8.28;
import {MultiSigTokenUtils} from "../../multiSigTokenDiamond/libs/multiSigTokenLibrary.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../interfaces/IDiamondLoupe.sol";
contract DiamondCutFacet is IDiamondCut, IDiamondLoupe{

    function facetCut(FacetCut[] calldata _diamondCut,address _init,bytes calldata _calldata) external {
        MultiSigTokenUtils.DiamondStorage storage diamondStorage = MultiSigTokenUtils.getDiamondStorage();
        require(msg.sender == diamondStorage._owner, "Only owner can cut facets");
        MultiSigTokenUtils.diamondCut(_diamondCut, _init, _calldata);
        emit DiamondCut(_diamondCut, _init, _calldata);
    }

    function facets() external view override returns (Facet[] memory facets_) {
        return MultiSigTokenUtils.facets();
    }

    function facetFunctionSelectors(address _facet) external view override returns (bytes4[] memory facetFunctionSelectors_) {
        return MultiSigTokenUtils.facetFunctionSelectors(_facet);
    }

    function facetAddresses() external view override returns (address[] memory facetAddresses_) {
        return MultiSigTokenUtils.facetAddresses();
    }

    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_) {
        return MultiSigTokenUtils.facetAddress(_functionSelector);
    }

    function supportsInterface(bytes4 _interfaceId) external view returns (bool supported_) {
        return MultiSigTokenUtils.supportsInterface(_interfaceId);
    }
 }