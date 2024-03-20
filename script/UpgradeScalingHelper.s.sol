// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import 'forge-std/console.sol';
import 'forge-std/Script.sol';

import '../src/InputScalingHelper.sol';

contract DeployScalingHelper is Script {
  InputScalingHelper wrappedProxy = InputScalingHelper(0x0000000000000000000000000000000000000000);

  function run() public {
    InputScalingHelper newImplementation = new InputScalingHelper();
    wrappedProxy.upgradeTo(address(newImplementation));

    console.log(wrappedProxy.owner()); // should be deployer
  }
}
