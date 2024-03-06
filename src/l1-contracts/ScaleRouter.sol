// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {IScaleRouter} from '../interfaces/IScaleRouter.sol';
import {IMetaAggregationRouterV2 as IMAR} from '../interfaces/IMetaAggregationRouterV2.sol';
import {KyberSwapRole} from 'ks-growth-utils-sc/contracts/KyberSwapRole.sol';

contract ScaleRouter is IScaleRouter, KyberSwapRole {

  uint256 private constant _PARTIAL_FILL = 0x01;
  uint256 private constant _REQUIRES_EXTRA_ETH = 0x02;
  uint256 private constant _SHOULD_CLAIM = 0x04;
  uint256 private constant _BURN_FROM_MSG_SENDER = 0x08;
  uint256 private constant _BURN_FROM_TX_ORIGIN = 0x10;
  uint256 private constant _SIMPLE_SWAP = 0x20;

  // scale contract of dex
  mapping(bytes4 => address) public scalerOf;

  function updateBatchScalers(bytes4[] memory funcSelectors, address[] memory scalers) external override onlyOperator {
    if(funcSelectors.length != scalers.length) revert InvalidLength();

    for (uint256 i; i < funcSelectors.length; ) {
      scalerOf[funcSelectors[i]] = scalers[i];

      unchecked {
        ++i;
      }
    }
  }

  function getScaledInputData(
    bytes calldata inputData,
    uint256 newAmount
  ) external pure returns (bytes memory) {
    bytes4 selector = bytes4(inputData[:4]);
    bytes calldata dataToDecode = inputData[4:];

    if (selector == IMAR.swap.selector) {
      IMAR.SwapExecutionParams memory params =
        abi.decode(dataToDecode, (IMAR.SwapExecutionParams));

      (params.desc, params.targetData) = _getScaledInputDataV2(
        params.desc, params.targetData, newAmount, _flagsChecked(params.desc.flags, _SIMPLE_SWAP)
      );
      return abi.encodeWithSelector(selector, params);
    } else if (selector == IMAR.swapSimpleMode.selector) {
      (
        address callTarget,
        IMAR.SwapDescriptionV2 memory desc,
        bytes memory targetData,
        bytes memory clientData
      ) = abi.decode(
        dataToDecode, (address, IMAR.SwapDescriptionV2, bytes, bytes)
      );

      (desc, targetData) = _getScaledInputDataV2(desc, targetData, newAmount, true);
      return abi.encodeWithSelector(selector, callTarget, desc, targetData, clientData);
    } else {
      revert InvalidSelector();
    }
  }

  function _getScaledInputDataV2(
    IMAR.SwapDescriptionV2 memory desc,
    bytes memory executorData,
    uint256 newAmount,
    bool isSimpleMode
  ) internal pure returns (IMAR.SwapDescriptionV2 memory, bytes memory) {
    uint256 oldAmount = desc.amount;
    if (oldAmount == newAmount) {
      return (desc, executorData);
    }

    // simple mode swap
    if (isSimpleMode) {
      return (
        _scaledSwapDescriptionV2(desc, oldAmount, newAmount),
        _scaledSimpleSwapData(executorData, oldAmount, newAmount)
      );
    }

    //normal mode swap
    return (
      _scaledSwapDescriptionV2(desc, oldAmount, newAmount),
      _scaledExecutorCallBytesData(executorData, oldAmount, newAmount)
    );
  }

  /// @dev Scale the swap description
  function _scaledSwapDescriptionV2(
    IMAR.SwapDescriptionV2 memory desc,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (IMAR.SwapDescriptionV2 memory) {
    desc.minReturnAmount = (desc.minReturnAmount * newAmount) / oldAmount;
    if (desc.minReturnAmount == 0) desc.minReturnAmount = 1;
    desc.amount = newAmount;

    uint256 nReceivers = desc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      desc.srcAmounts[i] = (desc.srcAmounts[i] * newAmount) / oldAmount;
      unchecked {
        ++i;
      }
    }
    return desc;
  }

  /// @dev Scale the executorData in case swapSimpleMode
  function _scaledSimpleSwapData(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    SimpleSwapData memory swapData = abi.decode(data, (SimpleSwapData));

    uint256 nPools = swapData.firstPools.length;
    for (uint256 i = 0; i < nPools;) {
      swapData.firstSwapAmounts[i] = (swapData.firstSwapAmounts[i] * newAmount) / oldAmount;
      unchecked {
        ++i;
      }
    }
    swapData.positiveSlippageData =
      _scaledPositiveSlippageFeeData(swapData.positiveSlippageData, oldAmount, newAmount);
    return abi.encode(swapData);
  }

  /// @dev Scale the executorData in case normal swap
  function _scaledExecutorCallBytesData(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory) {
    SwapExecutorDescription memory executorDesc = abi.decode(data, (SwapExecutorDescription));
    executorDesc.positiveSlippageData =
      _scaledPositiveSlippageFeeData(executorDesc.positiveSlippageData, oldAmount, newAmount);

    uint256 nSequences = executorDesc.swapSequences.length;
    for (uint256 i = 0; i < nSequences;) {
      Swap memory swap = executorDesc.swapSequences[i][0];
      bytes4 functionSelector = bytes4(swap.selectorAndFlags);

      swap.data = scalerOf[functionSelector].
      
       ScalingDataLib.newUniSwap(swap.data, oldAmount, newAmount);


      
      unchecked {
        ++i;
      }
    }
    return abi.encode(executorDesc);
  }

  function _scaledPositiveSlippageFeeData(
    bytes memory data,
    uint256 oldAmount,
    uint256 newAmount
  ) internal pure returns (bytes memory newData) {
    if (data.length > 32) {
      PositiveSlippageFeeData memory psData = abi.decode(data, (PositiveSlippageFeeData));
      uint256 left = uint256(psData.expectedReturnAmount >> 128);
      uint256 right = uint256(uint128(psData.expectedReturnAmount)) * newAmount / oldAmount;
      require(right <= type(uint128).max, 'Exceeded type range');
      psData.expectedReturnAmount = right | left << 128;
      data = abi.encode(psData);
    } else if (data.length == 32) {
      uint256 expectedReturnAmount = abi.decode(data, (uint256));
      uint256 left = uint256(expectedReturnAmount >> 128);
      uint256 right = uint256(uint128(expectedReturnAmount)) * newAmount / oldAmount;
      require(right <= type(uint128).max, 'Exceeded type range');
      expectedReturnAmount = right | left << 128;
      data = abi.encode(expectedReturnAmount);
    }
    return data;
  }

  function _flagsChecked(uint256 number, uint256 flag) internal pure returns (bool) {
    return number & flag != 0;
  }








}