// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import './Common.sol';
import 'src/interfaces/IExecutorHelperL2.sol';

/// @title DexReader2
/// @notice Contain functions to decode dex data
/// @dev For this repo's scope, we only care about swap amounts, so we just need to decode until we get swap amounts
contract DexReader2 is Common {
  function readStableSwap(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte = 0;
    IExecutorHelperL2.StableSwap memory swap;
    // decode
    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    (swap.tokenIndexTo, startByte) = _readUint8(data, startByte);
    if (isFirstDex) {
      (swap.dx, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.dx = collect ? type(uint256).max : 0;
    }
    return abi.encode(swap);
  }

  function readCurveSwap(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte = 0;
    bool canGetIndex;
    (canGetIndex, startByte) = _readBool(data, 0);
    IExecutorHelperL2.CurveSwap memory swap;
    // decode
    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    // read extra members due to inability to query on-chain
    if (!canGetIndex) {
      (swap.tokenTo, startByte) = _readAddress(data, startByte);
      uint8 t;
      (t, startByte) = _readUint8(data, startByte);
      swap.tokenIndexFrom = int128(int8(t));
    }
    uint8 x;
    (x, startByte) = _readUint8(data, startByte);
    swap.tokenIndexTo = int128(int8(x));
    if (isFirstDex) {
      (swap.dx, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.dx = collect ? type(uint256).max : 0;
    }
    return abi.encode(swap);
  }

  function readUniswapV3KSElastic(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public returns (bytes memory) {
    uint256 startByte = 0;
    IExecutorHelperL2.UniswapV3KSElastic memory swap;
    // decode
    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.recipient = nextPool;
    else if (recipientFlag == 2) swap.recipient = address(this);
    else (swap.recipient, startByte) = _readAddress(data, startByte);

    (swap.pool, startByte) = _readPool(data, startByte);

    if (getPoolOnly) return abi.encode(swap);

    if (isFirstDex) {
      (swap.swapAmount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.swapAmount = collect ? type(uint256).max : 0;
    }
    (swap.isUniV3, startByte) = _readBool(data, startByte);

    return abi.encode(swap);
  }

  function readBalancerV2(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte = 0;
    IExecutorHelperL2.BalancerV2 memory swap;
    // decode
    (swap.vault, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    (swap.poolId, startByte) = _readBytes32(data, startByte);
    uint8 indexOut;
    (indexOut, startByte) = _readUint8(data, startByte);
    if (isFirstDex) {
      (swap.amount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.amount = collect ? type(uint256).max : 0;
    }

    return abi.encode(swap);
  }

  function readDODO(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte = 0;
    IExecutorHelperL2.DODO memory swap;
    // decode
    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.recipient = nextPool;
    else if (recipientFlag == 2) swap.recipient = address(this);
    else (swap.recipient, startByte) = _readAddress(data, startByte);

    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    if (isFirstDex) {
      (swap.amount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.amount = collect ? type(uint256).max : 0;
    }

    return abi.encode(swap);
  }

  function readGMX(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte = 0;
    IExecutorHelperL2.GMX memory swap;
    // decode
    (swap.vault, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    (swap.tokenOut, startByte) = _readAddress(data, startByte);
    if (isFirstDex) {
      (swap.amount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.amount = collect ? type(uint256).max : 0;
    }

    return abi.encode(swap);
  }

  function readSynthetix(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte = 0;
    IExecutorHelperL2.Synthetix memory swap;
    // decode
    (swap.synthetixProxy, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    (swap.tokenOut, startByte) = _readAddress(data, startByte);
    (swap.sourceCurrencyKey, startByte) = _readBytes32(data, startByte);
    if (isFirstDex) {
      (swap.sourceAmount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.sourceAmount = collect ? type(uint256).max : 0;
    }

    return abi.encode(swap);
  }
}
