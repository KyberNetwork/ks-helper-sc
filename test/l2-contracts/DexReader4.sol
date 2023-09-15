// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import './Common.sol';
import 'src/interfaces/IExecutorHelperL2.sol';

/// @title DexReader4
/// @notice Contain functions to decode dex data
/// @dev For this repo's scope, we only care about swap amounts, so we just need to decode until we get swap amounts
contract DexReader4 is Common {
  function readIziSwap(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.IziSwap memory swap;
    // decode
    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    swap.tokenIn = tokenIn;
    (swap.tokenOut, startByte) = _readAddress(data, startByte);

    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.recipient = nextPool;
    else if (recipientFlag == 2) swap.recipient = address(this);
    else (swap.recipient, startByte) = _readAddress(data, startByte);

    if (isFirstDex) {
      (swap.swapAmount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.swapAmount = collect ? type(uint256).max : 0;
    }
    uint24 limitPointAsUint24;
    (limitPointAsUint24, startByte) = _readUint24(data, startByte);
    int24 limitPoint;
    assembly {
      limitPoint := limitPointAsUint24
    }
    swap.limitPoint = limitPoint;

    return abi.encode(swap);
  }

  function readTraderJoeV2(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.TraderJoeV2 memory swap;

    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.recipient = nextPool;
    else if (recipientFlag == 2) swap.recipient = address(this);
    else (swap.recipient, startByte) = _readAddress(data, startByte);
    // decode
    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    swap.tokenIn = tokenIn;
    (swap.tokenOut, startByte) = _readAddress(data, startByte);

    bool isV2;
    (isV2, startByte) = _readBool(data, startByte);

    if (isFirstDex) {
      (swap.collectAmount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.collectAmount = collect ? type(uint256).max : 0;
    }

    swap.collectAmount |= (isV2 ? 1 : 0) << 255; // @dev set most significant bit
    return abi.encode(swap);
  }
}
