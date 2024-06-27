// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import './Common.sol';
import 'src/interfaces/IExecutorHelperL2.sol';

/// @title DexReader1
/// @notice Contain functions to decode dex data
/// @dev For this repo's scope, we only care about swap amounts, so we just need to decode until we get swap amounts
contract DexReader1 is Common {
  function readUniSwap(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte = 0;
    IExecutorHelperL2.UniSwap memory swap;
    // decode
    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.recipient = nextPool;
    else if (recipientFlag == 2) swap.recipient = address(this);
    else (swap.recipient, startByte) = _readAddress(data, startByte);

    if (isFirstDex) {
      (swap.collectAmount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.collectAmount = collect ? type(uint256).max : 0;
    }
    return abi.encode(swap);
  }

  function readKyberLimitOrder(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte = 0;
    IExecutorHelperL2.KyberLimitOrder memory swap;
    // decode
    (swap.kyberLOAddress, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    (swap.makerAsset, startByte) = _readAddress(data, startByte);
    (swap.params, startByte) = _readFillBatchOrdersParams(data, startByte, isFirstDex);
    // infer
    swap.takerAsset = tokenIn;
    return abi.encode(swap);
  }

  function _readOrderRFQ(
    bytes memory data,
    uint256 startByte
  ) private pure returns (IExecutorHelperL2.OrderRFQ memory order, uint256) {
    bytes32 infoBytes;
    (infoBytes, startByte) = _readBytes32(data, startByte);
    order.info = uint256(infoBytes);
    (order.makerAsset, startByte) = _readAddress(data, startByte);
    (order.takerAsset, startByte) = _readAddress(data, startByte);
    (order.maker, startByte) = _readAddress(data, startByte);
    (order.allowedSender, startByte) = _readAddress(data, startByte);
    (order.makingAmount, startByte) = _readUint128AsUint256(data, startByte);
    (order.takingAmount, startByte) = _readUint128AsUint256(data, startByte);
    return (order, startByte);
  }

  function readKyberRFQ(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte = 0;
    IExecutorHelperL2.KyberRFQ memory swap;
    (swap.rfq, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    (swap.order, startByte) = _readOrderRFQ(data, startByte);
    (swap.signature, startByte) = _readBytes(data, startByte);

    if (isFirstDex) {
      (swap.amount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.amount = collect ? type(uint256).max : 0;
    }

    address addr;
    (addr, startByte) = _readAddress(data, startByte);
    swap.target = payable(addr);
    return abi.encode(swap);
  }

  function _readLimitOrder(
    bytes memory data,
    uint256 startByte
  ) private pure returns (IKyberLO.Order memory order, uint256) {
    (order.salt, startByte) = _readUint128AsUint256(data, startByte);
    (order.makerAsset, startByte) = _readAddress(data, startByte);
    (order.takerAsset, startByte) = _readAddress(data, startByte);
    (order.maker, startByte) = _readAddress(data, startByte);
    (order.receiver, startByte) = _readAddress(data, startByte);
    (order.allowedSender, startByte) = _readAddress(data, startByte);
    (order.makingAmount, startByte) = _readUint128AsUint256(data, startByte);
    (order.takingAmount, startByte) = _readUint128AsUint256(data, startByte);
    (order.feeRecipient, startByte) = _readAddress(data, startByte);
    (order.makerTokenFeePercent, startByte) = _readUint32(data, startByte);
    (order.makerAssetData, startByte) = _readBytes(data, startByte);
    (order.takerAssetData, startByte) = _readBytes(data, startByte);
    (order.getMakerAmount, startByte) = _readBytes(data, startByte);
    (order.getTakerAmount, startByte) = _readBytes(data, startByte);
    (order.predicate, startByte) = _readBytes(data, startByte);
    (order.permit, startByte) = _readBytes(data, startByte);
    (order.interaction, startByte) = _readBytes(data, startByte);
    return (order, startByte);
  }

  function _readFillBatchOrdersParams(
    bytes memory data,
    uint256 startByte,
    bool isFirstDex
  ) private pure returns (IKyberLO.FillBatchOrdersParams memory params, uint256) {
    // Order array
    bytes memory ret;
    (ret, startByte) = _calldataVal(data, startByte, 1);
    uint256 l = uint256(uint8(bytes1(ret)));
    params.orders = new IKyberLO.Order[](l);
    for (uint256 i = 0; i < l; ++i) {
      (params.orders[i], startByte) = _readLimitOrder(data, startByte);
    }

    // Signature array
    (ret, startByte) = _calldataVal(data, startByte, 1);
    l = uint256(uint8(bytes1(ret)));
    params.signatures = new bytes[](l);
    for (uint256 i = 0; i < l; ++i) {
      (params.signatures[i], startByte) = _readBytes(data, startByte);
    }

    // Other members
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
