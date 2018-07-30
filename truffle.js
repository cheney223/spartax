let secrets = require('./secret');
const WalletProvider = require("truffle-wallet-provider");
const Wallet = require('ethereumjs-wallet');
let mainNetPrivateKey = new Buffer(secrets.mainnetPK, "hex");
let mainNetWallet = Wallet.fromPrivateKey(mainNetPrivateKey);
let mainNetProvider = new WalletProvider(mainNetWallet, "https://mainnet.infura.io/");
let ropstenPrivateKey = new Buffer(secrets.ropstenPK, "hex");
let ropstenWallet = Wallet.fromPrivateKey(ropstenPrivateKey);
let ropstenProvider = new WalletProvider(ropstenWallet,  "https://ropsten.infura.io/");

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      gas: 4712388,
      network_id: "*" // Match any network id
    },
    ropsten: {
      provider: ropstenProvider,
      network_id: 3,
      gas: 4465030
    }
  }
};
