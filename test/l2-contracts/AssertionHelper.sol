// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {Test} from 'forge-std/Test.sol';
import {InputScalingHelperL2} from 'src/l2-contracts/InputScalingHelperL2.sol';
import {IMetaAggregationRouterV2} from 'src/interfaces/IMetaAggregationRouterV2.sol';

import {ExecutorReader} from 'src/l2-contracts/ExecutorReader.sol';
import {IExecutorHelperL2} from 'src/interfaces/IExecutorHelperL2.sol';
import {IAggregationExecutorOptimistic as IExecutorL2} from
  'src/interfaces/IAggregationExecutorOptimistic.sol';
import {Reader} from './DexScalersTest.t.sol';

contract AssertionHelper is Test {
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
        (IExecutorL2.Swap[] memory swaps, address tokenIn) =
          ExecutorReader.readSwapSingleSequence(simpleSwapData.swapDatas[i]);

        // check scaled data for first dex
        _assertDexData(
          InputScalingHelperL2.DexIndex(uint32(swaps[0].functionSelector)),
          swaps[0].data,
          oldAmount,
          newAmount
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
          InputScalingHelperL2.DexIndex(uint32(executorDesc.swapSequences[i][0].functionSelector)),
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
  }

  function _assertDexData(
    InputScalingHelperL2.DexIndex dexType,
    bytes memory dexData,
    uint256 oldAmount,
    uint256 newAmount
  ) internal {
    function (bytes memory,uint256,uint256) internal fn;

    if (
      dexType == InputScalingHelperL2.DexIndex.UNI
        || dexType == InputScalingHelperL2.DexIndex.KyberDMM
        || dexType == InputScalingHelperL2.DexIndex.Velodrome
        || dexType == InputScalingHelperL2.DexIndex.Camelot
        || dexType == InputScalingHelperL2.DexIndex.Fraxswap
    ) {
      fn = assertUniData;
    } else if (dexType == InputScalingHelperL2.DexIndex.StableSwap) {
      fn = assertStableSwapData;
    } else if (
      dexType == InputScalingHelperL2.DexIndex.Curve
        || dexType == InputScalingHelperL2.DexIndex.PancakeStableSwap
    ) {
      fn = assertCurveSwapData;
    } else if (dexType == InputScalingHelperL2.DexIndex.UniswapV3KSElastic) {
      fn = assertUniswapV3KSElasticData;
    } else if (dexType == InputScalingHelperL2.DexIndex.BalancerV2) {
      fn = assertBalancerV2Data;
    } else if (dexType == InputScalingHelperL2.DexIndex.DODO) {
      fn = assertDODOData;
    } else if (dexType == InputScalingHelperL2.DexIndex.GMX) {
      fn = assertGMXData;
    } else if (dexType == InputScalingHelperL2.DexIndex.Synthetix) {
      fn = assertSynthetixData;
    } else if (dexType == InputScalingHelperL2.DexIndex.wstETH) {
      fn = assertWrappedstETHData;
    } else if (dexType == InputScalingHelperL2.DexIndex.stETH) {
      fn = assertStETHData;
    } else if (dexType == InputScalingHelperL2.DexIndex.Platypus) {
      fn = assertPlatypusData;
    } else if (dexType == InputScalingHelperL2.DexIndex.PSM) {
      fn = assertPSMData;
    } else if (dexType == InputScalingHelperL2.DexIndex.Maverick) {
      fn = assertMaverickData;
    } else if (dexType == InputScalingHelperL2.DexIndex.SyncSwap) {
      fn = assertSyncSwapData;
    } else if (dexType == InputScalingHelperL2.DexIndex.AlgebraV1) {
      fn = assertAlgebraV1Data;
    } else if (dexType == InputScalingHelperL2.DexIndex.BalancerBatch) {
      fn = assertBalancerBatchData;
    } else if (
      dexType == InputScalingHelperL2.DexIndex.Mantis
        || dexType == InputScalingHelperL2.DexIndex.Wombat
        || dexType == InputScalingHelperL2.DexIndex.WooFiV2
        || dexType == InputScalingHelperL2.DexIndex.Smardex
        || dexType == InputScalingHelperL2.DexIndex.SolidlyV2
    ) {
      fn = assertMantisData;
    } else if (dexType == InputScalingHelperL2.DexIndex.iZiSwap) {
      fn = assertIziSwapData;
    } else if (dexType == InputScalingHelperL2.DexIndex.TraderJoeV2) {
      fn = assertTraderJoeV2Data;
    } else if (dexType == InputScalingHelperL2.DexIndex.LevelFiV2) {
      fn = assertLevelFiV2Data;
    } else if (dexType == InputScalingHelperL2.DexIndex.GMXGLP) {
      fn = assertGMXGLPData;
    } else if (dexType == InputScalingHelperL2.DexIndex.Vooi) {
      fn = assertVooiData;
    } else if (dexType == InputScalingHelperL2.DexIndex.VelocoreV2) {
      fn = assertVelocoreV2Data;
    } else if (dexType == InputScalingHelperL2.DexIndex.Kokonut) {
      fn = assertKokonutData;
    } else if (dexType == InputScalingHelperL2.DexIndex.BalancerV1) {
      fn = assertBalancerV1Data;
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
    IExecutorHelperL2.UniSwap memory data = abi.decode(depacked, (IExecutorHelperL2.UniSwap));

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
    IExecutorHelperL2.StableSwap memory data = abi.decode(depacked, (IExecutorHelperL2.StableSwap));

    assertEq(data.dx, mockParams.amount * newAmount / oldAmount);
  }

  function assertCurveSwapData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readCurveSwap({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      getPoolOnly: false
    });
    IExecutorHelperL2.CurveSwap memory data = abi.decode(depacked, (IExecutorHelperL2.CurveSwap));

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
    IExecutorHelperL2.UniswapV3KSElastic memory data =
      abi.decode(depacked, (IExecutorHelperL2.UniswapV3KSElastic));

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
    IExecutorHelperL2.BalancerV2 memory data = abi.decode(depacked, (IExecutorHelperL2.BalancerV2));

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
    IExecutorHelperL2.DODO memory data = abi.decode(depacked, (IExecutorHelperL2.DODO));

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
    IExecutorHelperL2.GMX memory data = abi.decode(depacked, (IExecutorHelperL2.GMX));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function assertSynthetixData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readSynthetix({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      getPoolOnly: false
    });
    IExecutorHelperL2.Synthetix memory data = abi.decode(depacked, (IExecutorHelperL2.Synthetix));

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
    IExecutorHelperL2.WSTETH memory data = abi.decode(depacked, (IExecutorHelperL2.WSTETH));

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
    IExecutorHelperL2.Platypus memory data = abi.decode(depacked, (IExecutorHelperL2.Platypus));

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
    IExecutorHelperL2.PSM memory data = abi.decode(depacked, (IExecutorHelperL2.PSM));

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
    IExecutorHelperL2.Maverick memory data = abi.decode(depacked, (IExecutorHelperL2.Maverick));

    assertEq(data.swapAmount, mockParams.amount * newAmount / oldAmount);
  }

  function assertSyncSwapData(bytes memory dexData, uint256 newAmount, uint256 oldAmount) internal {
    bytes memory depacked = reader.readSyncSwap({
      data: dexData,
      tokenIn: mockParams.srcToken,
      isFirstDex: true,
      getPoolOnly: false
    });
    IExecutorHelperL2.SyncSwap memory data = abi.decode(depacked, (IExecutorHelperL2.SyncSwap));

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
    IExecutorHelperL2.AlgebraV1 memory data = abi.decode(depacked, (IExecutorHelperL2.AlgebraV1));

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
    IExecutorHelperL2.BalancerBatch memory data =
      abi.decode(depacked, (IExecutorHelperL2.BalancerBatch));

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
    IExecutorHelperL2.Mantis memory data = abi.decode(depacked, (IExecutorHelperL2.Mantis));

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
    IExecutorHelperL2.IziSwap memory data = abi.decode(depacked, (IExecutorHelperL2.IziSwap));

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
    IExecutorHelperL2.TraderJoeV2 memory data =
      abi.decode(depacked, (IExecutorHelperL2.TraderJoeV2));

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
    IExecutorHelperL2.LevelFiV2 memory data = abi.decode(depacked, (IExecutorHelperL2.LevelFiV2));

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
    IExecutorHelperL2.GMXGLP memory data = abi.decode(depacked, (IExecutorHelperL2.GMXGLP));

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
    IExecutorHelperL2.Vooi memory data = abi.decode(depacked, (IExecutorHelperL2.Vooi));

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
    IExecutorHelperL2.VelocoreV2 memory data = abi.decode(depacked, (IExecutorHelperL2.VelocoreV2));

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
    IExecutorHelperL2.Kokonut memory data = abi.decode(depacked, (IExecutorHelperL2.Kokonut));

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
    IExecutorHelperL2.BalancerV1 memory data = abi.decode(depacked, (IExecutorHelperL2.BalancerV1));

    assertEq(data.amount, mockParams.amount * newAmount / oldAmount);
  }

  function excludeSighash(bytes calldata rawData) external returns (bytes memory) {
    return rawData[4:];
  }
}
