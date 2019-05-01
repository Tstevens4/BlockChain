pragma solidity ^0.5.2;

import './node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';
import './node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol';



contract Fighters is ERC721, Ownable {
  constructor() ERC721() public {
		//address contractOwner = msg.sender;
	}
  //will be used for the betting process.
  uint256 public betting_start;
  uint256 public betting_end;

  struct Fighter {
   //string Rarity; // Name of the Item
   uint Health; // Health points from 100-200 | 0 means fighter was defeated
   uint Speed; // Speed level - determine who attacks First 1-10
   uint AttackPower; // Amount of damage dealt | 16-50
   uint Defense; // Defence level from 0-15 | Reduce damage by level/100
  }
  //all the fighters that are created
  Fighter[] internal fighters;
  //fighters queued for the fight (2 at a time)
  uint[] QuedFighterIds;

  // mapping token owners to tokens
  // mapping (address => Fighter[]) internal ownedFighters;
  uint256 internal oneEther = 10000000;

  //bidder addreses
  address[] bidders;
  mapping(address => uint) public bids;
  //mapping bidder addresses to qued fighter Ids
  mapping(address => uint[]) public idsBidOn;

  //pool of bids for each fighter 
  uint256 f1TotalBets;
  uint256 f2TotalBets;
	uint f1NumberOfBidders;
	uint f2NumberOfBidders;


  // Track winner and game state
  uint winningFighterID;
  bool fightOver = false;



//ONLY OWNER CAN CALL THIS FUNCTION 
function CreateFighter() external onlyOwner{
    require(isOwner(), "only owner of the contract can call this function");
    Fighter memory _fighter = Fighter(random(40) + 160, random(7) + 4, random(30) + 20, random(15) + 2 ); 
    uint _id = fighters.push(_fighter) - 1;
   _mint(msg.sender, _id);
  }


 // Gets you a fighter with random stats lowest as rare up to to Legendary
  function buyLegendaryFighter() public payable {

    
    require(msg.value >= oneEther * 2 , "you need to bid at least 2 ether to get a chance at Legendary Fighters" );
    Fighter memory _fighter = Fighter(random(40) + 160, random(7) + 4, random(30) + 20, random(15) + 2 ); 
    uint _id = fighters.push(_fighter) - 1;
    _mint(msg.sender, _id);
  }
// Gets you a fighter with random stats more likely as a rare up to Legendary
   function buyRareFighter() public payable {
    require(msg.value >= oneEther, "you need to bid at least 1 ether to get a chance at rare Fighters" );
    Fighter memory _fighter = Fighter(random(80) + 120, random(8) + 3, random(33) + 18, random(16) ); 
    uint _id = fighters.push(_fighter) - 1;
    _mint(msg.sender, _id);
  }

// Gets you a fighter with random stats up to Legendary
   function buyFighter() public payable {
    require(msg.value >= oneEther / 2, "you need to bid at least half of an ether to get a random Fighter" );
    Fighter memory _fighter = Fighter(random(100) + 100, random(10) + 1, random(34) + 16, random(16) ); 
    uint _id = fighters.push(_fighter) - 1;
    _mint(msg.sender, _id);
  }

  function getFighterFromId(uint id) public view returns( uint, uint, uint, uint  ) {
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
  //Start the Fight by setting your fighter as a registered fighter
  function RegisterFighter(uint fighterId) public returns(bool){
    require(QuedFighterIds.length < 3, "There is already 2 Fighters In que the fight will start soon");
    require(ownerOf(fighterId) == msg.sender, "You need to own The fighters to start a fight");
    QuedFighterIds.push(fighterId);
    if(QuedFighterIds.length == 2){
      betting_start=now;
      betting_end = betting_start + 1 minutes;
    }
    return true;
  }
  
  // after the fighters are in que start betting session
  function BettingSession(uint fighterId) public payable{
    require(QuedFighterIds.length > 1 , "The aren't Enough Fighters in the que for the Betting Session To start yet ");
    require(msg.value == 100000000000000000, "Only bet size accepted is .1 ether" );
    require(betting_end > now, "The betting window has closed wait for another fight" );
    require(QuedFighterIds[0] == fighterId || QuedFighterIds[1] == fighterId, "The fighter you selected does not apper to be qued for betting");
	  if(fighterId == QuedFighterIds[0]){
	  	f1TotalBets += msg.value;
			f1NumberOfBidders++;
	  } else {
	  	f2TotalBets += msg.value;
			f2NumberOfBidders++;
    }
    bidders.push(msg.sender);
  }

  // function Fight() public {
  //     //Choose who fights first
  //     (uint  healthf1, uint  speedf1, uint  powerf1, uint  defensef1 )  = (getFighterFromId(QuedFighterIds[0]));
  //     (uint  healthf2, uint  speedf2, uint  powerf2, uint  defensef2) = getFighterFromId(QuedFighterIds[1]);

  //     fightOver = false;

      // Access each attribute via the array
      // Health - 0
      // Speed - 1
      // Attack - 2
      // Defense - 3
      // if (speedf1> speedf2){
      //     // F1 fights first
      //     while (!fightOver){
      //         f2[0] -= (f1[2] - f2[3]);
      //         if (f2[0] <= 0){
      //             //Fighter is defeated
      //             winningFighterID = QuedFighterIds[0];
      //             fightOver = true;
      //         }
      //         f1[0] -= (f2[2] - f1[3]);
      //         if (f1[0] <= 0){
      //             winningFighterID = QuedFighterIds[1];
      //             fightOver = true;
      //         }
      //     }
      // } else {
      //     // F2 fights first
      //     while(!fightOver){
      //         f1[0] -= (f2[2] - f1[3]);
      //         if (f1[0] <= 0){
      //             winningFighterID = QuedFighterIds[1];
      //             fightOver = true;
      //         }
      //         f2[0] -= (f1[2] - f2[3]);
      //         if (f2[0] <= 0){
      //             winningFighterID = QuedFighterIds[0];
      //             fightOver = true;
      //         }
      //     }
      // }

      //Fight is over, winner is set. Burn loser
  //     if (QuedFighterIds[0] == winningFighterID){
  //         burnToken(QuedFighterIds[1]);
  //     } else {
  //         burnToken(QuedFighterIds[0]);
  //     }

  //     //Distribute ether to winners
  //     distributeEther();
  //     //Reset the game state for the next round
  //     resetArena();
  // }

	// Reset the Arena to get ready for next fight
  function resetArena () public {
      QuedFighterIds.length = 0;
      bidders.length = 0;
			f1TotalBets = 0;
			f2TotalBets = 0;
			f1NumberOfBidders = 0;
			f2NumberOfBidders = 0;
  }

	//Allow players to collect their winnings
	function collectWinnings() public payable {
		require(fightOver == true);
		require(bids[msg.sender] > 0, "You did not bid on this fight");
		//Transfer the winner's ether to them, set balance to 0 to prevent multiple withdrawls
		msg.sender.transfer(bids[msg.sender]);
		delete bids[msg.sender];
	}

	function distributeEther() private {
    
		// Give fighter owner and contract owner their money
		if(winningFighterID == QuedFighterIds[0]){
			uint quarter = f2TotalBets/4;
			bids[ownerOf(winningFighterID)] += quarter;
			f2TotalBets -= quarter;
			//bids[contowner] += quarter;
			f2TotalBets -= quarter;
		}else {
			uint quarter = f1TotalBets/4;
			bids[ownerOf(winningFighterID)] += quarter;
			f1TotalBets -= quarter;
			//bids[contractOwner] += quarter;
			f1TotalBets -= quarter;
		}

		for(uint i = 0; i<bidders.length;i++){
			//Set losing player balances to 0
			if(idsBidOn[bidders[i]] != winningFighterID){
				bids[bidders[i]] = 0;
			}
			// Divide remaining losing pool amongst winners				
			if(idsBidOn[bidders[i]] == winningFighterID){
				// EqualShare is the losing pool divided by the number of wining betters
				// add equalShare to each winning better's account balance
				if(winningFighterID == QuedFighterIds[0]){
						uint equalShare = f2TotalBets / f1NumberOfBidders;
						bids[bidders[i]] += equalShare;
						f2TotalBets -= equalShare;
				}else{
						uint equalShare = f1TotalBets / f2NumberOfBidders;
						bids[bidders[i]] += equalShare;
						f1TotalBets -= equalShare;
				}

			}
		}
	}
}
