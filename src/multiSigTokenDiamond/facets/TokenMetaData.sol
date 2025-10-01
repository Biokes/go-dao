// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;
import {IERC20TokenMetadataFacet} from "../interfaces/ITokenMetatDataFacet.sol";
import {MultiSigTokenUtils} from "../libs/multiSigTokenLibrary.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract TokenMetaDataFacet is IERC20TokenMetadataFacet {
    function tokenURI() external view returns (string memory uri){
        return MultiSigTokenUtils.getDiamondStorage().tokenMetaData.tokenURI;
    }

    function setTokenURI(string calldata _tokenURI) external{
        MultiSigTokenUtils.DiamondStorage storage diamondStorage = MultiSigTokenUtils.getDiamondStorage();
        require(msg.sender== diamondStorage._owner,"You are UNAUTHORISED To set Token URI");
        MultiSigTokenUtils.setTokenURI(_tokenURI);
    }

    function setSVGImage(string calldata _svgImage) external{
        MultiSigTokenUtils.DiamondStorage storage diamondStorage = MultiSigTokenUtils.getDiamondStorage();
        require(msg.sender== diamondStorage._owner,"You are UNAUTHORISED To set SVG IMAGE");
        diamondStorage.tokenMetaData.svg = _svgImage;
    }

    function getSVGImage() external view returns (string memory ImageUrl){
        return MultiSigTokenUtils.getDiamondStorage().tokenMetaData.svg;
    }
}
