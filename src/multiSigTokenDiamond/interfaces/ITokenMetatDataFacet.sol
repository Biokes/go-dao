// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IERC20TokenMetadataFacet {
    function tokenURI() external view returns (string memory);
    function setTokenURI(string calldata _tokenURI) external;
    function setSVGImage(string calldata _svgImage) external;
    function getSVGImage() external view returns (string memory);
}
