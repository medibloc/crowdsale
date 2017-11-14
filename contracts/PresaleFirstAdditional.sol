pragma solidity ^0.4.11;

import './Pausable.sol';
import './ERC20Basic.sol';
import './SafeERC20.sol';
import './MedToken.sol';
import './PresaleFirst';
import './TokenLock';

contract PresaleFirstAddtional is Pausable {
  using SafeMath for uint256;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  PresaleFirst public presale;

  function PresaleFirstAddtional(address _presaleAddress) {
    presale = PresaleFirst(_presaleAddress);
  }

  function validPurchase() internal constant returns (bool) {
    bool additional = presale.locks(msg.sender) != 0x0;
    bool withinPeriod = now >= presale.startTime() && now <= presale.endTime();
    bool nonZeroPurchase = msg.value != 0;
    bool withinCap = (presale.weiRaised() + msg.value) * presale.rate() <= presale.cap();

    return additional && withinPeriod && nonZeroPurchase;
  }

  function () payable {
    buyMore(msg.sender);
  }

  function buyMore(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.mul(presale.rate());

    TokenLock lock = TokenLock(presale.locks(beneficiary));
    assert(MedToken(presale.token()).transfer(lock, tokens));

    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
  }
}
