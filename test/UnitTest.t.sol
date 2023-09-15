// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import 'forge-std/Test.sol';
import 'forge-std/console.sol';
import 'forge-std/StdJson.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '../src/InputScalingHelper.sol';
import './BaseInputScaling.t.sol';

contract UniswapTest is BaseInputScalingTest {
  using stdJson for string;

  address private constant ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

  function testSwap_IncreaseETH() public {
    //swap amount = 10000 ether
    SwapTx memory swap = _readInput(swapInputPath, '.swap_10000_ETH_USDC');

    string memory url = vm.envString('ETH_NODE_URL');
    vm.createSelectFork(url, swap.blockNumber - 1);
    alice = swap.sender;
    router = IMetaAggregationRouterV2(payable(routerAddress));
    bytes memory inputData = swap.encodedData;

    //non-scaled swap
    uint256 snapshot = vm.snapshot();
    uint256 initialResult = _swap(inputData, swap.value);

    //scaled swap
    vm.revertTo(snapshot);
    uint256 newAmount = 11_000 ether;
    bytes memory newData = scaleHelper.getScaledInputData(inputData, newAmount);
    uint256 afterResult = _swap(newData, newAmount);
    console.log(initialResult, afterResult);
  }

  function testSwap_DecreaseETH() public {
    //swap amount = 10000 ether
    SwapTx memory swap = _readInput(swapInputPath, '.swap_10000_ETH_USDC');

    string memory url = vm.envString('ETH_NODE_URL');
    vm.createSelectFork(url, swap.blockNumber - 1);
    alice = swap.sender;
    router = IMetaAggregationRouterV2(payable(routerAddress));
    bytes memory inputData = swap.encodedData;

    //non-scaled swap
    uint256 snapshot = vm.snapshot();
    uint256 initialResult = _swap(inputData, swap.value);

    //scaled swap
    vm.revertTo(snapshot);
    uint256 newAmount = 0.4 ether;
    bytes memory newData = scaleHelper.getScaledInputData(inputData, newAmount);
    uint256 afterResult = _swap(newData, newAmount);
    console.log(initialResult, afterResult);
  }

  function testSwapSimpleMode_Increase() public {
    //swap amount = 1e12
    SwapTx memory swap = _readInput(swapInputPath, '.swapSimpleMode_1000000_USDC_USDT');

    string memory url = vm.envString('ETH_NODE_URL');
    vm.createSelectFork(url, swap.blockNumber - 1);
    alice = swap.sender;
    router = IMetaAggregationRouterV2(payable(routerAddress));
    bytes memory inputData = swap.encodedData;

    //non-scaled swap
    uint256 snapshot = vm.snapshot();
    uint256 initialResult = _swap(inputData, 0);

    //scaled swap
    vm.revertTo(snapshot);
    uint256 newAmount = 1.1e12;
    bytes memory newData = scaleHelper.getScaledInputData(inputData, newAmount);
    uint256 afterResult = _swap(newData, 0);
    console.log(initialResult, afterResult);
  }

  function testSwapSimpleMode_Decrease() public {
    //swap amount = 1e12
    SwapTx memory swap = _readInput(swapInputPath, '.swapSimpleMode_1000000_USDC_USDT');

    string memory url = vm.envString('ETH_NODE_URL');
    vm.createSelectFork(url, swap.blockNumber - 1);
    alice = swap.sender;
    router = IMetaAggregationRouterV2(payable(routerAddress));
    bytes memory inputData = swap.encodedData;

    //non-scaled swap
    uint256 snapshot = vm.snapshot();
    uint256 initialResult = _swap(inputData, 0);

    //scaled swap
    vm.revertTo(snapshot);
    uint256 newAmount = 0.9e12;
    bytes memory newData = scaleHelper.getScaledInputData(inputData, newAmount);
    uint256 afterResult = _swap(newData, 0);
    console.log(initialResult, afterResult);
  }
}
