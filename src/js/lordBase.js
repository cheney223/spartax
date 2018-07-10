import contract from 'truffle-contract'
import LordBaseContract from '@contracts/LordBase.json'

const LordBase = {

    contract: null,
  
    instance: null,
  
    init: function () {
      let self = this
  
      return new Promise(function (resolve, reject) {
        self.contract = contract(LordBaseContract)
        self.contract.setProvider(window.web3.currentProvider)
        self.contract.deployed().then(instance => {
          self.instance = instance
          resolve()
        }).catch(err => {
          reject(err)
        })
      })
    },
    
    battle: function(attackId, defenceId) {
      let self = this
      return new Promise(function (resolve, reject) {
        console.log('attackId : '+ attackId)
        console.log('defenceId : '+ defenceId)
        console.log('from address : '+ window.web3.eth.accounts[0])
        self.instance.battle.sendTransaction(
          attackId,
          defenceId,
          {from: window.web3.eth.accounts[0]}).then(battle => {
            // var battleEvent = self.instance.Battle({attackId: attackId})
            // battleEvent.watch(function(err, result){
            //   if (err) {
            //     console.log(err)
            //   }
            //   console.log('battle consequence : ' + Number(result.args.battleConsequence))
            //   resolve(battle)
            // })
            resolve(battle)
          }).catch(err => {
            reject(err)
            console.log('err = '+ err)
          })
      })
    },
}
  
export default LordBase
  