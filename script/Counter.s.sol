// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";
import {ERC20} from "../src/ERC20.sol";

contract CounterScript is Script {
    Counter public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new Counter();

        vm.stopBroadcast();
    }
}

contract ERC20Script is Script {
    function run() external {
        uint256 deployerPrivateKey = INSERT_PRIVATE_KEY;
        vm.startBroadcast(deployerPrivateKey);

        ERC20 erc20 = new ERC20(1000000000);

        vm.stopBroadcast();
    }