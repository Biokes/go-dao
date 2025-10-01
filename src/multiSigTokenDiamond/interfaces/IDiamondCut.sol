// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import {IDiamond} from "./IDiamond.sol";
interface IDiamondCut is IDiamond{
    function facetCut(FacetCut[] calldata _facetAddress, address facetAddress, bytes calldata _calldata)external;
}
