pragma solidity ^0.4.24;

/*
 * ------------------------------------------------------------------------
 *
 * CustomerRole -
 *
 * @dev   Customer that consumes the beer.
 *
 * ------------------------------------------------------------------------
 */

contract CustomerRole
{
   address private _customerAddr;

   event CustomerSet(address addr);

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
      _customerAddr = msg.sender;
      emit CustomerSet(_customerAddr);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isCustomer() -
    *
    * @dev  Modifier that checks to see if msg.sender has the appropriate role.
    *
    * ------------------------------------------------------------------------
    */
   modifier isCustomer()
   {
      require(msg.sender == _customerAddr);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * setCustomer() -
    *
    * @dev  Sets the Customer address to given address.
    * @param addr - Address to set Customer ID
    *
    * ------------------------------------------------------------------------
    */
   function setCustomer(address addr)
      public
      isCustomer
   {
      require(addr != address(0));
      require(addr != _customerAddr);
      _customerAddr = addr;
      emit CustomerSet(addr);
   }
}
