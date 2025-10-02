// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import {MultiSigTokenUtils} from "./libs/multiSigTokenLibrary.sol";

contract Diamond{
    using MultiSigTokenUtils for MultiSigTokenUtils.DiamondStorage;

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