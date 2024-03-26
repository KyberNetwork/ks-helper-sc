// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import {IExecutorHelper} from '../interfaces/IExecutorHelper.sol';

import {RevertReasonParser} from '../libraries/RevertReasonParser.sol';

contract DexHelper01 {
  function executeUniswap(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.UniSwap memory uniSwap = abi.decode(data, (IExecutorHelper.UniSwap));
    uniSwap.collectAmount = (uniSwap.collectAmount * newAmount) / oldAmount;
    return abi.encode(uniSwap);
  }

  function executeStableSwap(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.StableSwap memory stableSwap = abi.decode(data, (IExecutorHelper.StableSwap));
    stableSwap.dx = (stableSwap.dx * newAmount) / oldAmount;
    return abi.encode(stableSwap);
  }

  function executeCurve(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.CurveSwap memory curveSwap = abi.decode(data, (IExecutorHelper.CurveSwap));
    curveSwap.dx = (curveSwap.dx * newAmount) / oldAmount;
    return abi.encode(curveSwap);
  }

  function executeKSClassic(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.UniSwap memory kyberDMMSwap = abi.decode(data, (IExecutorHelper.UniSwap));
    kyberDMMSwap.collectAmount = (kyberDMMSwap.collectAmount * newAmount) / oldAmount;
    return abi.encode(kyberDMMSwap);
  }

  function executeUniV3KSElastic(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.UniswapV3KSElastic memory uniSwapV3ProMM =
      abi.decode(data, (IExecutorHelper.UniswapV3KSElastic));
    uniSwapV3ProMM.swapAmount = (uniSwapV3ProMM.swapAmount * newAmount) / oldAmount;

    return abi.encode(uniSwapV3ProMM);
  }

  function executeBalV2(
    bytes memory scalingData,
    uint256 /* */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.BalancerV2 memory balancerV2 = abi.decode(data, (IExecutorHelper.BalancerV2));
    balancerV2.amount = (balancerV2.amount * newAmount) / oldAmount;
    return abi.encode(balancerV2);
  }

  function executeDODO(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.DODO memory dodo = abi.decode(data, (IExecutorHelper.DODO));
    dodo.amount = (dodo.amount * newAmount) / oldAmount;
    return abi.encode(dodo);
  }

  function executeVelodrome(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.UniSwap memory velodrome = abi.decode(data, (IExecutorHelper.UniSwap));
    velodrome.collectAmount = (velodrome.collectAmount * newAmount) / oldAmount;
    return abi.encode(velodrome);
  }

  function executeGMX(bytes memory scalingData, uint256 /*  */ ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.GMX memory gmx = abi.decode(data, (IExecutorHelper.GMX));
    gmx.amount = (gmx.amount * newAmount) / oldAmount;
    return abi.encode(gmx);
  }

  function executeSynthetix(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.Synthetix memory synthetix = abi.decode(data, (IExecutorHelper.Synthetix));
    synthetix.sourceAmount = (synthetix.sourceAmount * newAmount) / oldAmount;
    return abi.encode(synthetix);
  }

  function executeCamelot(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.UniSwap memory camelot = abi.decode(data, (IExecutorHelper.UniSwap));
    camelot.collectAmount = (camelot.collectAmount * newAmount) / oldAmount;
    return abi.encode(camelot);
  }

  function executePlatypus(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.Platypus memory platypus = abi.decode(data, (IExecutorHelper.Platypus));
    platypus.collectAmount = (platypus.collectAmount * newAmount) / oldAmount;
    return abi.encode(platypus);
  }

  function executeWrappedstETH(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.WSTETH memory wstEthData = abi.decode(data, (IExecutorHelper.WSTETH));
    wstEthData.amount = (wstEthData.amount * newAmount) / oldAmount;
    return abi.encode(wstEthData);
  }

  function executePSM(bytes memory scalingData, uint256 /*  */ ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.PSM memory psm = abi.decode(data, (IExecutorHelper.PSM));
    psm.amountIn = (psm.amountIn * newAmount) / oldAmount;
    return abi.encode(psm);
  }

  function executeFrax(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.UniSwap memory frax = abi.decode(data, (IExecutorHelper.UniSwap));
    frax.collectAmount = (frax.collectAmount * newAmount) / oldAmount;
    return abi.encode(frax);
  }

  function executeStEth(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 amount = abi.decode(data, (uint256));
    amount = (amount * newAmount) / oldAmount;
    return abi.encode(amount);
  }

  function executeMaverick(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.Maverick memory maverick = abi.decode(data, (IExecutorHelper.Maverick));
    maverick.swapAmount = (maverick.swapAmount * newAmount) / oldAmount;
    return abi.encode(maverick);
  }

  function executeSyncSwap(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.SyncSwap memory syncSwap = abi.decode(data, (IExecutorHelper.SyncSwap));
    syncSwap.collectAmount = (syncSwap.collectAmount * newAmount) / oldAmount;
    return abi.encode(syncSwap);
  }

  function executeAlgebraV1(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.AlgebraV1 memory algebraV1Swap = abi.decode(data, (IExecutorHelper.AlgebraV1));
    algebraV1Swap.swapAmount = (algebraV1Swap.swapAmount * newAmount) / oldAmount;
    return abi.encode(algebraV1Swap);
  }

  function executeBalancerBatch(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.BalancerBatch memory balancerBatch =
      abi.decode(data, (IExecutorHelper.BalancerBatch));
    balancerBatch.amountIn = (balancerBatch.amountIn * newAmount) / oldAmount;
    return abi.encode(balancerBatch);
  }

  function executeMantis(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.Mantis memory mantis = abi.decode(data, (IExecutorHelper.Mantis));
    mantis.amount = (mantis.amount * newAmount) / oldAmount;
    return abi.encode(mantis);
  }

  function executeIziSwap(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.IziSwap memory iZi = abi.decode(data, (IExecutorHelper.IziSwap));
    iZi.swapAmount = (iZi.swapAmount * newAmount) / oldAmount;
    return abi.encode(iZi);
  }

  function executeTraderJoeV2(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.TraderJoeV2 memory traderJoe = abi.decode(data, (IExecutorHelper.TraderJoeV2));

    // traderJoe.collectAmount; // most significant 1 bit is to determine whether pool is v2.1, else v2.0
    traderJoe.collectAmount = (traderJoe.collectAmount & (1 << 255))
      | ((uint256(traderJoe.collectAmount << 1 >> 1) * newAmount) / oldAmount);
    return abi.encode(traderJoe);
  }

  function executeLevelFiV2(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.LevelFiV2 memory levelFiV2 = abi.decode(data, (IExecutorHelper.LevelFiV2));
    levelFiV2.amountIn = (levelFiV2.amountIn * newAmount) / oldAmount;
    return abi.encode(levelFiV2);
  }

  function executeGMXGLP(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.GMXGLP memory swapData = abi.decode(data, (IExecutorHelper.GMXGLP));
    swapData.swapAmount = (swapData.swapAmount * newAmount) / oldAmount;
    return abi.encode(swapData);
  }

  function executeVooi(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.Vooi memory vooi = abi.decode(data, (IExecutorHelper.Vooi));
    vooi.fromAmount = (vooi.fromAmount * newAmount) / oldAmount;
    return abi.encode(vooi);
  }

  function executeVelocoreV2(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.VelocoreV2 memory velocorev2 = abi.decode(data, (IExecutorHelper.VelocoreV2));
    velocorev2.amount = (velocorev2.amount * newAmount) / oldAmount;
    return abi.encode(velocorev2);
  }

  function executeMaticMigrate(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.MaticMigrate memory maticMigrate =
      abi.decode(data, (IExecutorHelper.MaticMigrate));
    maticMigrate.amount = (maticMigrate.amount * newAmount) / oldAmount;
    return abi.encode(maticMigrate);
  }

  function executeKokonut(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.Kokonut memory kokonut = abi.decode(data, (IExecutorHelper.Kokonut));
    kokonut.dx = (kokonut.dx * newAmount) / oldAmount;
    return abi.encode(kokonut);
  }

  function executeBalancerV1(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.BalancerV1 memory balancerV1 = abi.decode(data, (IExecutorHelper.BalancerV1));
    balancerV1.amount = (balancerV1.amount * newAmount) / oldAmount;
    return abi.encode(balancerV1);
  }

  function executeArbswapStable(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.ArbswapStable memory arbswapStable =
      abi.decode(data, (IExecutorHelper.ArbswapStable));
    arbswapStable.dx = (arbswapStable.dx * newAmount) / oldAmount;
    return abi.encode(arbswapStable);
  }

  function executeBancorV2(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.BancorV2 memory bancorV2 = abi.decode(data, (IExecutorHelper.BancorV2));
    bancorV2.amount = (bancorV2.amount * newAmount) / oldAmount;
    return abi.encode(bancorV2);
  }

  function executeAmbient(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.Ambient memory ambient = abi.decode(data, (IExecutorHelper.Ambient));
    ambient.qty = uint128((uint256(ambient.qty) * newAmount) / oldAmount);
    return abi.encode(ambient);
  }

  function executeLighterV2(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.LighterV2 memory structData = abi.decode(data, (IExecutorHelper.LighterV2));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeUniV1(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.UniV1 memory structData = abi.decode(data, (IExecutorHelper.UniV1));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeEtherFieETH(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 depositAmount = abi.decode(data, (uint256));
    depositAmount = uint128((depositAmount * newAmount) / oldAmount);
    return abi.encode(depositAmount);
  }

  function executeEtherFiWeETH(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.EtherFiWeETH memory structData =
      abi.decode(data, (IExecutorHelper.EtherFiWeETH));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeKelp(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.Kelp memory structData = abi.decode(data, (IExecutorHelper.Kelp));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeEthenaSusde(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.EthenaSusde memory structData = abi.decode(data, (IExecutorHelper.EthenaSusde));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeRocketPool(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.RocketPool memory structData = abi.decode(data, (IExecutorHelper.RocketPool));
    uint128 _amount =
      uint128((uint256(uint128(structData.isDepositAndAmount)) * newAmount) / oldAmount);
    structData.isDepositAndAmount |= uint256(_amount);
    return abi.encode(structData);
  }

  function executeMakersDAI(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelper.MakersDAI memory structData = abi.decode(data, (IExecutorHelper.MakersDAI));
    uint128 _amount =
      uint128((uint256(uint128(structData.isRedeemAndAmount)) * newAmount) / oldAmount);
    structData.isRedeemAndAmount |= uint256(_amount);
    return abi.encode(structData);
  }
}
