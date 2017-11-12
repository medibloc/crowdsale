pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';

contract MedToken is MintableToken {
  event Inflation(address to, uint256 indexed amount);
  event InflationStarted();
  event InflationRateReset(uint256 indexed reductionMilliPercentage);

  address public pool;

  uint256 public inflationMilliPercentage;
  bool public isInflating = false;
  bool public inflationFinished = false;
  uint256 public timestampAnnual;
  uint256 public timestampInflation;
  uint256 public stoppableTime;
  uint256 public annualInflationRest;
  uint256 public dailyInflation;

  string public name = "MED TOKEN";
  string public symbol = "MED";
  uint256 public decimals = 8;

  function setInitialInflation(uint256 _inflationMilliPercentage) onlyOwner public {
    require(!isInflating);

    inflationMilliPercentage = _inflationMilliPercentage;
  }

  function setAnnualInflation(uint256 reductionMilliPercentage) onlyOwner public {
    require(!inflationFinished);
    require(reductionMilliPercentage > 0 && reductionMilliPercentage <= 100000);
    if (isInflating) {
      require(now > timestampAnnual + 31536000); // 1 year
    }

    if (annualInflationRest > 0 && isInflating) {
      totalSupply = totalSupply.add(annualInflationRest);
      balances[pool] = balances[pool].add(annualInflationRest);
    }
    inflationMilliPercentage = inflationMilliPercentage * reductionMilliPercentage / 100000;
    annualInflationRest = totalSupply * inflationMilliPercentage / 100000;
    dailyInflation = annualInflationRest / 365;
    InflationRateReset(reductionMilliPercentage);

    timestampAnnual = now;
  }

  function startInflation(address _pool, uint256 _stoppableTime) onlyOwner public {
    require(!inflationFinished);
    require(!isInflating);
    require(annualInflationRest > 0);

    isInflating = true;
    pool = _pool;
    timestampInflation = now;
    timestampAnnual = now;
    stoppableTime = _stoppableTime;

    InflationStarted();
  }

  function stopInflation() onlyOwner public {
    require(isInflating);
    require(now > stoppableTime);

    inflationFinished = true;
    isInflating = false;
  }

  function inflate() onlyOwner public {
    require(isInflating);
    require(timestampInflation < now);
    require(annualInflationRest > 0);

    uint256 daysPassed = (now - timestampInflation) / 86400;
    uint256 increase = daysPassed * dailyInflation;
    if (increase > annualInflationRest) {
      increase = annualInflationRest;
    }

    totalSupply = totalSupply.add(increase);
    balances[pool] = balances[pool].add(increase);
    annualInflationRest = annualInflationRest - increase;
    timestampInflation = now;

    Inflation(pool, increase);
  }
}
