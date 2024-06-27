// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import './Common.sol';
import 'src/interfaces/IExecutorHelperL2.sol';

/// @title DexReader6
/// @notice Contain functions to decode dex data
/// @dev For this repo's scope, we only care about swap amounts, so we just need to decode until we get swap amounts
contract DexReader6 is Common {
  function readLighterV2(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.LighterV2 memory swap;
    // decode
    (swap.orderBook, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    if (isFirstDex) {
      (swap.amount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.amount = collect ? type(uint256).max : 0;
    }

    swap.tokenIn = tokenIn;

    (swap.isAsk, startByte) = _readBool(data, startByte);

    (swap.tokenOut, startByte) = _readAddress(data, startByte);

    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.recipient = nextPool;
    else if (recipientFlag == 2) swap.recipient = address(this);
    else (swap.recipient, startByte) = _readAddress(data, startByte);

    return abi.encode(swap);
  }

  function readMaiPSM(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.FrxETH memory swap;
    // decode
    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    if (isFirstDex) {
      (swap.amount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.amount = collect ? type(uint256).max : 0;
    }

    (swap.tokenOut, startByte) = _readAddress(data, startByte);

    return abi.encode(swap);
  }

  function readHashflow(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public pure returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.Hashflow memory swap;
    // decode
    (swap.router, startByte) = _readAddress(data, startByte);
    if (getPoolOnly) return abi.encode(swap);
    (swap.quote, startByte) = _readHashflowRFQTQuote(data, startByte, tokenIn);
    return abi.encode(swap);
  }

  function _readHashflowRFQTQuote(
    bytes memory data,
    uint256 startByte,
    address tokenIn
  ) private pure returns (IExecutorHelperL2Struct.RFQTQuote memory quote, uint256) {
    (quote.pool, startByte) = _readAddress(data, startByte);
    (quote.externalAccount, startByte) = _readAddress(data, startByte);
    (quote.trader, startByte) = _readAddress(data, startByte);
    (quote.effectiveTrader, startByte) = _readAddress(data, startByte);
    quote.baseToken = tokenIn;
    (quote.quoteToken, startByte) = _readAddress(data, startByte);
    (quote.effectiveBaseTokenAmount, startByte) = _readUint128AsUint256(data, startByte);
    (quote.baseTokenAmount, startByte) = _readUint128AsUint256(data, startByte);
    (quote.quoteTokenAmount, startByte) = _readUint128AsUint256(data, startByte);
    (quote.quoteExpiry, startByte) = _readUint128AsUint256(data, startByte);
    (quote.nonce, startByte) = _readUint128AsUint256(data, startByte);
    (quote.txid, startByte) = _readBytes32(data, startByte);
    (quote.signature, startByte) = _readBytes(data, startByte);
    return (quote, startByte);
  }

  function readNative(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.Native memory swap;
    (swap.target, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    (swap.amount, startByte) = _readUint128(data, startByte);

    (swap.data, startByte) = _readBytes(data, startByte);

    swap.tokenIn = tokenIn;
    (swap.tokenOut, startByte) = _readAddress(data, startByte);

    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.recipient = nextPool;
    else if (recipientFlag == 2) swap.recipient = address(this);
    else (swap.recipient, startByte) = _readAddress(data, startByte);

    (bytes memory r,) = _calldataVal(data, startByte, 32);

    swap.multihopAndOffset = uint256(bytes32(r));

    return abi.encode(swap);
  }

  function readBebop(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.Bebop memory swap;
    // decode
    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    if (isFirstDex) {
      (swap.amount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.amount = collect ? type(uint256).max : 0;
    }

    (swap.data, startByte) = _readBytes(data, startByte);

    swap.tokenIn = tokenIn;

    (swap.tokenOut, startByte) = _readAddress(data, startByte);

    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.recipient = nextPool;
    else if (recipientFlag == 2) swap.recipient = address(this);
    else (swap.recipient, startByte) = _readAddress(data, startByte);

    return abi.encode(swap);
  }

  function readKyberDSLO(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.KyberDSLO memory swap;

    (swap.kyberLOAddress, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    (swap.makerAsset, startByte) = _readAddress(data, startByte);
    (swap.params, startByte) = _readFillDSLOBatchOrdersParams(data, startByte, isFirstDex);
    // infer
    swap.takerAsset = tokenIn;
    return abi.encode(swap);
  }

  function _readDSLimitOrder(
    bytes memory data,
    uint256 startByte
  ) private pure returns (IKyberDSLO.Order memory order, uint256) {
    (order.salt, startByte) = _readUint128AsUint256(data, startByte);
    (order.makerAsset, startByte) = _readAddress(data, startByte);
    (order.takerAsset, startByte) = _readAddress(data, startByte);
    (order.maker, startByte) = _readAddress(data, startByte);
    (order.receiver, startByte) = _readAddress(data, startByte);
    (order.allowedSender, startByte) = _readAddress(data, startByte);
    (order.makingAmount, startByte) = _readUint128AsUint256(data, startByte);
    (order.takingAmount, startByte) = _readUint128AsUint256(data, startByte);
    {
      bytes memory feeConfigAsBytes;
      (feeConfigAsBytes, startByte) = _calldataVal(data, startByte, 25); // read 25 bytes since feeConfig uses totally 193 bits
      order.feeConfig = uint256(uint200(bytes25(feeConfigAsBytes)));
    }
    (order.makerAssetData, startByte) = _readBytes(data, startByte);
    (order.takerAssetData, startByte) = _readBytes(data, startByte);
    (order.getMakerAmount, startByte) = _readBytes(data, startByte);
    (order.getTakerAmount, startByte) = _readBytes(data, startByte);
    (order.predicate, startByte) = _readBytes(data, startByte);
    (order.interaction, startByte) = _readBytes(data, startByte);
    return (order, startByte);
  }

  function _readSignature(
    bytes memory data,
    uint256 startByte
  ) private pure returns (IKyberDSLO.Signature memory sig, uint256) {
    (sig.orderSignature, startByte) = _readBytes(data, startByte);
    (sig.opSignature, startByte) = _readBytes(data, startByte);
    return (sig, startByte);
  }

  function _readUint32Array(
    bytes memory data,
    uint256 startByte
  ) internal pure returns (uint32[] memory bytesArray, uint256) {
    bytes memory ret;
    (ret, startByte) = _calldataVal(data, startByte, 1);
    uint256 length = uint256(uint8(bytes1(ret)));
    bytesArray = new uint32[](length);
    for (uint256 i = 0; i < length; ++i) {
      (bytesArray[i], startByte) = _readUint32(data, startByte);
    }
    return (bytesArray, startByte);
  }

  function _readFillDSLOBatchOrdersParams(
    bytes memory data,
    uint256 startByte,
    bool isFirstDex
  ) private pure returns (IKyberDSLO.FillBatchOrdersParams memory params, uint256) {
    // Order array
    bytes memory ret;
    (ret, startByte) = _calldataVal(data, startByte, 1);
    uint256 l = uint256(uint8(bytes1(ret)));
    params.orders = new IKyberDSLO.Order[](l);
    for (uint256 i = 0; i < l; ++i) {
      (params.orders[i], startByte) = _readDSLimitOrder(data, startByte);
    }

    // Signature array
    (ret, startByte) = _calldataVal(data, startByte, 1);
    l = uint256(uint8(bytes1(ret)));
    params.signatures = new IKyberDSLO.Signature[](l);
    for (uint256 i = 0; i < l; ++i) {
      (params.signatures[i], startByte) = _readSignature(data, startByte);
    }

    (params.opExpireTimes, startByte) = _readUint32Array(data, startByte);

    if (isFirstDex) {
      (params.takingAmount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      params.takingAmount = collect ? type(uint256).max : 0;
    }
    (params.thresholdAmount, startByte) = _readUint128AsUint256(data, startByte);
    (params.target, startByte) = _readAddress(data, startByte);
    return (params, startByte);
  }
}
