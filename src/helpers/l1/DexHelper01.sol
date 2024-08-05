// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IExecutorHelperStruct} from 'src/interfaces/IExecutorHelperStruct.sol';
import {IBebopV3} from 'src/interfaces/pools/IBebopV3.sol';
import {RevertReasonParser} from 'src/libraries/RevertReasonParser.sol';
import {BytesHelper} from 'src/libraries/BytesHelper.sol';

contract DexHelper01 {
  // Not support SwaapV2
  using BytesHelper for bytes;

  function executeUniswap(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.UniSwap memory uniSwap = abi.decode(data, (IExecutorHelperStruct.UniSwap));
    uniSwap.collectAmount = (uniSwap.collectAmount * newAmount) / oldAmount;
    return abi.encode(uniSwap);
  }

  function executeStableSwap(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.StableSwap memory stableSwap =
      abi.decode(data, (IExecutorHelperStruct.StableSwap));
    stableSwap.dx = (stableSwap.dx * newAmount) / oldAmount;
    return abi.encode(stableSwap);
  }

  function executeCurve(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.CurveSwap memory curveSwap =
      abi.decode(data, (IExecutorHelperStruct.CurveSwap));
    curveSwap.dx = (curveSwap.dx * newAmount) / oldAmount;
    return abi.encode(curveSwap);
  }

  function executeKSClassic(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.UniSwap memory kyberDMMSwap =
      abi.decode(data, (IExecutorHelperStruct.UniSwap));
    kyberDMMSwap.collectAmount = (kyberDMMSwap.collectAmount * newAmount) / oldAmount;
    return abi.encode(kyberDMMSwap);
  }

  function executeUniV3KSElastic(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.UniswapV3KSElastic memory uniSwapV3ProMM =
      abi.decode(data, (IExecutorHelperStruct.UniswapV3KSElastic));
    uniSwapV3ProMM.swapAmount = (uniSwapV3ProMM.swapAmount * newAmount) / oldAmount;

    return abi.encode(uniSwapV3ProMM);
  }

  function executeBalV2(
    bytes memory scalingData,
    uint256 /* */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.BalancerV2 memory balancerV2 =
      abi.decode(data, (IExecutorHelperStruct.BalancerV2));
    balancerV2.amount = (balancerV2.amount * newAmount) / oldAmount;
    return abi.encode(balancerV2);
  }

  function executeDODO(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.DODO memory dodo = abi.decode(data, (IExecutorHelperStruct.DODO));
    dodo.amount = (dodo.amount * newAmount) / oldAmount;
    return abi.encode(dodo);
  }

  function executeVelodrome(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.UniSwap memory velodrome =
      abi.decode(data, (IExecutorHelperStruct.UniSwap));
    velodrome.collectAmount = (velodrome.collectAmount * newAmount) / oldAmount;
    return abi.encode(velodrome);
  }

  function executeGMX(bytes memory scalingData, uint256 /*  */ ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.GMX memory gmx = abi.decode(data, (IExecutorHelperStruct.GMX));
    gmx.amount = (gmx.amount * newAmount) / oldAmount;
    return abi.encode(gmx);
  }

  function executeSynthetix(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.Synthetix memory synthetix =
      abi.decode(data, (IExecutorHelperStruct.Synthetix));
    synthetix.sourceAmount = (synthetix.sourceAmount * newAmount) / oldAmount;
    return abi.encode(synthetix);
  }

  function executeCamelot(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.UniSwap memory camelot = abi.decode(data, (IExecutorHelperStruct.UniSwap));
    camelot.collectAmount = (camelot.collectAmount * newAmount) / oldAmount;
    return abi.encode(camelot);
  }

  function executePlatypus(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.Platypus memory platypus =
      abi.decode(data, (IExecutorHelperStruct.Platypus));
    platypus.collectAmount = (platypus.collectAmount * newAmount) / oldAmount;
    return abi.encode(platypus);
  }

  function executeWrappedstETH(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.WSTETH memory wstEthData =
      abi.decode(data, (IExecutorHelperStruct.WSTETH));
    wstEthData.amount = (wstEthData.amount * newAmount) / oldAmount;
    return abi.encode(wstEthData);
  }

  function executePSM(bytes memory scalingData, uint256 /*  */ ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.PSM memory psm = abi.decode(data, (IExecutorHelperStruct.PSM));
    psm.amountIn = (psm.amountIn * newAmount) / oldAmount;
    return abi.encode(psm);
  }

  function executeFrax(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.UniSwap memory frax = abi.decode(data, (IExecutorHelperStruct.UniSwap));
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

    IExecutorHelperStruct.Maverick memory maverick =
      abi.decode(data, (IExecutorHelperStruct.Maverick));
    maverick.swapAmount = (maverick.swapAmount * newAmount) / oldAmount;
    return abi.encode(maverick);
  }

  function executeSyncSwap(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.SyncSwap memory syncSwap =
      abi.decode(data, (IExecutorHelperStruct.SyncSwap));
    syncSwap.collectAmount = (syncSwap.collectAmount * newAmount) / oldAmount;
    return abi.encode(syncSwap);
  }

  function executeAlgebraV1(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.AlgebraV1 memory algebraV1Swap =
      abi.decode(data, (IExecutorHelperStruct.AlgebraV1));
    algebraV1Swap.swapAmount = (algebraV1Swap.swapAmount * newAmount) / oldAmount;
    return abi.encode(algebraV1Swap);
  }

  function executeBalancerBatch(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.BalancerBatch memory balancerBatch =
      abi.decode(data, (IExecutorHelperStruct.BalancerBatch));
    balancerBatch.amountIn = (balancerBatch.amountIn * newAmount) / oldAmount;
    return abi.encode(balancerBatch);
  }

  function executeMantis(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.Mantis memory mantis = abi.decode(data, (IExecutorHelperStruct.Mantis));
    mantis.amount = (mantis.amount * newAmount) / oldAmount;
    return abi.encode(mantis);
  }

  function executeIziSwap(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.IziSwap memory iZi = abi.decode(data, (IExecutorHelperStruct.IziSwap));
    iZi.swapAmount = (iZi.swapAmount * newAmount) / oldAmount;
    return abi.encode(iZi);
  }

  function executeTraderJoeV2(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.TraderJoeV2 memory traderJoe =
      abi.decode(data, (IExecutorHelperStruct.TraderJoeV2));

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

    IExecutorHelperStruct.LevelFiV2 memory levelFiV2 =
      abi.decode(data, (IExecutorHelperStruct.LevelFiV2));
    levelFiV2.amountIn = (levelFiV2.amountIn * newAmount) / oldAmount;
    return abi.encode(levelFiV2);
  }

  function executeGMXGLP(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.GMXGLP memory swapData = abi.decode(data, (IExecutorHelperStruct.GMXGLP));
    swapData.swapAmount = (swapData.swapAmount * newAmount) / oldAmount;
    return abi.encode(swapData);
  }

  function executeVooi(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.Vooi memory vooi = abi.decode(data, (IExecutorHelperStruct.Vooi));
    vooi.fromAmount = (vooi.fromAmount * newAmount) / oldAmount;
    return abi.encode(vooi);
  }

  function executeVelocoreV2(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.VelocoreV2 memory velocorev2 =
      abi.decode(data, (IExecutorHelperStruct.VelocoreV2));
    velocorev2.amount = (velocorev2.amount * newAmount) / oldAmount;
    return abi.encode(velocorev2);
  }

  function executeMaticMigrate(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.MaticMigrate memory maticMigrate =
      abi.decode(data, (IExecutorHelperStruct.MaticMigrate));
    maticMigrate.amount = (maticMigrate.amount * newAmount) / oldAmount;
    return abi.encode(maticMigrate);
  }

  function executeKokonut(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.Kokonut memory kokonut = abi.decode(data, (IExecutorHelperStruct.Kokonut));
    kokonut.dx = (kokonut.dx * newAmount) / oldAmount;
    return abi.encode(kokonut);
  }

  function executeBalancerV1(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.BalancerV1 memory balancerV1 =
      abi.decode(data, (IExecutorHelperStruct.BalancerV1));
    balancerV1.amount = (balancerV1.amount * newAmount) / oldAmount;
    return abi.encode(balancerV1);
  }

  function executeArbswapStable(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.ArbswapStable memory arbswapStable =
      abi.decode(data, (IExecutorHelperStruct.ArbswapStable));
    arbswapStable.dx = (arbswapStable.dx * newAmount) / oldAmount;
    return abi.encode(arbswapStable);
  }

  function executeBancorV2(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.BancorV2 memory bancorV2 =
      abi.decode(data, (IExecutorHelperStruct.BancorV2));
    bancorV2.amount = (bancorV2.amount * newAmount) / oldAmount;
    return abi.encode(bancorV2);
  }

  function executeAmbient(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.Ambient memory ambient = abi.decode(data, (IExecutorHelperStruct.Ambient));
    ambient.qty = uint128((uint256(ambient.qty) * newAmount) / oldAmount);
    return abi.encode(ambient);
  }

  function executeLighterV2(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.LighterV2 memory structData =
      abi.decode(data, (IExecutorHelperStruct.LighterV2));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeUniV1(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.UniV1 memory structData = abi.decode(data, (IExecutorHelperStruct.UniV1));
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

    IExecutorHelperStruct.EtherFiWeETH memory structData =
      abi.decode(data, (IExecutorHelperStruct.EtherFiWeETH));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeKelp(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.Kelp memory structData = abi.decode(data, (IExecutorHelperStruct.Kelp));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeEthenaSusde(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.EthenaSusde memory structData =
      abi.decode(data, (IExecutorHelperStruct.EthenaSusde));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeRocketPool(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.RocketPool memory structData =
      abi.decode(data, (IExecutorHelperStruct.RocketPool));
    uint128 _amount =
      uint128((uint256(uint128(structData.isDepositAndAmount)) * newAmount) / oldAmount);

    bool _isDeposit = (structData.isDepositAndAmount >> 255) == 1;

    // reset and create new variable for isDeposit and amount
    structData.isDepositAndAmount = 0;
    structData.isDepositAndAmount |= uint256(uint128(_amount));
    structData.isDepositAndAmount |= uint256(_isDeposit ? 1 : 0) << 255;
    return abi.encode(structData);
  }

  function executeMakersDAI(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.MakersDAI memory structData =
      abi.decode(data, (IExecutorHelperStruct.MakersDAI));
    uint128 _amount =
      uint128((uint256(uint128(structData.isRedeemAndAmount)) * newAmount) / oldAmount);
    bool _isRedeem = (structData.isRedeemAndAmount >> 255) == 1;

    // reset and create new variable for isRedeem and amount
    structData.isRedeemAndAmount = 0;
    structData.isRedeemAndAmount |= uint256(uint128(_amount));
    structData.isRedeemAndAmount |= uint256(_isRedeem ? 1 : 0) << 255;
    return abi.encode(structData);
  }

  function executeRenzo(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.Renzo memory structData = abi.decode(data, (IExecutorHelperStruct.Renzo));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeFrxETH(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.FrxETH memory structData =
      abi.decode(data, (IExecutorHelperStruct.FrxETH));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeSfrxETH(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.SfrxETH memory structData =
      abi.decode(data, (IExecutorHelperStruct.SfrxETH));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeSfrxETHConvertor(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.SfrxETHConvertor memory structData =
      abi.decode(data, (IExecutorHelperStruct.SfrxETHConvertor));
    uint128 _amount =
      uint128((uint256(uint128(structData.isDepositAndAmount)) * newAmount) / oldAmount);

    bool _isDeposit = (structData.isDepositAndAmount >> 255) == 1;

    // reset and create new variable for isDeposit and amount
    structData.isDepositAndAmount = 0;
    structData.isDepositAndAmount |= uint256(uint128(_amount));
    structData.isDepositAndAmount |= uint256(_isDeposit ? 1 : 0) << 255;
    return abi.encode(structData);
  }

  function executeOriginETH(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.OriginETH memory structData =
      abi.decode(data, (IExecutorHelperStruct.OriginETH));
    structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeMantleUsd(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 isWrapAndAmount = abi.decode(data, (uint256));

    uint128 _amount = uint128((uint256(uint128(isWrapAndAmount)) * newAmount) / oldAmount);

    bool _isWrap = (isWrapAndAmount >> 255) == 1;

    // reset and create new variable for isWrap and amount
    isWrapAndAmount = 0;
    isWrapAndAmount |= uint256(uint128(_amount));
    isWrapAndAmount |= uint256(_isWrap ? 1 : 0) << 255;
    return abi.encode(isWrapAndAmount);
  }

  function executePufferFinance(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.PufferFinance memory structData =
      abi.decode(data, (IExecutorHelperStruct.PufferFinance));
    structData.permit.amount = uint128((uint256(structData.permit.amount) * newAmount) / oldAmount);
    return abi.encode(structData);
  }

  function executeSwellETH(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 amount = abi.decode(data, (uint256));
    amount = (amount * newAmount) / oldAmount;
    return abi.encode(amount);
  }

  function executeRswETH(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 amount = abi.decode(data, (uint256));
    amount = (amount * newAmount) / oldAmount;
    return abi.encode(amount);
  }

  function executeStaderETHx(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.StaderETHx memory structData =
      abi.decode(data, (IExecutorHelperStruct.StaderETHx));
    structData.amount = (structData.amount * newAmount) / oldAmount;
    return abi.encode(structData);
  }

  function executeBedrockUniETH(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 amount = abi.decode(data, (uint256));
    amount = (amount * newAmount) / oldAmount;
    return abi.encode(amount);
  }

  function executeWBETH(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 amount = abi.decode(data, (uint256));
    amount = (amount * newAmount) / oldAmount;
    return abi.encode(amount);
  }

  function executeMantleETH(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 amount = abi.decode(data, (uint256));
    amount = (amount * newAmount) / oldAmount;
    return abi.encode(amount);
  }

  function executeHashflow(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.Hashflow memory structData =
      abi.decode(data, (IExecutorHelperStruct.Hashflow));
    structData.quote.effectiveBaseTokenAmount =
      (structData.quote.effectiveBaseTokenAmount * newAmount) / oldAmount;
    return abi.encode(structData);
  }

  function executeRfq(bytes memory scalingData, uint256 /*  */ ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.KyberRFQ memory structData =
      abi.decode(data, (IExecutorHelperStruct.KyberRFQ));
    structData.amount = (structData.amount * newAmount) / oldAmount;
    return abi.encode(structData);
  }

  function executeNative(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    require(newAmount < oldAmount, 'Native: not support scale up');

    IExecutorHelperStruct.Native memory structData =
      abi.decode(data, (IExecutorHelperStruct.Native));

    require(structData.multihopAndOffset >> 255 == 0, 'Native: Multihop not supported');
    structData.amount = (structData.amount * newAmount) / oldAmount;

    uint256 amountInOffset = uint256(uint64(structData.multihopAndOffset >> 64));
    uint256 amountOutMinOffset = uint256(uint64(structData.multihopAndOffset));
    bytes memory newCallData = structData.data;

    newCallData = newCallData.update(structData.amount, amountInOffset);

    // update amount out min if needed
    if (amountOutMinOffset != 0) {
      newCallData = newCallData.update(1, amountOutMinOffset);
    }

    return abi.encode(structData);
  }

  function executeKyberLimitOrder(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.KyberLimitOrder memory structData =
      abi.decode(data, (IExecutorHelperStruct.KyberLimitOrder));
    structData.params.takingAmount = (structData.params.takingAmount * newAmount) / oldAmount;

    structData.params.thresholdAmount = 1;
    return abi.encode(structData);
  }

  function executeKyberDSLO(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.KyberDSLO memory structData =
      abi.decode(data, (IExecutorHelperStruct.KyberDSLO));
    structData.params.takingAmount = (structData.params.takingAmount * newAmount) / oldAmount;

    structData.params.thresholdAmount = 1;
    return abi.encode(structData);
  }

  function executeBebop(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    require(newAmount < oldAmount, 'Bebop: not support scale up');

    IExecutorHelperStruct.Bebop memory structData = abi.decode(data, (IExecutorHelperStruct.Bebop));

    structData.amount = (structData.amount * newAmount) / oldAmount;

    // update calldata with new swap amount
    (bytes4 selector, bytes memory callData) = structData.data.splitCalldata();

    (IBebopV3.Single memory s, IBebopV3.MakerSignature memory m,) =
      abi.decode(callData, (IBebopV3.Single, IBebopV3.MakerSignature, uint256));
    structData.data = bytes.concat(bytes4(selector), abi.encode(s, m, structData.amount));

    return abi.encode(structData);
  }

  function executeSymbioticLRT(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.SymbioticLRT memory structData =
      abi.decode(data, (IExecutorHelperStruct.SymbioticLRT));
    structData.amount = (structData.amount * newAmount) / oldAmount;
    return abi.encode(structData);
  }

  function executeMaverickV2(
    bytes memory scalingData,
    uint256 /*  */
  ) public pure returns (bytes memory) {
    (bytes memory data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    IExecutorHelperStruct.MaverickV2 memory structData =
      abi.decode(data, (IExecutorHelperStruct.MaverickV2));
    structData.collectAmount = (structData.collectAmount * newAmount) / oldAmount;
    return abi.encode(structData);
  }
}
