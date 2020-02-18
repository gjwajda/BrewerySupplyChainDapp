App = {
    web3Inst: null,
    web3Provider: null,
    contracts: {},
    metamaskAccountID: "0x0000000000000000000000000000000000000000",

    init: async () => {
        /// Setup access to blockchain
        return await App.initWeb3();
    },

    initWeb3: async () => {
        /// Find or Inject Web3 Provider
        /// Modern dapp browsers...
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            try {
                // Request account access
                await window.ethereum.enable();
            } catch (error) {
                // User denied account access...
                console.error("User denied account access")
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        }
        // If no injected web3 instance is detected, fall back to Ganache
        else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        }

        App.getMetaskAccountID();

        return App.initSupplyChain();
    },

    getMetaskAccountID: () => {
        if (!App.web3Inst) {
            App.web3Inst = new Web3(App.web3Provider);
        }

        // Retrieving accounts
        App.web3Inst.eth.getAccounts((err, res) => {
            if (err) {
                console.log('Error:', err);
                return;
            }
            console.log('getMetaskID:', res);
            App.metamaskAccountID = res[0];
        })
    },

    initSupplyChain: () => {
        /// Source the truffle compiled smart contracts
        let jsonSupplyChain = '../../build/contracts/SupplyChain.json';

        /// JSONfy the smart contracts
        $.getJSON(jsonSupplyChain, (data) => {
            console.log('data', data);
            App.contracts.SupplyChain = TruffleContract(data);
            App.contracts.SupplyChain.setProvider(App.web3Provider);

            App.fetchEvents();
        });

        return App.bindEvents();
    },

    bindEvents: () => {
        $("#btn-fetchGrainID").on('click', App.fetchGrainID);
        $("#btn-fetchGrainMeta").on('click', App.fetchGrainMeta);
        $("#btn-fetchBeerID").on('click', App.fetchBeerID);
        $("#btn-fetchBeerMeta").on('click', App.fetchBeerMeta);
        $("#btn-stockGrain").on('click', App.stockGrain);
        $("#btn-setGrainForSale").on('click', App.setGrainForSale);
        $("#btn-setGrainSold").on('click', App.setGrainSold);
        $("#btn-harvestGrain").on('click', App.harvestGrain);
        $("#btn-processGrain").on('click', App.processGrain);
        $("#btn-packageGrain").on('click', App.packageGrain);
        $("#btn-shipGrain").on('click', App.shipGrain);
        $("#btn-stockBeer").on('click', App.stockBeer);
        $("#btn-setBeerForSale").on('click', App.setBeerForSale);
        $("#btn-setBeerSold").on('click', App.setBeerSold);
        $("#btn-orderGrain").on('click', App.orderGrain);
        $("#btn-receiveGrain").on('click', App.receiveGrain);
        $("#btn-brewBeer").on('click', App.brewBeer);
        $("#btn-packageBeer").on('click', App.packageBeer);
        $("#btn-distributorShipBeer").on('click', App.distributorShipBeer);
        $("#btn-distributorOrderBeer").on('click', App.distributorOrderBeer);
        $("#btn-distributorReceiveBeer").on('click', App.distributorReceiveBeer);
        $("#btn-retailerShipBeer").on('click', App.retailerShipBeer);
        $("#btn-retailerOrderBeer").on('click', App.retailerOrderBeer);
        $("#btn-retailerReceiveBeer").on('click', App.retailerReceiveBeer);
        $("#btn-purchaseBeer").on('click', App.purchaseBeer);
    },

    fetchGrainID: async (event) => {
        event.preventDefault();
        console.log("fetchGrainID");

        let upc = $("[id=fetchGrain][name=upc]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.fetchGrainID(
                upc,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('fetchGrainID',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    fetchGrainMeta: async (event) => {
        event.preventDefault();
        console.log("fetchGrainMeta");

        let upc = $("[id=fetchGrain][name=upc]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.fetchGrainMeta(
                upc,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('fetchGrainMeta',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    fetchBeerID: async (event) => {
        event.preventDefault();
        console.log("fetchBeerID");

        let upc = $("[id=fetchBeer][name=upc]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.fetchBeerID(
                upc,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('fetchBeerID',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    fetchBeerMeta: async (event) => {
        event.preventDefault();
        console.log("fetchBeerMeta");

        let upc = $("[id=fetchBeer][name=upc]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.fetchBeerMeta(
                upc,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('fetchBeerMeta',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },

    // Farmer actions

    stockGrain: async (event) => {
        event.preventDefault();
        console.log("stockGrain");

        let price     = web3.toWei($("[id=farmer][name=price]").val(), "ether");
        let itemName  = $("[id=farmer][name=itemName]").val();
        let itemNotes = $("[id=farmer][name=itemNotes]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.stockGrain(
                price,
                itemName,
                itemNotes,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('stockGrain',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    setGrainForSale: async (event) => {
        event.preventDefault();
        console.log("setGrainForSale");

        let grainUPC  = $("[id=farmer][name=grainUPC]").val();
        let isForSale = $("[id=farmer][name=isForSale]").is(":checked");

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.setGrainForSale(
                grainUPC,
                isForSale,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('setGrainForSale',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    setGrainSold: async (event) => {
        event.preventDefault();
        console.log("setGrainSold");

        let grainUPC = $("[id=farmer][name=grainUPC]").val();
        let isSold   = $("[id=farmer][name=isSold]").is(":checked");

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.setGrainSold(
                grainUPC,
                isSold,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('setGrainSold',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    harvestGrain: async (event) => {
        event.preventDefault();
        console.log("harvestGrain");

        let beerUPC = $("[id=farmer][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.harvestGrain(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('harvestGrain',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    processGrain: async (event) => {
        event.preventDefault();
        console.log("processGrain");

        let beerUPC = $("[id=farmer][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.processGrain(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('processGrain',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    packageGrain: async (event) => {
        event.preventDefault();
        console.log("packageGrain");

        let beerUPC = $("[id=farmer][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.packageGrain(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('packageGrain',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    shipGrain: async (event) => {
        event.preventDefault();
        console.log("shipGrain");

        let beerUPC = $("[id=farmer][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.shipGrain(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('shipGrain',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },

    // Brewer actions

    stockBeer: async (event) => {
        event.preventDefault();
        console.log("stockBeer");

        let price     = web3.toWei($("[id=brewer][name=price]").val(), "ether");
        let grainUPC  = $("[id=brewer][name=grainUPC]").val();
        let itemName  = $("[id=brewer][name=itemName]").val();
        let itemNotes = $("[id=brewer][name=itemNotes]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.stockBeer(
                price,
                grainUPC,
                itemName,
                itemNotes,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('stockBeer',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    setBeerForSale: async (event) => {
        event.preventDefault();
        console.log("setBeerForSale");

        let beerUPC   = $("[id=brewer][name=beerUPC]").val();
        let isForSale = $("[id=brewer][name=isForSale]").is(":checked");

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.setBeerForSale(
                beerUPC,
                isForSale,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('setBeerForSale',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    setBeerSold: async (event) => {
        event.preventDefault();
        console.log("setBeerSold");

        let beerUPC = $("[id=brewer][name=beerUPC]").val();
        let isSold  = $("[id=brewer][name=isSold]").is(":checked");

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.setBeerSold(
                beerUPC,
                isSold,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('setBeerSold',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    orderGrain: async (event) => {
        event.preventDefault();
        console.log("orderGrain");

        let grainUPC = $("[id=brewer][name=grainUPC]").val();
        let beerUPC  = $("[id=brewer][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.fetchGrainMeta(
                grainUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            let cost = result[2].toNumber();
            App.contracts.SupplyChain.deployed()
            .then((instance) => {
                return instance.orderGrain(
                    grainUPC,
                    beerUPC,
                    {from: App.metamaskAccountID, value: cost}
                );
            }).then((result) => {
                $("#ftc-item").text(result);
                console.log('orderGrain',result);
            }).catch((err) => {
                console.log(err.message);
            });
        }).catch((err) => {
            console.log(err.message);
        });
    },
    receiveGrain: async (event) => {
        event.preventDefault();
        console.log("receiveGrain");

        let beerUPC = $("[id=brewer][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.receiveGrain(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('receiveGrain',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    brewBeer: async (event) => {
        event.preventDefault();
        console.log("brewBeer");

        let beerUPC = $("[id=brewer][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.brewBeer(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('brewBeer',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    packageBeer: async (event) => {
        event.preventDefault();
        console.log("packageBeer");

        let beerUPC = $("[id=brewer][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.packageBeer(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('packageBeer',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    distributorShipBeer: async (event) => {
        event.preventDefault();
        console.log("distributorShipBeer");

        let beerUPC = $("[id=brewer][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.distributorShipBeer(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('distributorShipBeer',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },

    // Distributor actions

    distributorOrderBeer: async (event) => {
        event.preventDefault();
        console.log("distributorOrderBeer");

        let beerUPC = $("[id=distributor][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.fetchBeerMeta(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            let cost = result[3].toNumber();
            App.contracts.SupplyChain.deployed()
            .then((instance) => {
                return instance.distributorOrderBeer(
                    beerUPC,
                    {from: App.metamaskAccountID, value: cost}
                );
            }).then((result) => {
                $("#ftc-item").text(result);
                console.log('distributorOrderBeer',result);
            }).catch((err) => {
                console.log(err.message);
            });
        }).catch((err) => {
            console.log(err.message);
        });
    },
    distributorReceiveBeer: async (event) => {
        event.preventDefault();
        console.log("distributorReceiveBeer");

        let beerUPC = $("[id=distributor][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.distributorReceiveBeer(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('distributorReceiveBeer',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },
    retailerShipBeer: async (event) => {
        event.preventDefault();
        console.log("retailerShipBeer");

        let beerUPC = $("[id=distributor][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.retailerShipBeer(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('retailerShipBeer',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },

    // Retailer actions

    retailerOrderBeer: async (event) => {
        event.preventDefault();
        console.log("retailerOrderBeer");

        let beerUPC = $("[id=retailer][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.fetchBeerMeta(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            let cost = result[3].toNumber();
            App.contracts.SupplyChain.deployed()
            .then((instance) => {
                return instance.retailerOrderBeer(
                    beerUPC,
                    {from: App.metamaskAccountID, value: cost}
                );
            }).then((result) => {
                $("#ftc-item").text(result);
                console.log('retailerOrderBeer',result);
            }).catch((err) => {
                console.log(err.message);
            });
        }).catch((err) => {
            console.log(err.message);
        });
    },
    retailerReceiveBeer: async (event) => {
        event.preventDefault();
        console.log("retailerReceiveBeer");

        let beerUPC = $("[id=retailer][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.retailerReceiveBeer(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            $("#ftc-item").text(result);
            console.log('retailerReceiveBeer',result);
        }).catch((err) => {
            console.log(err.message);
        });
    },

    // Customer actions

    purchaseBeer: async (event) => {
        event.preventDefault();
        console.log("purchaseBeer");

        let beerUPC = $("[id=customer][name=beerUPC]").val();

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            return instance.fetchBeerMeta(
                beerUPC,
                {from: App.metamaskAccountID}
            );
        }).then((result) => {
            let cost = result[3].toNumber();
            App.contracts.SupplyChain.deployed()
            .then((instance) => {
                return instance.purchaseBeer(
                    beerUPC,
                    {from: App.metamaskAccountID, value: cost}
                );
            }).then((result) => {
                $("#ftc-item").text(result);
                console.log('purchaseBeer',result);
            }).catch((err) => {
                console.log(err.message);
            });
        }).catch((err) => {
            console.log(err.message);
        });
    },

    fetchEvents: () => {
        if (typeof App.contracts.SupplyChain.currentProvider.sendAsync !== "function") {
            App.contracts.SupplyChain.currentProvider.sendAsync = () => {
                return App.contracts.SupplyChain.currentProvider.send.apply(
                    App.contracts.SupplyChain.currentProvider,
                    arguments
                );
            };
        }

        App.contracts.SupplyChain.deployed()
        .then((instance) => {
            let events = instance.allEvents((err, log) => {
                if (!err)
                    $("#ftc-events").append('<li>' + log.event + ' - ' + log.transactionHash + '</li>');
            });
        }).catch((err) => {
            console.log(err.message);
        });
    }
};

$(() => {
    $(window).load(() => {
        App.init();
    });
});
