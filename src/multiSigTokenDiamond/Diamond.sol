// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
import {MultiSigTokenUtils} from "./libs/multiSigTokenLibrary.sol";
import {IDiamondLoupe} from "../multiSigTokenDiamond/interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "../multiSigTokenDiamond/interfaces/IDiamondCut.sol";
import {IDiamond} from "../multiSigTokenDiamond/interfaces/IDiamond.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract Diamond{
    using MultiSigTokenUtils for MultiSigTokenUtils.DiamondStorage;

    constructor(address diamondFacetCut){
        MultiSigTokenUtils.DiamondStorage storage ds = MultiSigTokenUtils.getDiamondStorage();
        ds._owner = msg.sender;
        ds._name = "RAFIKKI TOKEN";
        ds._symbol = "RFKT";
        ds._decimal = 18;
        ds._totalSupply = 1000000 * 10**18;
        ds._balances[msg.sender] = ds._totalSupply/2;
        ds.tokenMetaData.svg = SVG;
        ds.tokenMetaData.tokenURI = string(
        abi.encodePacked(
            '{"name":"RAFIK TOKEN ","symbol":"RFKT",',
            '"description":"Rafik Diamond Token with Multi-Sig, Swap, and Custom SVG",',
            '"image":"data:image/svg+xml;base64,',Base64.encode(bytes(SVG)),'",',
            '"attributes":[{"trait_type":"Token Standard","value":"Rafik Token Service"},',
            '{"trait_type":"Features","value":"Multi-Sig, Swap, Custom Metadata"},',
            '{"trait_type":"Network","value":"LiskSepolia"},',
            '{"trait_type":"SVG Source","value":"Custom rafikToken.svg"}]}'
        )
    );
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
        MultiSigTokenUtils.diamondCut(facet, address(0),"");
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

  string constant SVG = 
    '<svg xmlns="http://www.w3.org/2000/svg" version="1.0" width="840.000000pt" height="852.000000pt" viewBox="0 0 840.000000 852.000000" preserveAspectRatio="xMidYMid meet">'
        '<g transform="translate(0.000000,852.000000) scale(0.100000,-0.100000)" fill="#000000" stroke="none">'
            '<path d="M4925 8109 c-62 -36 -135 -134 -135 -181 0 -128 233 -241 365 -177 62 30 90 143 53 214 -23 44 -83 102 -129 126 -49 25 -127 34 -154 18z"/>'
            '<path d="M2335 7873 c-68 -25 -127 -74 -161 -136 -25 -44 -29 -63 -29 -127 0 -137 58 -219 287 -406 141 -115 367 -334 447 -432 28 -34 95 -129 150 -210 92 -136 201 -282 201 -269 0 6 -190 498 -423 1099 -134 342 -135 346 -190 405 -77 84 -181 112 -282 76z"/>'
            '<path d="M3912 7494 c-47 -33 -57 -69 -56 -209 1 -136 0 -132 118 -696 64 -308 70 -488 18 -559 -31 -43 -98 -70 -172 -70 -135 0 -265 61 -473 221 -21 16 -14 2 28 -56 134 -187 168 -336 104 -463 -42 -84 -76 -107 -159 -107 -54 0 -78 6 -140 36 -97 47 -213 131 -351 255 -61 54 -137 122 -167 149 -70 62 -60 46 43 -75 106 -123 230 -286 288 -377 172 -269 207 -494 87 -556 -29 -15 -50 -18 -125 -13 -99 6 -194 29 -450 112 -351 113 -485 118 -518 20 -26 -79 32 -156 167 -221 98 -47 138 -61 431 -154 284 -90 420 -162 459 -245 61 -129 -58 -208 -394 -266 -63 -11 -239 -35 -390 -55 -420 -54 -563 -85 -651 -141 -67 -42 -80 -105 -31 -154 46 -45 97 -55 282 -54 163 2 201 6 660 70 154 22 235 28 385 28 175 1 194 -1 237 -21 126 -58 116 -192 -26 -364 -86 -105 -278 -263 -481 -399 -44 -29 -84 -57 -90 -62 -5 -5 78 34 185 86 382 186 653 257 806 211 123 -37 145 -123 71 -279 -42 -88 -82 -149 -232 -351 -202 -273 -270 -386 -281 -469 -9 -63 2 -94 39 -116 110 -68 226 25 494 399 236 327 337 436 435 465 92 28 172 -23 205 -132 30 -97 24 -349 -15 -607 -18 -116 -32 -223 -32 -238 0 -56 17 -24 49 91 73 262 189 527 290 662 95 127 202 173 322 140 47 -13 55 -24 88 -112 35 -95 52 -104 155 -87 104 18 143 5 217 -72 75 -76 113 -133 255 -380 190 -333 266 -433 350 -465 43 -16 49 -16 98 -1 66 21 81 21 133 -2 78 -36 171 -142 348 -395 157 -225 267 -302 356 -249 117 69 14 325 -436 1088 -62 105 -130 219 -152 255 -90 147 -237 416 -302 551 -124 257 -149 374 -95 439 43 50 98 73 192 78 96 5 167 -7 312 -53 58 -19 116 -35 130 -37 47 -6 32 17 -41 62 -93 57 -227 184 -261 247 -57 104 -52 239 11 295 75 67 220 83 646 72 403 -11 663 -9 747 6 91 16 162 53 182 94 9 19 16 41 16 49 0 23 -39 66 -80 87 -89 46 -204 58 -676 75 -538 19 -683 42 -761 121 -27 26 -33 40 -33 75 0 138 146 243 482 345 169 52 219 72 226 93 4 11 -8 13 -64 8 -38 -3 -138 -11 -221 -18 -327 -27 -520 27 -588 164 -55 113 -15 187 220 411 85 81 170 169 187 194 78 113 24 259 -93 255 -68 -3 -118 -36 -294 -197 -225 -206 -334 -249 -417 -166 -39 39 -37 86 6 175 50 104 131 210 392 515 304 354 412 521 414 638 0 55 -21 95 -63 121 -74 46 -155 18 -275 -93 -85 -80 -175 -189 -392 -471 -304 -396 -436 -532 -552 -567 -78 -23 -184 46 -238 156 -38 77 -56 164 -70 338 -6 76 -14 148 -19 160 -8 22 -9 22 -14 -7 -3 -16 -9 -52 -12 -80 -19 -150 -84 -317 -156 -399 -77 -88 -188 -120 -255 -74 -89 61 -146 227 -249 723 -76 369 -125 513 -195 584 -36 35 -90 42 -128 15z"/>'
        '</g>'
    '</svg>';


}