// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ICutrixData.sol";
import "../src/CutrixData.sol";
import "../src/Cutrix.sol";

contract CutrixScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("POLYGON_PRIAVTE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ICutrixData cutrixData;

        cutrixData = ICutrixData(new CutrixData()); 

        new Cutrix(cutrixData);

        vm.stopBroadcast();
    }
}

