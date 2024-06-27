// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console} from 'forge-std/Test.sol';
import {InputScalingHelperL2} from 'src/l2-contracts/InputScalingHelperL2.sol';
import {DexWriter} from './DexWriter.sol';
import {IMetaAggregationRouterV2} from 'src/interfaces/IMetaAggregationRouterV2.sol';
import {IAggregationExecutorOptimistic as IExecutorL2} from
  'src/interfaces/IAggregationExecutorOptimistic.sol';
import {Reader} from './DexScalersTest.t.sol';
import {TestDataWriter} from './TestDataWriter.sol';

contract InputScalingHelperL2Test is TestDataWriter {
  InputScalingHelperL2 helper = new InputScalingHelperL2();

  function setUp() public {
    mockParams.callTarget = makeAddr('callTarget');
    mockParams.approveTarget = makeAddr('approveTarget');
    mockParams.srcToken = makeAddr('srcToken');
    mockParams.dstToken = makeAddr('dstToken');
    mockParams.dstReceiver = makeAddr('dstReceiver');

    mockParams.srcReceivers.push(mockParams.callTarget);
    mockParams.srcReceivers.push(makeAddr('fee_receiver'));
  }

  function _assumeConditions(
    uint128 oldAmount,
    uint128 newAmount,
    uint128 minReturnAmount,
    uint8 recipientFlag
  ) internal pure {
    vm.assume(recipientFlag < 3);
    vm.assume(oldAmount != 0);
    vm.assume(newAmount != 0);

    vm.assume(uint256(minReturnAmount) * newAmount / oldAmount < type(uint128).max);
  }

  function _assumeDexType(uint8 dexType, bool excludeNotSupported) internal pure {
    vm.assume(dexType <= uint8(type(InputScalingHelperL2.DexIndex).max));

    if (excludeNotSupported) {
      vm.assume(
        InputScalingHelperL2.DexIndex(dexType) != InputScalingHelperL2.DexIndex.SwaapV2
          && InputScalingHelperL2.DexIndex(dexType) != InputScalingHelperL2.DexIndex.Hashflow
          && InputScalingHelperL2.DexIndex(dexType) != InputScalingHelperL2.DexIndex.Native
          && InputScalingHelperL2.DexIndex(dexType) != InputScalingHelperL2.DexIndex.Bebop
      );
    } else {
      vm.assume(
        InputScalingHelperL2.DexIndex(dexType) == InputScalingHelperL2.DexIndex.SwaapV2
          || InputScalingHelperL2.DexIndex(dexType) == InputScalingHelperL2.DexIndex.Hashflow
          || InputScalingHelperL2.DexIndex(dexType) == InputScalingHelperL2.DexIndex.Native
          || InputScalingHelperL2.DexIndex(dexType) == InputScalingHelperL2.DexIndex.Bebop
      );
    }
  }

  function test_swapNormalMode(
    uint128 oldAmount,
    uint128 newAmount,
    uint128 minReturnAmount,
    uint8 recipientFlag,
    uint8 dexType,
    uint8 noSequences
  ) public {
    _assumeConditions(oldAmount, newAmount, minReturnAmount, recipientFlag);
    _assumeDexType(dexType, true);
    vm.assume(noSequences > 0 && noSequences < 3);

    mockParams.amount = oldAmount;
    mockParams.minReturnAmount = minReturnAmount;
    mockParams.recipientFlag = recipientFlag;
    mockParams.noSequences = noSequences;

    for (uint256 i; i < mockParams.noSequences; ++i) {
      mockParams.swapSequences.push();
      mockParams.swapSequences[i].push(_createDexData(InputScalingHelperL2.DexIndex(dexType), 0));
      mockParams.swapSequences[i].push(_createDexData(InputScalingHelperL2.DexIndex(dexType), 1));
    }

    bytes memory rawData = abi.encodeWithSelector(
      IMetaAggregationRouterV2.swap.selector, _createMockSwapExecutionParams(false)
    );

    bytes memory scaledRawData = helper.getScaledInputData(rawData, newAmount);

    _assertScaledData(rawData, scaledRawData, oldAmount, newAmount, false);
  }

  // function test_revert_swapNormalMode(
  //   uint128 oldAmount,
  //   uint128 newAmount,
  //   uint128 minReturnAmount,
  //   uint8 recipientFlag,
  //   uint8 dexType
  // ) public {
  //   _assumeConditions(oldAmount, newAmount, minReturnAmount, recipientFlag);
  //   _assumeDexType(dexType, false);
  //   vm.assume(oldAmount != newAmount);

  //   mockParams.amount = oldAmount;
  //   mockParams.minReturnAmount = minReturnAmount;
  //   mockParams.recipientFlag = recipientFlag;
  //   mockParams.noSequences = 2;

  //   for (uint256 i; i < mockParams.noSequences; ++i) {
  //     mockParams.swapSequences.push();
  //     mockParams.swapSequences[i].push(_createDexData(InputScalingHelperL2.DexIndex(dexType), 0));
  //     mockParams.swapSequences[i].push(_createDexData(InputScalingHelperL2.DexIndex(dexType), 1));
  //   }

  //   bytes memory rawData = abi.encodeWithSelector(
  //     IMetaAggregationRouterV2.swap.selector, _createMockSwapExecutionParams(false)
  //   );

  //   vm.expectRevert();
  //   helper.getScaledInputData(rawData, newAmount);
  // }

  function test_swapSimpleMode(
    uint128 oldAmount,
    uint128 newAmount,
    uint128 minReturnAmount,
    uint8 recipientFlag,
    uint8 dexType,
    uint8 noSequences
  ) public {
    _assumeConditions(oldAmount, newAmount, minReturnAmount, recipientFlag);
    _assumeDexType(dexType, true);
    vm.assume(noSequences > 0 && noSequences < 3);

    console.log('dexType ', dexType);

    mockParams.amount = oldAmount;
    mockParams.minReturnAmount = minReturnAmount;
    mockParams.recipientFlag = recipientFlag;
    mockParams.noSequences = noSequences;

    for (uint256 i; i < mockParams.noSequences; ++i) {
      mockParams.swapSequences.push();
      mockParams.swapSequences[i].push(_createDexData(InputScalingHelperL2.DexIndex(dexType), 0));
      mockParams.swapSequences[i].push(_createDexData(InputScalingHelperL2.DexIndex(dexType), 1));
    }

    IMetaAggregationRouterV2.SwapExecutionParams memory exec = _createMockSwapExecutionParams(true);
    bytes memory rawData = abi.encodeWithSelector(
      IMetaAggregationRouterV2.swapSimpleMode.selector,
      exec.callTarget,
      exec.desc,
      exec.targetData,
      exec.clientData
    );

    bytes memory scaledRawData = helper.getScaledInputData(rawData, newAmount);

    _assertScaledData(rawData, scaledRawData, oldAmount, newAmount, true);
  }

  // function test_revert_swapSimpleMode(
  //   uint128 oldAmount,
  //   uint128 newAmount,
  //   uint128 minReturnAmount,
  //   uint8 recipientFlag,
  //   uint8 dexType
  // ) public {
  //   _assumeConditions(oldAmount, newAmount, minReturnAmount, recipientFlag);
  //   _assumeDexType(dexType, false);
  //   vm.assume(oldAmount != newAmount);

  //   mockParams.amount = oldAmount;
  //   mockParams.minReturnAmount = minReturnAmount;
  //   mockParams.recipientFlag = recipientFlag;
  //   mockParams.noSequences = 2;

  //   for (uint256 i; i < mockParams.noSequences; ++i) {
  //     mockParams.swapSequences.push();
  //     mockParams.swapSequences[i].push(_createDexData(InputScalingHelperL2.DexIndex(dexType), 0));
  //     mockParams.swapSequences[i].push(_createDexData(InputScalingHelperL2.DexIndex(dexType), 1));
  //   }

  //   IMetaAggregationRouterV2.SwapExecutionParams memory exec = _createMockSwapExecutionParams(true);
  //   bytes memory rawData = abi.encodeWithSelector(
  //     IMetaAggregationRouterV2.swapSimpleMode.selector,
  //     exec.callTarget,
  //     exec.desc,
  //     exec.targetData,
  //     exec.clientData
  //   );

  //   vm.expectRevert();

  //   helper.getScaledInputData(rawData, newAmount);
  // }
}
