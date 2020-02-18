const HDWallet = require('truffle-hdwallet-provider');
const infuraKey = "2b2ae9c6e90f4729bb76fc96e7aded8a";

const fs = require('fs');

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
    development2: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 9545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    rinkeby: {
      provider: () => new HDWallet(fs.readFileSync(".secret").toString().trim(),
                                   `https://rinkeby.infura.io/v3/${infuraKey}`),
      network_id: 4         // rinkeby's id
    }
  },
  compilers: {
    version: "0.4.24"
  }
};
