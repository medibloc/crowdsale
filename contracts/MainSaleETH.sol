pragma solidity ^0.4.15;

import './MedToken.sol';
import 'zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract MainSaleETH is Pausable {
  using SafeMath for uint256;

  mapping(bytes32 => uint256) public weiSent;
  uint256 public weiRaised;

  uint256 public startTime;
  uint256 public endTime;
  address public wallet;
  uint256 public cap;

  event TokenPurchase(address indexed purchaser, bytes32 indexed data, address indexed beneficiary, uint256 value);

  function MainSaleETH(
    uint256 _startTime,
    uint256 _endTime,
    address _wallet,
    uint256 _cap
  ) {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_wallet != 0x0);
    require(_cap > 0);

    startTime = _startTime;
    endTime = _endTime;
    wallet = _wallet;
    cap = _cap;
  }

  function setCap(uint256 _cap) onlyOwner public {
    require(_cap > 0);

    cap = _cap;
  }

  function getWeiSent(bytes data) constant returns (uint256) {
    return weiSent[sha3(data)];
  }

  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return withinPeriod && nonZeroPurchase && withinCap;
  }

  function () payable {
    buyTokens(msg.sender);
  }

  function buyTokens(address beneficiary) whenNotPaused public payable {
    require(beneficiary != 0x0);
    require(msg.data.length != 0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    weiRaised = weiRaised.add(weiAmount);
    bytes32 dataHash = sha3(msg.data);
    weiSent[dataHash] = weiSent[dataHash] + weiAmount;

    TokenPurchase(msg.sender, dataHash, beneficiary, weiAmount);

    forwardFunds();
  }
}
