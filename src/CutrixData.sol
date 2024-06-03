// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "./ICutrixData.sol";

// Cutrix: 4x4 representation of an Ethereum address using "rich" charachters. 
// Rich characters are hex characters with additional color and effects. 
// The possible effects are  blinking, frame around the character and boldness.
//
// This contract creates the Cutrix data, such as SVG and attributes
contract CutrixData is ICutrixData {
    using Strings for uint256;

    struct richChar {
        uint8 charColor; //4 bits of characters, 3 bits of color, leading 0
        uint8 flags; // 1 bit frame, 1 bold, 1 blnking, other left bits are meaningless
    }

    // Generates a Cutrix SVG from a uint256 representation of an address
    function CutrixSVG(uint256 addrAsUint256) public pure returns(string memory){
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
            '<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1000" xmlns:v="https://vecta.io/nano"><path fill="#080808" d="M0 0h1000v1000H0z"/><path fill="none" stroke="#979da6" stroke-width="3" opacity=".48" d="M40 920h920"/><path fill="#4E8E6C" d="M726 944h24v24h-24z"/><path fill="#C9AC55" d="M756 944h24v24h-24z"/><path fill="#979da6" d="M786 944h24v24h-24z"/><path fill="#5879C7" d="M816 944h24v24h-24z"/><path fill="#CE7A12" d="M846 944h24v24h-24z"/><path fill="#6A4D80" d="M876 944h24v24h-24z"/><path fill="#CC4D48" d="M906 944h24v24h-24z"/><path fill="#7E980B" d="M936 944h24v24h-24z"/><path fill="#fff" d="M40 945h24v28H40z"/><text transform="translate(45 969)" fill="#080808" font-size="24" font-weight="700" font-family="Oswald">         C       </text><text fill="#fff" font-size="24" font-weight="200" letter-spacing="0.14em" font-family="Oswald"><tspan x="71" y="969">UT</tspan><tspan x="102" font-weight="700" y="969">RIX</tspan></text><defs ><style>@font-face{font-family:"Oswald";src:url(data:application/font-woff;charset=utf-8;base64,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) format("woff"); font-weight:200;font-style:normal;} @font-face{font-family:"Oswald";src:url(data:application/font-woff;charset=utf-8;base64,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) format("woff"); font-weight:bold;font-style:normal;}</style></defs>'
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

    // Generates a Cutrix attributes from a uint256 representation of an address
    // Attributes generated: frame, bold, blinking and color rarity.
    // See Cutrix Readme for more information.
    function CutrixAttributes(uint256 addrAsUint256) public pure returns(string memory){
        richChar[16] memory richChar16 = address16richChars(addrAsUint256);

        // effect counters
        uint8 frameCounter = 0; 
        uint8 boldCounter = 0; 
        uint8 blinkingCounter = 0;

        // a counter for each of the possible 8 colors
        uint8[8] memory colorCounter = [0, 0, 0, 0, 0, 0, 0, 0];

        // count colors and effects
        for (uint8 i = 0; i < 16; i++) {
            // Extract color
            uint8 color = richChar16[i].charColor >> 4;

            // Extract effects
            bool frame = (richChar16[i].flags & 1) != 0;
            bool bold = ( (richChar16[i].flags >> 1) & 1) != 0;
            bool blinking = ( (richChar16[i].flags >> 2) & 1) != 0;

            // Add to colors counters
            colorCounter[color] = colorCounter[color] + 1;

            // Add to effects counters
            frameCounter = frame ? frameCounter + 1 : frameCounter;
            boldCounter = bold ? boldCounter + 1 : boldCounter;
            blinkingCounter = blinking ? blinkingCounter + 1 : blinkingCounter;
        }

        // find maximum color
        uint8 maxColorCount = colorCounter[0];
        for (uint8 i = 1; i < 8; i++) {
            if (colorCounter[i] > maxColorCount) {
                maxColorCount = colorCounter[i];
            }
        }

        // build the JSON of each trait in the attributes
        bytes memory frameTrait = abi.encodePacked(
            '{',
                '"trait_type": "Frame",', " ",
                '"max_value": 65536,', " ",
                '"value": ', Strings.toString(effectRarity(frameCounter)),
            '},'
        );

        bytes memory boldTrait = abi.encodePacked(
            '{',
                '"trait_type": "Bold",', " ",
                '"max_value": 65536,', " ",
                '"value": ', Strings.toString(effectRarity(boldCounter)),
            '},'
        );

        bytes memory blinkingTrait = abi.encodePacked(
            '{',
                '"trait_type": "Blinking",', " ",
                '"max_value": 65536,', " ",
                '"value": ', Strings.toString(effectRarity(blinkingCounter)),
            '},'
        );

        bytes memory colorTrait = abi.encodePacked(
            '{',
                '"trait_type": "Color",', " ",
                '"max_value": 281474976710656,', " ",
                '"value": ', Strings.toString(colorRarity(blinkingCounter)),
            '}'
        );

        return string( 
            abi.encodePacked(frameTrait, boldTrait, blinkingTrait, colorTrait)
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
        // Extract hex character
        bytes1 hexCharBytes1 = bytes1(cutrixRichChar.charColor & 0x0f);
        string memory hexChar = string(abi.encodePacked(_nibbleToAscii(uint8(hexCharBytes1))));

        // Extract color
        uint8 color = cutrixRichChar.charColor >> 4;

        // Extract effects
        bool frame = (cutrixRichChar.flags & 1) != 0;
        bool bold = ( (cutrixRichChar.flags >> 1) & 1) != 0;
        bool blinking = ( (cutrixRichChar.flags >> 2) & 1) != 0;

        // Position of the frame
        uint16 Xrect = xCoord - 83  + (frame ? 6 : 0);
        uint16 Yrect = yCoord - 143 + (frame ? 6 : 0);

        // Build the SVG of the rectangle that contains the character
        bytes memory rectSVG = abi.encodePacked('<rect transform="translate(', Strings.toString(Xrect), ' ', Strings.toString(Yrect), ')" fill="', getColor(color) ,'" ', getFrame(frame)  ,'/>');

        // Build and return the SVG of the richChar
        return string(abi.encodePacked(
            rectSVG, '<text transform="translate(', Strings.toString(xCoord), ' ', Strings.toString(yCoord), ')" fill="white" font-family="Oswald" font-size="92" font-weight=', getFontWeight(bold) ,'>', getBlinking(blinking), '<tspan x="-4">',string(abi.encodePacked(hexChar)), '</tspan> </text>'
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
        colors[0] = '#4E8E6C'; // Green
        colors[1] = '#C9AC55'; // Gold
        colors[2] = '#979da6'; // Silver
        colors[3] = '#5879C7'; // Blue
        colors[4] = '#CE7A12'; // Orange
        colors[5] = '#6A4D80'; // Purple
        colors[6] = '#CC4D48'; // Red
        colors[7] = '#7E980B'; // Lime

        return colors[color];
    }

    // Generates SVG blinking animation if blinking==true
    function getBlinking(bool blinking) public pure returns (string memory) {
        string memory blinking_string = blinking ? '<animate attributeName="fill" values="white;transparent" dur="1s" begin="0s" calcMode="discrete" repeatCount="indefinite"/>' : "";

        return blinking_string;
    }

    // Generates an SVG code snippet with/without frame for a character
    function getFrame(bool frame) public pure returns (string memory) {
        string memory frame_code = frame ? 'width="206" height="190" stroke="#fff" stroke-width="12px"' : 'width="218" height="202"';

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

    // Returns the rarity of an effect occurring exactly a specific number of times
    function effectRarity(uint8 amount) internal pure returns (uint256) {
        // Rarity values calculated using the Binomial Distribution Formula
        uint24[17] memory rarityArray = [65536, 4096, 546, 117, 36, 15, 8, 6, 5, 6, 8, 15, 36, 117, 546, 4096, 65536];

        return rarityArray[amount];

    }

    // Returns the rarity of a specific color occurring exactly a specific number of times
    function colorRarity(uint8 amount) internal pure returns (uint256) {
        // Rarity values calculated using the Binomial Distribution Formula
        // The first two rarities are '0' since the max occuring of a color can't be less than 2
        uint56[17] memory rarityArray = [0, 0, 3, 5, 11, 33, 124, 610, 3794, 29876, 298763, 3834131, 64413403, 1465404918, 47869893998, 2513169434917, 281474976710656];

        return rarityArray[amount];
    }
   
}