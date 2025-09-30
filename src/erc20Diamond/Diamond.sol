// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IDiamondCut} from "./DiamondCutInterface.sol";
import {IDiamondLoupe} from "./DiamondLoupeInterface.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {DiamondLibrary} from "./libs/DiamondLibrary.sol";


contract ERC20Diamond is IDiamondCut, IDiamondLoupe {
    using DiamondLibrary for DiamondLibrary.DiamondStorage;
    event  Transfer(address from, address to,uint supply);

    constructor() {
        DiamondLibrary.DiamondStorage storage diamondStorage = DiamondLibrary.diamondStorage();
        diamondStorage._owner = msg.sender;
        diamondStorage._name = "RAFIK NAME SERVICE TOKEN";
        diamondStorage._symbol = "RNST";
        diamondStorage._decimal = 18;
        diamondStorage._totalSupply = 1000000 * 10**18;
        diamondStorage._balances[msg.sender] = diamondStorage._totalSupply;
        emit Transfer(address(0), msg.sender, diamondStorage._totalSupply);
    }

    function diamondCut(FacetCut[] calldata _diamondCut,address _init,bytes calldata _calldata) external override {
        DiamondLibrary.DiamondStorage storage diamondStorage = DiamondLibrary.diamondStorage();
        require(msg.sender == diamondStorage._owner, "Only owner can cut facets");
        DiamondLibrary.diamondCut(_diamondCut, _init, _calldata);
        emit DiamondCut(_diamondCut, _init, _calldata);
    }

    function facets() external view override returns (Facet[] memory facets_) {
        return DiamondLibrary.facets();
    }

    function facetFunctionSelectors(address _facet) external view override returns (bytes4[] memory facetFunctionSelectors_) {
        return DiamondLibrary.facetFunctionSelectors(_facet);
    }

    function facetAddresses() external view override returns (address[] memory facetAddresses_) {
        return DiamondLibrary.facetAddresses();
    }

    function facetAddress(bytes4 _functionSelector) external view override returns (address facetAddress_) {
        return DiamondLibrary.facetAddress(_functionSelector);
    }

    function supportsInterface(bytes4 _interfaceId) external view override returns (bool supported_) {
        return DiamondLibrary.supportsInterface(_interfaceId);
    }



    receive() external payable {}

    fallback() external payable {
        address facet = DiamondLibrary.facetAddress(msg.sig);
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
