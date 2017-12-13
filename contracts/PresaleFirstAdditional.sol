pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/token/SafeERC20.sol';
import './MedToken.sol';
import './PresaleFirst.sol';
import './TokenLock.sol';

contract PresaleFirstAddtional is Pausable {
  using SafeMath for uint256;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  PresaleFirst public presale;
  address public fundReceiver;
  address public tokenOwner;

  function PresaleFirstAddtional(
      address _presaleAddress,
      address _fundReceiver,
      address _tokenOwner)
  {
    presale = PresaleFirst(_presaleAddress);
    fundReceiver = _fundReceiver;
    tokenOwner = _tokenOwner;
  }

  function validPurchase() internal constant returns (bool) {
    bool additional = presale.locks(msg.sender) != 0x0;
    bool withinPeriod = now >= presale.startTime() && now <= presale.endTime();
    bool nonZeroPurchase = msg.value != 0;
    bool withinCap = (presale.weiRaised() + msg.value) * presale.rate() <= presale.cap();

    return additional && withinPeriod && nonZeroPurchase && withinCap && !presale.paused();
  }

  function forwardFunds() internal {
    fundReceiver.transfer(msg.value);
  }

  function () payable {
    buyMore(msg.sender);
  }

  function buyMore(address beneficiary) whenNotPaused public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.mul(presale.rate());

    TokenLock lock = TokenLock(presale.locks(beneficiary));
    assert(MedToken(presale.token()).transferFrom(tokenOwner, lock, tokens));

    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }
}
