pragma solidity ^0.4.11;


import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';
import "zeppelin-solidity/contracts/token/SafeERC20.sol";
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * @title TokenLock
 * @dev TokenLock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
 contract TokenLock {
   using SafeERC20 for ERC20Basic;

   // ERC20 basic token contract being held
   ERC20Basic public token;

   // beneficiary of tokens after they are released
   address public beneficiary;

   address public owner;

   modifier onlyOwner() {
     require(msg.sender == owner);
     _;
   }

   function TokenLock(ERC20Basic _token, address _owner, address _beneficiary) {
     token = _token;
     beneficiary = _beneficiary;
     owner = _owner;
   }

   function release() onlyOwner public {
     uint256 amount = token.balanceOf(this);
     require(amount > 0);

     token.safeTransfer(beneficiary, amount);
   }

   function withdraw() onlyOwner public {
     uint256 amount = token.balanceOf(this);
     require(amount > 0);

     token.safeTransfer(owner, amount);
   }
 }
