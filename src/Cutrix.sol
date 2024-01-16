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

    function generateCutrix(uint256 tokenId) public pure returns(string memory){
        bytes1 lastChar = getFirstCharacter(uint256ToAddress(tokenId));

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="5 5 55 55" stroke="#000"> <path fill="white" stroke-width="3" d="M10 10h50v50H10z"/> <path fill="white" d="M11 11h12v12H11zM11 23h12v12H11zM11 35h12v12H11zM11 47h12v12H11zM23 11h12v12H23zM23 23h12v12H23zM23 35h12v12H23zM23 47h12v12H23zM35 11h12v12H35zM35 23h12v12H35zM35 35h12v12H35zM35 47h12v12H35zM47 11h12v12H47zM47 23h12v12H47zM47 35h12v12H47zM47 47h12v12H47z"/> <text x="12" y="21" font-size="12">',
                lastChar,
                '</text></svg>'
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

    // Function to return the first character of an address
    function getFirstCharacter(address addr) internal pure returns (bytes1) {
        // Convert the address to a string
        string memory addressString = addressToString(addr);

        // Get the first character after "0x"
        bytes1 firstCharacter = bytes(addressString)[2];

        return firstCharacter;
    }

    // Function to convert address to string
    function addressToString(address addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(addr)));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";

        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }

        return string(str);
    }

    function addressToUint256(address addr) public pure returns (uint256) {
        return uint256(uint160(addr));
    }

    function uint256ToAddress(uint256 addrAsUint256) public pure returns (address) {
        return address(uint160(addrAsUint256));
    }
   
}