// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import 'forge-std/Script.sol';
import {console} from 'forge-std/console.sol';
import {DexHelper01} from 'src/helpers/l1/DexHelper01.sol';
import {InputScalingHelperV2} from 'src/l1-contracts/InputScalingHelperV2.sol';
import {IExecutorHelper} from 'src/interfaces/IExecutorHelper.sol';

contract DeployScaleL1V2Full is Script {
  // @note: Please update this function to make sure this is latest data of supported helpers
  function _getFuncSelectorList() internal pure returns (bytes4[] memory funcSelectorList) {
    funcSelectorList = new bytes4[](69);
    funcSelectorList[0] = IExecutorHelper.executeUniswap.selector;
    funcSelectorList[1] = IExecutorHelper.executeStableSwap.selector;
    funcSelectorList[2] = IExecutorHelper.executeCurve.selector;
    funcSelectorList[3] = IExecutorHelper.executeKSClassic.selector;
    funcSelectorList[4] = IExecutorHelper.executeUniV3KSElastic.selector;
    funcSelectorList[5] = IExecutorHelper.executeBalV2.selector;
    funcSelectorList[6] = IExecutorHelper.executeWrappedstETH.selector;
    funcSelectorList[7] = IExecutorHelper.executeStEth.selector;
    funcSelectorList[8] = IExecutorHelper.executeDODO.selector;
    funcSelectorList[9] = IExecutorHelper.executeVelodrome.selector;
    funcSelectorList[10] = IExecutorHelper.executeGMX.selector;
    funcSelectorList[11] = IExecutorHelper.executeSynthetix.selector;
    funcSelectorList[12] = IExecutorHelper.executeCamelot.selector;
    funcSelectorList[13] = IExecutorHelper.executePSM.selector;
    funcSelectorList[14] = IExecutorHelper.executeFrax.selector;
    funcSelectorList[15] = IExecutorHelper.executePlatypus.selector;
    funcSelectorList[16] = IExecutorHelper.executeMaverick.selector;
    funcSelectorList[17] = IExecutorHelper.executeSyncSwap.selector;
    funcSelectorList[18] = IExecutorHelper.executeAlgebraV1.selector;
    funcSelectorList[19] = IExecutorHelper.executeBalancerBatch.selector;
    funcSelectorList[20] = IExecutorHelper.executeWombat.selector;
    funcSelectorList[21] = IExecutorHelper.executeMantis.selector;
    funcSelectorList[22] = IExecutorHelper.executeIziSwap.selector;
    funcSelectorList[23] = IExecutorHelper.executeWooFiV2.selector;
    funcSelectorList[24] = IExecutorHelper.executeTraderJoeV2.selector;
    funcSelectorList[25] = IExecutorHelper.executePancakeStableSwap.selector;
    funcSelectorList[26] = IExecutorHelper.executeLevelFiV2.selector;
    funcSelectorList[27] = IExecutorHelper.executeGMXGLP.selector;
    funcSelectorList[28] = IExecutorHelper.executeVooi.selector;
    funcSelectorList[29] = IExecutorHelper.executeVelocoreV2.selector;
    funcSelectorList[30] = IExecutorHelper.executeMaticMigrate.selector;
    funcSelectorList[31] = IExecutorHelper.executeSmardex.selector;
    funcSelectorList[32] = IExecutorHelper.executeSolidlyV2.selector;
    funcSelectorList[33] = IExecutorHelper.executeKokonut.selector;
    funcSelectorList[34] = IExecutorHelper.executeBalancerV1.selector;
    funcSelectorList[35] = IExecutorHelper.executeNomiswapStable.selector;
    funcSelectorList[36] = IExecutorHelper.executeArbswapStable.selector;
    funcSelectorList[37] = IExecutorHelper.executeBancorV2.selector;
    funcSelectorList[38] = IExecutorHelper.executeBancorV3.selector;
    funcSelectorList[39] = IExecutorHelper.executeAmbient.selector;
    funcSelectorList[40] = IExecutorHelper.executeLighterV2.selector;
    funcSelectorList[41] = IExecutorHelper.executeUniV1.selector;
    funcSelectorList[42] = IExecutorHelper.executeEtherFieETH.selector;
    funcSelectorList[43] = IExecutorHelper.executeEtherFiWeETH.selector;
    funcSelectorList[44] = IExecutorHelper.executeKelp.selector;
    funcSelectorList[45] = IExecutorHelper.executeEthenaSusde.selector;
    funcSelectorList[46] = IExecutorHelper.executeRocketPool.selector;
    funcSelectorList[47] = IExecutorHelper.executeMakersDAI.selector;
    funcSelectorList[48] = IExecutorHelper.executeRenzo.selector;
    funcSelectorList[49] = IExecutorHelper.executeWBETH.selector;
    funcSelectorList[50] = IExecutorHelper.executeMantleETH.selector;
    funcSelectorList[51] = IExecutorHelper.executeFrxETH.selector;
    funcSelectorList[52] = IExecutorHelper.executeSfrxETH.selector;
    funcSelectorList[53] = IExecutorHelper.executeSfrxETHConvertor.selector;
    funcSelectorList[54] = IExecutorHelper.executeSwellETH.selector;
    funcSelectorList[55] = IExecutorHelper.executeRswETH.selector;
    funcSelectorList[56] = IExecutorHelper.executeStaderETHx.selector;
    funcSelectorList[57] = IExecutorHelper.executeOriginETH.selector;
    funcSelectorList[58] = IExecutorHelper.executePrimeETH.selector;
    funcSelectorList[59] = IExecutorHelper.executeMantleUsd.selector;
    funcSelectorList[60] = IExecutorHelper.executeBedrockUniETH.selector;
    funcSelectorList[61] = IExecutorHelper.executeMaiPSM.selector;
    funcSelectorList[62] = IExecutorHelper.executePufferFinance.selector;
    funcSelectorList[63] = IExecutorHelper.executeRfq.selector;
    funcSelectorList[64] = IExecutorHelper.executeHashflow.selector;
    funcSelectorList[65] = IExecutorHelper.executeNative.selector;
    funcSelectorList[66] = IExecutorHelper.executeKyberDSLO.selector;
    funcSelectorList[67] = IExecutorHelper.executeKyberLimitOrder.selector;
    funcSelectorList[68] = IExecutorHelper.executeSymbioticLRT.selector;
  }

  function run() external {
    InputScalingHelperV2 scaleHelperSc;
    DexHelper01 dexHelper1;

    uint256 priv = vm.envUint('PRIVATE_KEY');

    vm.startBroadcast(priv);

    // deploy Dex helper and Scale helper
    dexHelper1 = new DexHelper01();
    console.log('DexHelper 1 deployed at:', address(dexHelper1));
    scaleHelperSc = new InputScalingHelperV2();
    console.log('ScaleHelper deployed at:', address(scaleHelperSc));

    // setup helper mappings
    bytes4[] memory funcSelectorList = _getFuncSelectorList();
    uint256 listLength = funcSelectorList.length;
    address[] memory helperList = new address[](listLength);
    for (uint16 i; i < listLength; i++) {
      helperList[i] = address(dexHelper1);
    }
    scaleHelperSc.batchUpdateHelpers(funcSelectorList, helperList);

    vm.stopBroadcast();
  }
}
