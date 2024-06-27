// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import 'forge-std/Test.sol';
import {InputScalingHelperL2} from 'src/l2-contracts/InputScalingHelperL2.sol';
import {IExecutorHelperL2} from 'src/interfaces/IExecutorHelperL2.sol';
import {IExecutorHelperL2Struct} from 'src/interfaces/IExecutorHelperL2Struct.sol';
import {IKyberDSLO} from 'src/interfaces/pools/IKyberDSLO.sol';
import {IKyberLO} from 'src/interfaces/pools/IKyberLO.sol';
import {DexReader1} from './DexReader1.sol';
import {DexReader2} from './DexReader2.sol';
import {DexReader3} from './DexReader3.sol';
import {DexReader4} from './DexReader4.sol';
import {DexReader5} from './DexReader5.sol';
import {DexReader6} from './DexReader6.sol';
import {DexWriter} from './DexWriter.sol';
import {ScalingDataL2Lib} from 'src/l2-contracts/ScalingDataL2Lib.sol';

contract Reader is DexReader1, DexReader2, DexReader3, DexReader4, DexReader5, DexReader6 {}

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
    IExecutorHelperL2Struct.UniSwap memory swap;
    swap.collectAmount = oldAmount;

    bytes memory compressed = writer.writeUniSwap(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newUniSwap(oldAmount, newAmount);

    IExecutorHelperL2Struct.UniSwap memory swapScaled = abi.decode(
      reader.readUniSwap(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.UniSwap)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(
      swapScaled.collectAmount, (swap.collectAmount * newAmount) / oldAmount, 'results are not eq'
    );
  }

  function test_scaleStableSwap(uint128 oldAmount, uint128 newAmount) public {
    _assumeConditions(oldAmount, newAmount, 0);
    IExecutorHelperL2Struct.StableSwap memory swap;
    swap.dx = oldAmount;

    bytes memory compressed = writer.writeStableSwap(swap, 0);
    bytes memory scaled = compressed.newStableSwap(oldAmount, newAmount);

    IExecutorHelperL2Struct.StableSwap memory swapScaled = abi.decode(
      reader.readStableSwap(scaled, MOCK_ADDRESS, true, false), (IExecutorHelperL2Struct.StableSwap)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.dx, (swap.dx * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleCurveSwap(uint128 oldAmount, uint128 newAmount, bool canGetIndex) public {
    _assumeConditions(oldAmount, newAmount, 0);
    IExecutorHelperL2Struct.CurveSwap memory swap;
    swap.dx = oldAmount;

    bytes memory compressed = writer.writeCurveSwap(swap, 0, 0, canGetIndex);
    bytes memory scaled = compressed.newCurveSwap(oldAmount, newAmount);

    IExecutorHelperL2Struct.CurveSwap memory swapScaled = abi.decode(
      reader.readCurveSwap(scaled, MOCK_ADDRESS, true, false), (IExecutorHelperL2Struct.CurveSwap)
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
    IExecutorHelperL2Struct.UniswapV3KSElastic memory swap;
    swap.swapAmount = oldAmount;

    bytes memory compressed = writer.writeUniswapV3KSElastic(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newUniswapV3KSElastic(oldAmount, newAmount);

    IExecutorHelperL2Struct.UniswapV3KSElastic memory swapScaled = abi.decode(
      reader.readUniswapV3KSElastic(scaled, MOCK_ADDRESS, true, address(this), false),
      (IExecutorHelperL2Struct.UniswapV3KSElastic)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.swapAmount, (swap.swapAmount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleBalancerV2(uint128 oldAmount, uint128 newAmount) public {
    _assumeConditions(oldAmount, newAmount, 0);
    IExecutorHelperL2Struct.BalancerV2 memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeBalancerV2(swap, 0, 0, 0);
    bytes memory scaled = compressed.newBalancerV2(oldAmount, newAmount);

    IExecutorHelperL2Struct.BalancerV2 memory swapScaled = abi.decode(
      reader.readBalancerV2(scaled, MOCK_ADDRESS, true, false), (IExecutorHelperL2Struct.BalancerV2)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleDODO(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.DODO memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeDODO(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newDODO(oldAmount, newAmount);

    IExecutorHelperL2Struct.DODO memory swapScaled = abi.decode(
      reader.readDODO(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.DODO)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleGMX(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.GMX memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeGMX(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newGMX(oldAmount, newAmount);

    IExecutorHelperL2Struct.GMX memory swapScaled = abi.decode(
      reader.readGMX(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false), (IExecutorHelperL2Struct.GMX)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleSynthetix(uint128 oldAmount, uint128 newAmount) public {
    _assumeConditions(oldAmount, newAmount, 0);
    IExecutorHelperL2Struct.Synthetix memory swap;
    swap.sourceAmount = oldAmount;

    bytes memory compressed = writer.writeSynthetix(swap, 0, 0);
    bytes memory scaled = compressed.newSynthetix(oldAmount, newAmount);

    IExecutorHelperL2Struct.Synthetix memory swapScaled = abi.decode(
      reader.readSynthetix(scaled, MOCK_ADDRESS, true, false), (IExecutorHelperL2Struct.Synthetix)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(
      swapScaled.sourceAmount, (swap.sourceAmount * newAmount) / oldAmount, 'results are not eq'
    );
  }

  function test_scaleWrappedstETH(uint128 oldAmount, uint128 newAmount) public {
    _assumeConditions(oldAmount, newAmount, 0);
    IExecutorHelperL2Struct.WSTETH memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeWrappedstETH(swap, 0, 0);
    bytes memory scaled = compressed.newWrappedstETHSwap(oldAmount, newAmount);

    IExecutorHelperL2Struct.WSTETH memory swapScaled = abi.decode(
      reader.readWrappedstETH(scaled, MOCK_ADDRESS, true, false), (IExecutorHelperL2Struct.WSTETH)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scalePlatypus(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.Platypus memory swap;
    swap.collectAmount = oldAmount;

    bytes memory compressed = writer.writePlatypus(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newPlatypus(oldAmount, newAmount);

    IExecutorHelperL2Struct.Platypus memory swapScaled = abi.decode(
      reader.readPlatypus(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.Platypus)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(
      swapScaled.collectAmount, (swap.collectAmount * newAmount) / oldAmount, 'results are not eq'
    );
  }

  function test_scalePSM(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.PSM memory swap;
    swap.amountIn = oldAmount;

    bytes memory compressed = writer.writePSM(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newPSM(oldAmount, newAmount);

    IExecutorHelperL2Struct.PSM memory swapScaled = abi.decode(
      reader.readPSM(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false), (IExecutorHelperL2Struct.PSM)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amountIn, (swap.amountIn * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleMaverick(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.Maverick memory swap;
    swap.swapAmount = oldAmount;

    bytes memory compressed = writer.writeMaverick(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newMaverick(oldAmount, newAmount);

    IExecutorHelperL2Struct.Maverick memory swapScaled = abi.decode(
      reader.readMaverick(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.Maverick)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.swapAmount, (swap.swapAmount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleSyncSwap(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.SyncSwap memory swap;
    swap.collectAmount = oldAmount;

    bytes memory compressed = writer.writeSyncSwap(swap, 0, 0);
    bytes memory scaled = compressed.newSyncSwap(oldAmount, newAmount);

    IExecutorHelperL2Struct.SyncSwap memory swapScaled = abi.decode(
      reader.readSyncSwap(scaled, MOCK_ADDRESS, true, false), (IExecutorHelperL2Struct.SyncSwap)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(
      swapScaled.collectAmount, (swap.collectAmount * newAmount) / oldAmount, 'results are not eq'
    );
  }

  function test_scaleAlgebraV1(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.AlgebraV1 memory swap;
    swap.swapAmount = oldAmount;

    bytes memory compressed = writer.writeAlgebraV1(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newAlgebraV1(oldAmount, newAmount);

    IExecutorHelperL2Struct.AlgebraV1 memory swapScaled = abi.decode(
      reader.readAlgebraV1(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.AlgebraV1)
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
    IExecutorHelperL2Struct.BalancerBatch memory swap;
    swap.amountIn = oldAmount;

    bytes memory compressed = writer.writeBalancerBatch(swap, 0, 0);
    bytes memory scaled = compressed.newBalancerBatch(oldAmount, newAmount);

    IExecutorHelperL2Struct.BalancerBatch memory swapScaled = abi.decode(
      reader.readBalancerBatch(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.BalancerBatch)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amountIn, (swap.amountIn * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleMantis(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.Mantis memory swap;
    swap.amount = oldAmount;
    swap.tokenOut = MOCK_ADDRESS;

    bytes memory compressed = writer.writeMantis(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newMantis(oldAmount, newAmount);

    IExecutorHelperL2Struct.Mantis memory swapScaled = abi.decode(
      reader.readMantis(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.Mantis)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleIziSwap(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.IziSwap memory swap;
    swap.swapAmount = oldAmount;

    bytes memory compressed = writer.writeIziSwap(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newIziSwap(oldAmount, newAmount);

    IExecutorHelperL2Struct.IziSwap memory swapScaled = abi.decode(
      reader.readIziSwap(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.IziSwap)
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
    IExecutorHelperL2Struct.TraderJoeV2 memory swap;
    swap.collectAmount = uint256(oldAmount) | (isV2 ? 1 : 0) << 255;

    bytes memory compressed = writer.writeTraderJoeV2(swap, 0, 0, recipientFlag);
    bytes memory scaled = compressed.newTraderJoeV2(oldAmount, newAmount);

    IExecutorHelperL2Struct.TraderJoeV2 memory swapScaled = abi.decode(
      reader.readTraderJoeV2(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.TraderJoeV2)
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
    IExecutorHelperL2Struct.LevelFiV2 memory swap;
    swap.amountIn = oldAmount;
    swap.toToken = MOCK_ADDRESS;

    bytes memory compressed = writer.writeLevelFiV2(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newLevelFiV2(oldAmount, newAmount);

    IExecutorHelperL2Struct.LevelFiV2 memory swapScaled = abi.decode(
      reader.readLevelFiV2(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.LevelFiV2)
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
    IExecutorHelperL2Struct.GMXGLP memory swap;
    swap.swapAmount = oldAmount;
    swap.tokenOut = MOCK_ADDRESS;

    bytes memory compressed = writer.writeGMXGLP(swap, 1, 0, recipientFlag, directionFlag);
    bytes memory scaled = compressed.newGMXGLP(oldAmount, newAmount);

    IExecutorHelperL2Struct.GMXGLP memory swapScaled = abi.decode(
      reader.readGMXGLP(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.GMXGLP)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.swapAmount, (swap.swapAmount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleVooi(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.Vooi memory swap;
    swap.fromAmount = oldAmount;
    swap.toToken = MOCK_ADDRESS;

    bytes memory compressed = writer.writeVooi(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newVooi(oldAmount, newAmount);

    IExecutorHelperL2Struct.Vooi memory swapScaled = abi.decode(
      reader.readVooi(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.Vooi)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.fromAmount, (swap.fromAmount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleVelocoreV2(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.VelocoreV2 memory swap;
    swap.amount = oldAmount;
    swap.tokenOut = MOCK_ADDRESS;

    bytes memory compressed = writer.writeVelocoreV2(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newVelocoreV2(oldAmount, newAmount);

    IExecutorHelperL2Struct.VelocoreV2 memory swapScaled = abi.decode(
      reader.readVelocoreV2(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.VelocoreV2)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleKokonut(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.Kokonut memory swap;
    swap.dx = oldAmount;

    bytes memory compressed = writer.writeKokonut(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newKokonut(oldAmount, newAmount);

    IExecutorHelperL2Struct.Kokonut memory swapScaled = abi.decode(
      reader.readKokonut(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.Kokonut)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.dx, (swap.dx * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleBalancerV1(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.BalancerV1 memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeBalancerV1(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newBalancerV1(oldAmount, newAmount);

    IExecutorHelperL2Struct.BalancerV1 memory swapScaled = abi.decode(
      reader.readBalancerV1(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.BalancerV1)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleArbswapStable(
    uint128 oldAmount,
    uint128 newAmount,
    uint8 recipientFlag
  ) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.ArbswapStable memory swap;
    swap.dx = oldAmount;

    bytes memory compressed = writer.writeArbswapStable(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newArbswapStable(oldAmount, newAmount);

    IExecutorHelperL2Struct.ArbswapStable memory swapScaled = abi.decode(
      reader.readArbswapStable(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.ArbswapStable)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.dx, (swap.dx * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleBancorV2(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);
    IExecutorHelperL2Struct.BancorV2 memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeBancorV2(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newBancorV2(oldAmount, newAmount);

    IExecutorHelperL2Struct.BancorV2 memory swapScaled = abi.decode(
      reader.readBancorV2(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.BancorV2)
    );

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, (swap.amount * newAmount) / oldAmount, 'results are not eq');
  }

  function test_scaleAmbient(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);

    IExecutorHelperL2Struct.Ambient memory swap;
    swap.qty = oldAmount;

    bytes memory compressed = writer.writeAmbient(swap, 1, 0);
    bytes memory scaled = compressed.newAmbient(oldAmount, newAmount);

    IExecutorHelperL2Struct.Ambient memory swapScaled = abi.decode(
      reader.readAmbient(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.Ambient)
    );

    uint256 tmpAmount = uint256(swap.qty) * uint256(newAmount); // handle phantom overflow

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.qty, tmpAmount / oldAmount, 'results are not eq');
  }

  function test_scaleLighterV2(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);

    IExecutorHelperL2Struct.LighterV2 memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeLighterV2(swap, 1, 0, recipientFlag);
    bytes memory scaled = compressed.newLighterV2(oldAmount, newAmount);

    IExecutorHelperL2Struct.LighterV2 memory swapScaled = abi.decode(
      reader.readLighterV2(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.LighterV2)
    );

    uint256 tmpAmount = uint256(swap.amount) * uint256(newAmount); // handle phantom overflow

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, tmpAmount / oldAmount, 'results are not eq');
  }

  function test_scaleMaiPSM(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);

    IExecutorHelperL2Struct.FrxETH memory swap;
    swap.amount = oldAmount;

    bytes memory compressed = writer.writeMaiPSM(swap, 1, 0);
    bytes memory scaled = compressed.newMaiPSM(oldAmount, newAmount);

    IExecutorHelperL2Struct.FrxETH memory swapScaled = abi.decode(
      reader.readMaiPSM(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.FrxETH)
    );

    uint256 tmpAmount = uint256(swap.amount) * uint256(newAmount); // handle phantom overflow

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, tmpAmount / oldAmount, 'results are not eq');
  }

  function test_scaleHashflow(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    // _assumeConditions(oldAmount, newAmount, recipientFlag);

    // IExecutorHelperL2Struct.Hashflow memory swap;
    // swap.quote.effectiveBaseTokenAmount = oldAmount;

    // bytes memory compressed = writer.writeHashflow(swap, 1, 0);

    // bytes memory scaled = compressed.newHashflow(oldAmount, newAmount);

    // IExecutorHelperL2Struct.Hashflow memory swapScaled = abi.decode(
    //   reader.readHashflow(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false), (IExecutorHelperL2Struct.Hashflow)
    // );

    // uint256 tmpAmount = uint256(swap.quote.effectiveBaseTokenAmount) * uint256(newAmount); // handle phantom overflow

    // assertTrue(compressed.length == scaled.length, 'data should not change length');
    // assertEq(swapScaled.quote.effectiveBaseTokenAmount, tmpAmount / oldAmount, 'results are not eq');
  }

  function test_scaleNative(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    // _assumeConditions(oldAmount, newAmount, recipientFlag);
    // vm.assume(newAmount < oldAmount);

    // IExecutorHelperL2Struct.Native memory swap;
    // swap.amount = oldAmount;

    // bytes memory compressed = writer.writeNative(swap, 1, 0);
    // bytes memory scaled = compressed.newNative(oldAmount, newAmount);

    // IExecutorHelperL2Struct.Native memory swapScaled = abi.decode(
    //   reader.readNative(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false), (IExecutorHelperL2Struct.Native)
    // );

    // uint256 tmpAmount = uint256(swap.amount) * uint256(newAmount); // handle phantom overflow

    // assertTrue(compressed.length == scaled.length, 'data should not change length');
    // assertEq(swapScaled.amount, tmpAmount / oldAmount, 'results are not eq');
  }

  function test_scaleBebop(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    // _assumeConditions(oldAmount, newAmount, recipientFlag);
    // vm.assume(newAmount < oldAmount);

    // IExecutorHelperL2Struct.Bebop memory swap;
    // swap.amount = oldAmount;

    // bytes memory compressed = writer.writeBebop(swap, 1, 0);
    // bytes memory scaled = compressed.newBebop(oldAmount, newAmount);

    // IExecutorHelperL2Struct.Bebop memory swapScaled = abi.decode(
    //   reader.readBebop(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false), (IExecutorHelperL2Struct.Bebop)
    // );

    // uint256 tmpAmount = uint256(swap.amount) * uint256(newAmount); // handle phantom overflow

    // assertTrue(compressed.length == scaled.length, 'data should not change length');
    // assertEq(swapScaled.amount, tmpAmount / oldAmount, 'results are not eq');
  }

  function test_scaleKyberRfq(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);

    IExecutorHelperL2Struct.KyberRFQ memory swap;
    swap.amount = oldAmount;
    bytes memory compressed = writer.writeKyberRFQ(swap, 1, 0);

    bytes memory scaled = compressed.newKyberRFQ(oldAmount, newAmount);

    IExecutorHelperL2Struct.KyberRFQ memory swapScaled = abi.decode(
      reader.readKyberRFQ(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.KyberRFQ)
    );
    uint256 tmpAmount = uint256(swap.amount) * uint256(newAmount); // handle phantom overflow

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.amount, tmpAmount / oldAmount, 'results are not eq');
  }

  function test_scaleKyberDSLO(uint128 oldAmount, uint128 newAmount, uint8 recipientFlag) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);

    IExecutorHelperL2Struct.KyberDSLO memory swap;
    swap.params.takingAmount = oldAmount;

    swap.params.orders = new IKyberDSLO.Order[](1);
    swap.params.signatures = new IKyberDSLO.Signature[](1);
    swap.params.opExpireTimes = new uint32[](1);

    bytes memory compressed = writer.writeKyberDSLO(swap, 1, 0);

    bytes memory scaled = compressed.newKyberDSLO(oldAmount, newAmount);

    IExecutorHelperL2Struct.KyberDSLO memory swapScaled = abi.decode(
      reader.readKyberDSLO(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.KyberDSLO)
    );

    uint256 tmpAmount = uint256(swap.params.takingAmount) * uint256(newAmount); // handle phantom overflow

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.params.takingAmount, tmpAmount / oldAmount, 'results are not eq');
  }

  function test_scaleKyberLimitOrder(
    uint128 oldAmount,
    uint128 newAmount,
    uint8 recipientFlag
  ) public {
    _assumeConditions(oldAmount, newAmount, recipientFlag);

    IExecutorHelperL2Struct.KyberLimitOrder memory swap;
    swap.params.takingAmount = oldAmount;

    swap.params.orders = new IKyberLO.Order[](1);
    swap.params.signatures = new bytes[](1);

    bytes memory compressed = writer.writeKyberLimitOrder(swap, 1, 0);

    console.logBytes(compressed);

    bytes memory scaled = compressed.newKyberLimitOrder(oldAmount, newAmount);

    IExecutorHelperL2Struct.KyberLimitOrder memory swapScaled = abi.decode(
      reader.readKyberLimitOrder(scaled, MOCK_ADDRESS, true, MOCK_ADDRESS, false),
      (IExecutorHelperL2Struct.KyberLimitOrder)
    );

    uint256 tmpAmount = uint256(swap.params.takingAmount) * uint256(newAmount); // handle phantom overflow

    assertTrue(compressed.length == scaled.length, 'data should not change length');
    assertEq(swapScaled.params.takingAmount, tmpAmount / oldAmount, 'results are not eq');
  }
}
