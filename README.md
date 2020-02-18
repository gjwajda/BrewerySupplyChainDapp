# BrewerySupplyChainDapp

Part of the Udacity Blockchain course. This is a prototype supply chain
decentralized application (dapp) for breweries that allows someone to manage
and audit blockchain product ownership as the product is transferred down
the supply chain.

------------------------------------------------------------------------------

Rinkeby Contract Address needed.

Required versions:

npm: v6.4.1

solc: v0.4.25

web3: v1.2.1

truffle: v4.1.15

Testing Networks as seen in truffle-config.js
development: 127.0.0.1:8545
development2: 127.0.0.1:9545

Examples:

Metamask: connect to http://127.0.0.1:8545
Launch: ganache-cli -m "<mnemonic>"
Migrate: truffle migrate --network development
Test: truffle test --network development
UI: npm run dev

Metamask: connect to http://127.0.0.1:9545
Launch: truffle develop
Migrate: truffle migrate --network development2
Test: truffle test --network development2
UI: npm run dev
