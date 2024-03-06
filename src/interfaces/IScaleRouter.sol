// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IScaleRouter {
  error InvalidLength();
  error InvalidSelector();

  // fee data in case taking in dest token
  struct PositiveSlippageFeeData {
    uint256 partnerPSInfor; // [partnerReceiver (160 bit) + partnerPercent(96bits)]
    uint256 expectedReturnAmount;
  }

  struct Swap {
    bytes data;
    bytes32 selectorAndFlags; // [selector (32 bits) + flags (224 bits)]; selector is 4 most significant bytes; flags are stored in 4 least significant bytes.
  }

  struct SimpleSwapData {
    address[] firstPools;
    uint256[] firstSwapAmounts;
    bytes[] swapDatas;
    uint256 deadline;
    bytes positiveSlippageData;
  }

  struct SwapExecutorDescription {
    Swap[][] swapSequences;
    address tokenIn;
    address tokenOut;
    address to;
    uint256 deadline;
    bytes positiveSlippageData;
  }

  function updateBatchScalers(bytes4[] memory funcSelectors, address[] memory scalers) external;
}