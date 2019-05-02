contract Fighters is ERC721, Ownable {
  constructor() ERC721() public {
		//address contractOwner = msg.sender;
	}
  //will be used for the betting process.
  uint256 public betting_start;
  uint256 public betting_end;

  address public AccountOwner = owner();

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
  mapping(address => uint) public idsBidOn;

  //pool of bids for each fighter 
  uint256 f1TotalBets;
  uint256 f2TotalBets;
	uint f1NumberOfBidders;
	uint f2NumberOfBidders;


  // Track winner and game state
  uint winningFighterID;
  bool fightOver = false;
  
  //Testy boi
  event Test(uint indexed value1);



//ONLY OWNER CAN CALL THIS FUNCTION 
function CreateFighter() external onlyOwner{
    require(isOwner(), "only owner of the contract can call this function");
    AccountOwner = owner();
    Fighter memory _fighter = Fighter(random(40) + 160, random(7) + 4, random(30) + 20, random(15) + 2 ); 
    uint _id = fighters.push(_fighter) - 1;
   _mint(msg.sender, _id);
  }

function test_log() public {
    emit Test(69);
}

 // Gets you a fighter with random stats lowest as rare up to to Legendary
  function buyLegendaryFighter() public payable {
    require(msg.value >= oneEther * 2 , "you need to bid at least 2 ether to get a chance at Legendary Fighters" );
    bids[AccountOwner] += msg.value;
    Fighter memory _fighter = Fighter(random(40) + 160, random(7) + 4, random(30) + 20, random(15) + 2 ); 
    uint _id = fighters.push(_fighter) - 1;
    _mint(msg.sender, _id);
  }
// Gets you a fighter with random stats more likely as a rare up to Legendary
   function buyRareFighter() public payable {
    require(msg.value >= oneEther, "you need to bid at least 1 ether to get a chance at rare Fighters" );
    bids[AccountOwner] += msg.value;
    Fighter memory _fighter = Fighter(random(80) + 120, random(8) + 3, random(33) + 18, random(16) ); 
    uint _id = fighters.push(_fighter) - 1;
    _mint(msg.sender, _id);
  }

// Gets you a fighter with random stats up to Legendary
   function buyFighter() public payable {
    require(msg.value >= oneEther / 2, "you need to bid at least half of an ether to get a random Fighter" );
    AccountOwner = owner();
    bids[AccountOwner] += msg.value;
    Fighter memory _fighter = Fighter(random(100) + 100, random(10) + 1, random(34) + 16, random(16) ); 
    uint _id = fighters.push(_fighter) - 1;
    _mint(msg.sender, _id);
  }

  function getFighterFromId(uint id) public view returns( uint, uint, uint, uint  ) {
    return (fighters[id].Health, fighters[id].Speed, fighters[id].AttackPower, fighters[id].Defense);
  }

  function getFighterBalance(address owner)public view returns (uint256){
    return(balanceOf(owner));
  }
  
  function getBetBalance(address owner) public view returns (uint){
      return(bids[owner]);
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
      betting_end = betting_start + 2 minutes;
    }
    return true;
  }
  
  // after the fighters are in que start betting session
  function Bet(uint fighterId) public payable{
    require(QuedFighterIds.length > 1 , "The aren't Enough Fighters in the que for the Betting Session To start yet ");
    require(msg.value == 100000000000000000, "Only bet size accepted is .1 ether" );
    require(betting_end > now, "The betting window has closed wait for another fight" );
    require(QuedFighterIds[0] == fighterId || QuedFighterIds[1] == fighterId, "The fighter you selected does not apper to be qued for betting");
	  require(idsBidOn[msg.sender] == 0, "You can only bid on one fighter");
    idsBidOn[msg.sender] = fighterId;
    bids[msg.sender] += msg.value;
    if(fighterId == QuedFighterIds[0]){
	  	f1TotalBets += msg.value;
		f1NumberOfBidders++;
	  } else {
	  	f2TotalBets += msg.value;
		f2NumberOfBidders++;
    }
    bidders.push(msg.sender);
  }

  function Fight() public payable {
      //Choose who fights first
      (uint  healthf1, uint  speedf1, uint  powerf1, uint  defensef1 )  = (getFighterFromId(QuedFighterIds[0]));
      (uint  healthf2, uint  speedf2, uint  powerf2, uint  defensef2) = getFighterFromId(QuedFighterIds[1]);

      fightOver = false;
      // Access each attribute via the array
      // Health - 0
      // Speed - 1
      // Attack - 2
      // Defense - 3
      uint f2Score = healthf2 % (powerf1-defensef2);
      uint f1Score = healthf1 % (powerf2-defensef1);
         
      if(f1Score > f2Score){
          winningFighterID = QuedFighterIds[0];
          fightOver = true;
      }
      if(f1Score < f2Score){
          winningFighterID = QuedFighterIds[1];
          fightOver = true;
      }
      if(f1Score == f2Score){
          if (speedf1 >= speedf2){
              winningFighterID = QuedFighterIds[0];
              fightOver = true;
          }
          if (speedf1 < speedf2){
              winningFighterID = QuedFighterIds[1];
              fightOver = true;
          }
      }
      
      // Fight is over, winner is set. Burn loser
    //   if (QuedFighterIds[0] == winningFighterID){
    //       burnToken(QuedFighterIds[1]);
    //   } else {
    //       burnToken(QuedFighterIds[0]);
    //   }
 

      //Distribute ether to winners
      distributeEther();
   
      //Reset the game state for the next round
      resetArena();
  }

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

	function distributeEther() public payable {
    
		// Give fighter owner and contract owner their money
    uint equalShare;
		if(winningFighterID == QuedFighterIds[0]){
			uint quarter = f2TotalBets/4;
			bids[ownerOf(winningFighterID)] += quarter;
			f2TotalBets -= quarter;
      equalShare = f2TotalBets / f1NumberOfBidders;
		}else {
			uint quarter = f1TotalBets/4;
			bids[ownerOf(winningFighterID)] += quarter;
			f1TotalBets -= quarter;
      equalShare = f1TotalBets / f2NumberOfBidders;
		}

		for(uint i = 0; i<bidders.length;i++){
			//Set losing player balances to 0
			if(idsBidOn[bidders[i]] != winningFighterID && bidders[i] != AccountOwner){
				bids[bidders[i]] = 0;
			}
			// Divide remaining losing pool amongst winners				
			if(idsBidOn[bidders[i]] == winningFighterID){
				// EqualShare is the losing pool divided by the number of wining betters
				// add equalShare to each winning better's account balance
				if(winningFighterID == QuedFighterIds[0]){
						bids[bidders[i]] += equalShare;
						f2TotalBets -= equalShare;
				}else{
						bids[bidders[i]] += equalShare;
						f1TotalBets -= equalShare;
				}

			}
		}
	}

}