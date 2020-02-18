pragma solidity ^0.4.24;

/*
 * ------------------------------------------------------------------------
 *
 * RetailerRole -
 *
 * @dev   Retailer that sells to the customer.
 *
 * ------------------------------------------------------------------------
 */

contract RetailerRole
{
   address private _retailerAddr;

   event RetailerSet(address addr);

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
      _retailerAddr = msg.sender;
      emit RetailerSet(_retailerAddr);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isRetailer() -
    *
    * @dev  Modifier that checks to see if msg.sender has the appropriate role.
    *
    * ------------------------------------------------------------------------
    */
   modifier isRetailer()
   {
      require(msg.sender == _retailerAddr);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * setRetailer() -
    *
    * @dev  Sets the Retailer address to given address.
    * @param addr - Address to set Retailer ID
    *
    * ------------------------------------------------------------------------
    */
   function setRetailer(address addr)
      public
      isRetailer
   {
      require(addr != address(0));
      require(addr != _retailerAddr);
      _retailerAddr = addr;
      emit RetailerSet(addr);
   }
}
