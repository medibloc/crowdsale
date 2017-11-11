var PresaleFirst = artifacts.require("./PresaleFirst.sol");
var ProxyWallet = artifacts.require("./ProxyWallet.sol");

module.exports = function(deployer) {
  const startTime = web3.eth.getBlock(web3.eth.blockNumber).timestamp + 1
  const endTime = startTime + (86400 * 20)
  const rate = new web3.BigNumber(2200)
  const wallet = web3.eth.accounts[0]
  const cap = 1000000000
  const minimum = 3000

  console.log(startTime)
  console.log(endTime)

  deployer.deploy(PresaleFirst, startTime, endTime, rate, wallet, cap, minimum)
    .then(function() {
      return deployer.deploy(ProxyWallet, PresaleFirst.address)
    })
};
