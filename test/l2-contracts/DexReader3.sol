// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import './Common.sol';
import 'src/interfaces/IExecutorHelperL2.sol';

/// @title DexReader3
/// @notice Contain functions to decode dex data
/// @dev For this repo's scope, we only care about swap amounts, so we just need to decode until we get swap amounts
contract DexReader3 is Common {
  function readWrappedstETH(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.WSTETH memory swap;
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
    return abi.encode(swap);
  }

  function readPlatypus(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.Platypus memory swap;
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
      (swap.collectAmount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.collectAmount = collect ? type(uint256).max : 0;
    }

    return abi.encode(swap);
  }

  function readPSM(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.PSM memory swap;
    // decode
    (swap.router, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    swap.tokenIn = tokenIn;
    (swap.tokenOut, startByte) = _readAddress(data, startByte);

    if (isFirstDex) {
      (swap.amountIn, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.amountIn = collect ? type(uint256).max : 0;
    }

    return abi.encode(swap);
  }

  function readMaverick(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.Maverick memory swap;
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

    return abi.encode(swap);
  }

  function readSyncSwap(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.SyncSwap memory swap;
    // decode
    (swap._data, startByte) = _readBytes(data, startByte);
    (swap.vault, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    (swap.pool, startByte) = _readAddress(data, startByte);
    if (isFirstDex) {
      (swap.collectAmount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.collectAmount = collect ? type(uint256).max : 0;
    }
    swap.tokenIn = tokenIn;

    return abi.encode(swap);
  }

  function readAlgebraV1(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.AlgebraV1 memory swap;
    // decode
    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.recipient = nextPool;
    else if (recipientFlag == 2) swap.recipient = address(this);
    else (swap.recipient, startByte) = _readAddress(data, startByte);

    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    swap.tokenIn = tokenIn;
    (swap.tokenOut, startByte) = _readAddress(data, startByte);
    if (isFirstDex) {
      (swap.swapAmount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.swapAmount = collect ? type(uint256).max : 0;
    }

    return abi.encode(swap);
  }

  function readBalancerBatch(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.BalancerBatch memory swap;
    // decode
    (swap.vault, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    (swap.poolIds, startByte) = _readBytes32Array(data, startByte);
    (swap.path, startByte) = _readAddressArray(data, startByte);
    (swap.userDatas, startByte) = _readBytesArray(data, startByte);

    if (isFirstDex) {
      (swap.amountIn, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.amountIn = collect ? type(uint256).max : 0;
    }

    return abi.encode(swap);
  }

  function readMantis(
    bytes memory data,
    address tokenIn,
    bool isFirstDex,
    address nextPool,
    bool getPoolOnly
  ) public view returns (bytes memory) {
    uint256 startByte;
    IExecutorHelperL2.Mantis memory swap;
    // decode
    (swap.pool, startByte) = _readPool(data, startByte);
    if (getPoolOnly) return abi.encode(swap);

    swap.tokenIn = tokenIn;
    (swap.tokenOut, startByte) = _readAddress(data, startByte);

    if (isFirstDex) {
      (swap.amount, startByte) = _readUint128AsUint256(data, startByte);
    } else {
      bool collect;
      (collect, startByte) = _readBool(data, startByte);
      swap.amount = collect ? type(uint256).max : 0;
    }

    uint8 recipientFlag;
    (recipientFlag, startByte) = _readUint8(data, startByte);
    if (recipientFlag == 1) swap.recipient = nextPool;
    else if (recipientFlag == 2) swap.recipient = address(this);
    else (swap.recipient, startByte) = _readAddress(data, startByte);

    return abi.encode(swap);
  }

  function _readBytes32Array(
    bytes memory data,
    uint256 startByte
  ) internal pure returns (bytes32[] memory bytesArray, uint256) {
    bytes memory ret;
    (ret, startByte) = _calldataVal(data, startByte, 1);
    uint256 length = uint256(uint8(bytes1(ret)));
    bytesArray = new bytes32[](length);
    for (uint8 i = 0; i < length; ++i) {
      (bytesArray[i], startByte) = _readBytes32(data, startByte);
    }
    return (bytesArray, startByte);
  }
}
