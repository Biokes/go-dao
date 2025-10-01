// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../interfaces/IDiamondLoupe.sol";

library MultiSigTokenUtils {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("multisig.token.diamond.storage");

    struct DiamondStorage {
        string _name;
        string _symbol;
        uint8 _decimal;
        uint256 _totalSupply;
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        address _owner;
        mapping(bytes4 => address) _facets;
        mapping(address => bytes4[]) _facetFunctionSelectors;
        bytes4[] _selectors;

        string tokenURI;

        mapping(address => Owner) owners;
        uint256 _required;
        uint256 _txCounter;
        mapping(uint256 => Transaction) _transactions;
    }

    struct Owner{
        uint8 position;
        bool isOwner;
    }

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 approvals;
        mapping(address => bool) approvedBy;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function diamondCut(IDiamondCut.FacetCut[] memory _diamondCut,address _init,bytes memory _calldata) internal {
        DiamondStorage storage ds = diamondStorage();
        for (uint256 i = 0; i < _diamondCut.length; i++) {
            
            IDiamondCut.FacetCut memory facetCut = _diamondCut[i];
            address facet_address = facetCut.facetAddress;
            IDiamondCut.FacetCutAction action = facetCut.action;

            if (action == IDiamondCut.FacetCutAction.Add) {
                addFacet(ds, facet_address, facetCut.functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFacet(ds, facet_address, facetCut.functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFacet(ds, facet_address, facetCut.functionSelectors);
            }
        }

        if (_init != address(0)) {
            (bool success,) = _init.delegatecall(_calldata);
            require(success, "Diamodcut Initialization failed");
        }
    }
    
    function addFacet(DiamondStorage storage ds,address _facetAddress,bytes4[] memory _functionSelectors) internal {
        require(_facetAddress != address(0), "Facet address cannot be zero");
        for (uint256 i = 0; i < _functionSelectors.length; i++) {
            bytes4 selector = _functionSelectors[i];
            require(ds._facets[selector] == address(0), "Function already exists");
            ds._facets[selector] = _facetAddress;
            ds._selectors.push(selector);
        }
        ds._facetFunctionSelectors[_facetAddress] = _functionSelectors;
    }

    function replaceFacet(DiamondStorage storage ds,address _facetAddress,bytes4[] memory _functionSelectors) internal {
        require(_facetAddress != address(0), "Facet address cannot be zero");
        for (uint256 i = 0; i < _functionSelectors.length; i++) {
            bytes4 selector = _functionSelectors[i];
            require(ds._facets[selector] != address(0), "Function does not exist");
            ds._facets[selector] = _facetAddress;
        }
        ds._facetFunctionSelectors[_facetAddress] = _functionSelectors;
    }

    function removeFacet(DiamondStorage storage ds,address _facetAddress,bytes4[] memory _functionSelectors) internal {
        require(_facetAddress == address(0), "Remove facet address must be zero");
        for (uint256 i = 0; i < _functionSelectors.length; i++) {
            bytes4 selector = _functionSelectors[i];
            require(ds._facets[selector] != address(0), "Function does not exist");
            delete ds._facets[selector];
            for (uint256 j = 0; j < ds._selectors.length; j++) {
                if (ds._selectors[j] == selector) {
                    ds._selectors[j] = ds._selectors[ds._selectors.length - 1];
                    ds._selectors.pop();
                    break;
                }
            }
        }
        delete ds._facetFunctionSelectors[_facetAddress];
    }


}
