// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import 'forge-std/Test.sol';
import 'forge-std/console.sol';
import 'forge-std/StdJson.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '../src/interfaces/IMetaAggregationRouterV2.sol';
import '../src/interfaces/IAggregationExecutor.sol';
import '../src/InputScalingHelper.sol';

contract BaseInputScalingTest is Test {
  using stdJson for string;

  address private constant ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
  bytes swapInputPath;
  address routerAddress;
  IMetaAggregationRouterV2 router;
  InputScalingHelper scaleHelper;
  address alice;

  struct SwapTx {
    uint256 blockNumber;
    address executorAddress;
    bytes encodedData;
    address sender;
    uint256 value;
  }

  function _readInput(
    bytes memory _inputPath,
    bytes memory testName
  ) internal virtual returns (SwapTx memory swap) {
    string memory root = vm.projectRoot();
    string memory path;
    path = string(bytes.concat(bytes(root), _inputPath));
    string memory jsonData = vm.readFile(path);
    swap.encodedData = jsonData.readBytes(string(bytes.concat(testName, '.data')));
    swap.executorAddress = jsonData.readAddress(string(bytes.concat(testName, '.executorAddress')));
    swap.blockNumber = jsonData.readUint(string(bytes.concat(testName, '.blockNumber')));
    swap.sender = jsonData.readAddress(string(bytes.concat(testName, '.sender')));
    swap.value = uint256(jsonData.readBytes32(string(bytes.concat(testName, '.value'))));
  }

  function _swap(bytes memory inputData, uint256 value) internal returns (uint256 returnAmount) {
    bytes4 selector;
    assembly {
      selector := mload(add(inputData, 0x20))
    }
    vm.startPrank(alice);

    if (selector == IMetaAggregationRouterV2.swapSimpleMode.selector) {
      bytes memory dataToDecode = new bytes(inputData.length - 4);
      for (uint256 i = 0; i < inputData.length - 4; ++i) {
        dataToDecode[i] = inputData[i + 4];
      }
      (
        IAggregationExecutor caller,
        IMetaAggregationRouterV2.SwapDescriptionV2 memory desc,
        bytes memory executorData,
        bytes memory clientData
      ) = abi.decode(
        dataToDecode,
        (IAggregationExecutor, IMetaAggregationRouterV2.SwapDescriptionV2, bytes, bytes)
      );
      if (address(desc.srcToken) != ETH_ADDRESS) {
        desc.srcToken.approve(address(router), 1e27);
      }
      (returnAmount,) = router.swapSimpleMode(caller, desc, executorData, clientData);
      vm.stopPrank();
    } else if (selector == IMetaAggregationRouterV2.swap.selector) {
      bytes memory dataToDecode = new bytes(inputData.length - 4);
      for (uint256 i = 0; i < inputData.length - 4; ++i) {
        dataToDecode[i] = inputData[i + 4];
      }
      IMetaAggregationRouterV2.SwapExecutionParams memory execution =
        abi.decode(dataToDecode, (IMetaAggregationRouterV2.SwapExecutionParams));

      if (address(execution.desc.srcToken) != ETH_ADDRESS) {
        execution.desc.srcToken.approve(address(router), 1e27);
        value = 0;
      }
      (returnAmount,) = router.swap{value: value}(execution);
      vm.stopPrank();
    }
  }

  function setUp() public virtual {
    swapInputPath = '/test/onchain-data/swap.json';
    routerAddress = 0x6131B5fae19EA4f9D964eAc0408E4408b66337b5;
    scaleHelper = new InputScalingHelper();
    vm.makePersistent(address(scaleHelper));
  }
}
