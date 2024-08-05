// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console} from 'forge-std/Test.sol';
import {InputScalingHelperL2} from 'src/l2-contracts/InputScalingHelperL2.sol';
import {IMetaAggregationRouterV2} from 'src/interfaces/IMetaAggregationRouterV2.sol';

import {ExecutorReader} from 'src/l2-contracts/ExecutorReader.sol';
import {IExecutorHelperL2} from 'src/interfaces/IExecutorHelperL2.sol';
import {IExecutorHelperL2Struct} from 'src/interfaces/IExecutorHelperL2Struct.sol';
import {IAggregationExecutorOptimistic as IExecutorL2} from
  'src/interfaces/IAggregationExecutorOptimistic.sol';
import {Reader} from 'test/l2-contracts/base/DexScalersTest.t.sol';
import {BaseConfig} from './BaseConfig.sol';

contract AssertionHelperL2V2 is Test {
  Reader reader = new Reader();

  address constant MOCK_ADDRESS = address(0);

  struct MockParams {
    address callTarget;
    address approveTarget;
    uint256 amount;
    uint256 minReturnAmount;
    address srcToken;
    address dstToken;
    address dstReceiver;
    address[] srcReceivers;
    uint256[] srcAmounts;
    uint8 recipientFlag;
    uint256 noSequences;
    IExecutorL2.Swap[][] swapSequences;
    address[] simpleSwapFirstPools;
    uint256[] simpleSwapFirstAmounts;
  }

  MockParams mockParams;

  function _assertScaledData(
    bytes memory rawData,
    bytes memory scaledRawData,
    uint256 oldAmount,
    uint256 newAmount,
    bool isSimpleMode
  ) internal {
    assertEq(rawData.length, scaledRawData.length, 'scaled data length not equal to original data');

    // remove first 4 bytes
    scaledRawData = this.excludeSighash(scaledRawData);

    console.log('stuck here ');
    IMetaAggregationRouterV2.SwapExecutionParams memory exec;

    if (isSimpleMode) {
      (exec.callTarget, exec.desc, exec.targetData, exec.clientData) = abi.decode(
        scaledRawData, (address, IMetaAggregationRouterV2.SwapDescriptionV2, bytes, bytes)
      );

      IMetaAggregationRouterV2.SimpleSwapData memory simpleSwapData =
        abi.decode(exec.targetData, (IMetaAggregationRouterV2.SimpleSwapData));

      // check arrays length
      assertEq(simpleSwapData.firstSwapAmounts.length, simpleSwapData.swapDatas.length);
      assertEq(simpleSwapData.firstPools.length, simpleSwapData.swapDatas.length);

      // for each sequence
      for (uint256 i; i < simpleSwapData.firstPools.length; ++i) {
        // check first swap amounts scaled properly
        assertEq(simpleSwapData.firstSwapAmounts[i], mockParams.amount * newAmount / oldAmount);
        (IExecutorL2.Swap[] memory swaps,) =
          ExecutorReader.readSwapSingleSequence(simpleSwapData.swapDatas[i]);

        // check scaled data for first dex
        _assertDexData(
          BaseConfig.DexName(uint32(swaps[0].functionSelector)), swaps[0].data, oldAmount, newAmount
        );
      }
    } else {
      // decode swap execution params should not fail
      exec = abi.decode(scaledRawData, (IMetaAggregationRouterV2.SwapExecutionParams));

      // decode executor data
      IExecutorL2.SwapExecutorDescription memory executorDesc = abi.decode(
        ExecutorReader.readSwapExecutorDescription(exec.targetData),
        (IExecutorL2.SwapExecutorDescription)
      );

      // check scaled data for each first dex
      for (uint256 i; i < executorDesc.swapSequences.length; ++i) {
        _assertDexData(
          BaseConfig.DexName(uint32(executorDesc.swapSequences[i][0].functionSelector)),
          executorDesc.swapSequences[i][0].data,
          oldAmount,
          newAmount
        );
      }
    }

    for (uint256 i; i < exec.desc.srcAmounts.length; ++i) {
      assertEq(
        exec.desc.srcAmounts[i],
        mockParams.amount * newAmount / oldAmount,
        'desc.srcAmounts scaled improperly'
      );
    }

    // check description amount scaled properly
    assertEq(
      exec.desc.amount,
      mockParams.amount * newAmount / oldAmount,
      'router desc amount not scaled properly'
    );

    uint256 expectedMinReturnAmount = mockParams.minReturnAmount * newAmount / oldAmount;
    if (expectedMinReturnAmount == 0) expectedMinReturnAmount = 1;

    assertEq(
      exec.desc.minReturnAmount,
      expectedMinReturnAmount,
      'router desc min return amount not scaled properly'
    );
  }

  function _assertDexData(
    BaseConfig.DexName dexName,
    bytes memory dexData,
    uint256 oldAmount,
    uint256 newAmount
  ) internal {
    function (bytes memory,uint256,uint256) internal fn;

    if (
      dexName == BaseConfig.DexName.UniV1 || dexName == BaseConfig.DexName.KyberDMM
        || dexName == BaseConfig.DexName.Velodrome || dexName == BaseConfig.DexName.Camelot
        || dexName == BaseConfig.DexName.Fraxswap
    ) {
      fn = assertUniData;
    } else if (dexName == BaseConfig.DexName.StableSwap) {
      fn = assertStableSwapData;
    } else if (
      dexName == BaseConfig.DexName.Curve || dexName == BaseConfig.DexName.PancakeStableSwap
    ) {
      fn = assertCurveSwapData;
    } else if (dexName == BaseConfig.DexName.UniswapV3KSElastic) {
      fn = assertUniswapV3KSElasticData;
    } else if (dexName == BaseConfig.DexName.BalancerV2) {
      fn = assertBalancerV2Data;
    } else if (dexName == BaseConfig.DexName.DODO) {
      fn = assertDODOData;
    } else if (dexName == BaseConfig.DexName.GMX) {
      fn = assertGMXData;
    } else if (dexName == BaseConfig.DexName.Synthetix) {
      fn = assertSynthetixData;
    } else if (dexName == BaseConfig.DexName.WstETH) {
      fn = assertWrappedstETHData;
    } else if (dexName == BaseConfig.DexName.StETH) {
      fn = assertStETHData;
    } else if (dexName == BaseConfig.DexName.Platypus) {
      fn = assertPlatypusData;
    } else if (dexName == BaseConfig.DexName.PSM) {
      fn = assertPSMData;
    } else if (dexName == BaseConfig.DexName.Maverick) {
      fn = assertMaverickData;
    } else if (dexName == BaseConfig.DexName.SyncSwap) {
      fn = assertSyncSwapData;
    } else if (dexName == BaseConfig.DexName.AlgebraV1) {
      fn = assertAlgebraV1Data;
    } else if (dexName == BaseConfig.DexName.BalancerBatch) {
      fn = assertBalancerBatchData;
    } else if (
      dexName == BaseConfig.DexName.Mantis || dexName == BaseConfig.DexName.Wombat
        || dexName == BaseConfig.DexName.WooFiV2 || dexName == BaseConfig.DexName.Smardex
        || dexName == BaseConfig.DexName.SolidlyV2 || dexName == BaseConfig.DexName.BancorV3
    ) {
      fn = assertMantisData;
    } else if (dexName == BaseConfig.DexName.iZiSwap) {
      fn = assertIziSwapData;
    } else if (dexName == BaseConfig.DexName.TraderJoeV2) {
      fn = assertTraderJoeV2Data;
    } else if (dexName == BaseConfig.DexName.LevelFiV2) {
      fn = assertLevelFiV2Data;
    } else if (dexName == BaseConfig.DexName.GMXGLP) {
      fn = assertGMXGLPData;
    } else if (dexName == BaseConfig.DexName.Vooi) {
      fn = assertVooiData;
    } else if (dexName == BaseConfig.DexName.VelocoreV2) {
      fn = assertVelocoreV2Data;
    } else if (dexName == BaseConfig.DexName.Kokonut) {
      fn = assertKokonutData;
    } else if (dexName == BaseConfig.DexName.BalancerV1) {
      fn = assertBalancerV1Data;
    } else if (dexName == BaseConfig.DexName.BancorV2) {
      fn = assertBancorV2;
    } else if (dexName == BaseConfig.DexName.Ambient) {
      fn = assertAmbient;
    } else if (dexName == BaseConfig.DexName.Native) {
      fn = assertNative;
    } else if (dexName == BaseConfig.DexName.Bebop) {
      fn = assertBebop;
    } else if (dexName == BaseConfig.DexName.KyberDSLO) {
      fn = assertKyberDSLO;
    } else if (dexName == BaseConfig.DexName.KyberLimitOrder) {
      fn = assertKyberLimitOrder;
    } else if (dexName == BaseConfig.DexName.KyberRFQ) {
      fn = assertKyberRfq;
    } else if (dexName == BaseConfig.DexName.Hashflow) {
      fn = assertHashflow;
    } else if (dexName == BaseConfig.DexName.SymbioticLRT) {
      fn = assertSymbioticLRTData;
    } else if (dexName == BaseConfig.DexName.MaverickV2) {
      fn = assertMaverickV2Data;
    } else {
      fn = assertNothing;
      // do nothing, since we need to check revert condition from InputScalingHelperL2 contract
    }

    fn(dexData, newAmount, oldAmount);
  }

  function assertNothing(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {}

  function assertUniData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readUniSwap({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.UniSwap memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.UniSwap));

    assertEq(data.collectAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertStableSwapData(
    bytes memory dexData,
    uint256 newAmount,
    uint256 oldAmount
  ) internal {
    bytes memory depacked = reader.readStableSwap({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.StableSwap memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.StableSwap));

    assertEq(data.dx, mockParams.amount * newAmount / oldAmount);
  }

  function assertCurveSwapData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readCurveSwap({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.CurveSwap memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.CurveSwap));

    assertEq(data.dx, mockParams.amount * newAmount / oldAmount);
  }

  function assertUniswapV3KSElasticData(
    bytes memory dexData,
    uint256 newAmount,
    uint256 oldAmount
  ) internal {
    bytes memory depacked = reader.readUniswapV3KSElastic({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.UniswapV3KSElastic memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.UniswapV3KSElastic));

    assertEq(data.swapAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertBalancerV2Data(
    bytes memory dexData,
    uint256 newAmount,
    uint256 oldAmount
  ) internal {
    bytes memory depacked = reader.readBalancerV2({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.BalancerV2 memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.BalancerV2));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertDODOData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readDODO({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.DODO memory data = abi.decode(depacked, (IExecutorHelperL2Struct.DODO));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertGMXData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readGMX({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.GMX memory data = abi.decode(depacked, (IExecutorHelperL2Struct.GMX));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertSynthetixData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readSynthetix({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.Synthetix memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.Synthetix));

    assertEq(data.sourceAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertWrappedstETHData(
    bytes memory dexData,
    uint256 newAmount,
    uint256 oldAmount
  ) internal {
    bytes memory depacked = reader.readWrappedstETH({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.WSTETH memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.WSTETH));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertStETHData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    (uint256 amount,) = reader._readUint128AsUint256(dexData, 0);
    assertEq(amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertPlatypusData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readPlatypus({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.Platypus memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.Platypus));

    assertEq(data.collectAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertPSMData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readPSM({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.PSM memory data = abi.decode(depacked, (IExecutorHelperL2Struct.PSM));

    assertEq(data.amountIn, mockParams.amount * newAmount / oldAmount);
  }

  function assertMaverickData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readMaverick({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.Maverick memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.Maverick));

    assertEq(data.swapAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertSyncSwapData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readSyncSwap({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.SyncSwap memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.SyncSwap));

    assertEq(data.collectAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertAlgebraV1Data(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readAlgebraV1({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.AlgebraV1 memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.AlgebraV1));

    assertEq(data.swapAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertBalancerBatchData(
    bytes memory dexData,
    uint256 newAmount,
    uint256 oldAmount
  ) internal {
    bytes memory depacked = reader.readBalancerBatch({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.BalancerBatch memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.BalancerBatch));

    assertEq(data.amountIn, mockParams.amount * newAmount / oldAmount);
  }

  function assertMantisData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readMantis({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.Mantis memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.Mantis));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertIziSwapData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readIziSwap({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.IziSwap memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.IziSwap));

    assertEq(data.swapAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertTraderJoeV2Data(
    bytes memory dexData,
    uint256 newAmount,
    uint256 oldAmount
  ) internal {
    bytes memory depacked = reader.readTraderJoeV2({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.TraderJoeV2 memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.TraderJoeV2));

    assertEq(data.collectAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertLevelFiV2Data(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readLevelFiV2({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.LevelFiV2 memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.LevelFiV2));

    assertEq(data.amountIn, mockParams.amount * newAmount / oldAmount);
  }

  function assertGMXGLPData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readGMXGLP({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.GMXGLP memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.GMXGLP));

    assertEq(data.swapAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertVooiData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readVooi({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.Vooi memory data = abi.decode(depacked, (IExecutorHelperL2Struct.Vooi));

    assertEq(data.fromAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertVelocoreV2Data(
    bytes memory dexData,
    uint256 newAmount,
    uint256 oldAmount
  ) internal {
    bytes memory depacked = reader.readVelocoreV2({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.VelocoreV2 memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.VelocoreV2));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertKokonutData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readKokonut({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.Kokonut memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.Kokonut));

    assertEq(data.dx, mockParams.amount * newAmount / oldAmount);
  }

  function assertBalancerV1Data(
    bytes memory dexData,
    uint256 newAmount,
    uint256 oldAmount
  ) internal {
    bytes memory depacked = reader.readBalancerV1({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.BalancerV1 memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.BalancerV1));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertBancorV2(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readBancorV2({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.BancorV2 memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.BancorV2));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertAmbient(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readAmbient({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.Ambient memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.Ambient));

    assertEq(data.qty, mockParams.amount * newAmount / oldAmount);
  }

  function assertNative(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    // bytes memory depacked = reader.readNative({
    //   data: dexData,
    //   tokenIn: mockParams.srcToken,
    //   isFirstDex: true,
    //   nextPool: MOCK_ADDRESS,
    //   getPoolOnly: false
    // });
    // IExecutorHelperL2Struct.Native memory data =
    //   abi.decode(depacked, (IExecutorHelperL2Struct.Native));

    // @note: data.amount is not correct, because we already update data in calldata so we need to read data from
    // amountInOffset instead of swapdata.amount
    // assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertBebop(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readBebop({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.Bebop memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.Bebop));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertHashflow(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readHashflow({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.Hashflow memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.Hashflow));

    assertEq(data.quote.effectiveBaseTokenAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertKyberRfq(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readKyberRFQ({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.KyberRFQ memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.KyberRFQ));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertKyberDSLO(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readKyberDSLO({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.KyberDSLO memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.KyberDSLO));

    assertEq(data.params.takingAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertKyberLimitOrder(
    bytes memory dexData,
    uint256 newAmount,
    uint256 oldAmount
  ) internal {
    bytes memory depacked = reader.readKyberLimitOrder({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.KyberLimitOrder memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.KyberLimitOrder));

    assertEq(data.params.takingAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertSymbioticLRTData(
    bytes memory dexData,
    uint256 newAmount,
    uint256 oldAmount
  ) internal {
    bytes memory depacked = reader.readSymbioticLRT({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.SymbioticLRT memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.SymbioticLRT));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertMaverickV2Data(
    bytes memory dexData,
    uint256 newAmount,
    uint256 oldAmount
  ) internal {
    bytes memory depacked = reader.readMaverickV2({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      nextPool: MOCK_ADDRESS,
      getPoolOnly: false
    });
    IExecutorHelperL2Struct.MaverickV2 memory data =
      abi.decode(depacked, (IExecutorHelperL2Struct.MaverickV2));

    assertEq(data.collectAmount, mockParams.amount * newAmount / oldAmount);
  }

  function excludeSighash(bytes calldata rawData) external pure returns (bytes memory) {
    return rawData[4:];
  }
}
