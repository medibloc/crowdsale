pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';

contract MedToken is MintableToken {
  string public name = "MED TOKEN";
  string public symbol = "MED";
  uint256 public decimals = 8;
}
