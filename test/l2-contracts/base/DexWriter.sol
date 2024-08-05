pragma solidity 0.8.25;

import {IExecutorHelperL2} from 'src/interfaces/IExecutorHelperL2.sol';
import 'forge-std/Test.sol';

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

  function writeLevelFiV2(
    IExecutorHelperL2.LevelFiV2 memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    shortData = bytes.concat(shortData, bytes20(swap.toToken));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amountIn)));
    else shortData = bytes.concat(shortData, bytes1(swap.amountIn > 0 ? 1 : 0));

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }
  }

  function writeGMXGLP(
    IExecutorHelperL2.GMXGLP memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag,
    uint8 directionFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.rewardRouter));

    shortData = bytes.concat(shortData, bytes20(swap.yearnVault));

    shortData = bytes.concat(shortData, bytes1(directionFlag));

    if (directionFlag == 1) {
      shortData = bytes.concat(shortData, bytes20(swap.tokenOut));
    }

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.swapAmount)));
    else shortData = bytes.concat(shortData, bytes1(swap.swapAmount > 0 ? 1 : 0));

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }
  }

  function writeVooi(
    IExecutorHelperL2.Vooi memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    shortData = bytes.concat(shortData, bytes1(uint8(swap.toID)));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.fromAmount)));
    else shortData = bytes.concat(shortData, bytes1(swap.fromAmount > 0 ? 1 : 0));

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.to));
    }
  }

  function writeVelocoreV2(
    IExecutorHelperL2.VelocoreV2 memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.vault));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));
    shortData = bytes.concat(shortData, bytes20(swap.stablePool));
    shortData = bytes.concat(shortData, bytes20(swap.wrapToken));
    shortData = bytes.concat(shortData, bytes1(swap.isConvertFirst ? 1 : 0));
  }

  function writeKokonut(
    IExecutorHelperL2.Kokonut memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.dx)));
    else shortData = bytes.concat(shortData, bytes1(swap.dx > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes1(uint8(swap.tokenIndexFrom)));
  }

  function writeBalancerV1(
    IExecutorHelperL2.BalancerV1 memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));
  }

  function writeArbswapStable(
    IExecutorHelperL2.ArbswapStable memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.dx)));
    else shortData = bytes.concat(shortData, bytes1(swap.dx > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes1(uint8(swap.tokenIndexFrom)));
  }

  function writeBancorV2(
    IExecutorHelperL2.BancorV2 memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    shortData = bytes.concat(shortData, _writeAddressArray(swap.swapPath));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }
  }

  function writeAmbient(
    IExecutorHelperL2.Ambient memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.qty)));
    else shortData = bytes.concat(shortData, bytes1(swap.qty > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes20(swap.base));
    shortData = bytes.concat(shortData, bytes20(swap.quote));
    shortData = bytes.concat(shortData, bytes16(uint128(swap.poolIdx)));
    shortData = bytes.concat(shortData, bytes1(swap.settleFlags));
  }

  function writeLighterV2(
    IExecutorHelperL2.LighterV2 memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.orderBook));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));

    shortData = bytes.concat(shortData, bytes1(uint8(swap.isAsk ? 1 : 0)));

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }
  }

  function writeMaiPSM(
    IExecutorHelperL2.FrxETH memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes20(swap.tokenOut));
  }

  function writeMantleUsd(
    bool isWrap,
    uint256 amount
  ) external pure returns (bytes memory shortData) {
    uint256 isWrapAndAmount;
    isWrapAndAmount |= uint256(uint128(amount));
    isWrapAndAmount |= uint256(isWrap ? 1 : 0) << 255;
    shortData = bytes.concat(shortData, bytes32(abi.encode(isWrapAndAmount)));
  }

  function writeHashflow(
    IExecutorHelperL2.Hashflow memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex
  ) external pure returns (bytes memory shortData) {
    // shortData = bytes.concat(shortData, bytes20(swap.router));
    shortData = bytes.concat(shortData, bytes20(0x55084eE0fEf03f14a305cd24286359A35D735151));

    // shortData = bytes.concat(shortData, bytes20(swap.quote.pool));
    shortData = bytes.concat(shortData, bytes20(0x031903307c517c11B71f8313D19aFDe0a4F41CB5));

    // shortData = bytes.concat(shortData, bytes20(swap.quote.externalAccount));
    shortData = bytes.concat(shortData, bytes20(0xBB289bC97591F70D8216462DF40ED713011B968a));

    // shortData = bytes.concat(shortData, bytes20(swap.quote.trader));
    shortData = bytes.concat(shortData, bytes20(address(1)));

    // shortData = bytes.concat(shortData, bytes20(swap.quote.effectiveTrader));
    shortData = bytes.concat(shortData, bytes20(address(2)));

    // shortData = bytes.concat(shortData, bytes20(swap.quote.baseToken));
    // shortData = bytes.concat(shortData, bytes20(address(3)));

    // shortData = bytes.concat(shortData, bytes20(swap.quote.quoteToken));
    shortData = bytes.concat(shortData, bytes20(address(4)));

    shortData = bytes.concat(shortData, bytes16(uint128(swap.quote.effectiveBaseTokenAmount)));

    // shortData = bytes.concat(shortData, bytes16(uint128(swap.quote.baseTokenAmount)));
    shortData = bytes.concat(shortData, bytes16(uint128(5)));

    // shortData = bytes.concat(shortData, bytes16(uint128(swap.quote.quoteTokenAmount)));
    shortData = bytes.concat(shortData, bytes16(uint128(6)));

    // shortData = bytes.concat(shortData, bytes16(uint128(swap.quote.quoteExpiry)));
    shortData = bytes.concat(shortData, bytes16(uint128(1702530183)));

    // shortData = bytes.concat(shortData, bytes16(uint128(swap.quote.nonce)));
    shortData = bytes.concat(shortData, bytes16(uint128(1702530155606)));

    // shortData = bytes.concat(shortData, bytes32((swap.quote.txid)));

    bytes32 txId = 0x1120000ae000ae0000ccac3950a660ffffffffffffff001d084d9d0537630000;
    shortData = bytes.concat(shortData, txId);

    // shortData = bytes.concat(shortData, bytes(swap.quote.signature));
    bytes memory signatures =
      hex'944666bd43459bf84bb3766f1f2b35a7615bf1c630e4aee9fed96754d5efb24765daa0e009faa0b858147ba592c09617bbac8bd14f9f45993d45b184a7635eba1c';
    shortData = bytes.concat(shortData, bytes4(uint32(signatures.length)));
    shortData = bytes.concat(shortData, signatures);
  }

  function writeKyberRFQ(
    IExecutorHelperL2.KyberRFQ memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));

    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.rfq));

    shortData = bytes.concat(shortData, bytes32(swap.order.info));
    shortData = bytes.concat(shortData, bytes20(swap.order.makerAsset));
    shortData = bytes.concat(shortData, bytes20(swap.order.takerAsset));
    shortData = bytes.concat(shortData, bytes20(swap.order.maker));
    shortData = bytes.concat(shortData, bytes20(swap.order.allowedSender));
    shortData = bytes.concat(shortData, bytes16(uint128(swap.order.makingAmount)));
    shortData = bytes.concat(shortData, bytes16(uint128(swap.order.takingAmount)));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.signature.length)));
    shortData = bytes.concat(shortData, bytes(swap.signature));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    shortData = bytes.concat(shortData, bytes20(address(swap.target)));
  }

  function writeKyberDSLO(
    IExecutorHelperL2.KyberDSLO memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.kyberLOAddress));

    shortData = bytes.concat(shortData, bytes20(swap.makerAsset));
    // shortData = bytes.concat(shortData, bytes20(swap.takerAsset)); // not write taker asset because we using inter data

    shortData = bytes.concat(shortData, bytes1(uint8(1))); // order length
    shortData = bytes.concat(shortData, bytes16(uint128(swap.params.orders[0].salt)));
    shortData = bytes.concat(shortData, bytes20(swap.params.orders[0].makerAsset));
    shortData = bytes.concat(shortData, bytes20(swap.params.orders[0].takerAsset));

    shortData = bytes.concat(shortData, bytes20(swap.params.orders[0].maker));
    shortData = bytes.concat(shortData, bytes20(swap.params.orders[0].receiver));
    shortData = bytes.concat(shortData, bytes20(swap.params.orders[0].allowedSender));
    shortData = bytes.concat(shortData, bytes16(uint128(swap.params.orders[0].makingAmount)));
    shortData = bytes.concat(shortData, bytes16(uint128(swap.params.orders[0].takingAmount)));
    shortData = bytes.concat(shortData, bytes25(uint200(swap.params.orders[0].feeConfig)));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].makerAssetData.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].makerAssetData));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].takerAssetData.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].takerAssetData));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].getMakerAmount.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].getMakerAmount));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].getTakerAmount.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].getTakerAmount));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].predicate.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].predicate));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].interaction.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].interaction));

    shortData = bytes.concat(shortData, bytes1(uint8(1))); // signature length

    shortData =
      bytes.concat(shortData, bytes4(uint32(swap.params.signatures[0].orderSignature.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.signatures[0].orderSignature));

    shortData =
      bytes.concat(shortData, bytes4(uint32(swap.params.signatures[0].opSignature.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.signatures[0].opSignature));

    shortData = bytes.concat(shortData, bytes1(uint8(1))); // opExpireTimes length
    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.opExpireTimes[0])));

    // write takingAmount
    if (sequenceIndex == 0) {
      shortData = bytes.concat(shortData, bytes16(uint128(swap.params.takingAmount)));
    } else {
      shortData = bytes.concat(shortData, bytes1(swap.params.takingAmount > 0 ? 1 : 0));
    }

    // write thresholdAmount
    shortData = bytes.concat(shortData, bytes16(uint128(swap.params.thresholdAmount)));

    // write target
    shortData = bytes.concat(shortData, bytes20(swap.params.target));
  }

  function writeKyberLimitOrder(
    IExecutorHelperL2.KyberLimitOrder memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.kyberLOAddress));

    shortData = bytes.concat(shortData, bytes20(swap.makerAsset));
    // shortData = bytes.concat(shortData, bytes20(swap.takerAsset)); // not write taker asset because we using inter data

    shortData = bytes.concat(shortData, bytes1(uint8(1))); // order length
    shortData = bytes.concat(shortData, bytes16(uint128(swap.params.orders[0].salt)));
    shortData = bytes.concat(shortData, bytes20(swap.params.orders[0].makerAsset));
    shortData = bytes.concat(shortData, bytes20(swap.params.orders[0].takerAsset));
    shortData = bytes.concat(shortData, bytes20(swap.params.orders[0].maker));
    shortData = bytes.concat(shortData, bytes20(swap.params.orders[0].receiver));
    shortData = bytes.concat(shortData, bytes20(swap.params.orders[0].allowedSender));
    shortData = bytes.concat(shortData, bytes16(uint128(swap.params.orders[0].makingAmount)));
    shortData = bytes.concat(shortData, bytes16(uint128(swap.params.orders[0].takingAmount)));
    shortData = bytes.concat(shortData, bytes20(swap.params.orders[0].feeRecipient));
    shortData = bytes.concat(shortData, bytes4(swap.params.orders[0].makerTokenFeePercent));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].makerAssetData.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].makerAssetData));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].takerAssetData.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].takerAssetData));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].getMakerAmount.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].getMakerAmount));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].getTakerAmount.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].getTakerAmount));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].predicate.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].predicate));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].permit.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].permit));

    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.orders[0].interaction.length)));
    shortData = bytes.concat(shortData, bytes(swap.params.orders[0].interaction));

    shortData = bytes.concat(shortData, bytes1(uint8(1))); // signature length
    shortData = bytes.concat(shortData, bytes4(uint32(swap.params.signatures[0].length)));
    shortData = bytes.concat(shortData, bytes(swap.params.signatures[0]));

    if (sequenceIndex == 0) {
      shortData = bytes.concat(shortData, bytes16(uint128(swap.params.takingAmount)));
    } else {
      shortData = bytes.concat(shortData, bytes1(swap.params.takingAmount > 0 ? 1 : 0));
    }

    shortData = bytes.concat(shortData, bytes16(uint128(swap.params.thresholdAmount)));
    shortData = bytes.concat(shortData, bytes20(swap.params.target));
  }

  function writeNative(
    IExecutorHelperL2.Native memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) {
      shortData = bytes.concat(shortData, bytes20(0xEAd050515E10fDB3540ccD6f8236C46790508A76));
    }

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    bytes memory txData =
      hex'e525b10b000000000000000000000000000000000000000000000000000000000000002000000000000000000000000028cacd5e26a719f139e2105ca1efc3d9dc892826000000000000000000000000ff8ba4d1fc3762f6154cc942ccf30049a2a0cec60000000000000000000000000c7bbb021d72db4ffba37bdf4ef055eecdbc0a2900000000000000000000000000000000000000000000000000000000000000000000000000000000000000006b175474e89094c44da98b954eedeac495271d0f0000000000000000000000000000000000000000000000000de0b6b3a76400000000000000000000000000000000000000000000000000000de0b6b3a764000000000000000000000000000000000000000000000000009dd5a918da264750a00000000000000000000000000000000000000000000000000000000066446d6300000000000000000000000000000000000000000000000000031fba4adce8b5aa90a6f1d9aa48e9bc0e8f482b556346000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000026000000000000000000000000067297ee4eb097e072b4ab6f1620268061ae8046400000000000000000000000060cba82ddbf4b5ddcd4398cdd05354c6a790c309000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e0000000000000000000000000000000000000000000000000000000000000036000000000000000000000000000000000000000000000009c419a9b29e355f63800000000000000000000000000000000000000000000000000000000000000413b580ff580901e38e887ac461642a872c28c49639c9a167818a2197b340786ca4a3929d425aeffe47ba889e0611cf6560d88d1e5dc51ff9ef7509b2a89b045ba1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004120ac97d68f0dd0e1db8e77fe7ecc9dd5d3bdab27f4348eb783383a139335ffd67d7fed87cb5174cbcfab840c05aca6866319df8270376acb0367a0ecb03fabff1c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
    shortData = bytes.concat(shortData, bytes4(uint32(txData.length)));
    shortData = bytes.concat(shortData, txData);

    shortData = bytes.concat(shortData, bytes20(address(1)));

    shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    if (recipientFlag == 0) {
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }

    // shortData = bytes.concat(shortData, bytes32(swap.multihopAndOffset));
    shortData = bytes.concat(shortData, bytes32(uint256(3615561838447072116736)));
  }

  function writeBebop(
    IExecutorHelperL2.Bebop memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external view returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(address(1)));

    console.log('bebop sequenceIndex ', sequenceIndex);
    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    bytes memory txData =
      hex'4dcebcba000000000000000000000000000000000000000000000000000000006662a4e1000000000000000000000000185a4dc360ce69bdccee33b3784b0282f7961aea00000000000000000000000051c72848c68a965f66fa7a88855f9f7784502a7f0000000000000000000000000000000000000000000000000000031fd03a5b2b000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb480000000000000000000000000000000000000000000000000de0b6b3a764000000000000000000000000000000000000000000000000000000000000e34268a9000000000000000000000000c7c0ada69917a0f3652c45ba2d11206e42c4a4300000000000000000000000000000000000000000000000000000000000000000c44f2c06827682c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000041f4e2951c9f194deba1bc5ae9dad7455564b8b9f9c5d33cca30bfc9362b2d1f23449522fd9e06bc83bb472c326e657f1b15cab6beb89db3b201f0f26c35a3ed7d1c00000000000000000000000000000000000000000000000000000000000000';
    shortData = bytes.concat(shortData, bytes4(uint32(txData.length)));
    shortData = bytes.concat(shortData, txData);

    shortData = bytes.concat(shortData, bytes20(address(2)));

    shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    if (recipientFlag == 0) {
      shortData = bytes.concat(shortData, bytes20(address(3)));
    }
  }

  function writeSymbioticLRT(
    IExecutorHelperL2.SymbioticLRT memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) external pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.vault));

    if (sequenceIndex == 0) shortData = bytes.concat(shortData, bytes16(uint128(swap.amount)));
    else shortData = bytes.concat(shortData, bytes1(swap.amount > 0 ? 1 : 0));

    // shortData = bytes.concat(shortData, bytes20(swap.tokenIn));

    shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    if (recipientFlag == 0) {
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
    }

    shortData = bytes.concat(shortData, bytes1(swap.isVer0 ? 1 : 0));
  }

  function writeMaverickV2(
    IExecutorHelperL2.MaverickV2 memory swap,
    uint256 poolIndex,
    uint256 sequenceIndex,
    uint8 recipientFlag
  ) public pure returns (bytes memory shortData) {
    shortData = bytes.concat(shortData, bytes3(uint24(poolIndex)));
    if (poolIndex == 0) shortData = bytes.concat(shortData, bytes20(swap.pool));

    if (sequenceIndex == 0) {
      shortData = bytes.concat(shortData, bytes16(uint128(swap.collectAmount)));
    } else {
      shortData = bytes.concat(shortData, bytes1(swap.collectAmount > 0 ? 1 : 0));
    }

    if (recipientFlag == 1 || recipientFlag == 2) {
      shortData = bytes.concat(shortData, bytes1(uint8(recipientFlag)));
    } else {
      shortData = bytes.concat(shortData, bytes1(uint8(0)));
      shortData = bytes.concat(shortData, bytes20(swap.recipient));
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
