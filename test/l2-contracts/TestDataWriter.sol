// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IMetaAggregationRouterV2} from 'src/interfaces/IMetaAggregationRouterV2.sol';
import {IExecutorHelperL2} from 'src/interfaces/IExecutorHelperL2.sol';
import {IAggregationExecutorOptimistic as IExecutorL2} from
  'src/interfaces/IAggregationExecutorOptimistic.sol';
import {InputScalingHelperL2} from 'src/l2-contracts/InputScalingHelperL2.sol';
import {DexWriter} from './DexWriter.sol';
import {AssertionHelper} from './AssertionHelper.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/interfaces/IERC20.sol';
import {CalldataWriter} from 'src/l2-contracts/CalldataWriter.sol';
import {IKyberLO} from 'src/interfaces/pools/IKyberLO.sol';
import {IKyberDSLO} from 'src/interfaces/pools/IKyberDSLO.sol';

contract TestDataWriter is AssertionHelper {
  DexWriter writer = new DexWriter();

  function _createMockSwapExecutionParams(bool simpleMode)
    internal
    returns (IMetaAggregationRouterV2.SwapExecutionParams memory exec)
  {
    exec.callTarget = mockParams.callTarget;
    exec.approveTarget = mockParams.approveTarget;
    exec.desc = _createMockSwapDescriptionV2();

    IExecutorL2.SwapExecutorDescription memory desc = _createMockSwapExecutorDescription();

    if (simpleMode) {
      IMetaAggregationRouterV2.SimpleSwapData memory simpleSwapData;

      simpleSwapData.positiveSlippageData = desc.positiveSlippageData;

      uint256 i;

      simpleSwapData.swapDatas = new bytes[](mockParams.noSequences);

      while (i < mockParams.noSequences) {
        mockParams.simpleSwapFirstPools.push(MOCK_ADDRESS);
        mockParams.simpleSwapFirstAmounts.push(mockParams.amount);

        simpleSwapData.swapDatas[i] = CalldataWriter._writeSwapSingleSequence(
          abi.encode(mockParams.swapSequences[i]), mockParams.srcToken
        );
        ++i;
      }

      simpleSwapData.firstPools = mockParams.simpleSwapFirstPools;
      simpleSwapData.firstSwapAmounts = mockParams.simpleSwapFirstAmounts;

      exec.targetData = abi.encode(simpleSwapData);
    } else {
      exec.targetData = CalldataWriter.writeSwapExecutorDescription(desc);
    }
  }

  function _createMockSwapDescriptionV2()
    internal
    returns (IMetaAggregationRouterV2.SwapDescriptionV2 memory desc)
  {
    mockParams.srcAmounts.push(mockParams.amount);
    mockParams.srcAmounts.push(mockParams.amount);
    desc.srcAmounts = mockParams.srcAmounts;
    desc.srcReceivers = mockParams.srcReceivers;
    desc.feeAmounts = mockParams.srcAmounts;
    desc.feeReceivers = mockParams.srcReceivers;
    desc.srcToken = IERC20(mockParams.srcToken);
    desc.dstToken = IERC20(mockParams.dstToken);
    desc.dstReceiver = mockParams.dstReceiver;
    desc.amount = mockParams.amount;
    desc.minReturnAmount = mockParams.minReturnAmount;
  }

  function _createMockSwapExecutorDescription()
    internal
    returns (IExecutorL2.SwapExecutorDescription memory desc)
  {
    desc.tokenIn = mockParams.srcToken;
    desc.tokenOut = mockParams.dstToken;
    desc.to = mockParams.dstReceiver;
    desc.deadline = block.timestamp;
    desc.positiveSlippageData =
      abi.encode((mockParams.minReturnAmount << 128) | mockParams.minReturnAmount);

    desc.swapSequences = mockParams.swapSequences;
  }

  function _createDexData(
    InputScalingHelperL2.DexIndex dexType,
    uint256 sequenceIndex
  ) internal view returns (IExecutorL2.Swap memory swap) {
    function(uint256) internal view returns(IExecutorL2.Swap memory) fn;

    if (
      dexType == InputScalingHelperL2.DexIndex.UNI
        || dexType == InputScalingHelperL2.DexIndex.KyberDMM
        || dexType == InputScalingHelperL2.DexIndex.Velodrome
        || dexType == InputScalingHelperL2.DexIndex.Camelot
        || dexType == InputScalingHelperL2.DexIndex.Fraxswap
    ) {
      fn = _createUniSwap;
    } else if (dexType == InputScalingHelperL2.DexIndex.StableSwap) {
      fn = _createStableSwap;
    } else if (
      dexType == InputScalingHelperL2.DexIndex.Curve
        || dexType == InputScalingHelperL2.DexIndex.PancakeStableSwap
    ) {
      fn = _createCurveSwap;
    } else if (dexType == InputScalingHelperL2.DexIndex.UniswapV3KSElastic) {
      fn = _createUniswapV3KSElastic;
    } else if (dexType == InputScalingHelperL2.DexIndex.BalancerV2) {
      fn = _createBalancerV2;
    } else if (dexType == InputScalingHelperL2.DexIndex.DODO) {
      fn = _createDODO;
    } else if (dexType == InputScalingHelperL2.DexIndex.GMX) {
      fn = _createGMX;
    } else if (dexType == InputScalingHelperL2.DexIndex.Synthetix) {
      fn = _createSynthetix;
    } else if (dexType == InputScalingHelperL2.DexIndex.wstETH) {
      fn = _createWrappedstETH;
    } else if (dexType == InputScalingHelperL2.DexIndex.stETH) {
      fn = _createStETH;
    } else if (dexType == InputScalingHelperL2.DexIndex.Platypus) {
      fn = _createPlatypus;
    } else if (dexType == InputScalingHelperL2.DexIndex.PSM) {
      fn = _createPSM;
    } else if (dexType == InputScalingHelperL2.DexIndex.Maverick) {
      fn = _createMaverick;
    } else if (dexType == InputScalingHelperL2.DexIndex.SyncSwap) {
      fn = _createSyncSwap;
    } else if (dexType == InputScalingHelperL2.DexIndex.AlgebraV1) {
      fn = _createAlgebraV1;
    } else if (dexType == InputScalingHelperL2.DexIndex.BalancerBatch) {
      fn = _createBalancerBatch;
    } else if (
      dexType == InputScalingHelperL2.DexIndex.Mantis
        || dexType == InputScalingHelperL2.DexIndex.Wombat
        || dexType == InputScalingHelperL2.DexIndex.WooFiV2
        || dexType == InputScalingHelperL2.DexIndex.Smardex
        || dexType == InputScalingHelperL2.DexIndex.SolidlyV2
        || dexType == InputScalingHelperL2.DexIndex.NomiswapStable
        || dexType == InputScalingHelperL2.DexIndex.BancorV3
    ) {
      fn = _createMantis;
    } else if (dexType == InputScalingHelperL2.DexIndex.iZiSwap) {
      fn = _createIziSwap;
    } else if (dexType == InputScalingHelperL2.DexIndex.TraderJoeV2) {
      fn = _createTraderJoeV2;
    } else if (dexType == InputScalingHelperL2.DexIndex.LevelFiV2) {
      fn = _createLevelFiV2;
    } else if (dexType == InputScalingHelperL2.DexIndex.GMXGLP) {
      fn = _createGMXGLP;
    } else if (dexType == InputScalingHelperL2.DexIndex.Vooi) {
      fn = _createVooi;
    } else if (dexType == InputScalingHelperL2.DexIndex.VelocoreV2) {
      fn = _createVelocoreV2;
    } else if (dexType == InputScalingHelperL2.DexIndex.Kokonut) {
      fn = _createKokonut;
    } else if (dexType == InputScalingHelperL2.DexIndex.BalancerV1) {
      fn = _createBalancerV1;
    } else if (dexType == InputScalingHelperL2.DexIndex.ArbswapStable) {
      fn = _createArbswapStable;
    } else if (dexType == InputScalingHelperL2.DexIndex.BancorV2) {
      fn = _createBancorV2;
    } else if (dexType == InputScalingHelperL2.DexIndex.Ambient) {
      fn = _createAmbient;
    } else if (dexType == InputScalingHelperL2.DexIndex.LighterV2) {
      fn = _createLighterV2;
    } else if (dexType == InputScalingHelperL2.DexIndex.MaiPSM) {
      fn = _createMaiPSM;
    } else if (dexType == InputScalingHelperL2.DexIndex.Hashflow) {
      fn = _createHashflow;
    } else if (dexType == InputScalingHelperL2.DexIndex.KyberLimitOrder) {
      fn = _createKyberLimitOrder;
    } else if (dexType == InputScalingHelperL2.DexIndex.KyberDSLO) {
      fn = _createKyberDSLO;
    } else if (dexType == InputScalingHelperL2.DexIndex.KyberRFQ) {
      fn = _createKyberRfq;
    } else if (dexType == InputScalingHelperL2.DexIndex.Native) {
      fn = _createNative;
    } else if (dexType == InputScalingHelperL2.DexIndex.Bebop) {
      fn = _createBebop;
    } else {
      // do nothing, since we need to check revert condition from InputScalingHelperL2 contract
      swap.data = bytes('mock data');
      fn = _nothing;
    }

    swap = fn(sequenceIndex);

    swap.functionSelector = bytes4(uint32(dexType));
  }

  function _nothing(uint256 sequenceIndex) internal view returns (IExecutorL2.Swap memory swap) {}

  function _createUniSwap(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.UniSwap memory data;
    data.collectAmount = mockParams.amount;
    swap.data = writer.writeUniSwap({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createStableSwap(uint256) internal view returns (IExecutorL2.Swap memory swap) {
    IExecutorHelperL2.StableSwap memory data;
    data.dx = mockParams.amount;
    swap.data = writer.writeStableSwap({swap: data, poolIndex: 0});
  }

  function _createCurveSwap(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.CurveSwap memory data;
    data.dx = mockParams.amount;
    swap.data = writer.writeCurveSwap({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      canGetIndex: true
    });
  }

  function _createUniswapV3KSElastic(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.UniswapV3KSElastic memory data;
    data.swapAmount = mockParams.amount;
    swap.data = writer.writeUniswapV3KSElastic({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createBalancerV2(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.BalancerV2 memory data;
    data.amount = mockParams.amount;
    swap.data = writer.writeBalancerV2({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      assetOutIndex: 0
    });
  }

  function _createDODO(uint256 sequenceIndex) internal view returns (IExecutorL2.Swap memory swap) {
    IExecutorHelperL2.DODO memory data;
    data.amount = mockParams.amount;
    swap.data = writer.writeDODO({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createGMX(uint256 sequenceIndex) internal view returns (IExecutorL2.Swap memory swap) {
    IExecutorHelperL2.GMX memory data;
    data.amount = mockParams.amount;
    swap.data = writer.writeGMX({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createSynthetix(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.Synthetix memory data;
    data.sourceAmount = mockParams.amount;
    swap.data = writer.writeSynthetix({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex});
  }

  function _createWrappedstETH(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.WSTETH memory data;
    data.amount = mockParams.amount;
    swap.data = writer.writeWrappedstETH({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex});
  }

  function _createStETH(uint256) internal view returns (IExecutorL2.Swap memory swap) {
    uint128 amount = uint128(mockParams.amount);
    swap.data = abi.encodePacked(amount);
  }

  function _createPlatypus(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.Platypus memory data;
    data.collectAmount = mockParams.amount;
    swap.data = writer.writePlatypus({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createPSM(uint256 sequenceIndex) internal view returns (IExecutorL2.Swap memory swap) {
    IExecutorHelperL2.PSM memory data;
    data.amountIn = mockParams.amount;
    swap.data = writer.writePSM({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createMaverick(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.Maverick memory data;
    data.swapAmount = mockParams.amount;
    swap.data = writer.writeMaverick({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createSyncSwap(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.SyncSwap memory data;
    data.collectAmount = mockParams.amount;
    swap.data = writer.writeSyncSwap({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex});
  }

  function _createAlgebraV1(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.AlgebraV1 memory data;
    data.swapAmount = mockParams.amount;
    swap.data = writer.writeAlgebraV1({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createBalancerBatch(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.BalancerBatch memory data;
    data.amountIn = mockParams.amount;
    swap.data = writer.writeBalancerBatch({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex});
  }

  function _createMantis(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.Mantis memory data;
    data.amount = mockParams.amount;
    swap.data = writer.writeMantis({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createIziSwap(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.IziSwap memory data;
    data.swapAmount = mockParams.amount;
    swap.data = writer.writeIziSwap({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createTraderJoeV2(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.TraderJoeV2 memory data;
    data.collectAmount = mockParams.amount;
    swap.data = writer.writeTraderJoeV2({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createLevelFiV2(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.LevelFiV2 memory data;
    data.amountIn = mockParams.amount;
    swap.data = writer.writeLevelFiV2({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createGMXGLP(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.GMXGLP memory data;
    data.swapAmount = mockParams.amount;
    swap.data = writer.writeGMXGLP({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag,
      directionFlag: mockParams.recipientFlag
    });
  }

  function _createVooi(uint256 sequenceIndex) internal view returns (IExecutorL2.Swap memory swap) {
    IExecutorHelperL2.Vooi memory data;
    data.fromAmount = mockParams.amount;
    swap.data = writer.writeVooi({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createVelocoreV2(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.VelocoreV2 memory data;
    data.amount = mockParams.amount;
    swap.data = writer.writeVelocoreV2({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createKokonut(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.Kokonut memory data;
    data.dx = mockParams.amount;
    swap.data = writer.writeKokonut({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createBalancerV1(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.BalancerV1 memory data;
    data.amount = mockParams.amount;
    swap.data = writer.writeBalancerV1({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createArbswapStable(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.ArbswapStable memory data;
    data.dx = mockParams.amount;
    swap.data = writer.writeArbswapStable({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createBancorV2(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.BancorV2 memory data;
    data.amount = mockParams.amount;
    swap.data = writer.writeBancorV2({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createAmbient(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.Ambient memory data;
    data.qty = uint128(mockParams.amount);
    swap.data = writer.writeAmbient({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex});
  }

  function _createLighterV2(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.LighterV2 memory data;
    data.amount = uint128(mockParams.amount);
    swap.data = writer.writeLighterV2({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createMaiPSM(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.FrxETH memory data;
    data.amount = uint128(mockParams.amount);
    swap.data = writer.writeMaiPSM({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex});
  }

  function _createHashflow(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.Hashflow memory data;
    data.quote.effectiveBaseTokenAmount = uint128(mockParams.amount);
    swap.data = writer.writeHashflow({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex});
  }

  function _createKyberRfq(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.KyberRFQ memory data;
    data.amount = uint128(mockParams.amount);
    swap.data = writer.writeKyberRFQ({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex});
  }

  function _createKyberDSLO(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.KyberDSLO memory data;
    data.params.takingAmount = uint128(mockParams.amount);

    data.params.orders = new IKyberDSLO.Order[](1);
    data.params.signatures = new IKyberDSLO.Signature[](1);
    data.params.opExpireTimes = new uint32[](1);

    swap.data = writer.writeKyberDSLO({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex});
  }

  function _createKyberLimitOrder(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.KyberLimitOrder memory data;
    data.params.takingAmount = uint128(mockParams.amount);

    data.params.orders = new IKyberLO.Order[](1);
    data.params.signatures = new bytes[](1);
    swap.data =
      writer.writeKyberLimitOrder({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex});
  }

  function _createNative(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.Native memory data;
    data.amount = uint128(mockParams.amount);
    swap.data = writer.writeNative({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex});
  }

  function _createBebop(uint256 sequenceIndex) internal view returns (IExecutorL2.Swap memory swap) {
    IExecutorHelperL2.Bebop memory data;
    data.amount = uint128(mockParams.amount);
    swap.data = writer.writeBebop({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex});
  }
}
