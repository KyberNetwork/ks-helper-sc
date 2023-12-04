// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import 'forge-std/Test.sol';
import {InputScalingHelperL2} from 'src/l2-contracts/InputScalingHelperL2.sol';
import {IExecutorHelperL2} from 'src/interfaces/IExecutorHelperL2.sol';
import {DexReader1} from './DexReader1.sol';
import {DexReader2} from './DexReader2.sol';
import {DexReader3} from './DexReader3.sol';
import {DexReader4} from './DexReader4.sol';
import {DexWriter} from './DexWriter.sol';
import {ScalingDataL2Lib} from 'src/l2-contracts/ScalingDataL2Lib.sol';

contract Reader is DexReader1, DexReader2, DexReader3, DexReader4 {}

contract DexScalersTest is Test {
  using ScalingDataL2Lib for bytes;

  Reader reader;
  DexWriter writer;

  address constant MOCK_ADDRESS = address(0xdead);

  function setUp() public {
    reader = new Reader();
    writer = new DexWriter();
  }

  function _assumeConditions(
    uint128 oldAmount,
    uint128 newAmount,
    uint8 recipientFlag
  ) internal pure {
    vm.assume(recipientFlag < 3);
    vm.assume(oldAmount != 0);
    vm.assume(newAmount != 0);
  }

  function test_scaleUniSwap(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.UniSwap memory swap;
    swap.collectAmount = oldAmount;

    bytes memory compressed = writer.writeUniSwap(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newUniSwap(oldAmount, newAmount);

    IExecutorHelperL2.UniSwap memory swapScaled = abi.decode(
      reader.readUniSwap(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2.UniSwap)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(
      swapScaled.collectAmount, (swap.collectAmount * newAmount) / oldAmount, 'results are not eq'
    );
  }

  function test_scaleStableSwap(uint128 oldAmount, uint128 newAmount) public {
    _assumeConditions(oldAmount, newAmount, 0);
    IExecutorHelperL2.StableSwap memory swap;
    swap.dx = oldAmount;

    bytes memory compressed = writer.writeStableSwap(swap, 0);
    bytes memory scaled = compressed.newStableSwap(oldAmount, newAmount);

    IExecutorHelperL2.StableSwap memory swapScaled = abi.decode(
      reader.readStableSwap(scaled, MOCK_ADDRESS, true, false), (IExecutorHelperL2.StableSwap)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.dx, (swap.dx * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleCurveSwap(uint128 oldAmount, uint128 newAmount, bool canGetIndex) public {
    _assumeConditions(oldAmount, newAmount, 0);
    IExecutorHelperL2.CurveSwap memory swap;
    swap.dx = oldAmount;

    bytes memory compressed = writer.writeCurveSwap(swap, 0, 0, canGetIndex);
    bytes memory scaled = compressed.newCurveSwap(oldAmount, newAmount);

    IExecutorHelperL2.CurveSwap memory swapScaled = abi.decode(
      reader.readCurveSwap(scaled, MOCK_ADDRESS, true, false), (IExecutorHelperL2.CurveSwap)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.dx, (swap.dx * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleUniswapV3KSElastic(
    uint128 oldAmount,
    uint128 newAmount,
    uint8 recipientFlag
  ) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.UniswapV3KSElastic memory swap;
    swap.swapAmount = oldAmount;

    bytes memory compressed = writer.writeUniswapV3KSElastic(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newUniswapV3KSElastic(oldAmount, newAmount);

    IExecutorHelperL2.UniswapV3KSElastic memory swapScaled = abi.decode(
      reader.readUniswapV3KSElastic(scaled, MOCK_ADDRESS, true, address(this), false),
      (IExecutorHelperL2.UniswapV3KSElastic)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.swapAmount, (swap.swapAmount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleBalancerV2(uint128 oldAmount, uint128 newAmount) public {
    _assumeConditions(oldAmount, newAmount, 0);
    IExecutorHelperL2.BalancerV2 memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeBalancerV2(swap, 0, 0, 0);
    bytes memory scaled = compressed.newBalancerV2(oldAmount, newAmount);

    IExecutorHelperL2.BalancerV2 memory swapScaled = abi.decode(
      reader.readBalancerV2(scaled, MOCK_ADDRESS, true, false), (IExecutorHelperL2.BalancerV2)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleDODO(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.DODO memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeDODO(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newDODO(oldAmount, newAmount);

    IExecutorHelperL2.DODO memory swapScaled = abi.decode(
      reader.readDODO(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false), (IExecutorHelperL2.DODO)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleGMX(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.GMX memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeGMX(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newGMX(oldAmount, newAmount);

    IExecutorHelperL2.GMX memory swapScaled = abi.decode(
      reader.readGMX(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false), (IExecutorHelperL2.GMX)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleSynthetix(uint128 oldAmount, uint128 newAmount) public {
    _assumeConditions(oldAmount, newAmount, 0);
    IExecutorHelperL2.Synthetix memory swap;
    swap.sourceAmount = oldAmount;

    bytes memory compressed = writer.writeSynthetix(swap, 0, 0);
    bytes memory scaled = compressed.newSynthetix(oldAmount, newAmount);

    IExecutorHelperL2.Synthetix memory swapScaled = abi.decode(
      reader.readSynthetix(scaled, MOCK_ADDRESS, true, false), (IExecutorHelperL2.Synthetix)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(
      swapScaled.sourceAmount, (swap.sourceAmount * newAmount) / oldAmount, 'results are not eq'
    );
  }

  function test_scaleWrappedstETH(uint128 oldAmount, uint128 newAmount) public {
    _assumeConditions(oldAmount, newAmount, 0);
    IExecutorHelperL2.WSTETH memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeWrappedstETH(swap, 0, 0);
    bytes memory scaled = compressed.newWrappedstETHSwap(oldAmount, newAmount);

    IExecutorHelperL2.WSTETH memory swapScaled = abi.decode(
      reader.readWrappedstETH(scaled, MOCK_ADDRESS, true, false), (IExecutorHelperL2.WSTETH)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scalePlatypus(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.Platypus memory swap;
    swap.collectAmount = oldAmount;

    bytes memory compressed = writer.writePlatypus(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newPlatypus(oldAmount, newAmount);

    IExecutorHelperL2.Platypus memory swapScaled = abi.decode(
      reader.readPlatypus(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2.Platypus)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(
      swapScaled.collectAmount, (swap.collectAmount * newAmount) / oldAmount, 'results are not eq'
    );
  }

  function test_scalePSM(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.PSM memory swap;
    swap.amountIn = oldAmount;

    bytes memory compressed = writer.writePSM(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newPSM(oldAmount, newAmount);

    IExecutorHelperL2.PSM memory swapScaled = abi.decode(
      reader.readPSM(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false), (IExecutorHelperL2.PSM)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amountIn, (swap.amountIn * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleMaverick(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.Maverick memory swap;
    swap.swapAmount = oldAmount;

    bytes memory compressed = writer.writeMaverick(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newMaverick(oldAmount, newAmount);

    IExecutorHelperL2.Maverick memory swapScaled = abi.decode(
      reader.readMaverick(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2.Maverick)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.swapAmount, (swap.swapAmount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleSyncSwap(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.SyncSwap memory swap;
    swap.collectAmount = oldAmount;

    bytes memory compressed = writer.writeSyncSwap(swap, 0, 0);
    bytes memory scaled = compressed.newSyncSwap(oldAmount, newAmount);

    IExecutorHelperL2.SyncSwap memory swapScaled = abi.decode(
      reader.readSyncSwap(scaled, MOCK_ADDRESS, true, false), (IExecutorHelperL2.SyncSwap)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(
      swapScaled.collectAmount, (swap.collectAmount * newAmount) / oldAmount, 'results are not eq'
    );
  }

  function test_scaleAlgebraV1(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.AlgebraV1 memory swap;
    swap.swapAmount = oldAmount;

    bytes memory compressed = writer.writeAlgebraV1(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newAlgebraV1(oldAmount, newAmount);

    IExecutorHelperL2.AlgebraV1 memory swapScaled = abi.decode(
      reader.readAlgebraV1(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2.AlgebraV1)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.swapAmount, (swap.swapAmount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleBalancerBatch(
    uint128 oldAmount,
    uint128 newAmount,
    uint8 recipientFlag
  ) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.BalancerBatch memory swap;
    swap.amountIn = oldAmount;

    bytes memory compressed = writer.writeBalancerBatch(swap, 0, 0);
    bytes memory scaled = compressed.newBalancerBatch(oldAmount, newAmount);

    IExecutorHelperL2.BalancerBatch memory swapScaled = abi.decode(
      reader.readBalancerBatch(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2.BalancerBatch)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amountIn, (swap.amountIn * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleMantis(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.Mantis memory swap;
    swap.amount = oldAmount;
    swap.tokenOut = MOCK_ADDRESS;

    bytes memory compressed = writer.writeMantis(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newMantis(oldAmount, newAmount);

    IExecutorHelperL2.Mantis memory swapScaled = abi.decode(
      reader.readMantis(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false), (IExecutorHelperL2.Mantis)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleIziSwap(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.IziSwap memory swap;
    swap.swapAmount = oldAmount;

    bytes memory compressed = writer.writeIziSwap(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newIziSwap(oldAmount, newAmount);

    IExecutorHelperL2.IziSwap memory swapScaled = abi.decode(
      reader.readIziSwap(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2.IziSwap)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.swapAmount, (swap.swapAmount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleTraderJoeV2(
    uint128 oldAmount,
    uint128 newAmount,
    uint8 recipientFlag,
    bool isV2
  ) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.TraderJoeV2 memory swap;
    swap.collectAmount = uint256(oldAmount) | (isV2 ? 1 : 0) << 255;

    bytes memory compressed = writer.writeTraderJoeV2(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newTraderJoeV2(oldAmount, newAmount);

    IExecutorHelperL2.TraderJoeV2 memory swapScaled = abi.decode(
      reader.readTraderJoeV2(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2.TraderJoeV2)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(
      swapScaled.collectAmount & ~uint256(1 << 255),
      ((swap.collectAmount & ~uint256(1 << 255)) * newAmount) / oldAmount,
      'results are not eq'
    );
  }

  function test_scaleLevelFiV2(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.LevelFiV2 memory swap;
    swap.amountIn = oldAmount;
    swap.toToken = MOCK_ADDRESS;

    bytes memory compressed = writer.writeLevelFiV2(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newLevelFiV2(oldAmount, newAmount);

    IExecutorHelperL2.LevelFiV2 memory swapScaled = abi.decode(
      reader.readLevelFiV2(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2.LevelFiV2)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amountIn, (swap.amountIn * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleGMXGLP(
    uint128 oldAmount,
    uint128 newAmount,
    uint8 recipientFlag,
    uint8 directionFlag
  ) public {
    vm.assume(directionFlag < 2);
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.GMXGLP memory swap;
    swap.swapAmount = oldAmount;
    swap.tokenOut = MOCK_ADDRESS;

    bytes memory compressed = writer.writeGMXGLP(swap, 1, 0, recipientFlag, directionFlag);
    bytes memory scaled = compressed.newGMXGLP(oldAmount, newAmount);

    IExecutorHelperL2.GMXGLP memory swapScaled = abi.decode(
      reader.readGMXGLP(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false), (IExecutorHelperL2.GMXGLP)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.swapAmount, (swap.swapAmount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleVooi(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.Vooi memory swap;
    swap.fromAmount = oldAmount;
    swap.toToken = MOCK_ADDRESS;

    bytes memory compressed = writer.writeVooi(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newVooi(oldAmount, newAmount);

    IExecutorHelperL2.Vooi memory swapScaled = abi.decode(
      reader.readVooi(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false), (IExecutorHelperL2.Vooi)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.fromAmount, (swap.fromAmount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleVelocoreV2(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.VelocoreV2 memory swap;
    swap.amount = oldAmount;
    swap.tokenOut = MOCK_ADDRESS;

    bytes memory compressed = writer.writeVelocoreV2(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newVelocoreV2(oldAmount, newAmount);

    IExecutorHelperL2.VelocoreV2 memory swapScaled = abi.decode(
      reader.readVelocoreV2(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2.VelocoreV2)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleKokonut(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.Kokonut memory swap;
    swap.dx = oldAmount;

    bytes memory compressed = writer.writeKokonut(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newKokonut(oldAmount, newAmount);

    IExecutorHelperL2.Kokonut memory swapScaled = abi.decode(
      reader.readKokonut(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2.Kokonut)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.dx, (swap.dx * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleBalancerV1(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2.BalancerV1 memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeBalancerV1(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newBalancerV1(oldAmount, newAmount);

    IExecutorHelperL2.BalancerV1 memory swapScaled = abi.decode(
      reader.readBalancerV1(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2.BalancerV1)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }
}
