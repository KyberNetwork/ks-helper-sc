// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {CalldataReader} from './CalldataReader.sol';

contract Common is CalldataReader {
  function _readPool(bytes memory data, uint256 startByte) internal view returns (address, uint256) {
    uint24 poolId;
    address poolAddress;
    (poolId, startByte) = _readUint24(data, startByte);
    if (poolId == 0) {
      (poolAddress, startByte) = _readAddress(data, startByte);
    } else {
      poolAddress = address(this); // this is a mock address
    }
    return (poolAddress, startByte);
  }
}
