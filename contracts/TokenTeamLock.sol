pragma solidity ^0.4.11;


import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/ownership/Pausable.sol';
import 'zeppelin-solidity/contracts/token/SafeERC20.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract TokenTeamLock is Pausable {
  using SafeERC20 for ERC20Basic;
  using SafeMath for uint256;

  ERC20Basic public token;
  address public beneficiary;
  uint256 public firstReleaseTime;
  uint256 public quarterYear = 7884000;

  uint256 private maxSplitNum = 8;

  uint256 public firstAmount;
  uint256 public splitAmount;

  uint256 public alreadySent = 0;

  bool public initFlag = false;

  function TokenTeamLock(
      ERC20Basic _token,
      address _beneficiary,
      uint256 _firstReleaseTime
    )
  {
    require(_firstReleaseTime > now);
    token = _token;
    beneficiary = _beneficiary;
    firstReleaseTime = _firstReleaseTime;
    owner = msg.sender;
  }

  function init() onlyOwner public {
    require(!initFlag);

    uint256 amount = token.balanceOf(this);
    require(amount > 0);

    firstAmount = amount / 3;
    splitAmount = amount / 12;
    alreadySent = 0;

    initFlag = true;
  }

  function widthdraw() onlyOwner public {
    require(token.balanceOf(this) > 0);

    token.safeTransfer(owner, token.balanceOf(this));
  }

  function claim() public {
    require(msg.sender == beneficiary);
    release();
  }

  function send() onlyOwner public {
    release();
  }

  function resetBeneficiary(address _beneficiary) onlyOwner public {
    beneficiary = _beneficiary;
  }

  function release() whenNotPaused {
    require(now >= firstReleaseTime);
    require(initFlag);

    uint256 amountLeft = token.balanceOf(this);
    require(amountLeft > 0);

    uint256 amount = 0;

    uint256 releasableSplitNum = (now - firstReleaseTime) / quarterYear;
    if (releasableSplitNum >= maxSplitNum) {
      amount = amountLeft;
    } else {
      uint256 releasableAmount = firstAmount + releasableSplitNum * splitAmount;

      amount = releasableAmount - alreadySent;
    }

    require(amountLeft >= amount);
    require(amount > 0);

    token.safeTransfer(beneficiary, amount);
    alreadySent = alreadySent + amount;
  }
}
