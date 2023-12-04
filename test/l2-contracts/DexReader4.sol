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

  function readLevelFiV2(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.LevelFiV2 memory swap;
    // decode
    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    swap.fromToken = tokenIn;
    (swap.toToken, startByte) = _readAddress(data, startByte);

    if (isFirstDex) {
      (swap.amountIn, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.amountIn = collect ? type(uint256).max : 0;
    }

    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.recipient = nextPool;
    else if (recipientFlag == 2) swap.recipient = address(this);
    else (swap.recipient, startByte) = _readAddress(data, startByte);

    return abi.encode(swap);
  }

  function readGMXGLP(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.GMXGLP memory swap;
    (swap.rewardRouter, startByte) = _readPool(data, startByte);

    (swap.stakedGLP, startByte) = _readAddress(data, startByte);

    uint8 directionFlag;
    (directionFlag, startByte) = _readUint8(data, startByte);
    if (directionFlag == 0) swap.tokenOut = swap.stakedGLP;
    else if (directionFlag == 1) (swap.tokenOut, startByte) = _readAddress(data, startByte);

    // ignore glpManager
    swap.tokenIn = tokenIn;

    if (isFirstDex) {
      (swap.swapAmount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.swapAmount = collect ? type(uint256).max : 0;
    }

    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.recipient = nextPool;
    else if (recipientFlag == 2) swap.recipient = address(this);
    else (swap.recipient, startByte) = _readAddress(data, startByte);
    return abi.encode(swap);
  }

  function readVooi(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.Vooi memory swap;
    // decode
    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    swap.fromToken = tokenIn;
    uint8 _toID;
    (_toID, startByte) = _readUint8(data, startByte);

    swap.toID = uint256(_toID);

    if (isFirstDex) {
      (swap.fromAmount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.fromAmount = collect ? type(uint256).max : 0;
    }

    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.to = nextPool;
    else if (recipientFlag == 2) swap.to = address(this);
    else (swap.to, startByte) = _readAddress(data, startByte);

    return abi.encode(swap);
  }

  function readVelocoreV2(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.VelocoreV2 memory swap;
    // decode
    (swap.vault, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    if (isFirstDex) {
      (swap.amount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.amount = collect ? type(uint256).max : 0;
    }

    swap.tokenIn = tokenIn;
    (swap.tokenOut, startByte) = _readAddress(data, startByte);
    (swap.stablePool, startByte) = _readAddress(data, startByte);
    (swap.wrapToken, startByte) = _readAddress(data, startByte);
    (swap.isConvertFirst, startByte) = _readBool(data, startByte);

    return abi.encode(swap);
  }

  function readKokonut(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.Kokonut memory swap;
    // decode
    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    swap.fromToken = tokenIn;

    if (isFirstDex) {
      (swap.dx, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.dx = collect ? type(uint256).max : 0;
    }
    return abi.encode(swap);
  }

  function readBalancerV1(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.BalancerV1 memory swap;
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

    swap.tokenIn = tokenIn;
    (swap.tokenOut, startByte) = _readAddress(data, startByte);

    return abi.encode(swap);
  }
}
