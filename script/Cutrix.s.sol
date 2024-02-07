// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ICutrixLibrary.sol";
import "../src/CutrixLibrary.sol";
import "../src/Cutrix.sol";

contract CutrixScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_ANVIL");
        vm.startBroadcast(deployerPrivateKey);

        ICutrixLibrary cutrixLibrary;

        cutrixLibrary = ICutrixLibrary(new CutrixLibrary()); 

        new Cutrix(cutrixLibrary);

        vm.stopBroadcast();
    }
}

