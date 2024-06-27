// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import './Common.sol';
import 'src/interfaces/IExecutorHelperL2.sol';

/// @title DexReader5
/// @notice Contain functions to decode dex data
/// @dev For this repo's scope, we only care about swap amounts, so we just need to decode until we get swap amounts
contract DexReader5 is Common {}
