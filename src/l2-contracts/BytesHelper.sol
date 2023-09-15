pragma solidity 0.8.9;

library BytesHelper {
  function write16Bytes(
    bytes memory original,
    uint256 index,
    bytes16 value
  ) internal pure returns (bytes memory) {
    assembly {
      let offset := add(original, add(index, 32))
      let val := mload(offset) // read 32 bytes [index : index + 32]
      val := or(val, value) // set 16 bytes to val above
      mstore(offset, val) // store to [index : index + 32]
    }
    return original;
  }

  function write16Bytes(
    bytes memory original,
    uint256 index,
    uint128 value
  ) internal pure returns (bytes memory) {
    return write16Bytes(original, index, bytes16(value));
  }

  function write16Bytes(
    bytes memory original,
    uint256 index,
    uint256 value,
    string memory errorMsg
  ) internal pure returns (bytes memory) {
    require(
      value <= type(uint128).max,
      string(abi.encodePacked(errorMsg, '/Exceed compressed type range'))
    );
    return write16Bytes(original, index, uint128(value));
  }
}
