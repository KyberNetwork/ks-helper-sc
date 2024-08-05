// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IMetaAggregationRouterV2} from 'src/interfaces/IMetaAggregationRouterV2.sol';
import {IExecutorHelperL2} from 'src/interfaces/IExecutorHelperL2.sol';
import {IAggregationExecutorOptimistic as IExecutorL2} from
  'src/interfaces/IAggregationExecutorOptimistic.sol';
import {InputScalingHelperL2} from 'src/l2-contracts/InputScalingHelperL2.sol';
import {DexWriter} from 'test/l2-contracts/base/DexWriter.sol';
import {AssertionHelperL2V2} from './AssertionHelperL2V2.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/interfaces/IERC20.sol';
import {CalldataWriter} from 'src/l2-contracts/CalldataWriter.sol';
import {IKyberLO} from 'src/interfaces/pools/IKyberLO.sol';
import {IKyberDSLO} from 'src/interfaces/pools/IKyberDSLO.sol';
import {BaseConfig} from './BaseConfig.sol';
import {console} from 'forge-std/Test.sol';

contract DataWriterL2V2 is AssertionHelperL2V2 {
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
    view
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
    BaseConfig.DexName dexName,
    uint256 sequenceIndex
  ) internal view returns (IExecutorL2.Swap memory swap) {
    function(uint256) internal view returns(IExecutorL2.Swap memory) fn;

    if (
      dexName == BaseConfig.DexName.UniV1 || dexName == BaseConfig.DexName.KyberDMM
        || dexName == BaseConfig.DexName.Velodrome || dexName == BaseConfig.DexName.Camelot
        || dexName == BaseConfig.DexName.Fraxswap
    ) {
      fn = _createUniSwap;
    } else if (dexName == BaseConfig.DexName.StableSwap) {
      fn = _createStableSwap;
    } else if (
      dexName == BaseConfig.DexName.Curve || dexName == BaseConfig.DexName.PancakeStableSwap
    ) {
      fn = _createCurveSwap;
    } else if (dexName == BaseConfig.DexName.UniswapV3KSElastic) {
      fn = _createUniswapV3KSElastic;
    } else if (dexName == BaseConfig.DexName.BalancerV2) {
      fn = _createBalancerV2;
    } else if (dexName == BaseConfig.DexName.DODO) {
      fn = _createDODO;
    } else if (dexName == BaseConfig.DexName.GMX) {
      fn = _createGMX;
    } else if (dexName == BaseConfig.DexName.Synthetix) {
      fn = _createSynthetix;
    } else if (dexName == BaseConfig.DexName.WstETH) {
      fn = _createWrappedstETH;
    } else if (dexName == BaseConfig.DexName.StETH) {
      fn = _createStETH;
    } else if (dexName == BaseConfig.DexName.Platypus) {
      fn = _createPlatypus;
    } else if (dexName == BaseConfig.DexName.PSM) {
      fn = _createPSM;
    } else if (dexName == BaseConfig.DexName.Maverick) {
      fn = _createMaverick;
    } else if (dexName == BaseConfig.DexName.SyncSwap) {
      fn = _createSyncSwap;
    } else if (dexName == BaseConfig.DexName.AlgebraV1) {
      fn = _createAlgebraV1;
    } else if (dexName == BaseConfig.DexName.BalancerBatch) {
      fn = _createBalancerBatch;
    } else if (
      dexName == BaseConfig.DexName.Mantis || dexName == BaseConfig.DexName.Wombat
        || dexName == BaseConfig.DexName.WooFiV2 || dexName == BaseConfig.DexName.Smardex
        || dexName == BaseConfig.DexName.SolidlyV2 || dexName == BaseConfig.DexName.NomiswapStable
        || dexName == BaseConfig.DexName.BancorV3
    ) {
      fn = _createMantis;
    } else if (dexName == BaseConfig.DexName.iZiSwap) {
      fn = _createIziSwap;
    } else if (dexName == BaseConfig.DexName.TraderJoeV2) {
      fn = _createTraderJoeV2;
    } else if (dexName == BaseConfig.DexName.LevelFiV2) {
      fn = _createLevelFiV2;
    } else if (dexName == BaseConfig.DexName.GMXGLP) {
      fn = _createGMXGLP;
    } else if (dexName == BaseConfig.DexName.Vooi) {
      fn = _createVooi;
    } else if (dexName == BaseConfig.DexName.VelocoreV2) {
      fn = _createVelocoreV2;
    } else if (dexName == BaseConfig.DexName.Kokonut) {
      fn = _createKokonut;
    } else if (dexName == BaseConfig.DexName.BalancerV1 || dexName == BaseConfig.DexName.Kelp) {
      fn = _createBalancerV1;
    } else if (dexName == BaseConfig.DexName.ArbswapStable) {
      fn = _createArbswapStable;
    } else if (dexName == BaseConfig.DexName.BancorV2) {
      fn = _createBancorV2;
    } else if (dexName == BaseConfig.DexName.Ambient) {
      fn = _createAmbient;
    } else if (dexName == BaseConfig.DexName.LighterV2) {
      fn = _createLighterV2;
    } else if (dexName == BaseConfig.DexName.MaiPSM) {
      fn = _createMaiPSM;
    } else if (dexName == BaseConfig.DexName.Hashflow) {
      fn = _createHashflow;
    } else if (dexName == BaseConfig.DexName.KyberLimitOrder) {
      fn = _createKyberLimitOrder;
    } else if (dexName == BaseConfig.DexName.KyberDSLO) {
      fn = _createKyberDSLO;
    } else if (dexName == BaseConfig.DexName.KyberRFQ) {
      fn = _createKyberRfq;
    } else if (dexName == BaseConfig.DexName.Native) {
      fn = _createNative;
    } else if (dexName == BaseConfig.DexName.Bebop) {
      fn = _createBebop;
    } else if (dexName == BaseConfig.DexName.MantleUsd) {
      fn = _createMantleUsd;
    } else if (dexName == BaseConfig.DexName.SymbioticLRT) {
      fn = _createSymbioticLRT;
    } else if (dexName == BaseConfig.DexName.MaverickV2) {
      fn = _createMaverickV2;
    } else {
      // do nothing, since we need to check revert condition from InputScalingHelperL2 contract
      swap.data = bytes('mock data');
      fn = _nothing;
    }

    swap = fn(sequenceIndex);

    swap.functionSelector = bytes4(uint32(dexName));
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

    console.logBytes(swap.data);
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
    swap.data =
      writer.writeNative({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex, recipientFlag: 0});
  }

  function _createBebop(uint256 sequenceIndex) internal view returns (IExecutorL2.Swap memory swap) {
    IExecutorHelperL2.Bebop memory data;
    data.amount = uint128(mockParams.amount);
    swap.data =
      writer.writeBebop({swap: data, poolIndex: 0, sequenceIndex: sequenceIndex, recipientFlag: 0});
  }

  function _createMantleUsd(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    uint256 isWrapAndAmount;
    isWrapAndAmount |= uint256(uint128(mockParams.amount));
    isWrapAndAmount |= uint256(1) << 255;
    swap.data = abi.encode(isWrapAndAmount);
  }

  function _createSymbioticLRT(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.SymbioticLRT memory data;
    data.amount = mockParams.amount;
    swap.data = writer.writeSymbioticLRT({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }

  function _createMaverickV2(uint256 sequenceIndex)
    internal
    view
    returns (IExecutorL2.Swap memory swap)
  {
    IExecutorHelperL2.MaverickV2 memory data;
    data.collectAmount = mockParams.amount;
    swap.data = writer.writeMaverickV2({
      swap: data,
      poolIndex: 0,
      sequenceIndex: sequenceIndex,
      recipientFlag: mockParams.recipientFlag
    });
  }
}
