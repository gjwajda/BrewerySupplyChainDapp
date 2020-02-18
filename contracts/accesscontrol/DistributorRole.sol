pragma solidity ^0.4.24;

/*
 * ------------------------------------------------------------------------
 *
 * DistributorRole -
 *
 * @dev   Distributor that buys and distributes the beer.
 *
 * ------------------------------------------------------------------------
 */

contract DistributorRole
{
   address private _distributorAddr;

   event DistributorSet(address addr);

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
      _distributorAddr = msg.sender;
      emit DistributorSet(_distributorAddr);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isDistributor() -
    *
    * @dev  Modifier that checks to see if msg.sender has the appropriate role.
    *
    * ------------------------------------------------------------------------
    */
   modifier isDistributor()
   {
      require(msg.sender == _distributorAddr);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * setDistributor() -
    *
    * @dev  Sets the Distributor address to given address.
    * @param addr - Address to set Distributor ID
    *
    * ------------------------------------------------------------------------
    */
   function setDistributor(address addr)
      public
      isDistributor
   {
      require(addr != address(0));
      require(addr != _distributorAddr);
      _distributorAddr = addr;
      emit DistributorSet(addr);
   }
}
