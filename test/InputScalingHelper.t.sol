// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import 'forge-std/Test.sol';
import 'forge-std/console.sol';
import 'forge-std/StdJson.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

import {IExecutorHelper} from '../src/interfaces/IExecutorHelper.sol';

import '../src/InputScalingHelperV2.sol';
import '../src/helpers/Dexhelper01.sol';

import './BaseInputScaling.t.sol';

contract DexesTest is BaseInputScalingTest {
  using stdJson for string;

  address private constant ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

  InputScalingHelperV2 scaleHelperV2;
  DexHelper01 helper01;

  function setUp() public override {
    super.setUp();

    scaleHelperV2 = new InputScalingHelperV2();
    helper01 = new DexHelper01();

    bytes4[] memory funcSelectors = new bytes4[](48);

    funcSelectors[0] = IExecutorHelper.executeUniswap.selector;
    funcSelectors[1] = IExecutorHelper.executeStableSwap.selector;
    funcSelectors[2] = IExecutorHelper.executeCurve.selector;
    funcSelectors[3] = IExecutorHelper.executeKSClassic.selector;
    funcSelectors[4] = IExecutorHelper.executeUniV3KSElastic.selector;
    funcSelectors[5] = IExecutorHelper.executeBalV2.selector;
    funcSelectors[6] = IExecutorHelper.executeWrappedstETH.selector;
    funcSelectors[7] = IExecutorHelper.executeStEth.selector;
    funcSelectors[8] = IExecutorHelper.executeDODO.selector;
    funcSelectors[9] = IExecutorHelper.executeVelodrome.selector;
    funcSelectors[10] = IExecutorHelper.executeGMX.selector;
    funcSelectors[11] = IExecutorHelper.executeSynthetix.selector;
    funcSelectors[12] = IExecutorHelper.executeCamelot.selector;
    funcSelectors[13] = IExecutorHelper.executePSM.selector;
    funcSelectors[14] = IExecutorHelper.executeFrax.selector;
    funcSelectors[15] = IExecutorHelper.executePlatypus.selector;
    funcSelectors[16] = IExecutorHelper.executeMaverick.selector;
    funcSelectors[17] = IExecutorHelper.executeSyncSwap.selector;
    funcSelectors[18] = IExecutorHelper.executeAlgebraV1.selector;
    funcSelectors[19] = IExecutorHelper.executeBalancerBatch.selector;
    funcSelectors[20] = IExecutorHelper.executeWombat.selector;
    funcSelectors[21] = IExecutorHelper.executeMantis.selector;
    funcSelectors[22] = IExecutorHelper.executeIziSwap.selector;
    funcSelectors[23] = IExecutorHelper.executeWooFiV2.selector;
    funcSelectors[24] = IExecutorHelper.executeTraderJoeV2.selector;
    funcSelectors[25] = IExecutorHelper.executePancakeStableSwap.selector;
    funcSelectors[26] = IExecutorHelper.executeLevelFiV2.selector;
    funcSelectors[27] = IExecutorHelper.executeGMXGLP.selector;
    funcSelectors[28] = IExecutorHelper.executeVooi.selector;
    funcSelectors[29] = IExecutorHelper.executeVelocoreV2.selector;
    funcSelectors[30] = IExecutorHelper.executeMaticMigrate.selector;
    funcSelectors[31] = IExecutorHelper.executeSmardex.selector;
    funcSelectors[32] = IExecutorHelper.executeSolidlyV2.selector;
    funcSelectors[33] = IExecutorHelper.executeKokonut.selector;
    funcSelectors[34] = IExecutorHelper.executeBalancerV1.selector;
    funcSelectors[35] = IExecutorHelper.executeNomiswapStable.selector;
    funcSelectors[36] = IExecutorHelper.executeArbswapStable.selector;
    funcSelectors[37] = IExecutorHelper.executeBancorV2.selector;
    funcSelectors[38] = IExecutorHelper.executeBancorV3.selector;
    funcSelectors[39] = IExecutorHelper.executeAmbient.selector;
    funcSelectors[40] = IExecutorHelper.executeLighterV2.selector;
    funcSelectors[41] = IExecutorHelper.executeUniV1.selector;
    funcSelectors[42] = IExecutorHelper.executeEtherFieETH.selector;
    funcSelectors[43] = IExecutorHelper.executeEtherFiWeETH.selector;
    funcSelectors[44] = IExecutorHelper.executeKelp.selector;
    funcSelectors[45] = IExecutorHelper.executeEthenaSusde.selector;
    funcSelectors[46] = IExecutorHelper.executeRocketPool.selector;
    funcSelectors[47] = IExecutorHelper.executeMakersDAI.selector;

    address[] memory executors = new address[](48);
    for (uint256 i; i < executors.length; i++) {
      executors[i] = address(helper01);
    }

    scaleHelperV2.batchUpdateHelpers(funcSelectors, executors);
  }

  function testScaleUniswap() public {
    SwapTx memory swap = _readInput(swapInputPath, '.uniswap_ethereum_1_ETH_USDC');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function testScaleBalancer() public {
    //swap amount = 1 ether
    SwapTx memory swap = _readInput(swapInputPath, '.balancer_ethereum_1_ETH_USDC');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function testScaleCurve() public {
    //swap amount = 1 ether
    SwapTx memory swap = _readInput(swapInputPath, '.curve_ethereum_1_ETH_USDC');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function testScaleKyberDMM() public {
    //swap amount = 1 ether
    SwapTx memory swap = _readInput(swapInputPath, '.kyberDMM_ethereum_1_ETH_USDC');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function testScaleUniswapV3() public {
    //swap amount = 1 ether
    SwapTx memory swap = _readInput(swapInputPath, '.uniswapv3_ethereum_1_ETH_USDC');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function testScaleStable() public {
    //swap amount = 1 ether
    SwapTx memory swap = _readInput(swapInputPath, '.saddle_ethereum_1_WETH_SETH');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function testScaleDodo() public {
    //swap amount = 1 ether
    SwapTx memory swap = _readInput(swapInputPath, '.dodo_ethereum_1000_USDC_USDT');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function testScaleVelodrome() public {
    //swap amount = 1 ether
    SwapTx memory swap = _readInput(swapInputPath, '.velodrome_optimism_1_ETH_USDC');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function testScaleGMX() public {
    //swap amount = 1 ether
    SwapTx memory swap = _readInput(swapInputPath, '.gmx_arbitrum_1_WETH_USDC');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function testScaleFrax() public {
    //swap amount = 1 ether
    SwapTx memory swap = _readInput(swapInputPath, '.frax_ethereum_1_ETH_USDC');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function testScalePlatypus() public {
    //swap amount = 1 ether
    SwapTx memory swap = _readInput(swapInputPath, '.platypus_avalanche_1_WAVAX_SAVAX');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function testScaleCamelot() public {
    //swap amount = 1 ether
    SwapTx memory swap = _readInput(swapInputPath, '.camelot_arbitrum_1_ETH_USDC');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function testScaleWstETH() public {
    //swap amount = 1 ether
    SwapTx memory swap = _readInput(swapInputPath, '.wstETH_ethereum_1_stETH_wstETH');
    bytes4 selector = _getSelector(swap.encodedData);

    IMetaAggregationRouterV2.SwapDescriptionV2 memory desc =
      _decodeSwapDescription(selector, swap.encodedData);

    uint256 newAmount = 1e18;
    bytes memory newData = scaleHelperV2.getScaledInputData(swap.encodedData, newAmount);
    IMetaAggregationRouterV2.SwapDescriptionV2 memory newDesc =
      _decodeSwapDescription(selector, newData);

    assertEq(newDesc.minReturnAmount, (desc.minReturnAmount * newAmount) / desc.amount);
    assertEq(newDesc.amount, newAmount);

    uint256 nReceivers = newDesc.srcReceivers.length;
    for (uint256 i = 0; i < nReceivers;) {
      assertEq(newDesc.srcAmounts[i], (desc.srcAmounts[i] * newAmount) / desc.amount);
      unchecked {
        ++i;
      }
    }
  }

  function _decodeSwapDescription(
    bytes4 selector,
    bytes memory data
  ) internal pure returns (IMetaAggregationRouterV2.SwapDescriptionV2 memory desc) {
    if (selector == IMetaAggregationRouterV2.swap.selector) {
      (IMetaAggregationRouterV2.SwapExecutionParams memory executionParams) =
        abi.decode(_removeSelector(data), (IMetaAggregationRouterV2.SwapExecutionParams));

      desc = executionParams.desc;
    } else {
      (, desc,,) = abi.decode(
        _removeSelector(data), (address, IMetaAggregationRouterV2.SwapDescriptionV2, bytes, bytes)
      );
    }
  }

  function _getSelector(bytes memory data) internal pure returns (bytes4) {
    bytes4 fragment0 = data[0];
    bytes4 fragment1 = data[1];
    fragment1 = fragment1 >> 8;
    bytes4 fragment2 = data[2];
    fragment2 = fragment2 >> 16;
    bytes4 fragment3 = data[3];
    fragment3 = fragment3 >> 24;

    bytes4 selector = fragment0 | fragment1 | fragment2 | fragment3;
    return selector;
  }

  function _removeSelector(bytes memory data) internal pure returns (bytes memory) {
    bytes memory returnValue = new bytes(data.length - 4);
    for (uint256 i = 4; i < data.length; i++) {
      returnValue[i - 4] = data[i];
    }
    return returnValue;
  }
}
