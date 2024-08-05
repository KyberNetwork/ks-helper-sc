// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console} from 'forge-std/Test.sol';
import {InputScalingHelperL2V2} from 'src/l2-contracts/InputScalingHelperL2V2.sol';
import {IMetaAggregationRouterV2} from 'src/interfaces/IMetaAggregationRouterV2.sol';
import {IExecutorHelperL2} from 'src/interfaces/IExecutorHelperL2.sol';

import {IAggregationExecutorOptimistic as IExecutorL2} from
  'src/interfaces/IAggregationExecutorOptimistic.sol';
import {DexHelper01L2} from 'src/helpers/l2/DexHelper01L2.sol';

import {DexWriter} from 'test/l2-contracts/base/DexWriter.sol';
import {Reader} from 'test/l2-contracts/base/DexScalersTest.t.sol';
import {DataWriterL2V2} from './DataWriterL2V2.sol';

import {BaseConfig} from './BaseConfig.sol';

contract InputScalingHelperL2V2Test is DataWriterL2V2 {
  InputScalingHelperL2V2 scaleHelper = new InputScalingHelperL2V2();
  DexHelper01L2 dexHelper1 = new DexHelper01L2();

  uint256[] arrDexNameIndex = [38]; // swaapv2

  function _getFuncSelectorList() internal pure returns (bytes4[] memory funcSelectorList) {
    funcSelectorList = new bytes4[](52);
    funcSelectorList[0] = IExecutorHelperL2.executeUniswap.selector;
    funcSelectorList[1] = IExecutorHelperL2.executeKSClassic.selector;
    funcSelectorList[2] = IExecutorHelperL2.executeVelodrome.selector;
    funcSelectorList[3] = IExecutorHelperL2.executeFrax.selector;
    funcSelectorList[4] = IExecutorHelperL2.executeCamelot.selector;
    funcSelectorList[5] = IExecutorHelperL2.executeKyberLimitOrder.selector;
    funcSelectorList[6] = IExecutorHelperL2.executeRfq.selector;
    funcSelectorList[7] = IExecutorHelperL2.executeHashflow.selector;
    funcSelectorList[8] = IExecutorHelperL2.executeStableSwap.selector;
    funcSelectorList[9] = IExecutorHelperL2.executeCurve.selector;
    funcSelectorList[10] = IExecutorHelperL2.executeUniV3KSElastic.selector;
    funcSelectorList[11] = IExecutorHelperL2.executeBalV2.selector;
    funcSelectorList[12] = IExecutorHelperL2.executeDODO.selector;
    funcSelectorList[13] = IExecutorHelperL2.executeGMX.selector;
    funcSelectorList[14] = IExecutorHelperL2.executeSynthetix.selector;
    funcSelectorList[15] = IExecutorHelperL2.executeWrappedstETH.selector;
    funcSelectorList[16] = IExecutorHelperL2.executeStEth.selector;
    funcSelectorList[17] = IExecutorHelperL2.executePlatypus.selector;
    funcSelectorList[18] = IExecutorHelperL2.executePSM.selector;
    funcSelectorList[19] = IExecutorHelperL2.executeMaverick.selector;
    funcSelectorList[20] = IExecutorHelperL2.executeSyncSwap.selector;
    funcSelectorList[21] = IExecutorHelperL2.executeAlgebraV1.selector;
    funcSelectorList[22] = IExecutorHelperL2.executeBalancerBatch.selector;
    funcSelectorList[23] = IExecutorHelperL2.executeMantis.selector;
    funcSelectorList[24] = IExecutorHelperL2.executeWombat.selector;
    funcSelectorList[25] = IExecutorHelperL2.executeWooFiV2.selector;
    funcSelectorList[26] = IExecutorHelperL2.executeIziSwap.selector;
    funcSelectorList[27] = IExecutorHelperL2.executeTraderJoeV2.selector;
    funcSelectorList[28] = IExecutorHelperL2.executeKyberDSLO.selector;
    funcSelectorList[29] = IExecutorHelperL2.executeLevelFiV2.selector;
    funcSelectorList[30] = IExecutorHelperL2.executeGMXGLP.selector;
    funcSelectorList[31] = IExecutorHelperL2.executePancakeStableSwap.selector;
    funcSelectorList[32] = IExecutorHelperL2.executeVooi.selector;
    funcSelectorList[33] = IExecutorHelperL2.executeVelocoreV2.selector;
    funcSelectorList[34] = IExecutorHelperL2.executeSmardex.selector;
    funcSelectorList[35] = IExecutorHelperL2.executeSolidlyV2.selector;
    funcSelectorList[36] = IExecutorHelperL2.executeKokonut.selector;
    funcSelectorList[37] = IExecutorHelperL2.executeBalancerV1.selector;
    funcSelectorList[38] = IExecutorHelperL2.executeSwaapV2.selector;
    funcSelectorList[39] = IExecutorHelperL2.executeNomiswapStable.selector;
    funcSelectorList[40] = IExecutorHelperL2.executeArbswapStable.selector;
    funcSelectorList[41] = IExecutorHelperL2.executeBancorV3.selector;
    funcSelectorList[42] = IExecutorHelperL2.executeBancorV2.selector;
    funcSelectorList[43] = IExecutorHelperL2.executeAmbient.selector;
    funcSelectorList[44] = IExecutorHelperL2.executeNative.selector;
    funcSelectorList[45] = IExecutorHelperL2.executeLighterV2.selector;
    funcSelectorList[46] = IExecutorHelperL2.executeBebop.selector;
    funcSelectorList[47] = IExecutorHelperL2.executeMantleUsd.selector;
    funcSelectorList[48] = IExecutorHelperL2.executeMaiPSM.selector;
    funcSelectorList[49] = IExecutorHelperL2.executeKelp.selector;
    funcSelectorList[50] = IExecutorHelperL2.executeSymbioticLRT.selector;
    funcSelectorList[51] = IExecutorHelperL2.executeMaverickV2.selector;
  }

  function setUp() public {
    vm.label(address(dexHelper1), 'ScaleHelper SC');
    mockParams.callTarget = makeAddr('callTarget');
    mockParams.approveTarget = makeAddr('approveTarget');
    mockParams.srcToken = makeAddr('srcToken');
    mockParams.dstToken = makeAddr('dstToken');
    mockParams.dstReceiver = makeAddr('dstReceiver');

    mockParams.srcReceivers.push(mockParams.callTarget);
    mockParams.srcReceivers.push(makeAddr('fee_receiver'));

    bytes4[] memory funcSelectorList = _getFuncSelectorList();

    uint256 listLength = funcSelectorList.length;

    address[] memory helperList = new address[](listLength);
    uint256[] memory indexList = new uint256[](listLength);

    for (uint16 i; i < listLength; i++) {
      indexList[i] = i;
      helperList[i] = address(dexHelper1);
    }

    scaleHelper.batchUpdateHelpers(funcSelectorList, indexList, helperList);
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

  function _assumeConditionsFail(
    uint128 oldAmount,
    uint128 newAmount,
    uint128 minReturnAmount
  ) internal pure {
    vm.assume(oldAmount != newAmount);
    vm.assume(uint256(minReturnAmount) * newAmount / oldAmount < type(uint128).max);
  }

  function _assumeDexNameExcludedNotSupported(uint8 dexName) internal pure {
    vm.assume(dexName <= uint8(type(BaseConfig.DexName).max));
    // swaapv2
    vm.assume(dexName != 38);
  }

  function test_swapNormalMode(
    uint128 oldAmount,
    uint128 newAmount,
    uint128 minReturnAmount,
    uint8 recipientFlag,
    uint8 dexName,
    uint8 noSequences
  ) public {
    _assumeConditions(oldAmount, newAmount, minReturnAmount, recipientFlag);
    _assumeDexNameExcludedNotSupported(dexName);

    console.log('dexName ', dexName);

    // native and bebop not support scale up
    if (dexName == 44 || dexName == 46) {
      newAmount = oldAmount - oldAmount / 3 - 1;
    }
    vm.assume(noSequences > 0 && noSequences < 3);

    mockParams.amount = oldAmount;
    mockParams.minReturnAmount = minReturnAmount;
    mockParams.recipientFlag = recipientFlag;
    mockParams.noSequences = noSequences;

    for (uint256 i; i < mockParams.noSequences; ++i) {
      mockParams.swapSequences.push();
      mockParams.swapSequences[i].push(_createDexData(BaseConfig.DexName(dexName), 0));
      mockParams.swapSequences[i].push(_createDexData(BaseConfig.DexName(dexName), 1));
    }

    bytes memory rawData = abi.encodeWithSelector(
      IMetaAggregationRouterV2.swap.selector, _createMockSwapExecutionParams(false)
    );

    (bool isSuccess, bytes memory scaledData) = scaleHelper.getScaledInputData(rawData, newAmount);

    assertEq(isSuccess, true);

    _assertScaledData(rawData, scaledData, oldAmount, newAmount, false);
  }

  function test_fail_swapNormalMode(
    uint128 oldAmount,
    uint128 newAmount,
    uint128 minReturnAmount,
    uint8 recipientFlag,
    uint8 dexName,
    uint8 noSequences,
    uint256 dexSeed
  ) public {
    oldAmount = uint128(bound(oldAmount, 1, type(uint128).max));
    newAmount = uint128(bound(newAmount, 1, type(uint128).max));
    _assumeConditionsFail(oldAmount, newAmount, minReturnAmount);

    dexSeed = bound(dexSeed, 0, arrDexNameIndex.length - 1);
    recipientFlag = uint8(bound(recipientFlag, 0, 2));
    dexName = uint8(bound(dexName, 0, uint8(type(BaseConfig.DexName).max)));
    vm.assume(dexName == arrDexNameIndex[dexSeed]);

    // native and bebop not support scale up
    if (dexName == 44 || dexName == 46) {
      newAmount = oldAmount - oldAmount / 3 - 1;
    }

    console.log('dexName ', dexName);
    noSequences = uint8(bound(noSequences, 1, 2));

    mockParams.amount = oldAmount;
    mockParams.minReturnAmount = minReturnAmount;
    mockParams.recipientFlag = recipientFlag;
    mockParams.noSequences = noSequences;

    for (uint256 i; i < mockParams.noSequences; ++i) {
      mockParams.swapSequences.push();
      mockParams.swapSequences[i].push(_createDexData(BaseConfig.DexName(dexName), 0));
      mockParams.swapSequences[i].push(_createDexData(BaseConfig.DexName(dexName), 1));
    }

    bytes memory rawData = abi.encodeWithSelector(
      IMetaAggregationRouterV2.swap.selector, _createMockSwapExecutionParams(false)
    );

    (bool isSuccess,) = scaleHelper.getScaledInputData(rawData, newAmount);

    assertEq(isSuccess, false);
  }

  function test_swapSimpleMode(
    uint128 oldAmount,
    uint128 newAmount,
    uint128 minReturnAmount,
    uint8 recipientFlag,
    uint8 dexName,
    uint8 noSequences
  ) public {
    _assumeConditions(oldAmount, newAmount, minReturnAmount, recipientFlag);
    _assumeDexNameExcludedNotSupported(dexName);
    vm.assume(noSequences > 0 && noSequences < 3);

    console.log('dexName ', dexName);

    // native and bebop not support scale up
    if (dexName == 44 || dexName == 46) {
      newAmount = oldAmount - oldAmount / 3 - 1;
    }

    mockParams.amount = oldAmount;
    mockParams.minReturnAmount = minReturnAmount;
    mockParams.recipientFlag = recipientFlag;
    mockParams.noSequences = noSequences;

    for (uint256 i; i < mockParams.noSequences; ++i) {
      mockParams.swapSequences.push();
      mockParams.swapSequences[i].push(_createDexData(BaseConfig.DexName(dexName), 0));
      mockParams.swapSequences[i].push(_createDexData(BaseConfig.DexName(dexName), 1));
    }

    // true is simple mode
    IMetaAggregationRouterV2.SwapExecutionParams memory exec = _createMockSwapExecutionParams(true);
    bytes memory rawData = abi.encodeWithSelector(
      IMetaAggregationRouterV2.swapSimpleMode.selector,
      exec.callTarget,
      exec.desc,
      exec.targetData,
      exec.clientData
    );

    (bool isSuccess, bytes memory scaledData) = scaleHelper.getScaledInputData(rawData, newAmount);

    assertEq(isSuccess, true);

    _assertScaledData(rawData, scaledData, oldAmount, newAmount, true);
  }
}
