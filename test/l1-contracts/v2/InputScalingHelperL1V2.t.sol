// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console} from 'forge-std/Test.sol';
import {IMetaAggregationRouterV2} from 'src/interfaces/IMetaAggregationRouterV2.sol';
import {IExecutorHelper} from 'src/interfaces/IExecutorHelper.sol';
import {IAggregationExecutor as IExecutorL1} from 'src/interfaces/IAggregationExecutor.sol';
import {InputScalingHelperV2} from 'src/l1-contracts/InputScalingHelperV2.sol';
import {DexHelper01} from 'src/helpers/l1/DexHelper01.sol';

import {TestL1DataWriter as TestDataWriter} from './TestL1DataWriter.sol';
import {BaseConfig} from './BaseConfig.sol';

contract InputScalingHelperL1V2Test is TestDataWriter {
  InputScalingHelperV2 scaleHelper = new InputScalingHelperV2();
  DexHelper01 dexHelper1 = new DexHelper01();
  uint16 DEX_NUM;

  function _getFuncSelectorList() internal pure returns (bytes4[] memory funcSelectorList) {
    funcSelectorList = new bytes4[](70);
    funcSelectorList[0] = IExecutorHelper.executeUniswap.selector;
    funcSelectorList[1] = IExecutorHelper.executeStableSwap.selector;
    funcSelectorList[2] = IExecutorHelper.executeCurve.selector;
    funcSelectorList[3] = IExecutorHelper.executeKSClassic.selector;
    funcSelectorList[4] = IExecutorHelper.executeUniV3KSElastic.selector;
    funcSelectorList[5] = IExecutorHelper.executeBalV2.selector;
    funcSelectorList[6] = IExecutorHelper.executeWrappedstETH.selector;
    funcSelectorList[7] = IExecutorHelper.executeStEth.selector;
    funcSelectorList[8] = IExecutorHelper.executeDODO.selector;
    funcSelectorList[9] = IExecutorHelper.executeVelodrome.selector;
    funcSelectorList[10] = IExecutorHelper.executeGMX.selector;
    funcSelectorList[11] = IExecutorHelper.executeSynthetix.selector;
    funcSelectorList[12] = IExecutorHelper.executeCamelot.selector;
    funcSelectorList[13] = IExecutorHelper.executePSM.selector;
    funcSelectorList[14] = IExecutorHelper.executeFrax.selector;
    funcSelectorList[15] = IExecutorHelper.executePlatypus.selector;
    funcSelectorList[16] = IExecutorHelper.executeMaverick.selector;
    funcSelectorList[17] = IExecutorHelper.executeSyncSwap.selector;
    funcSelectorList[18] = IExecutorHelper.executeAlgebraV1.selector;
    funcSelectorList[19] = IExecutorHelper.executeBalancerBatch.selector;
    funcSelectorList[20] = IExecutorHelper.executeWombat.selector;
    funcSelectorList[21] = IExecutorHelper.executeMantis.selector;
    funcSelectorList[22] = IExecutorHelper.executeIziSwap.selector;
    funcSelectorList[23] = IExecutorHelper.executeWooFiV2.selector;
    funcSelectorList[24] = IExecutorHelper.executeTraderJoeV2.selector;
    funcSelectorList[25] = IExecutorHelper.executePancakeStableSwap.selector;
    funcSelectorList[26] = IExecutorHelper.executeLevelFiV2.selector;
    funcSelectorList[27] = IExecutorHelper.executeGMXGLP.selector;
    funcSelectorList[28] = IExecutorHelper.executeVooi.selector;
    funcSelectorList[29] = IExecutorHelper.executeVelocoreV2.selector;
    funcSelectorList[30] = IExecutorHelper.executeMaticMigrate.selector;
    funcSelectorList[31] = IExecutorHelper.executeSmardex.selector;
    funcSelectorList[32] = IExecutorHelper.executeSolidlyV2.selector;
    funcSelectorList[33] = IExecutorHelper.executeKokonut.selector;
    funcSelectorList[34] = IExecutorHelper.executeBalancerV1.selector;
    funcSelectorList[35] = IExecutorHelper.executeNomiswapStable.selector;
    funcSelectorList[36] = IExecutorHelper.executeArbswapStable.selector;
    funcSelectorList[37] = IExecutorHelper.executeBancorV2.selector;
    funcSelectorList[38] = IExecutorHelper.executeBancorV3.selector;
    funcSelectorList[39] = IExecutorHelper.executeAmbient.selector;
    funcSelectorList[40] = IExecutorHelper.executeLighterV2.selector;
    funcSelectorList[41] = IExecutorHelper.executeUniV1.selector;
    funcSelectorList[42] = IExecutorHelper.executeEtherFieETH.selector;
    funcSelectorList[43] = IExecutorHelper.executeEtherFiWeETH.selector;
    funcSelectorList[44] = IExecutorHelper.executeKelp.selector;
    funcSelectorList[45] = IExecutorHelper.executeEthenaSusde.selector;
    funcSelectorList[46] = IExecutorHelper.executeRocketPool.selector;
    funcSelectorList[47] = IExecutorHelper.executeMakersDAI.selector;
    funcSelectorList[48] = IExecutorHelper.executeRenzo.selector;
    funcSelectorList[49] = IExecutorHelper.executeWBETH.selector;
    funcSelectorList[50] = IExecutorHelper.executeMantleETH.selector;
    funcSelectorList[51] = IExecutorHelper.executeFrxETH.selector;
    funcSelectorList[52] = IExecutorHelper.executeSfrxETH.selector;
    funcSelectorList[53] = IExecutorHelper.executeSfrxETHConvertor.selector;
    funcSelectorList[54] = IExecutorHelper.executeSwellETH.selector;
    funcSelectorList[55] = IExecutorHelper.executeRswETH.selector;
    funcSelectorList[56] = IExecutorHelper.executeStaderETHx.selector;
    funcSelectorList[57] = IExecutorHelper.executeOriginETH.selector;
    funcSelectorList[58] = IExecutorHelper.executePrimeETH.selector;
    funcSelectorList[59] = IExecutorHelper.executeMantleUsd.selector;
    funcSelectorList[60] = IExecutorHelper.executeBedrockUniETH.selector;
    funcSelectorList[61] = IExecutorHelper.executeMaiPSM.selector;
    funcSelectorList[62] = IExecutorHelper.executePufferFinance.selector;
    funcSelectorList[63] = IExecutorHelper.executeRfq.selector;
    funcSelectorList[64] = IExecutorHelper.executeHashflow.selector;
    funcSelectorList[65] = IExecutorHelper.executeNative.selector;
    funcSelectorList[66] = IExecutorHelper.executeKyberDSLO.selector;
    funcSelectorList[67] = IExecutorHelper.executeKyberLimitOrder.selector;
    funcSelectorList[68] = IExecutorHelper.executeSymbioticLRT.selector;
    funcSelectorList[69] = IExecutorHelper.executeMaverickV2.selector;
  }

  function setUp() public {
    mockParams.callTarget = makeAddr('callTarget');
    mockParams.approveTarget = makeAddr('approveTarget');
    mockParams.srcToken = makeAddr('srcToken');
    mockParams.dstToken = makeAddr('dstToken');
    mockParams.dstReceiver = makeAddr('dstReceiver');

    mockParams.srcReceivers.push(mockParams.callTarget);
    mockParams.srcReceivers.push(makeAddr('fee_receiver'));

    bytes4[] memory funcSelectorList = _getFuncSelectorList();

    uint256 listLength = funcSelectorList.length;

    address[] memory executorList = new address[](listLength);

    for (uint16 i; i < listLength; i++) {
      executorList[i] = address(dexHelper1);
    }

    scaleHelper.batchUpdateHelpers(funcSelectorList, executorList);
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

  function _assumeDexName(uint8 dexName, bool excludeNotSupported) internal pure {
    vm.assume(dexName <= uint8(type(BaseConfig.DexName).max));

    if (excludeNotSupported) {
      // can't mock test with mock data, but we can scale for value 2 (Native)
      vm.assume(dexName > 2);
    } else {
      vm.assume(dexName < 2);
    }
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
    _assumeDexName({dexName: dexName, excludeNotSupported: true});

    console.log(dexName);
    vm.assume(noSequences > 0 && noSequences < 3);

    mockParams.amount = oldAmount;
    mockParams.minReturnAmount = minReturnAmount;
    mockParams.recipientFlag = recipientFlag;
    mockParams.noSequences = noSequences;

    for (uint256 i; i < mockParams.noSequences; ++i) {
      mockParams.swapSequences.push();
      mockParams.swapSequences[i].push(_createDexData(BaseConfig.DexName(dexName)));
      mockParams.swapSequences[i].push(_createDexData(BaseConfig.DexName(dexName)));
    }

    bytes memory rawData = abi.encodeWithSelector(
      IMetaAggregationRouterV2.swap.selector, _createMockSwapExecutionParams({simpleMode: false})
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
    uint8 noSequences
  ) public {
    _assumeConditions(oldAmount, newAmount, minReturnAmount, recipientFlag);
    _assumeDexName({dexName: dexName, excludeNotSupported: false});
    vm.assume(oldAmount != newAmount);

    console.log(dexName);
    vm.assume(noSequences > 0 && noSequences < 3);

    mockParams.amount = oldAmount;
    mockParams.minReturnAmount = minReturnAmount;
    mockParams.recipientFlag = recipientFlag;
    mockParams.noSequences = noSequences;

    for (uint256 i; i < mockParams.noSequences; ++i) {
      mockParams.swapSequences.push();
      mockParams.swapSequences[i].push(_createDexData(BaseConfig.DexName(dexName)));
      mockParams.swapSequences[i].push(_createDexData(BaseConfig.DexName(dexName)));
    }

    bytes memory rawData = abi.encodeWithSelector(
      IMetaAggregationRouterV2.swap.selector, _createMockSwapExecutionParams({simpleMode: false})
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
    _assumeDexName({dexName: dexName, excludeNotSupported: true});

    console.log(dexName);
    vm.assume(noSequences > 0 && noSequences < 3);

    mockParams.amount = oldAmount;
    mockParams.minReturnAmount = minReturnAmount;
    mockParams.recipientFlag = recipientFlag;
    mockParams.noSequences = noSequences;

    for (uint256 i; i < mockParams.noSequences; ++i) {
      mockParams.swapSequences.push();
      mockParams.swapSequences[i].push(_createDexData(BaseConfig.DexName(dexName)));
      mockParams.swapSequences[i].push(_createDexData(BaseConfig.DexName(dexName)));
    }

    IMetaAggregationRouterV2.SwapExecutionParams memory exec =
      _createMockSwapExecutionParams({simpleMode: true});

    bytes memory rawData = abi.encodeWithSelector(
      IMetaAggregationRouterV2.swapSimpleMode.selector,
      exec.callTarget,
      exec.desc,
      exec.targetData,
      exec.clientData
    );

    (bool isSuccess, bytes memory scaledRawData) =
      scaleHelper.getScaledInputData(rawData, newAmount);

    assertEq(isSuccess, true);

    _assertScaledData(rawData, scaledRawData, oldAmount, newAmount, true);
  }
}
