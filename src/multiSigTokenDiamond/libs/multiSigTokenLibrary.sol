// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IDiamond} from "../interfaces/IDiamondCut.sol";
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

        MetaData tokenMetaData;

        mapping(address => Owner) owners;
        uint256 _required;
        uint256 _txCounter;
        mapping(uint256 => Transaction) _transactions;

    }

    struct MetaData{
        string tokenURI;
        string svg;
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
        mapping(address => Approvals) approvedBy;
    }
    struct Approvals{
        bool isApproved;
        uint timeApproved;
    }

    function getDiamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function diamondCut(IDiamond.FacetCut[] memory _diamondCut,address _init,bytes memory _calldata) internal {
        DiamondStorage storage ds = getDiamondStorage();
        for (uint256 i = 0; i < _diamondCut.length; i++) {
            IDiamond.FacetCut memory facetCut = _diamondCut[i];
            address facet_address = facetCut.facetAddress;
            IDiamond.FacetCutAction action = facetCut.action;
            if (action == IDiamond.FacetCutAction.Add) {
                addFacet(ds, facet_address, facetCut.functionSelectors);
            } else if (action == IDiamond.FacetCutAction.Replace) {
                replaceFacet(ds, facet_address, facetCut.functionSelectors);
            } else if (action == IDiamond.FacetCutAction.Remove) {
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

   function facets() internal view returns (IDiamondLoupe.Facet[] memory facets_) {
        facets_ = new IDiamondLoupe.Facet[](facetAddresses().length);
        for (uint256 i = 0; i < facets_.length; i++) {
            address facetAddress_ = facetAddresses()[i];
            facets_[i] = IDiamondLoupe.Facet({
                facetAddress: facetAddress_,
                functionSelectors: facetFunctionSelectors(facetAddress_)
            });
        }
    }
    
    function setTokenURI(string calldata tokenURI) internal {
        DiamondStorage storage ds = getDiamondStorage();
        ds.tokenMetaData.tokenURI = tokenURI;
    }

    function facetFunctionSelectors(address _facet) internal view returns (bytes4[] memory) {
        DiamondStorage storage ds = getDiamondStorage();
        return ds._facetFunctionSelectors[_facet];
    }

    function facetAddresses() internal view returns (address[] memory) {
        DiamondStorage storage ds = getDiamondStorage();
        address[] memory addresses_ = new address[](ds._selectors.length);
        for (uint256 i = 0; i < ds._selectors.length; i++) {
            addresses_[i] = ds._facets[ds._selectors[i]];
        }
        return addresses_;
    }

    function facetAddress(bytes4 _functionSelector) internal view returns (address) {
        DiamondStorage storage ds = getDiamondStorage();
        return ds._facets[_functionSelector];
    }

    function supportsInterface(bytes4 _interfaceId) internal view returns (bool) {
        DiamondStorage storage ds =getDiamondStorage();
        return ds._facets[_interfaceId] != address(0);
    }

    function swapEthToToken() internal returns (uint swappedAmount){
        DiamondStorage storage ds = getDiamondStorage();
        require(msg.value > 0, "No ETH sent");
        swappedAmount = (msg.value * 1000);
        ds._balances[msg.sender] += swappedAmount;
        ds._totalSupply += swappedAmount;
    }

    function withdrawEth() internal {
        DiamondStorage storage ds = getDiamondStorage();
        require(msg.sender== ds._owner,"Only owner can withdraw eth");
        uint balance = address(this).balance;
        (bool success, ) = payable(ds._owner).call{value: balance}("");
        require(success, "ETH transfer failed");
    }
}
