// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// A Cutrix is a 4x4 representation of an address using "rich" charachters 
// that are characters with color and effect. 
// The possible effects are  blinking, frame around the character and bold.
interface ICutrixLibrary {
    // Generates a Cutrix SVG from a uint256 representation of an address
    function CutrixSVG(uint256 addrAsUint256) external view returns(string memory); 

    function CutrixAttributes(uint256 addrAsUint256) external view returns (string memory);
}