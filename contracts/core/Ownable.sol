pragma solidity ^0.4.24;

/*
 * ------------------------------------------------------------------------
 *
 * Ownable -
 *
 * @dev  Provides basic authorization control.
 *
 * ------------------------------------------------------------------------
 */

contract Ownable {
   address private _owner;

   event ownershipTransfered(address addrFrom,
                             address addrTo);

   /*
    * ------------------------------------------------------------------------
    *
    * constructor() -
    *
    * ------------------------------------------------------------------------
    */
   constructor ()
      internal
   {
      _owner = msg.sender;
      emit ownershipTransfered(address(0), _owner);
   }

   /*
    * ------------------------------------------------------------------------
    *
    * isOwner() -
    *
    * @dev  Modifier that checks to see if msg.sender has the appropriate role.
    *
    * ------------------------------------------------------------------------
    */
   modifier isOwner()
   {
      require(msg.sender == _owner);
      _;
   }

   /*
    * ------------------------------------------------------------------------
    *
    * renounceOwnership() -
    *
    * @dev  Function to renounce ownership
    *
    * ------------------------------------------------------------------------
    */
   function renounceOwnership()
      public
      isOwner
   {
      _owner = address(0);
      emit ownershipTransfered(_owner, address(0));
   }

   /*
    * ------------------------------------------------------------------------
    *
    * transferOwnership() -
    *
    * @dev  Function to transfer ownership
    * @param addrTo - Address to transfer ownership to
    *
    * ------------------------------------------------------------------------
    */
   function transferOwnership(address addrTo)
      public
      isOwner
   {
      require(addrTo != address(0));
      _owner = addrTo;
      emit ownershipTransfered(_owner, addrTo);
   }
}
