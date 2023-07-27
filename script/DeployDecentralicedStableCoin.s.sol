// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";

contract DeployDecentralicedStableCoin is Script {
    uint256 public constant INITIAL_SUPPLY = 10000 ether;

    function run() external returns (DecentralizedStableCoin) {
        vm.startBroadcast();
        DecentralizedStableCoin dsc = new DecentralizedStableCoin();
        vm.stopBroadcast();
        return dsc;
    }
}
