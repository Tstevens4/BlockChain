pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract Fighters is ERC721Token, Ownable {
  constructor() ERC721("Fighters", "FFA") public {}

  struct Fighter {
   //string name; // Name of the Item
   uint Health; // Health points from 100-200 | 0 means fighter was defeated
   uint Speed; // Speed level - determine who attacks First 1-10
   uint AttackPower; // Amount of damage dealt | 16-50
   uint Defense; // Defence level from 0-15 | Reduce damage by level/100
  }

  Fighter[] fighters;

  function mint() public {
    require(msg.sender == owner());
    Fighter memory _fighter = Fighter(random(100) + 100, random(10) + 1, random(34) + 16, random(16) ); 
    uint _id = fighters.push(fighter) - 1;
    _mint(msg.sender, _id);
  }

  function getFighterFromId(uint id) public view returns( uint8, uint8, uint8, uint8) {
    return (fighters[id].name, fighters[id].Health, fighters[id].Speed, fighters[id].AttackPower, fighters[id].Defense);
  }
  
  function random(uint8 modulo) private view returns (uint8) {
       return uint8(uint256(keccak256(block.timestamp, block.difficulty))% modulo);
   }
}