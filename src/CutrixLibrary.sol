// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// A Cutrix is a 4x4 representation of an address using "rich" charachters 
// that are characters with color and effect. 
// The possible effects are  blinking, frame around the character and bold.
library CutrixLibrary {
    using Strings for uint256;

    struct richChar {
        uint8 charColor; //4 bits of characters, 3 bits of color, leading 0
        uint8 flags; // 1 bit frame, 1 bold, 1 blnking, other left bits are meaningless
    }

    // Generates a Cutrix SVG from a uint256 representation of an address
    function generateCutrix(uint256 addrAsUint256) public pure returns(string memory){
        richChar[16] memory richChar16 = address16richChars(addrAsUint256);

        // Array holding the 16 svg strings of the Cutrix characters
        string[16] memory cutrixChar;

        uint16 x_start = 123;
        uint16 x_gap = 234;
        uint16 y_start = 183;
        uint16 y_gap = 218;


        // Extract the actualy character from each richChar
        for (uint256 i = 0; i < 16; i++) {
            bytes1 cutrixCharBytes1 = bytes1(richChar16[i].charColor & 0x0f);
            cutrixChar[i] = string(abi.encodePacked(_nibbleToAscii(uint8(cutrixCharBytes1))));
        }

        // Declare the svg variable and initiate it with the a 4x4 matrix
        bytes memory svg;
        svg = abi.encodePacked(
            '<svg  xmlns="http://www.w3.org/2000/svg"  xmlns:xlink="http://www.w3.org/1999/xlink"  width="1000"  height="1000"  viewBox="0 0 1000 1000"><style>  @import url("https://fonts.googleapis.com/css2?family=Oswald:wght@200;700");  text {    font-family: "Oswald";  }</style><rect width="1000" height="1000" fill="#080808" /><line  id="line"  x2="920"  transform="translate(40 920)"  fill="none"  stroke="#979da6"  stroke-width="3"  opacity="0.48"/><g id="footer" transform="translate(0 -79)"><g id="colors" transform="translate(340 -10)"><rect  width="24"  height="24"  transform="translate(386 1033)"  fill="#cb4640"/><rect  width="24"  height="24"  transform="translate(416 1033)"  fill="#f9b529"/><rect  width="24"  height="24"  transform="translate(446 1033)"  fill="#d5c021"/><rect  width="24"  height="24"  transform="translate(476 1033)"  fill="#979da6"/><rect  width="24"  height="24"  transform="translate(506 1033)"  fill="#6a4f9a"/><rect  width="24"  height="24"  transform="translate(536 1033)"  fill="#2a36ac"/><rect  width="24"  height="24"  transform="translate(566 1033)"  fill="#be4570"/><rect  width="24"  height="24"  transform="translate(596 1033)"  fill="#489171"/>g> id="logo" transform="translate(0 -5)"><rect width="24" height="28" transform="translate(40 1029)" fill="#fff" /><text  id="C"  transform="translate(45 1053)"  fill="#080808"  font-size="24"  font-weight="700">  C</text><text  id="UTRIX"  transform="translate(68 1053)"  fill="#fff"  font-size="24"  font-weight="200"  letter-spacing="0.14em">  <tspan x="3" y="0">UT</tspan>  <tspan x="34" y="0" font-weight="700">RIX</tspan></text></g></g>'
        );

        // Add the 16 rich characters to the matrix
        for (uint8 i = 0; i < 16; i++) {
            uint16 xCoord = x_start + x_gap * (i % 4);
            uint16 yCoord = y_start + y_gap * (i / 4);

            svg = abi.encodePacked(
                svg,
                richCharSVG(xCoord, yCoord, richChar16[i])
            );
        }

        // Close the svg
        svg = abi.encodePacked(svg, '</svg>');

        // Return the svg as a data URI scheme
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    // Casts an address (as a uint256) into a richChar struct
    function address16richChars(uint256 addrAsUint256) internal pure returns (richChar[16] memory) {
        // An address has only 160 bits 
        uint160 Uint160Address = uint160(addrAsUint256);
        
        // A richChar to return
        richChar[16] memory richChar16;

        // Variable to use inside the for loop
        uint8 addr8bitslice;

        // Extracts slices of 10 bits from the bit representation into the array
        for (uint256 i = 0; i < 16; i++) {
            // Get a remaining right 8 bits from the bit representation
            addr8bitslice = uint8(Uint160Address);

            // Set the most left bit of those 8 bits to 0 (char & color are only 7)
            addr8bitslice = addr8bitslice & 0x7f;

            // Remove the 7 bits of char and color we just extracted from the bit representation
            Uint160Address = Uint160Address >> 7;

            // Save the 7 bits we extracted in the array
            richChar16[i].charColor = addr8bitslice;

            // Get a remaining right 8 bits from the bit representation
            addr8bitslice = uint8(Uint160Address);

            // Set the 5 most left bit to 0, leaving only 3 relevant flags
            addr8bitslice = addr8bitslice & 0x07;

            // Remove 3 bits of the flags from the bit representation
            Uint160Address = Uint160Address >> 3;

            // Save the flags in the array
            richChar16[i].flags = addr8bitslice;
        }

        return richChar16;
    }

    // Generates an SVG of richChar placed in a given x-y coordinates
    function richCharSVG(uint16 xCoord, uint16 yCoord, richChar memory cutrixRichChar) public pure returns (string memory) {
        // Extract the hex character from cutrixRichChar
        bytes1 hexCharBytes1 = bytes1(cutrixRichChar.charColor & 0x0f);
        string memory hexChar = string(abi.encodePacked(_nibbleToAscii(uint8(hexCharBytes1))));

        // Extract the character color
        uint8 color = cutrixRichChar.charColor >> 4;

        // Extract effects
        bool frame = (cutrixRichChar.flags & 1) != 0;
        bool bold = ( (cutrixRichChar.flags >> 1) & 1) != 0;
        bool blinking = ( (cutrixRichChar.flags >> 2) & 1) != 0;

        // Position of the frame
        uint16 Xrect = xCoord - 83;
        uint16 Yrect = yCoord - 143;

        // Build the SVG of the rectangle that contains the character
        bytes memory rectSVT = abi.encodePacked('<rect transform="translate(', Strings.toString(Xrect), ' ', Strings.toString(Yrect), ')" fill="', getColor(color) ,'" ', getFrame(frame)  ,'/>');

        // Build and return the SVG of the richChar
        return string(abi.encodePacked(
            rectSVT, '<text transform="translate(', Strings.toString(xCoord), ' ', Strings.toString(yCoord), ')" fill="white" font-size="92" font-weight=', getFontWeight(bold) ,'>', getBlinking(blinking), '<tspan x="-4">',string(abi.encodePacked(hexChar)), '</tspan> </text>'
        ));
    }

    // Returns font_weight based on the value of 'bold' variable
    function getFontWeight(bool bold) public pure returns (string memory) {
        string memory font_weight = bold ? '"700"' : '"200"';

        return font_weight;
    }

    // Returns html value for a number of color 
    function getColor(uint8 color) public pure returns (string memory) {
        string[8] memory colors;

         // Initialize the array with colors
        colors[0] = "#cb4640";
        colors[1] = "#f9b529";
        colors[2] = "#d5c021";
        colors[3] = "#979da6";
        colors[4] = "#6a4f9a";
        colors[5] = "#2a36ac";
        colors[6] = "#be4570";
        colors[7] = "#489171";

        return colors[color];
    }

    // Generates SVG blinking animation if blinking==true
    function getBlinking(bool blinking) public pure returns (string memory) {
        string memory blinking_string = blinking ? '<animate attributeName="fill" values="white;transparent" dur="1s" begin="0s" calcMode="discrete" repeatCount="indefinite"/>' : "";

        return blinking_string;
    }

    // Generates an SVG code snippet with/without frame for a character
    function getFrame(bool frame) public pure returns (string memory) {
        string memory frame_code = frame ? 'width="212" height="202" stroke="#fff" stroke-width="12px"' : 'width="218" height="202"';

        return frame_code;
    }

    // Convert a 4-bit nibble to its ASCII representation
    function _nibbleToAscii(uint8 nibble) private pure returns (bytes1) {
        if (nibble < 10) {
            return bytes1(nibble + 0x30); // Convert to ASCII '0' to '9'
        } else {
            return bytes1(nibble + 0x37); // Convert to ASCII 'A' to 'F'
        }
    }

    // Makes it easier for outside interactions to cast address into an Uin256
    function addressToUint256(address addr) public pure returns (uint256) {
        return uint256(uint160(addr));
    }
   
}