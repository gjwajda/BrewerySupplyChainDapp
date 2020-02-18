pragma solidity ^0.4.24;

/*
 * ------------------------------------------------------------------------
 *
 * FarmerRole -
 *
 * @dev   Farmer that grows the crops.
 *
 * ------------------------------------------------------------------------
 */

contract FarmerRole
{
   address private _farmerAddr;

   event FarmerSet(address addr);

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
      _farmerAddr = msg.sender;
      emit FarmerSet(_farmerAddr);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isFarmer() -
    *
    * @dev  Modifier that checks to see if msg.sender has the appropriate role.
    *
    * ------------------------------------------------------------------------
    */
   modifier isFarmer()
   {
      require(msg.sender == _farmerAddr);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * setFarmer() -
    *
    * @dev  Sets the farmer address to given address.
    * @param addr - Address to set Farmer ID
    *
    * ------------------------------------------------------------------------
    */
   function setFarmer(address addr)
      public
      isFarmer
   {
      require(addr != address(0));
      require(addr != _farmerAddr);
      _farmerAddr = addr;
      emit FarmerSet(addr);
   }
}
