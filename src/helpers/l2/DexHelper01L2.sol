// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IExecutorHelper} from 'src/interfaces/IExecutorHelper.sol';
import {BytesHelper} from 'src/l2-contracts/BytesHelper.sol';
import {CalldataReader} from 'src/l2-contracts/CalldataReader.sol';
import {Common} from 'src/l2-contracts/Common.sol';
import {IKyberDSLO} from 'src/interfaces/pools/IKyberDSLO.sol';
import {IKyberLO} from 'src/interfaces/pools/IKyberLO.sol';
import {IExecutorHelperL2} from 'src/interfaces/IExecutorHelperL2.sol';
import {IBebopV3} from 'src/interfaces/pools/IBebopV3.sol';

contract DexHelper01L2 {
  // Not support SwaapV2
  using BytesHelper for bytes;
  using CalldataReader for bytes;
  using Common for bytes;

  function executeUniswap(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    // decode
    (, startByte) = _data._readPool(startByte);
    (, startByte) = _data._readRecipient(startByte);
    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleUniSwap'
    );
  }

  function executeKSClassic(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    // decode
    (, startByte) = _data._readPool(startByte);
    (, startByte) = _data._readRecipient(startByte);
    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleKSClassic'
    );
  }

  function executeVelodrome(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    // decode
    (, startByte) = _data._readPool(startByte);
    (, startByte) = _data._readRecipient(startByte);
    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleVelodrome'
    );
  }

  function executeCamelot(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    // decode
    (, startByte) = _data._readPool(startByte);
    (, startByte) = _data._readRecipient(startByte);
    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleCamelot'
    );
  }

  function executeFrax(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    // decode
    (, startByte) = _data._readPool(startByte);
    (, startByte) = _data._readRecipient(startByte);
    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleFrax'
    );
  }

  function executeStableSwap(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    (, startByte) = _data._readPool(startByte);
    (, startByte) = _data._readUint8(startByte);
    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleStableSwap'
    );
  }

  function executeCurve(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    bool canGetIndex;
    (canGetIndex, startByte) = _data._readBool(0);
    (, startByte) = _data._readPool(startByte);
    if (!canGetIndex) {
      (, startByte) = _data._readAddress(startByte);
      (, startByte) = _data._readUint8(startByte);
    }
    (, startByte) = _data._readUint8(startByte);
    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleCurveSwap'
    );
  }

  function executePancakeStableSwap(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    bool canGetIndex;
    (canGetIndex, startByte) = _data._readBool(0);
    (, startByte) = _data._readPool(startByte);
    if (!canGetIndex) {
      (, startByte) = _data._readAddress(startByte);
      (, startByte) = _data._readUint8(startByte);
    }
    (, startByte) = _data._readUint8(startByte);
    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scalePancakeStableSwap'
    );
  }

  function executeUniV3KSElastic(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    (, startByte) = _data._readRecipient(startByte);
    (, startByte) = _data._readPool(startByte);
    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte,
      oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount,
      'scaleUniswapV3KSElastic'
    );
  }

  function executeBalV2(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    (, startByte) = _data._readPool(startByte);
    (, startByte) = _data._readBytes32(startByte);
    (, startByte) = _data._readUint8(startByte);
    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleBalancerV2'
    );
  }

  function executeDODO(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    (, startByte) = _data._readRecipient(startByte);
    (, startByte) = _data._readPool(startByte);
    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleDODO'
    );
  }

  function executeGMX(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    // decode
    (, startByte) = _data._readPool(startByte);

    (, startByte) = _data._readAddress(startByte);

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleGMX'
    );
  }

  function executeSynthetix(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    // decode
    (, startByte) = _data._readPool(startByte);

    (, startByte) = _data._readAddress(startByte);
    (, startByte) = _data._readBytes32(startByte);

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleSynthetix'
    );
  }

  function executePlatypus(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    // decode
    (, startByte) = _data._readPool(startByte);

    (, startByte) = _data._readAddress(startByte);

    (, startByte) = _data._readRecipient(startByte);

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scalePlatypus'
    );
  }

  function executeWrappedstETH(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    // decode
    (, startByte) = _data._readPool(startByte);

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleWrappedstETH'
    );
  }

  function executePSM(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    // decode
    (, startByte) = _data._readPool(startByte);

    (, startByte) = _data._readAddress(startByte);

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);

    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scalePSM'
    );
  }

  function executeStEth(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    (uint256 swapAmount,) = _data._readUint128AsUint256(0);
    return
      _data.write16Bytes(0, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleStETH');
  }

  function executeMaverick(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    // decode
    (, startByte) = _data._readPool(startByte);

    (, startByte) = _data._readAddress(startByte);

    (, startByte) = _data._readRecipient(startByte);

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleMaverick'
    );
  }

  function executeSyncSwap(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    // decode
    (, startByte) = _data._readBytes(startByte);
    (, startByte) = _data._readPool(startByte);

    (, startByte) = _data._readAddress(startByte);

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleSyncSwap'
    );
  }

  function executeAlgebraV1(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readRecipient(startByte);

    (, startByte) = _data._readPool(startByte);

    (, startByte) = _data._readAddress(startByte);

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);

    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleAlgebraV1'
    );
  }

  function executeBalancerBatch(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    // decode
    (, startByte) = _data._readPool(startByte);

    (, startByte) = _data._readBytes32Array(startByte);
    (, startByte) = _data._readAddressArray(startByte);
    (, startByte) = _data._readBytesArray(startByte);

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleBalancerBatch'
    );
  }

  function executeMantis(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readAddress(startByte); // tokenOut

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleMantis'
    );
  }

  function executeBancorV3(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readAddress(startByte); // tokenOut

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleBancorV3'
    );
  }

  function executeNomiswapStable(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readAddress(startByte); // tokenOut

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleNomiswapStable'
    );
  }

  function executeSmardex(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readAddress(startByte); // tokenOut

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleSmardex'
    );
  }

  function executeWombat(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readAddress(startByte); // tokenOut

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleWombat'
    );
  }

  function executeWooFiV2(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readAddress(startByte); // tokenOut

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleWooFiV2'
    );
  }

  function executeSolidlyV2(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readAddress(startByte); // tokenOut

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleSolidlyV2'
    );
  }

  function executeIziSwap(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readAddress(startByte); // tokenOut

    // recipient
    (, startByte) = _data._readRecipient(startByte);

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleIziSwap'
    );
  }

  function executeTraderJoeV2(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    // recipient
    (, startByte) = _data._readRecipient(startByte);

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readAddress(startByte); // tokenOut

    (, startByte) = _data._readBool(startByte); // isV2

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleTraderJoeV2'
    );
  }

  function executeLevelFiV2(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readAddress(startByte); // tokenOut

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleLevelFiV2'
    );
  }

  function executeGMXGLP(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readAddress(startByte); // yearnVault

    uint8 directionFlag;
    (directionFlag, startByte) = _data._readUint8(startByte);
    if (directionFlag == 1) (, startByte) = _data._readAddress(startByte); // tokenOut

    (uint256 swapAmount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (swapAmount * newAmount) / oldAmount, 'scaleGMXGLP'
    );
  }

  function executeVooi(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readUint8(startByte); // toId

    (uint256 fromAmount,) = _data._readUint128AsUint256(startByte); // amount

    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (fromAmount * newAmount) / oldAmount, 'scaleVooi'
    );
  }

  function executeVelocoreV2(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (uint256 amount,) = _data._readUint128AsUint256(startByte); // amount

    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleVelocoreV2'
    );
  }

  function executeKokonut(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (uint256 amount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleKokonut'
    );
  }

  function executeBalancerV1(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (uint256 amount,) = _data._readUint128AsUint256(startByte); // amount

    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleBalancerV1'
    );
  }

  function executeArbswapStable(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (uint256 dx,) = _data._readUint128AsUint256(startByte); // dx

    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (dx * newAmount) / oldAmount, 'scaleArbswapStable'
    );
  }

  function executeBancorV2(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (, startByte) = _data._readAddressArray(startByte); // swapPath

    (uint256 amount,) = _data._readUint128AsUint256(startByte); // amount

    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleBancorV2'
    );
  }

  function executeAmbient(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (uint128 qty,) = _data._readUint128(startByte); // amount

    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (qty * newAmount) / oldAmount, 'scaleAmbient'
    );
  }

  function executeLighterV2(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // orderbook

    (uint256 amount,) = _data._readUint128AsUint256(startByte); // amount

    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleLighterV2'
    );
  }

  function executeKelp(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // pool

    (uint256 amount,) = _data._readUint128AsUint256(startByte); // amount

    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleKelp'
    );
  }

  function executeMaiPSM(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    (, startByte) = _data._readPool(startByte); // pool

    (uint256 amount,) = _data._readUint128AsUint256(startByte); // amount

    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleMaiPSM'
    );
  }

  function executeNative(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    require(newAmount < oldAmount, 'Native: not support scale up');

    uint256 startByte;
    bytes memory strData;
    uint256 amountStartByte;
    uint256 amount;
    uint256 multihopAndOffset;
    uint256 strDataStartByte;

    (, startByte) = _data._readPool(startByte); // target

    amountStartByte = startByte;
    (amount, startByte) = _data._readUint128AsUint256(startByte); // amount

    strDataStartByte = startByte;
    (strData, startByte) = _data._readBytes(startByte); // data

    (, startByte) = _data._readAddress(startByte); // tokenOut

    uint8 receipientFlag;
    (receipientFlag, startByte) = _data._readUint8(startByte); // receipientFlag
    if (receipientFlag == 0) (, startByte) = _data._readAddress(startByte); // recipient

    (multihopAndOffset, startByte) = _data._readUint256(startByte); // multihopAndOffset

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

    _data.write16Bytes(amountStartByte, amount, 'scaleNativeAmount');

    return _data.writeBytes(strDataStartByte + 4, strData); // 4 is strData length
  }

  function executeKyberDSLO(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // kyberLOAddress

    (, startByte) = _data._readAddress(startByte); // makerAsset

    (
      IKyberDSLO.FillBatchOrdersParams memory params,
      ,
      uint256 takingAmountStartByte,
      uint256 thresholdStartByte
    ) = _data._readDSLOFillBatchOrdersParams(startByte); // FillBatchOrdersParams

    _data = _data.write16Bytes(
      takingAmountStartByte,
      oldAmount == 0 ? 0 : (params.takingAmount * newAmount) / oldAmount,
      'scaleDSLO'
    );

    return _data.write16Bytes(thresholdStartByte, 1, 'scaleThreshold');
  }

  function executeKyberLimitOrder(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // kyberLOAddress

    (, startByte) = _data._readAddress(startByte); // makerAsset

    (
      IKyberLO.FillBatchOrdersParams memory params,
      ,
      uint256 takingAmountStartByte,
      uint256 thresholdStartByte
    ) = _data._readLOFillBatchOrdersParams(startByte); // FillBatchOrdersParams

    _data = _data.write16Bytes(
      takingAmountStartByte,
      oldAmount == 0 ? 0 : (params.takingAmount * newAmount) / oldAmount,
      'scaleLO'
    );
    return _data.write16Bytes(thresholdStartByte, 1, 'scaleThreshold');
  }

  function executeHashflow(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readAddress(startByte); // router

    (IExecutorHelperL2.RFQTQuote memory rfqQuote,, uint256 ebtaStartByte) =
      _data._readRFQTQuote(startByte); // RFQTQuote

    return _data.write16Bytes(
      ebtaStartByte,
      oldAmount == 0 ? 0 : (rfqQuote.effectiveBaseTokenAmount * newAmount) / oldAmount,
      'scaleHashflow'
    );
  }

  function executeRfq(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    (, startByte) = _data._readPool(startByte); // rfq
    (, startByte) = _data._readOrderRFQ(startByte); // order
    (, startByte) = _data._readBytes(startByte); // signature
    (uint256 amount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleKyberRFQ'
    );
  }

  function executeBebop(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    require(newAmount < oldAmount, 'Bebop: not support scale up');

    uint256 startByte;
    uint256 amount;
    uint256 amountStartByte;
    uint256 txDataStartByte;
    bytes memory txData;

    (, startByte) = _data._readPool(startByte); // pool

    amountStartByte = startByte;
    (amount, startByte) = _data._readUint128AsUint256(startByte); // amount

    txDataStartByte = startByte;
    (txData, startByte) = _data._readBytes(startByte); // data

    amount = (amount * newAmount) / oldAmount;

    {
      // update calldata with new swap amount
      (bytes4 selector, bytes memory callData) = txData.splitCalldata();

      (IBebopV3.Single memory s, IBebopV3.MakerSignature memory m,) =
        abi.decode(callData, (IBebopV3.Single, IBebopV3.MakerSignature, uint256));

      txData = bytes.concat(bytes4(selector), abi.encode(s, m, amount));
    }

    _data.write16Bytes(amountStartByte, amount, 'scaleBebopAmount');

    return _data.writeBytes(txDataStartByte + 4, txData);
  }

  function executeMantleUsd(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    (uint256 isWrapAndAmount,) = _data._readUint256(0);

    bool _isWrap = isWrapAndAmount >> 255 == 1;
    uint256 _amount = uint256(uint128(isWrapAndAmount));

    //scale amount
    _amount = oldAmount == 0 ? 0 : (_amount * newAmount) / oldAmount;

    // reset and create new variable for isWrap and amount
    isWrapAndAmount = 0;
    isWrapAndAmount |= uint256(uint128(_amount));
    isWrapAndAmount |= uint256(_isWrap ? 1 : 0) << 255;
    return abi.encode(isWrapAndAmount);
  }

  function executeSymbioticLRT(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;

    (, startByte) = _data._readPool(startByte); // vault

    (uint256 amount,) = _data._readUint128AsUint256(startByte); // amount
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (amount * newAmount) / oldAmount, 'scaleSymbioticLRT'
    );
  }

  function executeMaverickV2(
    uint256,
    bytes memory scalingData,
    uint256,
    address,
    bool,
    address
  ) external pure returns (bytes memory) {
    (bytes memory _data, uint256 oldAmount, uint256 newAmount) =
      abi.decode(scalingData, (bytes, uint256, uint256));

    uint256 startByte;
    // decode
    (, startByte) = _data._readPool(startByte);
    (uint256 collectAmount,) = _data._readUint128AsUint256(startByte);
    return _data.write16Bytes(
      startByte, oldAmount == 0 ? 0 : (collectAmount * newAmount) / oldAmount, 'scaleMaverickV2'
    );
  }
}
