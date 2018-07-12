var WarriorBase = artifacts.require('./WarriorBase.sol')
var LordBase = artifacts.require('./LordBase.sol')
var Random = artifacts.require('./Random.sol')
var SafeMath = artifacts.require('./SafeMath.sol')
var ERC721 = artifacts.require('./erc721.sol')
var Database = artifacts.require('./Database.sol')
module.exports = function(deployer) {
  
  deployer.deploy(SafeMath)

  deployer.deploy(Random)
    .then(() => Random.deployed())
      .then(Random => deployer.deploy(Database,{gas: 4712388}))
        .then(() => Database.deployed())
          .then(Database => deployer.deploy(WarriorBase, Random.address, Database.address, {gas: 4712388}))
            .then(() => WarriorBase.deployed())
              .then(WarriorBase => deployer.deploy(LordBase, WarriorBase.address, Database.address, {gas: 5000000}))
              
};
