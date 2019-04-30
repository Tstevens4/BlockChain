pragma solidity ^0.5.2;

import './node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';
import './node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol';


contract Fighters is ERC721, Ownable {
  constructor() ERC721() public {}

  struct Fighter {
   //string Rarity; // Name of the Item
   uint Health; // Health points from 100-200 | 0 means fighter was defeated
   uint Speed; // Speed level - determine who attacks First 1-10
   uint AttackPower; // Amount of damage dealt | 16-50
   uint Defense; // Defence level from 0-15 | Reduce damage by level/100
  }

  Fighter[] internal fighters;
  mapping (address => Fighter[]) internal ownedFighters;
  uint256 internal oneEther = 10000000;
  
//ONLY OWNER CAN CALL THIS FUNCTION 
function CreateFighter() external onlyOwner{
    require(isOwner(), "only owner of the contract can call this function");
    Fighter memory _fighter = Fighter(random(40) + 160, random(7) + 4, random(30) + 20, random(15) + 2 ); 
    uint _id = fighters.push(_fighter) - 1;
   _mint(msg.sender, _id);
  }


 // Gets you a fighter with random stats lowest as rare up to to Legendary
  function buyLegendaryFighter() public payable {
    
    require(msg.value >= oneEther * 2 , "you need to bid atleast 2 ethetTo get a chance at Legendary Fighters" );
    Fighter memory _fighter = Fighter(random(40) + 160, random(7) + 4, random(30) + 20, random(15) + 2 ); 
    uint _id = fighters.push(_fighter) - 1;
    _mint(msg.sender, _id);
  }
// Gets you a fighter with random stats more likely as a rare up to Legendary
   function buyRareFighter() public payable {
    require(msg.value >= oneEther, "you need to bid atleast 1 ether get a chance at rare Fighters" );
    Fighter memory _fighter = Fighter(random(80) + 120, random(8) + 3, random(33) + 18, random(16) ); 
    uint _id = fighters.push(_fighter) - 1;
    _mint(msg.sender, _id);
  }

// Gets you a fighter with random stats up to Legendary
   function buyFighter() public payable {
    require(msg.value >= oneEther / 2, "you need to bid atleast half of an ether get a random Fighter" );
    Fighter memory _fighter = Fighter(random(100) + 100, random(10) + 1, random(34) + 16, random(16) ); 
    uint _id = fighters.push(_fighter) - 1;
    _mint(msg.sender, _id);
  }





  function getFighterFromId(uint id) public view returns( uint, uint, uint, uint) {
    return (fighters[id].Health, fighters[id].Speed, fighters[id].AttackPower, fighters[id].Defense);
  }

  function getBalance(address owner)public view returns (uint256){
    return(balanceOf(owner));
  }
  
  function random(uint modulo) private view returns (uint) {
    return uint(blockhash(block.number-1)) % modulo;
  }

  function burnToken(uint256 tokenId) public returns (bool) {
    _burn(msg.sender, tokenId);
    return true;
  }
}