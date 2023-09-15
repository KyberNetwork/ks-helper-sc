// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import './Common.sol';
import 'src/interfaces/IExecutorHelperL2.sol';

/// @title DexReader1
/// @notice Contain functions to decode dex data
/// @dev For this repo's scope, we only care about swap amounts, so we just need to decode until we get swap amounts
contract DexReader1 is Common {
  function readUniSwap(
    bytes memory data,
    address, /* tokenIn */
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
}
