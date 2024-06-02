// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "./ICutrixData.sol";

// Cutrix: 4x4 representation of an Ethereum address using "rich" charachters. 
// Rich characters are hex characters with additional color and effects. 
// The possible effects are  blinking, frame around the character and boldness.
contract Cutrix is  ERC721URIStorage, ERC721Enumerable, Ownable {
    using Strings for uint256;

    struct richChar {
        uint8 charColor; //4 bits of characters, 3 bits of color, leading 0
        uint8 flags; // 1 bit underlink, 1 overline, 1 blnking, rest is garbage bits
    }

    ICutrixData internal cutrixData;

    constructor(ICutrixData cutrixDataContructor) ERC721("Cutrix", "CTRX") Ownable(msg.sender) {
        cutrixData = cutrixDataContructor;
    }

    // The tokenID is actually the uint256 representation of an address.
    // Anyone can mint a token, but the ownership will go to the address that tokenID represents.
    function mint(uint256 tokenID) external {
        uint160 Uint160Address = uint160(tokenID);
        address tokenIDAddress = address(Uint160Address);

        _mint(tokenIDAddress, tokenID);
    }

    function tokenURI(uint256 tokenID) public view override(ERC721, ERC721URIStorage) returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Cutrix #', Strings.toString(tokenID), '",',
                '"description": "A moderately handsome wallet address",',
                '"image": "', cutrixData.CutrixSVG(tokenID), '",',
                '"attributes": [', cutrixData.CutrixAttributes(tokenID), ']',
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