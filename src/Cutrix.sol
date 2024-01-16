// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Cutrix is ERC721URIStorage {
    using Strings for uint256;

    constructor() ERC721("Cutrix", "CTRX") {}

    function mint(uint256 tokenID) external {
        _mint(msg.sender, tokenID);
    }

    function generateCutrix(uint256 tokenId) public view returns(string memory){

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="5 5 55 55" stroke="#000"> <path fill="white" stroke-width="3" d="M10 10h50v50H10z"/> <path fill="white" d="M11 11h12v12H11zM11 23h12v12H11zM11 35h12v12H11zM11 47h12v12H11zM23 11h12v12H23zM23 23h12v12H23zM23 35h12v12H23zM23 47h12v12H23zM35 11h12v12H35zM35 23h12v12H35zM35 35h12v12H35zM35 47h12v12H35zM47 11h12v12H47zM47 23h12v12H47zM47 35h12v12H47zM47 47h12v12H47z"/> </svg>'
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Cutrix #', Strings.toString(tokenId), '",',
                '"description": "A moderately handsome wallet address",',
                '"image": "', generateCutrix(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
   
}