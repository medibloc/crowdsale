pragma solidity ^0.4.15;

import './MedToken.sol';
import 'zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract MainSale is CappedCrowdsale, Pausable {
  using SafeMath for uint256;

  mapping(address => uint256) public locks;

  function MainSale(
    uint256 _startTime,
    uint256 _endTime,
    uint _rate,
    address _tokenAddress,
    address _wallet,
    uint256 _cap
  )
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    CappedCrowdsale(_cap)
  {
    require(_tokenAddress != 0x0);

    token = MedToken(_tokenAddress);
  }

  function setCap(uint256 _cap) onlyOwner public {
    require(_cap > 0);

    cap = _cap;
  }

  function releaseLock(address beneficiary) onlyOwner public {
    require(locks[beneficiary] > 0);

    require(token.transfer(beneficiary, locks[beneficiary]));
    locks[beneficiary] = 0;
  }

  function withdrawLock(address originalSender) onlyOwner public {
    require(locks[originalSender] > 0);

    require(token.transfer(owner, locks[originalSender]));
    locks[originalSender] = 0;
  }

  function () payable {
    buyTokens(msg.sender);
  }

  function buyTokens(address beneficiary) whenNotPaused public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.mul(rate);

    weiRaised = weiRaised.add(weiAmount);

    token.mint(this, tokens);
    locks[msg.sender] = locks[msg.sender] + tokens;
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  function handOverTokenOwnership() onlyOwner public {
    token.transferOwnership(owner);
  }
}
