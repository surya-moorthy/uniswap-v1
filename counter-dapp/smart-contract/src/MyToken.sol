// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {

   uint256 public constant Total_supply = 10000 * 1000;

   address owner;

   event Mint(address receiver, uint256 amount);
   event Burn(address auth,uint256 amount );

   constructor() ERC20("MYTOKEN" , "MYT") {
       owner = msg.sender;
       _mint(owner, Total_supply); 
   }

   function mint(address receiver,uint256 amount) public {
       require( amount + Total_supply >= totalSupply(),"Insufficient balance");
       _mint(receiver,amount);
       emit Mint(receiver, amount);
   }

   function burn(uint256 amount) public {
    _burn(msg.sender,amount);
   emit Burn(msg.sender, amount);
   }

   function TransferOwnership(address sub) public {
     owner = sub;
   }
}
