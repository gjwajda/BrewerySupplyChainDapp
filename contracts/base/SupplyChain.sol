pragma solidity ^0.4.24;

import "../core/Ownable.sol";
import "../accesscontrol/FarmerRole.sol";
import "../accesscontrol/BrewerRole.sol";
import "../accesscontrol/DistributorRole.sol";
import "../accesscontrol/RetailerRole.sol";
import "../accesscontrol/CustomerRole.sol";

/*
 * ------------------------------------------------------------------------
 *
 * SupplyChain -
 *
 * @dev  SupplyChain contract.
 *
 * ------------------------------------------------------------------------
 */

contract SupplyChain is Ownable,
                        FarmerRole,
                        BrewerRole,
                        DistributorRole,
                        RetailerRole,
                        CustomerRole
{

   uint256 _grainUPCCount;    // total Universal Product Codes to grain
   uint256 _grainSKUCount;    // total Stock Keeping Units to grain

   uint256 _beerUPCCount;     // total Universal Product Codes to beer
   uint256 _beerSKUCount;     // total Stock Keeping Units to beer

   mapping (uint256 => Grain) _grainInventory;  // UPC -> Grain
   mapping (uint256 => Beer) _beerInventory;    // UPC -> Beer

   enum State
   {
      Start,                     // 0
      DistributorBeerOrdered,    // 1
      GrainOrdered,              // 2
      GrainHarvested,            // 3
      GrainProcessed,            // 4
      GrainPackaged,             // 5
      GrainShipped,              // 6
      GrainReceived,             // 7
      BeerBrewed,                // 8
      BeerPackaged,              // 9
      DistributorBeerShipped,    // 10
      DistributorBeerReceived,   // 11
      RetailerBeerOrdered,       // 12
      RetailerBeerShipped,       // 13
      RetailerBeerReceived,      // 14
      BeerPurchased              // 15
   }

   State constant kDefaultState = State.Start;

   /* Grain item used by the beer */
   struct Grain
   {
      uint256 UPC;            // uinversal product code
      uint256 SKU;            // stock keeping unit
      uint256 price;          // price of grain

      bool isForSale;         // if grain is for sale
      bool isSold;            // if grain sold

      address farmerID;       // address of farmer
      address consumerID;     // address of consumer

      string itemName;        // name of grain
      string itemNotes;       // additional notes
   }

   /* Beer item */
   struct Beer
   {
      uint256 UPC;            // uinversal product code
      uint256 SKU;            // stock keeping unit
      uint256 grainUPC;       // uinversal product code of grain
      uint256 price;          // price of beer

      State itemState;        // state

      bool isForSale;         // if beer is ready to be bought by distributors
      bool isSold;            // if beer is bought by distributors

      address brewerID;       // address of brewer
      address distributorID;  // address of distributor
      address retailerID;     // address of retailer
      address customerID;     // address of customer

      string itemName;        // name of beer
      string itemNotes;       // additional notes
   }

   event GrainStocked(uint256 grainUPC);
   event GrainSetForSale(uint256 grainUPC, bool forSale);
   event GrainSetSold(uint256 grainUPC, bool isSold);
   event BeerStocked(uint256 beerUPC);
   event BeerSetForSale(uint256 beerUPC, bool forSale);
   event BeerSetSold(uint256 beerUPC, bool isSold);
   event DistributorBeerOrdered(uint256 beerUPC);
   event GrainOrdered(uint256 grainUPC, uint256 beerUPC);
   event GrainHarvested(uint256 beerUPC);
   event GrainProcessed(uint256 beerUPC);
   event GrainPackaged(uint256 beerUPC);
   event GrainShipped(uint256 beerUPC);
   event GrainReceived(uint256 beerUPC);
   event BeerBrewed(uint256 beerUPC);
   event BeerPackaged(uint256 beerUPC);
   event DistributorBeerShipped(uint256 beerUPC);
   event DistributorBeerReceived(uint256 beerUPC);
   event RetailerBeerOrdered(uint256 beerUPC);
   event RetailerBeerShipped(uint256 beerUPC);
   event RetailerBeerReceived(uint256 beerUPC);
   event BeerPurchased(uint256 beerUPC);

   /*
    * ------------------------------------------------------------------------
    *
    * isGrainInStock() -
    *
    * @dev  Modifier that checks if grain is in stock.
    * @param upc - UPC of Grain item
    *
    * ------------------------------------------------------------------------
    */
   modifier isGrainInStock(uint256 upc)
   {
      require(_grainInventory[upc].UPC != 0);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isBeerInStock() -
    *
    * @dev  Modifier that checks if beer is in stock.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isBeerInStock(uint256 upc)
   {
      require(_beerInventory[upc].UPC != 0);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * paidEnoughForGrain() -
    *
    * @dev  Modifier that checks if paid amount for Grain is sufficient
    *       and refunds the remaining balance.
    * @param upc - UPC of Grain item
    *
    * ------------------------------------------------------------------------
    */
   modifier paidEnoughForGrain(uint256 upc)
   {
      uint256 price = _grainInventory[upc].price;
      require(msg.value >= price);
      _;
      uint256 amountToReturn = msg.value - price;
      _grainInventory[upc].consumerID.transfer(amountToReturn);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * paidEnoughForBeer() -
    *
    * @dev  Modifier that checks if paid amount for Beer is sufficient
    *       and refunds the remaining balance.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier paidEnoughForBeer(uint256 upc)
   {
      uint256 price = _beerInventory[upc].price;
      require(msg.value >= price);
      _;
      uint256 amountToReturn = msg.value - price;
      _beerInventory[upc].customerID.transfer(amountToReturn);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isGrainForSale() -
    *
    * @dev  Modifier that checks if grain is for sale.
    * @param upc - UPC of Grain item
    *
    * ------------------------------------------------------------------------
    */
   modifier isGrainForSale(uint256 upc)
   {
      require(_grainInventory[upc].isForSale == true);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isGrainSold() -
    *
    * @dev  Modifier that checks if grain has been sold.
    * @param upc - UPC of Grain item
    *
    * ------------------------------------------------------------------------
    */
   modifier isGrainSold(uint256 upc)
   {
      require(_grainInventory[upc].isSold == true);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isBeerForSale() -
    *
    * @dev  Modifier that checks if beer is for sale.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isBeerForSale(uint256 upc)
   {
      require(_beerInventory[upc].isForSale == true);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isBeerSold() -
    *
    * @dev  Modifier that checks if beer has been sold.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isBeerSold(uint256 upc)
   {
      require(_beerInventory[upc].isSold == true);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isBeerDefaultState() -
    *
    * @dev  Modifier that checks state to verify beer is in default state.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isBeerDefaultState(uint256 upc)
   {
      require(_beerInventory[upc].itemState == kDefaultState);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isBeerOrderedByDistributor() -
    *
    * @dev  Modifier that checks state to verify beer has been ordered by
    *       the distributor.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isBeerOrderedByDistributor(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.DistributorBeerOrdered);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isGrainOrdered() -
    *
    * @dev  Modifier that checks state to verify grain has been ordered.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isGrainOrdered(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.GrainOrdered);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isGrainHarvested() -
    *
    * @dev  Modifier that checks state to verify grain has been harvested.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isGrainHarvested(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.GrainHarvested);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isGrainProcessed() -
    *
    * @dev  Modifier that checks state to verify grain has been processed.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isGrainProcessed(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.GrainProcessed);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isGrainPackaged() -
    *
    * @dev  Modifier that checks state to verify grain has been packaged.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isGrainPackaged(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.GrainPackaged);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isGrainShipped() -
    *
    * @dev  Modifier that checks state to verify grain has been shipped.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isGrainShipped(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.GrainShipped);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isGrainReceived() -
    *
    * @dev  Modifier that checks state to verify grain has been received.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isGrainReceived(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.GrainReceived);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isBeerBrewed() -
    *
    * @dev  Modifier that checks state to verify beer has been brewed.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isBeerBrewed(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.BeerBrewed);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isBeerPackaged() -
    *
    * @dev  Modifier that checks state to verify beer has been packaged.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isBeerPackaged(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.BeerPackaged);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isShippedToDistributor() -
    *
    * @dev  Modifier that checks state to verify beer has been shipped to
    *       the distributor.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isShippedToDistributor(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.DistributorBeerShipped);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isReceivedAtDistributor() -
    *
    * @dev  Modifier that checks state to verify beer has been received at
    *       the distributor.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isReceivedAtDistributor(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.DistributorBeerReceived);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isBeerOrderedByRetailer() -
    *
    * @dev  Modifier that checks state to verify beer has been ordered by
    *       the retailer.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isBeerOrderedByRetailer(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.RetailerBeerOrdered);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isShippedToRetailer() -
    *
    * @dev  Modifier that checks state to verify beer has been shipped to
    *       the retailer.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isShippedToRetailer(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.RetailerBeerShipped);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isReceivedAtRetailer() -
    *
    * @dev  Modifier that checks state to verify beer has been received at
    *       the retailer.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   modifier isReceivedAtRetailer(uint256 upc)
   {
      require(_beerInventory[upc].itemState == State.RetailerBeerReceived);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * constructor() -
    *
    * ------------------------------------------------------------------------
    */
   constructor()
      public
   {
      _grainUPCCount = 0;
      _grainSKUCount = 0;
      _beerUPCCount = 0;
      _beerSKUCount = 0;
   }

   // Internal functions

   /*
    * ------------------------------------------------------------------------
    *
    * _setGrainForSale() -
    *
    * @dev  Internal func to change for sale status of grain.
    * @param upc - UPC of Grain item
    * @param forSale - Whether item is for sale or not
    *
    * ------------------------------------------------------------------------
    */
   function _setGrainForSale(uint256 upc,
                             bool forSale)
      internal
      isGrainInStock(upc)
   {
      require(_grainInventory[upc].isForSale != forSale);
      _grainInventory[upc].isForSale = forSale;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * _setGrainSold() -
    *
    * @dev  Internal func to change for sold status of grain.
    * @param upc - UPC of Grain item
    * @param isSold - Whether item is sold or not
    *
    * ------------------------------------------------------------------------
    */
   function _setGrainSold(uint256 upc,
                          bool isSold)
      internal
      isGrainInStock(upc)
   {
      require(_grainInventory[upc].isSold != isSold);
      _grainInventory[upc].isSold = isSold;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * _setBeerForSale() -
    *
    * @dev  Internal func to change for sale status of beer.
    * @param upc - UPC of Beer item
    * @param forSale - Whether item is for sale or not
    *
    * ------------------------------------------------------------------------
    */
   function _setBeerForSale(uint256 upc,
                            bool forSale)
      internal
      isBeerInStock(upc)
   {
      require(_beerInventory[upc].isForSale != forSale);
      _beerInventory[upc].isForSale = forSale;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * _setBeerSold() -
    *
    * @dev  Internal func to change for sold status of beer.
    * @param upc - UPC of Beer item
    * @param isSold - Whether item is sold or not
    *
    * ------------------------------------------------------------------------
    */
   function _setBeerSold(uint256 upc,
                         bool isSold)
      internal
      isBeerInStock(upc)
   {
      require(_beerInventory[upc].isSold != isSold);
      _beerInventory[upc].isSold = isSold;
   }

   // Public Functions

   /*
    * ------------------------------------------------------------------------
    *
    * stockGrain() -
    *
    * @dev  Add new stock of grain.
    * @param price - price of grain
    * @param itemName - name of grain
    * @param itemNotes - additional notes to be included with grain item
    *
    * ------------------------------------------------------------------------
    */
   function stockGrain(uint256 price,
                       string itemName,
                       string itemNotes)
      public
      isFarmer
   {
      uint256 grainUPC = ++_grainUPCCount;
      uint256 grainSKU = ++_grainSKUCount;

      _grainInventory[grainUPC].UPC        = grainUPC;
      _grainInventory[grainUPC].SKU        = grainSKU;
      _grainInventory[grainUPC].price      = price;

      _grainInventory[grainUPC].isForSale  = false;
      _grainInventory[grainUPC].isSold     = false;

      _grainInventory[grainUPC].farmerID   = msg.sender;
      _grainInventory[grainUPC].consumerID = address(0);

      _grainInventory[grainUPC].itemName   = itemName;
      _grainInventory[grainUPC].itemNotes  = itemNotes;

      emit GrainStocked(grainUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * setGrainForSale() -
    *
    * @dev  Change for sale status of grain.
    * @param grainUPC - UPC of Grain item
    * @param forSale - Whether item is for sale or not
    *
    * ------------------------------------------------------------------------
    */
   function setGrainForSale(uint256 grainUPC,
                            bool forSale)
      public
      isFarmer
   {
      _setGrainForSale(grainUPC, forSale);
      emit GrainSetForSale(grainUPC, forSale);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * setGrainSold() -
    *
    * @dev  Change for sold status of grain.
    * @param grainUPC - UPC of Grain item
    * @param isSold - Whether item is sold or not
    *
    * ------------------------------------------------------------------------
    */
   function setGrainSold(uint256 grainUPC,
                         bool isSold)
      public
      isFarmer
   {
      _setGrainSold(grainUPC, isSold);
      emit GrainSetSold(grainUPC, isSold);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * stockBeer() -
    *
    * @dev  Add new stock of beer.
    * @param price - price of beer
    * @param grainUPC - UPC of Grain item
    * @param itemName - name of beer
    * @param itemNotes - additional notes to be included with beer item
    *
    * ------------------------------------------------------------------------
    */
   function stockBeer(uint256 price,
                      uint256 grainUPC,
                      string itemName,
                      string itemNotes)
      public
      isBrewer
      isGrainInStock(grainUPC)
   {
      uint256 beerUPC = ++_beerUPCCount;
      uint256 beerSKU = ++_beerSKUCount;

      _beerInventory[beerUPC].UPC           = beerUPC;
      _beerInventory[beerUPC].SKU           = beerSKU;
      _beerInventory[beerUPC].grainUPC      = grainUPC;
      _beerInventory[beerUPC].price         = price;

      _beerInventory[beerUPC].itemState     = kDefaultState;

      _beerInventory[beerUPC].isForSale     = false;
      _beerInventory[beerUPC].isSold        = false;

      _beerInventory[beerUPC].brewerID      = msg.sender;
      _beerInventory[beerUPC].distributorID = address(0);
      _beerInventory[beerUPC].retailerID    = address(0);
      _beerInventory[beerUPC].customerID    = address(0);

      _beerInventory[beerUPC].itemName      = itemName;
      _beerInventory[beerUPC].itemNotes     = itemNotes;

      emit BeerStocked(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * setBeerForSale() -
    *
    * @dev  Change for sale status of beer.
    * @param beerUPC - UPC of Beer item
    * @param forSale - Whether item is for sale or not
    *
    * ------------------------------------------------------------------------
    */
   function setBeerForSale(uint256 beerUPC,
                           bool forSale)
      public
      isBrewer
   {
      _setBeerForSale(beerUPC, forSale);
      emit BeerSetForSale(beerUPC, forSale);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * setBeerSold() -
    *
    * @dev  Change for sold status of beer.
    * @param beerUPC - UPC of Beer item
    * @param isSold - Whether item is sold or not
    *
    * ------------------------------------------------------------------------
    */
   function setBeerSold(uint256 beerUPC,
                        bool isSold)
      public
      isBrewer
   {
      _setBeerSold(beerUPC, isSold);
      emit BeerSetSold(beerUPC, isSold);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * distributorOrderBeer() -
    *
    * @dev  Distributor order the beer.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function distributorOrderBeer(uint256 beerUPC)
      public
      payable
      isDistributor
      isBeerInStock(beerUPC)
      isBeerDefaultState(beerUPC)
      isBeerForSale(beerUPC)
      paidEnoughForBeer(beerUPC)
   {
      _setBeerForSale(beerUPC, false);
      _setBeerSold(beerUPC, true);
      _beerInventory[beerUPC].distributorID = msg.sender;

      _beerInventory[beerUPC].itemState = State.DistributorBeerOrdered;
      emit DistributorBeerOrdered(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * orderGrain() -
    *
    * @dev  Order the grain.
    * @param grainUPC - UPC of Grain item
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function orderGrain(uint256 grainUPC,
                       uint256 beerUPC)
      public
      payable
      isBrewer
      isGrainInStock(grainUPC)
      isBeerOrderedByDistributor(beerUPC)
      isGrainForSale(grainUPC)
      paidEnoughForGrain(grainUPC)
   {
      _setGrainForSale(grainUPC, false);
      _setGrainSold(grainUPC, true);
      _grainInventory[grainUPC].consumerID = msg.sender;

      _beerInventory[beerUPC].itemState = State.GrainOrdered;
      emit GrainOrdered(grainUPC, beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * harvestGrain() -
    *
    * @dev  Harvest the grain.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function harvestGrain(uint256 beerUPC)
      public
      isFarmer
      isGrainOrdered(beerUPC)
   {
      _beerInventory[beerUPC].itemState = State.GrainHarvested;
      emit GrainHarvested(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * processGrain() -
    *
    * @dev  Process the grain.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function processGrain(uint256 beerUPC)
      public
      isFarmer
      isGrainHarvested(beerUPC)
   {
      _beerInventory[beerUPC].itemState = State.GrainProcessed;
      emit GrainProcessed(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * packageGrain() -
    *
    * @dev  Package the grain.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function packageGrain(uint256 beerUPC)
      public
      isFarmer
      isGrainProcessed(beerUPC)
   {
      _beerInventory[beerUPC].itemState = State.GrainPackaged;
      emit GrainPackaged(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * shipGrain() -
    *
    * @dev  Ship the grain.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function shipGrain(uint256 beerUPC)
      public
      isFarmer
      isGrainPackaged(beerUPC)
      isGrainSold(_beerInventory[beerUPC].grainUPC)
   {
      _beerInventory[beerUPC].itemState = State.GrainShipped;
      emit GrainShipped(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * receiveGrain() -
    *
    * @dev  Receive the grain.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function receiveGrain(uint256 beerUPC)
      public
      isBrewer
      isGrainShipped(beerUPC)
   {
      _beerInventory[beerUPC].itemState = State.GrainReceived;
      emit GrainReceived(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * brewBeer() -
    *
    * @dev  Brew the beer.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function brewBeer(uint256 beerUPC)
      public
      isBrewer
      isGrainReceived(beerUPC)
   {
      _beerInventory[beerUPC].itemState = State.BeerBrewed;
      emit BeerBrewed(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * packageBeer() -
    *
    * @dev  Package the beer.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function packageBeer(uint256 beerUPC)
      public
      isBrewer
      isBeerBrewed(beerUPC)
   {
      _beerInventory[beerUPC].itemState = State.BeerPackaged;
      emit BeerPackaged(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * distributorShipBeer() -
    *
    * @dev  Ship the beer.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function distributorShipBeer(uint256 beerUPC)
      public
      isBrewer
      isBeerPackaged(beerUPC)
      isBeerSold(beerUPC)
   {
      _beerInventory[beerUPC].itemState = State.DistributorBeerShipped;
      emit DistributorBeerShipped(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * distributorReceiveBeer() -
    *
    * @dev  Receive the beer at distributor.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function distributorReceiveBeer(uint256 beerUPC)
      public
      isDistributor
      isShippedToDistributor(beerUPC)
   {
      _setBeerForSale(beerUPC, true);
      _setBeerSold(beerUPC, false);

      _beerInventory[beerUPC].itemState = State.DistributorBeerReceived;
      emit DistributorBeerReceived(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * retailerOrderBeer() -
    *
    * @dev  Retailer order the beer.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function retailerOrderBeer(uint256 beerUPC)
      public
      payable
      isRetailer
      isBeerInStock(beerUPC)
      isReceivedAtDistributor(beerUPC)
      isBeerForSale(beerUPC)
      paidEnoughForBeer(beerUPC)
   {
      _setBeerForSale(beerUPC, false);
      _setBeerSold(beerUPC, true);
      _beerInventory[beerUPC].retailerID = msg.sender;

      _beerInventory[beerUPC].itemState = State.RetailerBeerOrdered;
      emit RetailerBeerOrdered(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * retailerShipBeer() -
    *
    * @dev  Ship the beer to retailer.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function retailerShipBeer(uint256 beerUPC)
      public
      isDistributor
      isBeerOrderedByRetailer(beerUPC)
      isBeerSold(beerUPC)
   {
      _beerInventory[beerUPC].itemState = State.RetailerBeerShipped;
      emit RetailerBeerShipped(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * retailerReceiveBeer() -
    *
    * @dev  Receive the beer at retailer.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function retailerReceiveBeer(uint256 beerUPC)
      public
      isRetailer
      isShippedToRetailer(beerUPC)
   {
      _setBeerForSale(beerUPC, true);
      _setBeerSold(beerUPC, false);

      _beerInventory[beerUPC].itemState = State.RetailerBeerReceived;
      emit RetailerBeerReceived(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * purchaseBeer() -
    *
    * @dev  Customer purchase the beer.
    * @param beerUPC - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function purchaseBeer(uint256 beerUPC)
      public
      payable
      isCustomer
      isBeerInStock(beerUPC)
      isReceivedAtRetailer(beerUPC)
      isBeerForSale(beerUPC)
      paidEnoughForBeer(beerUPC)
   {
      _setBeerForSale(beerUPC, false);
      _setBeerSold(beerUPC, true);
      _beerInventory[beerUPC].customerID = msg.sender;

      _beerInventory[beerUPC].itemState = State.BeerPurchased;
      emit BeerPurchased(beerUPC);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * fetchGrainID() -
    *
    * @dev  Return ID info on grain item.
    * @param upc - UPC of Grain item
    *
    * ------------------------------------------------------------------------
    */
   function fetchGrainID(uint256 upc)
      public
      view
      returns(
         uint256 UPC,
         uint256 SKU,
         address farmerID,
         address consumerID
      )
   {
      Grain storage grain = _grainInventory[upc];
      return
      (
         UPC        = grain.UPC,
         SKU        = grain.SKU,
         farmerID   = grain.farmerID,
         consumerID = grain.consumerID
      );
   }

   /*
    * ------------------------------------------------------------------------
    *
    * fetchGrainMeta() -
    *
    * @dev  Return metadata on grain item.
    * @param upc - UPC of Grain item
    *
    * ------------------------------------------------------------------------
    */
   function fetchGrainMeta(uint256 upc)
      public
      view
      returns(
         bool isForSale,
         bool isSold,
         uint256 price,

         string itemName,
         string itemNotes
      )
   {
      Grain storage grain = _grainInventory[upc];
      return
      (
         isForSale  = grain.isForSale,
         isSold     = grain.isSold,
         price      = grain.price,

         itemName   = grain.itemName,
         itemNotes  = grain.itemNotes
      );
   }

   /*
    * ------------------------------------------------------------------------
    *
    * fetchBeerID() -
    *
    * @dev  Return ID info on beer item.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function fetchBeerID(uint256 upc)
      public
      view
      returns(
         uint256 UPC,
         uint256 SKU,
         uint256 grainUPC,

         address brewerID,
         address distributorID,
         address retailerID,
         address customerID
      )
   {
      Beer memory beer = _beerInventory[upc];
      return
      (
         UPC             = beer.UPC,
         SKU             = beer.SKU,
         grainUPC        = beer.grainUPC,

         brewerID        = beer.brewerID,
         distributorID   = beer.distributorID,
         retailerID      = beer.retailerID,
         customerID      = beer.customerID
      );
   }

   /*
    * ------------------------------------------------------------------------
    *
    * fetchBeerMeta() -
    *
    * @dev  Return metadata on beer item.
    * @param upc - UPC of Beer item
    *
    * ------------------------------------------------------------------------
    */
   function fetchBeerMeta(uint256 upc)
      public
      view
      returns(
         State itemState,

         bool isForSale,
         bool isSold,
         uint256 price,

         string itemName,
         string itemNotes
      )
   {
      Beer memory beer = _beerInventory[upc];
      return
      (
         itemState       = beer.itemState,

         isForSale       = beer.isForSale,
         isSold          = beer.isSold,
         price           = beer.price,

         itemName        = beer.itemName,
         itemNotes       = beer.itemNotes
      );
   }
}
