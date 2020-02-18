pragma solidity ^0.4.24;

/*
 * ------------------------------------------------------------------------
 *
 * BrewerRole -
 *
 * @dev   Brewer that makes the beer.
 *
 * ------------------------------------------------------------------------
 */

contract BrewerRole
{
   address private _brewerAddr;

   event BrewerSet(address addr);

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
      _brewerAddr = msg.sender;
      emit BrewerSet(_brewerAddr);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isBrewer() -
    *
    * @dev  Modifier that checks to see if msg.sender has the appropriate role.
    *
    * ------------------------------------------------------------------------
    */
   modifier isBrewer()
   {
      require(msg.sender == _brewerAddr);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * setBrewer() -
    *
    * @dev  Sets the Brewer address to given address.
    * @param addr - Address to set Brewer ID
    *
    * ------------------------------------------------------------------------
    */
   function setBrewer(address addr)
      public
      isBrewer
   {
      require(addr != address(0));
      require(addr != _brewerAddr);
      _brewerAddr = addr;
      emit BrewerSet(addr);
   }
}
