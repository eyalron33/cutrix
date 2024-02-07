// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "./ICutrixData.sol";

contract Cutrix is ERC721URIStorage, Ownable {
    using Strings for uint256;

    struct richChar {
        uint8 charColor; //4 bits of characters, 3 bits of color, leading 0
        uint8 flags; // 1 bit underlink, 1 overline, 1 blnking, rest is garbage bits
    }

    ICutrixData internal cutrixData;

    constructor(ICutrixData cutrixDataContructor) ERC721("Cutrix", "CTRX") Ownable(msg.sender) {
        cutrixData = cutrixDataContructor;
    }

    function mint(uint256 tokenID) external {
        _mint(msg.sender, tokenID);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Cutrix #', Strings.toString(tokenId), '",',
                '"description": "A moderately handsome wallet address",',
                '"image": "', cutrixData.CutrixSVG(tokenId), '"',
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