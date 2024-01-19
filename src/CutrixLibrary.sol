// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// A Cutrix is a 4x4 representation of an address using "rich" charachters
// that includes color and effects.
library CutrixLibrary {
    using Strings for uint256;

    struct richChar {
        uint8 charColor; //4 bits of characters, 3 bits of color, leading 0
        uint8 flags; // 1 bit underlink, 1 overline, 1 blnking, rest of left bits are garbage
    }

    // Generate a Cutrix SVG from a uint256 representation of an address
    function generateCutrix(uint256 addrAsUint256) public pure returns(string memory){
        richChar[16] memory richChar16 = address16richChars(addrAsUint256);

        // Array holding the 16 svg strings of the Cutrix characters
        string[16] memory cutrixChar;


        // Extract the actualy character from each richChar
        for (uint256 i = 0; i < 16; i++) {
            bytes1 cutrixCharBytes1 = bytes1(richChar16[i].charColor & 0x0f);
            cutrixChar[i] = string(abi.encodePacked(_nibbleToAscii(uint8(cutrixCharBytes1))));
        }

        // Declare the svg variable and initiate it with the a 4x4 matrix
        bytes memory svg;
        svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="5 5 55 55" stroke="#000"> <path fill="white" stroke-width="3" d="M10 10h50v50H10z"/> <path fill="white" d="M11 11h12v12H11zM11 23h12v12H11zM11 35h12v12H11zM11 47h12v12H11zM23 11h12v12H23zM23 23h12v12H23zM23 35h12v12H23zM23 47h12v12H23zM35 11h12v12H35zM35 23h12v12H35zM35 35h12v12H35zM35 47h12v12H35zM47 11h12v12H47zM47 23h12v12H47zM47 35h12v12H47zM47 47h12v12H47z"/>'
        );

        // Add the 16 rich characters to the matrix
        for (uint8 i = 0; i < 16; i++) {
            uint8 xCoord = 12 + (i % 4) * 13;
            uint8 yCoord = 21 + (i / 4) * 12;

            svg = abi.encodePacked(
                svg,
                richCharSVG(xCoord, yCoord, richChar16[i])
            );
        }

        // close the svg
        svg = abi.encodePacked(svg, '</svg>');

        // return the svg as a data URI scheme
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    // Casts and address (as a uint256) into a richChar struct
    function address16richChars(uint256 addrAsUint256) internal pure returns (richChar[16] memory) {
        // An address has only 160 bits 
        uint160 Uint160Address = uint160(addrAsUint256);
        
        // A ruchChar to return
        richChar[16] memory richChar16;

        // variable to use inside the for loop
        uint8 addr8bitslice;

        // extracts slices of 10 bits from the bit representation fo the array
        for (uint256 i = 0; i < 16; i++) {
            // get the remaining right 8 bits from the address
            addr8bitslice = uint8(Uint160Address);

            // set the most left bit to 0
            addr8bitslice = addr8bitslice & 0x7f;

            // remove the 7 bits of char and color from the address
            Uint160Address = Uint160Address >> 7;

            // save it in the array
            richChar16[i].charColor = addr8bitslice;

            // get the remaining right 8 bits from the address
            addr8bitslice = uint8(Uint160Address);

            // set the 5 most left bit to 0, leaving on 3 relevant flags
            addr8bitslice = addr8bitslice & 0x07;

            // remove the 3 bits of the flags from the address
            Uint160Address = Uint160Address >> 3;

            // save it in the array
            richChar16[i].flags = addr8bitslice;
        }

        return richChar16;
    }

    function richCharSVG(uint8 xCoord, uint8 yCoord, richChar memory cutrixRichChar) public pure returns (string memory) {
        // Extract the hex character from cutrixRichChar
        bytes1 hexCharBytes1 = bytes1(cutrixRichChar.charColor & 0x0f);
        string memory hexChar = string(abi.encodePacked(_nibbleToAscii(uint8(hexCharBytes1))));

        // Extract the character color
        uint8 color = cutrixRichChar.charColor >> 4;

        // Extract effects
        bool underline = (cutrixRichChar.flags & 1) != 0;
        bool overline = ( (cutrixRichChar.flags >> 1) & 1) != 0;
        bool blinking = ( (cutrixRichChar.flags >> 2) & 1) != 0;

        // Build and return the richChar SVG represenatation
        return string(abi.encodePacked(
            '<text x="', Strings.toString(xCoord), '" y="', Strings.toString(yCoord), '" font-size="8" stroke="', getColor(color), '" text-decoration="',getDecoration(underline, overline),  '">',
            string(abi.encodePacked(hexChar)), ' ', getBlinking(blinking),
            '</text>'
        ));
    }

    function getDecoration(bool underline, bool overline) public pure returns (string memory) {
        string memory underline_string = underline ? "underline " : "";
        string memory overline_string = overline ? "overline" : "";

        return string.concat(underline_string, overline_string);
    }

    function getColor(uint8 color) public pure returns (string memory) {
        string[8] memory colors;

         // Initialize the array with colors
        colors[0] = "black";
        colors[1] = "red";
        colors[2] = "blue";
        colors[3] = "green";
        colors[4] = "darkorange";
        colors[5] = "darkviolet";
        colors[6] = "gold";
        colors[7] = "gray";

        return colors[color];
    }

    function getBlinking(bool blinking) public pure returns (string memory) {
        string memory blinking_string = blinking ? '<animate attributeName="stroke-opacity" values="1;0" begin="0s" dur="1.5s" calcMode="discrete" repeatCount="indefinite"/>' : "";

        return blinking_string;
    }

    function _nibbleToAscii(uint8 nibble) private pure returns (bytes1) {
        if (nibble < 10) {
            return bytes1(nibble + 0x30); // Convert to ASCII '0' to '9'
        } else {
            return bytes1(nibble + 0x57); // Convert to ASCII 'a' to 'f'
        }
    }

    // Make it easier for outside interactions to cast address into an Uin256
    function addressToUint256(address addr) public pure returns (uint256) {
        return uint256(uint160(addr));
    }
   
}