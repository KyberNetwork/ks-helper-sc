pragma solidity 0.8.9;

import {IExecutorHelperL2} from 'src/interfaces/IExecutorHelperL2.sol';

/// @title DexWriter
/// @notice Contain functions to compress DEX structs for L2
/// @dev For this repo's scope, we only care about format of the data, so we dont need to infer dex data like what we do onchain
contract DexWriter {
  function writeUniSwap(
    IExecutorHelperL2.UniSwap memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) public pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }

    if (sequenceIndex == 0) {
      shortData = bytes.concat(shortData, bytes16(uint128(swap.collectAmount)));
    } else {
      shortData = bytes.concat(shortData, bytes1(swap.collectAmount > 0 ? 1 : 0));
    }

    shortData = bytes.concat(shortData, bytes4(swap.swapFee));
    shortData = bytes.concat(shortData, bytes4(swap.feePrecision));
    shortData = bytes.concat(shortData, bytes4(swap.tokenWeightInput));
  }

  function writeStableSwap(
    IExecutorHelperL2.StableSwap memory swap,
    uint256 poolIndex
  ) public pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    shortData = bytes.concat(shortData, bytes1(swap.tokenIndexTo));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.dx)));
    else shortData = bytes.concat(shortData, bytes1(swap.dx > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes20(swap.poolLp));
    shortData = bytes.concat(shortData, bytes1(swap.isSaddle ? 1 : 0));
  }

  function writeCurveSwap(
    IExecutorHelperL2.CurveSwap memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    bool canGetIndex
  ) public pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes1(canGetIndex ? 1 : 0));

    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    if (!canGetIndex) shortData = bytes.concat(shortData, bytes20(swap.tokenTo));
    if (!canGetIndex) {
      shortData = bytes.concat(shortData, bytes1(uint8(uint128(swap.tokenIndexFrom))));
    }
    shortData = bytes.concat(shortData, bytes1(uint8(uint128(swap.tokenIndexTo))));
    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.dx)));
    else shortData = bytes.concat(shortData, bytes1(swap.dx > 0 ? 1 : 0));
    shortData = bytes.concat(shortData, bytes1(swap.usePoolUnderlying ? 1 : 0));
    shortData = bytes.concat(shortData, bytes1(swap.useTriCrypto ? 1 : 0));
  }

  function writeUniswapV3KSElastic(
    IExecutorHelperL2.UniswapV3KSElastic memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) public pure returns (bytes memory shortData) {
    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }
    //shortData = bytes.concat(shortData, bytes20(swap.pool));
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));
    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.swapAmount)));
    else shortData = bytes.concat(shortData, bytes1(swap.swapAmount > 0 ? 1 : 0));
    // shortData = bytes.concat(shortData, bytes20(swap.sqrtPriceLimitX96));
    shortData = bytes.concat(shortData, bytes1(swap.isUniV3 ? 1 : 0));
  }

  function writeBalancerV2(
    IExecutorHelperL2.BalancerV2 memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 assetOutIndex
  ) public pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.vault));

    shortData = bytes.concat(shortData, swap.poolId);

    shortData = bytes.concat(shortData, bytes1(assetOutIndex));
    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));
  }

  function writeDODO(
    IExecutorHelperL2.DODO memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) public pure returns (bytes memory shortData) {
    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes20(swap.sellHelper));
    shortData = bytes.concat(shortData, bytes1(swap.isSellBase ? 1 : 0));
    shortData = bytes.concat(shortData, bytes1(swap.isVersion2 ? 1 : 0));
  }

  function writeGMX(
    IExecutorHelperL2.GMX memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) public pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.vault));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));
    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.receiver));
    }
  }

  function writeSynthetix(
    IExecutorHelperL2.Synthetix memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex
  ) public pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.synthetixProxy));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));
    shortData = bytes.concat(shortData, swap.sourceCurrencyKey);
    if (sequenceIndex == 0) {
      shortData = bytes.concat(shortData, bytes16(uint128(swap.sourceAmount)));
    } else {
      shortData = bytes.concat(shortData, bytes1(swap.sourceAmount > 0 ? 1 : 0));
    }
    shortData = bytes.concat(shortData, swap.destinationCurrencyKey);
    shortData = bytes.concat(shortData, bytes1(swap.useAtomicExchange ? 1 : 0));
  }

  function writeWrappedstETH(
    IExecutorHelperL2.WSTETH memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes1(swap.isWrapping ? 1 : 0));
  }

  function writePlatypus(
    IExecutorHelperL2.Platypus memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }

    if (sequenceIndex == 0) {
      shortData = bytes.concat(shortData, bytes16(uint128(swap.collectAmount)));
    } else {
      shortData = bytes.concat(shortData, bytes1(swap.collectAmount > 0 ? 1 : 0));
    }
  }

  function writePSM(
    IExecutorHelperL2.PSM memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.router));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amountIn)));
    else shortData = bytes.concat(shortData, bytes1(swap.amountIn > 0 ? 1 : 0));

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }
  }

  function writeMaverick(
    IExecutorHelperL2.Maverick memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.swapAmount)));
    else shortData = bytes.concat(shortData, bytes1(swap.swapAmount > 0 ? 1 : 0));
  }

  function writeSyncSwap(
    IExecutorHelperL2.SyncSwap memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, _writeBytes(swap._data));

    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.vault));

    shortData = bytes.concat(shortData, bytes20(swap.pool));

    if (sequenceIndex == 0) {
      shortData = bytes.concat(shortData, bytes16(uint128(swap.collectAmount)));
    } else {
      shortData = bytes.concat(shortData, bytes1(swap.collectAmount > 0 ? 1 : 0));
    }
  }

  function writeAlgebraV1(
    IExecutorHelperL2.AlgebraV1 memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));
    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.swapAmount)));
    else shortData = bytes.concat(shortData, bytes1(swap.swapAmount > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes32(swap.senderFeeOnTransfer));
  }

  function writeBalancerBatch(
    IExecutorHelperL2.BalancerBatch memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.vault));

    shortData = bytes.concat(shortData, _writeBytes32Array(swap.poolIds));
    shortData = bytes.concat(shortData, _writeAddressArray(swap.path));
    shortData = bytes.concat(shortData, _writeBytesArray(swap.userDatas));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amountIn)));
    else shortData = bytes.concat(shortData, bytes1(swap.amountIn > 0 ? 1 : 0));
  }

  function writeMantis(
    IExecutorHelperL2.Mantis memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }
  }

  function writeIziSwap(
    IExecutorHelperL2.IziSwap memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.swapAmount)));
    else shortData = bytes.concat(shortData, bytes1(swap.swapAmount > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes3(uint24(swap.limitPoint)));
  }

  function writeTraderJoeV2(
    IExecutorHelperL2.TraderJoeV2 memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }

    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));

    bool isV2 = swap.collectAmount >> 255 & 1 == 1;
    shortData = bytes.concat(shortData, bytes1(uint8(isV2 ? 1 : 0)));

    if (sequenceIndex == 0) {
      shortData = bytes.concat(shortData, bytes16(uint128(swap.collectAmount)));
    } else {
      shortData = bytes.concat(shortData, bytes1(swap.collectAmount > 0 ? 1 : 0));
    }
  }

  /*
   ************************ Utility ************************
   */

  function _writeAddressArray(address[] memory addrs) internal pure returns (bytes memory data) {
    uint8 length = uint8(addrs.length);
    data = bytes.concat(data, bytes1(length));
    for (uint8 i = 0; i < length; ++i) {
      data = bytes.concat(data, bytes20(addrs[i]));
    }
    return data;
  }

  function _writeUint256ArrayAsUint128Array(uint256[] memory us)
    internal
    pure
    returns (bytes memory data)
  {
    uint8 length = uint8(us.length);
    data = bytes.concat(data, bytes1(length));
    for (uint8 i = 0; i < length; ++i) {
      data = bytes.concat(data, bytes16(uint128(us[i])));
    }
    return data;
  }

  function _writeBytes32Array(bytes32[] memory arr) internal pure returns (bytes memory data) {
    uint8 length = uint8(arr.length);
    data = bytes.concat(data, bytes1(length));
    for (uint8 i = 0; i < length; ++i) {
      data = bytes.concat(data, arr[i]);
    }
    return data;
  }

  function _writeBytes(bytes memory b) internal pure returns (bytes memory data) {
    uint32 length = uint32(b.length);
    data = bytes.concat(data, bytes4(length));
    data = bytes.concat(data, b);
    return data;
  }

  function _writeBytesArray(bytes[] memory bytesArray) internal pure returns (bytes memory data) {
    uint8 x = uint8(bytesArray.length);
    data = bytes.concat(data, bytes1(x));
    for (uint8 i; i < x; ++i) {
      uint32 length = uint32(bytesArray[i].length);
      data = bytes.concat(data, bytes4(length));
      data = bytes.concat(data, bytesArray[i]);
    }
    return data;
  }
}
