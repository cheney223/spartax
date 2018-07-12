import contract from 'truffle-contract'
import WarriorBaseContract from '@contracts/WarriorBase.json'

const WarriorBase = {

    contract: null,
  
    instance: null,
  
    init: function () {
      let self = this
  
      return new Promise(function (resolve, reject) {
        self.contract = contract(WarriorBaseContract)
        self.contract.setProvider(window.web3.currentProvider)

        self.contract.deployed().then(instance => {
          self.instance = instance
          
          resolve()
        }).catch(err => {
          reject(err)
        })
      })
    },
    
    getCurAccount: function() {
      return window.web3.eth.accounts[0]
    },

    consequence:function(winnerId, loserId, winnerAddr, loserAddr) {
      let self = this
      
      return new Promise(function (resolve, reject) {
        console.log('web3 winnerId = ' + winnerId)
        console.log('web3 loserId = '+loserId)
        console.log('web3 winnerAddr = ' + winnerAddr)
        console.log('web3 loserAddr = ' + loserAddr)
        self.instance.consequence.sendTransaction(
          winnerId, 
          loserId, 
          winnerAddr, 
          loserAddr,
          {from: window.web3.eth.accounts[0],
           gas:3000000}
        ).then(consequence => {
          var consequenceEvent = self.instance.Consequence({winnerAddr:winnerAddr})
          consequenceEvent.watch(function(err,result){
            console.log('val to tranfer : ' + Number(result.args.valToTransfer))
          })
          resolve(consequence)
        }).catch(err => {
          reject(err)
        })
      })
    },

      
    getBalance:function() {
      let self = this

      return new Promise(function (resolve, reject) {
        self.instance.getBalance.call(
          {from: window.web3.eth.accounts[0]}
        ).then(balance => {
          resolve(window.web3.fromWei(balance,'ether'))
        }).catch(err => {
          reject(err)
        })
      })
    },

    getToken: function( tokenId ) {
      let self = this
      return new Promise(function(resolve, reject) {
        self.instance.getToken.call(
          tokenId,
          {from: window.web3.eth.accounts[0]}
        ).then(getToken => {
          console.log(tokenId + ' : js token = ' + getToken)
          resolve(getToken)
        }).catch(err => {
          console.log(tokenId + ' : js error = ' + err)
          reject(err)
        })
      })
    },

    getEnemyTokens: function( owner ){
      let self = this
      return new Promise(function(resolve,reject){
        self.instance.getEnemyTokens.call(
          window.web3.eth.accounts[0]
        ).then(getEnemyTokens => {
          resolve(getEnemyTokens)
        }).catch(err => {
          reject(err)
        })
      })
    },

    getOwnTokens: function( owner ){
      let self = this
      return new Promise(function(resolve,reject){
        self.instance.getOwnTokens.call(
          window.web3.eth.accounts[0]
        ).then(getOwnTokens => {
          resolve(getOwnTokens)
        }).catch(err => {
          reject(err)
        })
      })
    },

    getTokenOwner: function( id ){
      let self = this
      return new Promise(function(resolve, reject) {
        self.instance.getTokenOwner.call(
          id,
          {from: window.web3.eth.accounts[0]}
        ).then(getTokenOwner => {
          resolve(getTokenOwner)
        }).catch(err => {
          reject(err)
        })
      })
    },

    getTokenNum: function() {
      let self = this
      return new Promise(function(resolve,reject) {
        self.instance.getTokenNum.call(
          {from: window.web3.eth.accounts[0]}
        ).then(result => {
          resolve(result)
        }).catch(err => {
          reject(err)
        })
      })
    },

    adoptLvOne: function() {
      let self = this
      return new Promise(function(resolve, reject) {
        self.instance.adoptLvOne.sendTransaction(
          {from: window.web3.eth.accounts[0], value: window.web3.toWei('0.01', 'ether')}
        ).then(adoptLvOne => {
          resolve(adoptLvOne)
        }).catch(err => {
          reject(err)
        })
      })
    },

    adoptLvTwo: function() {
      let self = this
      return new Promise(function(resolve, reject) {
        self.instance.adoptLvTwo.sendTransaction(
        {from: window.web3.eth.accounts[0], value: window.web3.toWei('0.05', 'ether')}
        ).then(adoptLvTwo => {
          resolve(adoptLvTwo)
        }).catch(err => {
          reject(err)
        })
      })
    },

    adoptLvThree: function() {
      let self = this
      return new Promise(function(resolve, reject) {
        self.instance.adoptLvThree.sendTransaction(
        {from: window.web3.eth.accounts[0], value: window.web3.toWei('0.1', 'ether')}
        ).then(adoptLvThree => {
          resolve(adoptLvThree)
        }).catch(err => {
          reject(err)
        })
      })
    },

    adoptLvFour: function() {
      let self = this
      return new Promise(function(resolve, reject) {
        self.instance.adoptLvFour.sendTransaction(
        {from: window.web3.eth.accounts[0], value: window.web3.toWei('0.5', 'ether')}
        ).then(adoptLvFour => {
          resolve(adoptLvFour)
        }).catch(err => {
          reject(err)
        })
      })
    },

    killWarrior:function(_id) {
      let self = this
      return new Promise(function(resolve,reject) {
        console.log('warrior Id to kill : '+_id)
        self.instance.killWarrior.sendTransaction(
          _id,
          {from: window.web3.eth.accounts[0],
          gas: 50000000}
        ).then(killWarrior => {
          resolve(killWarrior)
        }).catch(err => {
          reject(err)
        })
      })
    }
    
  
  }
  
  export default WarriorBase
  