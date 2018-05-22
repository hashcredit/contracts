// var StandardToken = artifacts.require("./lib/StandardToken.sol");
// var Token = artifacts.require("./lib/Token.sol");
var DMToken = artifacts.require("./DMToken.sol");

var accounts = web3.eth.accounts

module.exports = function(deployer) {
  // deployer.deploy(Token);
  // deployer.deploy(StandardToken);
  deployer.deploy(DMToken);

};
