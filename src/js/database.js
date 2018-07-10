import contract from 'truffle-contract'
import DatabaseContractt from '@contracts/Database.json'

const Database = {

    contract: null,
  
    instance: null,
  
    init: function () {
      let self = this
  
      return new Promise(function (resolve, reject) {
        self.contract = contract(DatabaseContractt)
        self.contract.setProvider(window.web3.currentProvider)
        self.contract.deployed().then(instance => {
          self.instance = instance
          resolve()
        }).catch(err => {
          reject(err)
        })
      })
    },


    getAccountEth: function() {
      let self = this
      
      return new Promise(function (resolve, reject) {
        self.instance.getAccountEth.call(
          window.web3.eth.accounts[0],
          {from: window.web3.eth.accounts[0]}
        ).then(accountEth => {
          resolve(accountEth)
        }).catch(err => {
            reject(err)
        })
      }) 
    },

}
  
  export default Database