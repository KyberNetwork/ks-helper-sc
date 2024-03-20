// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import 'forge-std/console.sol';
import 'forge-std/Script.sol';

import '@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol';

import '../src/InputScalingHelper.sol';

contract DeployScalingHelper is Script {
  ERC1967Proxy proxy;
  InputScalingHelper wrappedProxy;

  function run() public {
    InputScalingHelper implementation = new InputScalingHelper();

    // deploy proxy contract and point it to implementation
    proxy = new ERC1967Proxy(address(implementation), '');

    // wrap in ABI to support easier calls
    wrappedProxy = InputScalingHelper(address(proxy));
    wrappedProxy.initialize();

    // expect 100
    console.log(wrappedProxy.owner()); // should be deployer
  }
}
