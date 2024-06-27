// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {CalldataReader} from 'src/l2-contracts/CalldataReader.sol';
import {IExecutorHelperL2} from 'src/interfaces/IExecutorHelperL2.sol';
import {IExecutorHelperL2Struct} from 'src/interfaces/IExecutorHelperL2Struct.sol';
import {IBebopV3} from 'src/interfaces/pools/IBebopV3.sol';
import {BytesHelper} from 'src/l2-contracts/BytesHelper.sol';
import {Common} from 'src/l2-contracts/Common.sol';
import {IKyberDSLO} from 'src/interfaces/pools/IKyberDSLO.sol';
import {IKyberLO} from 'src/interfaces/pools/IKyberLO.sol';

/// @title DexScaler
/// @notice Contain functions to scale DEX structs
/// @dev For this repo's scope, we only care about swap amounts, so we just need to decode until we get swap amounts
library DexScaler {
  using BytesHelper for bytes;
  using CalldataReader for bytes;
  using Common for bytes;

  function scaleUniSwap(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;
    // decode
    (, startByte) = data._readPool(startByte);
    (, startByte) = data._readRecipient(startByte);
    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleUniSwap'
    );
  }

  function scaleStableSwap(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;
    (, startByte) = data._readPool(startByte);
    (, startByte) = data._readUint8(startByte);
    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleStableSwap'
    );
  }

  function scaleCurveSwap(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;
    bool canGetIndex;
    (canGetIndex, startByte) = data._readBool(0);
    (, startByte) = data._readPool(startByte);
    if (!canGetIndex) {
      (, startByte) = data._readAddress(startByte);
      (, startByte) = data._readUint8(startByte);
    }
    (, startByte) = data._readUint8(startByte);
    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleCurveSwap'
    );
  }

  function scaleUniswapV3KSElastic(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;
    (, startByte) = data._readRecipient(startByte);
    (, startByte) = data._readPool(startByte);
    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte,
      oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount,
      'scaleUniswapV3KSElastic'
    );
  }

  function scaleBalancerV2(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;
    (, startByte) = data._readPool(startByte);
    (, startByte) = data._readBytes32(startByte);
    (, startByte) = data._readUint8(startByte);
    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleBalancerV2'
    );
  }

  function scaleDODO(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;
    (, startByte) = data._readRecipient(startByte);
    (, startByte) = data._readPool(startByte);
    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleDODO'
    );
  }

  function scaleGMX(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;
    // decode
    (, startByte) = data._readPool(startByte);

    (, startByte) = data._readAddress(startByte);

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleGMX'
    );
  }

  function scaleSynthetix(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    // decode
    (, startByte) = data._readPool(startByte);

    (, startByte) = data._readAddress(startByte);
    (, startByte) = data._readBytes32(startByte);

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleSynthetix'
    );
  }

  function scaleWrappedstETH(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    // decode
    (, startByte) = data._readPool(startByte);

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleWrappedstETH'
    );
  }

  function scaleStETH(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    (uint256 swapAmount,) = data._readUint128AsUint256(0);
    return
      data.write16Bytes(0, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleStETH');
  }

  function scalePlatypus(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    // decode
    (, startByte) = data._readPool(startByte);

    (, startByte) = data._readAddress(startByte);

    (, startByte) = data._readRecipient(startByte);

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scalePlatypus'
    );
  }

  function scalePSM(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    // decode
    (, startByte) = data._readPool(startByte);

    (, startByte) = data._readAddress(startByte);

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);

    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scalePSM'
    );
  }

  function scaleMaverick(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    // decode
    (, startByte) = data._readPool(startByte);

    (, startByte) = data._readAddress(startByte);

    (, startByte) = data._readRecipient(startByte);

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleMaverick'
    );
  }

  function scaleSyncSwap(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    // decode
    (, startByte) = data._readBytes(startByte);
    (, startByte) = data._readPool(startByte);

    (, startByte) = data._readAddress(startByte);

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleSyncSwap'
    );
  }

  function scaleAlgebraV1(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readRecipient(startByte);

    (, startByte) = data._readPool(startByte);

    (, startByte) = data._readAddress(startByte);

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);

    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleAlgebraV1'
    );
  }

  function scaleBalancerBatch(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    // decode
    (, startByte) = data._readPool(startByte);

    (, startByte) = data._readBytes32Array(startByte);
    (, startByte) = data._readAddressArray(startByte);
    (, startByte) = data._readBytesArray(startByte);

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte);
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleBalancerBatch'
    );
  }

  function scaleMantis(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // pool

    (, startByte) = data._readAddress(startByte); // tokenOut

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte); // amount
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleMantis'
    );
  }

  function scaleIziSwap(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // pool

    (, startByte) = data._readAddress(startByte); // tokenOut

    // recipient
    (, startByte) = data._readRecipient(startByte);

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte); // amount
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleIziSwap'
    );
  }

  function scaleTraderJoeV2(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    // recipient
    (, startByte) = data._readRecipient(startByte);

    (, startByte) = data._readPool(startByte); // pool

    (, startByte) = data._readAddress(startByte); // tokenOut

    (, startByte) = data._readBool(startByte); // isV2

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte); // amount
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleTraderJoeV2'
    );
  }

  function scaleLevelFiV2(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // pool

    (, startByte) = data._readAddress(startByte); // tokenOut

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte); // amount
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleLevelFiV2'
    );
  }

  function scaleGMXGLP(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // pool

    (, startByte) = data._readAddress(startByte); // yearnVault

    uint8 directionFlag;
    (directionFlag, startByte) = data._readUint8(startByte);
    if (directionFlag == 1) (, startByte) = data._readAddress(startByte); // tokenOut

    (uint256 swapAmount,) = data._readUint128AsUint256(startByte); // amount
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleGMXGLP'
    );
  }

  function scaleVooi(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // pool

    (, startByte) = data._readUint8(startByte); // toId

    (uint256 fromAmount,) = data._readUint128AsUint256(startByte); // amount

    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (fromAmount * newAmount) / oldAmount, 'scaleVooi'
    );
  }

  function scaleVelocoreV2(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // pool

    (uint256 amount,) = data._readUint128AsUint256(startByte); // amount

    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleVelocoreV2'
    );
  }

  function scaleKokonut(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // pool

    (uint256 amount,) = data._readUint128AsUint256(startByte); // amount
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleKokonut'
    );
  }

  function scaleBalancerV1(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // pool

    (uint256 amount,) = data._readUint128AsUint256(startByte); // amount

    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleBalancerV1'
    );
  }

  function scaleArbswapStable(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // pool

    (uint256 dx,) = data._readUint128AsUint256(startByte); // dx

    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (dx * newAmount) / oldAmount, 'scaleArbswapStable'
    );
  }

  function scaleBancorV2(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // pool

    (, startByte) = data._readAddressArray(startByte); // swapPath

    (uint256 amount,) = data._readUint128AsUint256(startByte); // amount

    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleBancorV2'
    );
  }

  function scaleAmbient(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // pool

    (uint128 qty,) = data._readUint128(startByte); // amount

    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (qty * newAmount) / oldAmount, 'scaleAmbient'
    );
  }

  function scaleLighterV2(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // orderbook

    (uint256 amount,) = data._readUint128AsUint256(startByte); // amount

    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleLighterV2'
    );
  }

  function scaleMaiPSM(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;
    (, startByte) = data._readPool(startByte); // pool

    (uint256 amount,) = data._readUint128AsUint256(startByte); // amount

    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleMaiPSM'
    );
  }

  function scaleKyberRFQ(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;
    (, startByte) = data._readPool(startByte); // rfq
    (, startByte) = data._readOrderRFQ(startByte); // order
    (, startByte) = data._readBytes(startByte); // signature
    (uint256 amount,) = data._readUint128AsUint256(startByte); // amount
    return data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleKyberRFQ'
    );
  }

  function scaleDSLO(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // kyberLOAddress

    (, startByte) = data._readAddress(startByte); // makerAsset

    // (, startByte) = data._readAddress(startByte); // don't have takerAsset

    (
      IKyberDSLO.FillBatchOrdersParams memory params,
      ,
      uint256 takingAmountStartByte,
      uint256 thresholdStartByte
    ) = data._readDSLOFillBatchOrdersParams(startByte); // FillBatchOrdersParams

    data = data.write16Bytes(
      takingAmountStartByte,
      oldAmount == 0 ? 0 : (params.takingAmount * newAmount) / oldAmount,
      'scaleDSLO'
    );

    return data.write16Bytes(thresholdStartByte, 1, 'scaleThreshold');
  }

  function scaleKyberLimitOrder(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readPool(startByte); // kyberLOAddress

    (, startByte) = data._readAddress(startByte); // makerAsset

    // (, startByte) = data._readAddress(startByte); // takerAsset

    (
      IKyberLO.FillBatchOrdersParams memory params,
      ,
      uint256 takingAmountStartByte,
      uint256 thresholdStartByte
    ) = data._readLOFillBatchOrdersParams(startByte); // FillBatchOrdersParams

    data = data.write16Bytes(
      takingAmountStartByte,
      oldAmount == 0 ? 0 : (params.takingAmount * newAmount) / oldAmount,
      'scaleLO'
    );
    return data.write16Bytes(thresholdStartByte, 1, 'scaleThreshold');
  }

  function scaleHashflow(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    uint256 startByte;

    (, startByte) = data._readAddress(startByte); // router

    (IExecutorHelperL2.RFQTQuote memory rfqQuote,, uint256 ebtaStartByte) =
      data._readRFQTQuote(startByte); // RFQTQuote

    return data.write16Bytes(
      ebtaStartByte,
      oldAmount == 0 ? 0 : (rfqQuote.effectiveBaseTokenAmount * newAmount) / oldAmount,
      'scaleHashflow'
    );
  }

  function scaleNative(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    require(newAmount < oldAmount, 'Native: not support scale up');

    uint256 startByte;
    bytes memory strData;
    uint256 amount;
    uint256 multihopAndOffset;
    uint256 strDataStartByte;

    (, startByte) = data._readAddress(startByte); // target
    (amount, startByte) = data._readUint128AsUint256(startByte); // amount
    (strData, startByte) = data._readBytes(startByte); // data
    strDataStartByte = startByte;
    (, startByte) = data._readAddress(startByte); // tokenIn
    (, startByte) = data._readAddress(startByte); // tokenOut
    (, startByte) = data._readAddress(startByte); // recipient
    (multihopAndOffset, startByte) = data._readUint256(startByte); // multihopAndOffset

    require(multihopAndOffset >> 255 == 0, 'Native: Multihop not supported');

    amount = (amount * newAmount) / oldAmount;

    uint256 amountInOffset = uint256(uint64(multihopAndOffset >> 64));
    uint256 amountOutMinOffset = uint256(uint64(multihopAndOffset));
    // bytes memory newCallData = strData;

    strData = strData.write32Bytes(amountInOffset, amount, 'ScaleStructDataAmount');

    // update amount out min if needed
    if (amountOutMinOffset != 0) {
      strData = strData.write32Bytes(amountOutMinOffset, 1, 'ScaleStructDataAmountOutMin');
    }

    return data.writeBytes(strDataStartByte, strData);
  }

  function scaleBebop(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    require(newAmount < oldAmount, 'Bebop: not support scale up');

    uint256 startByte;
    uint256 amount;
    uint256 amountStartByte;
    bytes memory txData;

    (, startByte) = data._readAddress(startByte); // pool

    (amount, startByte) = data._readUint128AsUint256(startByte); // amount
    amountStartByte = startByte;
    (txData, startByte) = data._readBytes(startByte); // data

    amount = (amount * newAmount) / oldAmount;

    // update calldata with new swap amount
    (bytes4 selector, bytes memory callData) = txData.splitCalldata();

    (IBebopV3.Single memory s, IBebopV3.MakerSignature memory m,) =
      abi.decode(callData, (IBebopV3.Single, IBebopV3.MakerSignature, uint256));

    txData = bytes.concat(bytes4(selector), abi.encode(s, m, amount));

    data.write32Bytes(amountStartByte, amount, 'scaleBebopAmount');

    return data.writeBytes(startByte, txData);
  }
}
