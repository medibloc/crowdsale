pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import './MedToken.sol';
import './TokenLock.sol';

contract PresaleFirst is CappedCrowdsale, Pausable {
  using SafeMath for uint256;

  uint256 public minimum;
  mapping(address => address) public locks;

  function PresaleFirst(
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rate,
    address _wallet,
    uint256 _cap,
    uint256 _minimum,
    uint256 _initialMint
  )
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    CappedCrowdsale(_cap)
  {
    minimum = _minimum;
    token.mint(owner, _initialMint);
  }

  function createTokenContract() internal returns (MintableToken) {
    return new MedToken();
  }

  function validPurchase() internal constant returns (bool) {
    bool moreThanMinimum = msg.value >= minimum;
    return super.validPurchase() && moreThanMinimum;
  }

  function () payable {
      buyTokens(msg.sender);
  }

  function buyTokens(address beneficiary) whenNotPaused public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    if (locks[msg.sender] == 0x0) {
      TokenLock lock = new TokenLock(MedToken(token), owner, beneficiary);
      locks[msg.sender] = address(lock);
    }

    token.mint(locks[msg.sender], tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  function handOverTokenOwnership() onlyOwner public {
    token.transferOwnership(owner);
  }
}
