// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IMetaAggregationRouterV2} from 'src/interfaces/IMetaAggregationRouterV2.sol';
import {IAggregationExecutor as IExecutorL1} from 'src/interfaces/IAggregationExecutor.sol';

import {IExecutorHelper} from 'src/interfaces/IExecutorHelper.sol';
import {IExecutorHelperStruct} from 'src/interfaces/IExecutorHelperStruct.sol';
import {BaseConfig} from './BaseConfig.sol';

import {AssertionHelperL1} from './AssertionHelperL1.sol';

import {IERC20} from 'openzeppelin-contracts/contracts/interfaces/IERC20.sol';

contract TestL1DataWriter is AssertionHelperL1 {
  function _createMockSwapExecutionParams(bool simpleMode)
    internal
    returns (IMetaAggregationRouterV2.SwapExecutionParams memory exec)
  {
    exec.callTarget = mockParams.callTarget;
    exec.approveTarget = mockParams.approveTarget;
    exec.desc = _createMockSwapDescriptionV2();

    IExecutorL1.SwapExecutorDescription memory desc = _createMockSwapExecutorDescription();

    if (simpleMode) {
      IMetaAggregationRouterV2.SimpleSwapData memory simpleSwapData;

      simpleSwapData.positiveSlippageData = desc.positiveSlippageData;

      uint256 i;

      simpleSwapData.swapDatas = new bytes[](mockParams.noSequences);

      while (i < mockParams.noSequences) {
        mockParams.simpleSwapFirstPools.push(MOCK_ADDRESS);
        mockParams.simpleSwapFirstAmounts.push(mockParams.amount);

        simpleSwapData.swapDatas[i] = abi.encode(mockParams.swapSequences[i]);

        ++i;
      }

      simpleSwapData.firstPools = mockParams.simpleSwapFirstPools;
      simpleSwapData.firstSwapAmounts = mockParams.simpleSwapFirstAmounts;

      exec.targetData = abi.encode(simpleSwapData);
    } else {
      exec.targetData = abi.encode(desc);
    }
  }

  function _createMockSwapDescriptionV2()
    internal
    returns (IMetaAggregationRouterV2.SwapDescriptionV2 memory desc)
  {
    desc.srcToken = IERC20(mockParams.srcToken);
    desc.dstToken = IERC20(mockParams.dstToken);
    desc.srcReceivers = mockParams.srcReceivers;

    // mock amount
    mockParams.srcAmounts.push(mockParams.amount);
    mockParams.srcAmounts.push(mockParams.amount);
    desc.amount = mockParams.amount;

    desc.srcAmounts = mockParams.srcAmounts;
    desc.feeReceivers = mockParams.srcReceivers;
    desc.feeAmounts = mockParams.srcAmounts;
    desc.dstReceiver = mockParams.dstReceiver;

    desc.minReturnAmount = mockParams.minReturnAmount;
  }

  function _createMockSwapExecutorDescription()
    internal
    view
    returns (IExecutorL1.SwapExecutorDescription memory desc)
  {
    desc.tokenIn = mockParams.srcToken;
    desc.tokenOut = mockParams.dstToken;
    desc.to = mockParams.dstReceiver;
    desc.deadline = block.timestamp;
    desc.positiveSlippageData =
      abi.encode((mockParams.minReturnAmount << 128) | mockParams.minReturnAmount);

    desc.swapSequences = mockParams.swapSequences;
  }

  function _createDexData(BaseConfig.DexName dexName)
    internal
    view
    returns (IExecutorL1.Swap memory swap)
  {
    function() internal view returns(IExecutorL1.Swap memory) fn;

    if (
      dexName == BaseConfig.DexName.UNI || dexName == BaseConfig.DexName.KyberDMM
        || dexName == BaseConfig.DexName.Velodrome || dexName == BaseConfig.DexName.Fraxswap
    ) {
      fn = _createUniSwap;
    } else if (
      dexName == BaseConfig.DexName.Mantis || dexName == BaseConfig.DexName.Wombat
        || dexName == BaseConfig.DexName.WooFiV2 || dexName == BaseConfig.DexName.Smardex
        || dexName == BaseConfig.DexName.SolidlyV2 || dexName == BaseConfig.DexName.NomiswapStable
        || dexName == BaseConfig.DexName.BancorV3
    ) {
      fn = _createMantis;
    } else if (
      dexName == BaseConfig.DexName.Curve || dexName == BaseConfig.DexName.PancakeStableSwap
    ) {
      fn = _createCurveSwap;
    } else if (dexName == BaseConfig.DexName.OriginETH || dexName == BaseConfig.DexName.PrimeETH) {
      fn = _createOriginETH;
    } else if (dexName == BaseConfig.DexName.FrxETH || dexName == BaseConfig.DexName.MaiPSM) {
      fn = _createFrxETH;
    } else if (dexName == BaseConfig.DexName.Camelot) {
      fn = _createCamelot;
    } else if (dexName == BaseConfig.DexName.StableSwap) {
      fn = _createStableSwap;
    } else if (dexName == BaseConfig.DexName.GMX) {
      fn = _createGMX;
    } else if (dexName == BaseConfig.DexName.UniV3ProMM) {
      fn = _createUniV3KSElastic;
    } else if (dexName == BaseConfig.DexName.RFQ) {
      fn = _createKyberRfq;
    } else if (dexName == BaseConfig.DexName.BalancerV2) {
      fn = _createBalancerV2;
    } else if (dexName == BaseConfig.DexName.DODO) {
      fn = _createDODO;
    } else if (dexName == BaseConfig.DexName.Synthetix) {
      fn = _createSynthetix;
    } else if (dexName == BaseConfig.DexName.PSM) {
      fn = _createPSM;
    } else if (dexName == BaseConfig.DexName.WSTETH) {
      fn = _createWrappedstETH;
    } else if (dexName == BaseConfig.DexName.StEth) {
      fn = _createStEth;
    } else if (dexName == BaseConfig.DexName.Platypus) {
      fn = _createPlatypus;
    } else if (dexName == BaseConfig.DexName.Maverick) {
      fn = _createMaverick;
    } else if (dexName == BaseConfig.DexName.SyncSwap) {
      fn = _createSyncSwap;
    } else if (dexName == BaseConfig.DexName.AlgebraV1) {
      fn = _createAlgebraV1;
    } else if (dexName == BaseConfig.DexName.BalancerBatch) {
      fn = _createBalancerBatch;
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
    } else if (dexName == BaseConfig.DexName.MaticMigrate) {
      fn = _createMaticMigrate;
    } else if (dexName == BaseConfig.DexName.Kokonut) {
      fn = _createKokonut;
    } else if (dexName == BaseConfig.DexName.BalancerV1) {
      fn = _createBalancerV1;
    } else if (dexName == BaseConfig.DexName.ArbswapStable) {
      fn = _createArbswapStable;
    } else if (dexName == BaseConfig.DexName.BancorV2) {
      fn = _createBancorV2;
    } else if (dexName == BaseConfig.DexName.Ambient) {
      fn = _createAmbient;
    } else if (dexName == BaseConfig.DexName.UniV1) {
      fn = _createUniV1;
    } else if (dexName == BaseConfig.DexName.LighterV2) {
      fn = _createAmbient;
    } else if (dexName == BaseConfig.DexName.EtherFieETH) {
      fn = _createEtherFieETH;
    } else if (dexName == BaseConfig.DexName.EtherFiWeETH) {
      fn = _createEtherFiWeETH;
    } else if (dexName == BaseConfig.DexName.Kelp) {
      fn = _createKelp;
    } else if (dexName == BaseConfig.DexName.EthenaSusde) {
      fn = _createEthenaSusde;
    } else if (dexName == BaseConfig.DexName.RocketPool) {
      fn = _createRocketPool;
    } else if (dexName == BaseConfig.DexName.MakersDAI) {
      fn = _createMakersDAI;
    } else if (dexName == BaseConfig.DexName.Renzo) {
      fn = _createRenzo;
    } else if (dexName == BaseConfig.DexName.WBETH) {
      fn = _createWBETH;
    } else if (dexName == BaseConfig.DexName.MantleETH) {
      fn = _createMantleETH;
    } else if (dexName == BaseConfig.DexName.SfrxETH) {
      fn = _createSfrxETH;
    } else if (dexName == BaseConfig.DexName.SfrxETHConvertor) {
      fn = _createSfrxETHConvertor;
    } else if (dexName == BaseConfig.DexName.SwellETH) {
      fn = _createSwellETH;
    } else if (dexName == BaseConfig.DexName.RswETH) {
      fn = _createRswETH;
    } else if (dexName == BaseConfig.DexName.StaderETHx) {
      fn = _createStaderETHx;
    } else if (dexName == BaseConfig.DexName.MantleUsd) {
      fn = _createMantleUsd;
    } else if (dexName == BaseConfig.DexName.BedrockUniETH) {
      fn = _createBedrockUniETH;
    } else if (dexName == BaseConfig.DexName.Hashflow) {
      fn = _createHashflow;
    } else if (dexName == BaseConfig.DexName.PufferFinance) {
      fn = _createPufferFinance;
    } else if (dexName == BaseConfig.DexName.Native) {
      fn = _createNative;
    } else if (dexName == BaseConfig.DexName.KyberLO) {
      fn = _createKyberLO;
    } else if (dexName == BaseConfig.DexName.KyberDSLO) {
      fn = _createKyberDSLO;
    } else if (dexName == BaseConfig.DexName.SymbioticLRT) {
      fn = _createSymbioticLRT;
    } else if (dexName == BaseConfig.DexName.MaverickV2) {
      fn = _createMaverickV2;
    } else {
      // bebop, swaapv2
      swap.data = bytes('mock data');
      fn = _nothing;
    }

    swap = fn();
  }

  function _nothing() internal view returns (IExecutorL1.Swap memory swap) {}

  function _createUniSwap() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.UniSwap memory dexStructData;
    dexStructData.collectAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeUniswap.selector);
  }

  function _createGMX() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.GMX memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeGMX.selector);
  }

  function _createStableSwap() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.StableSwap memory dexStructData;
    dexStructData.dx = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeStableSwap.selector);
  }

  function _createCurveSwap() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.CurveSwap memory dexStructData;
    dexStructData.dx = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeCurve.selector);
  }

  function _createUniV3KSElastic() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.UniswapV3KSElastic memory dexStructData;
    dexStructData.swapAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeUniV3KSElastic.selector);
  }

  function _createBalancerV2() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.BalancerV2 memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeBalV2.selector);
  }

  function _createDODO() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.DODO memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeDODO.selector);
  }

  function _createSynthetix() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.Synthetix memory dexStructData;
    dexStructData.sourceAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeSynthetix.selector);
  }

  function _createCamelot() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.UniSwap memory dexStructData;
    dexStructData.collectAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeCamelot.selector);
  }

  function _createPlatypus() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.Platypus memory dexStructData;
    dexStructData.collectAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executePlatypus.selector);
  }

  function _createWrappedstETH() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.WSTETH memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeWrappedstETH.selector);
  }

  function _createPSM() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.PSM memory dexStructData;
    dexStructData.amountIn = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executePSM.selector);
  }

  function _createStEth() internal view returns (IExecutorL1.Swap memory swap) {
    swap.data = abi.encode(mockParams.amount);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeStEth.selector);
  }

  function _createMaverick() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.Maverick memory dexStructData;
    dexStructData.swapAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeMaverick.selector);
  }

  function _createSyncSwap() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.SyncSwap memory dexStructData;
    dexStructData.collectAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeSyncSwap.selector);
  }

  function _createAlgebraV1() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.AlgebraV1 memory dexStructData;
    dexStructData.swapAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeAlgebraV1.selector);
  }

  function _createBalancerBatch() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.BalancerBatch memory dexStructData;
    dexStructData.amountIn = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeBalancerBatch.selector);
  }

  function _createMantis() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.Mantis memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeMantis.selector);
  }

  function _createIziSwap() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.IziSwap memory dexStructData;
    dexStructData.swapAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeIziSwap.selector);
  }

  function _createTraderJoeV2() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.TraderJoeV2 memory dexStructData;
    dexStructData.collectAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeTraderJoeV2.selector);
  }

  function _createLevelFiV2() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.LevelFiV2 memory dexStructData;
    dexStructData.amountIn = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeLevelFiV2.selector);
  }

  function _createGMXGLP() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.GMXGLP memory dexStructData;
    dexStructData.swapAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeGMXGLP.selector);
  }

  function _createVooi() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.Vooi memory dexStructData;
    dexStructData.fromAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeVooi.selector);
  }

  function _createVelocoreV2() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.VelocoreV2 memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeVelocoreV2.selector);
  }

  function _createMaticMigrate() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.MaticMigrate memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeMaticMigrate.selector);
  }

  function _createKokonut() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.Kokonut memory dexStructData;
    dexStructData.dx = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeKokonut.selector);
  }

  function _createBalancerV1() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.BalancerV1 memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeBalancerV1.selector);
  }

  function _createArbswapStable() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.ArbswapStable memory dexStructData;
    dexStructData.dx = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeArbswapStable.selector);
  }

  function _createBancorV2() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.BancorV2 memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeBancorV2.selector);
  }

  function _createAmbient() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.Ambient memory dexStructData;
    dexStructData.qty = uint128(mockParams.amount);
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeAmbient.selector);
  }

  function _createLighterV2() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.LighterV2 memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeLighterV2.selector);
  }

  function _createUniV1() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.UniV1 memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeUniV1.selector);
  }

  function _createEtherFieETH() internal view returns (IExecutorL1.Swap memory swap) {
    swap.data = abi.encode(mockParams.amount);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeEtherFieETH.selector);
  }

  function _createEtherFiWeETH() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.EtherFiWeETH memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeEtherFiWeETH.selector);
  }

  function _createKelp() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.Kelp memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeKelp.selector);
  }

  function _createEthenaSusde() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.EthenaSusde memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeEthenaSusde.selector);
  }

  function _createRocketPool() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.RocketPool memory dexStructData;
    dexStructData.isDepositAndAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeRocketPool.selector);
  }

  function _createMakersDAI() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.MakersDAI memory dexStructData;
    dexStructData.isRedeemAndAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeMakersDAI.selector);
  }

  function _createRenzo() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.Renzo memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeRenzo.selector);
  }

  function _createWBETH() internal view returns (IExecutorL1.Swap memory swap) {
    swap.data = abi.encode(mockParams.amount);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeWBETH.selector);
  }

  function _createMantleETH() internal view returns (IExecutorL1.Swap memory swap) {
    swap.data = abi.encode(mockParams.amount);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeMantleETH.selector);
  }

  function _createFrxETH() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.FrxETH memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeFrxETH.selector);
  }

  function _createSfrxETH() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.SfrxETH memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeSfrxETH.selector);
  }

  function _createSfrxETHConvertor() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.SfrxETHConvertor memory dexStructData;
    dexStructData.isDepositAndAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeSfrxETHConvertor.selector);
  }

  function _createSwellETH() internal view returns (IExecutorL1.Swap memory swap) {
    swap.data = abi.encode(mockParams.amount);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeSwellETH.selector);
  }

  function _createRswETH() internal view returns (IExecutorL1.Swap memory swap) {
    swap.data = abi.encode(mockParams.amount);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeRswETH.selector);
  }

  function _createStaderETHx() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.StaderETHx memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeStaderETHx.selector);
  }

  function _createOriginETH() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.OriginETH memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeOriginETH.selector);
  }

  function _createMantleUsd() internal view returns (IExecutorL1.Swap memory swap) {
    swap.data = abi.encode(mockParams.amount);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeMantleUsd.selector);
  }

  function _createHashflow() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.Hashflow memory dexStructData;
    dexStructData.quote.effectiveBaseTokenAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeHashflow.selector);
  }

  function _createPufferFinance() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.PufferFinance memory dexStructData;
    dexStructData.permit.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executePufferFinance.selector);
  }

  function _createBedrockUniETH() internal view returns (IExecutorL1.Swap memory swap) {
    swap.data = abi.encode(mockParams.amount);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeBedrockUniETH.selector);
  }

  function _createKyberRfq() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.KyberRFQ memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeRfq.selector);
  }

  function _createNative() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.Native memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeNative.selector);
  }

  function _createKyberLO() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.KyberLimitOrder memory dexStructData;
    dexStructData.params.takingAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeKyberLimitOrder.selector);
  }

  function _createKyberDSLO() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.KyberDSLO memory dexStructData;
    dexStructData.params.takingAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeKyberDSLO.selector);
  }

  function _createSymbioticLRT() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.SymbioticLRT memory dexStructData;
    dexStructData.amount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeSymbioticLRT.selector);
  }

  function _createMaverickV2() internal view returns (IExecutorL1.Swap memory swap) {
    IExecutorHelperStruct.MaverickV2 memory dexStructData;
    dexStructData.collectAmount = mockParams.amount;
    swap.data = abi.encode(dexStructData);

    swap.selectorAndFlags = bytes32(IExecutorHelper.executeMaverickV2.selector);
  }
}
