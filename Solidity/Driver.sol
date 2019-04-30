pragma solidity ^0.4.24;

//Intended use cycle
// Players all place bets on who is going to win
// Once all bets collected, playGame & getTeamStats functions are invoked
// Once a winner is determined, distributeEther is called
//    - Takes ether from all losers, evenly distributes amongst winners
//    - Leaves two portions for the contract owner
// Once all ether is distributed, the players call collectWinnings to retrieve their ether
// Once all the balances have been collected, resetGame is called to prep for the next round of betting.

contract Driver {

    constructor () public {
        owner = msg.sender;
    }

    address owner;
    //Define team stats
    struct Team{
        uint Offense;
        uint Defense;
        uint SpecialTeams;
    }

    struct Player {
        uint balance;
        uint team;
    }

    //Track bets
    mapping(address => Player) betters;
    address [] addrs;

    //Ether holder
    uint pool = 0;
    git
    //Stats of the 2 competing teams
    Team t1 = Team(0,0,0);
    Team t2 = Team(0,0,0);

    //Winning team identifies which team won
    //Game complete flag tells whether we have executed the game yet
    uint winningTeam = 0;
    bool gameCompleteFlag = false;

    // Save how much each player is betting on a team
    function placeBet(uint _bet, uint _team) public payable {
        require(_bet > 0);
        uint prevBal = betters[msg.sender].balance;
        //Remove old entries to keep mapping small
        if (prevBal != 0){
            delete betters[msg.sender];
        }
        uint newBal = prevBal + _bet;
        betters[msg.sender] = Player(newBal, _team);
        addrs.push(msg.sender);
    }

    //Execute the game
    function playGame(uint _team1, uint _team2) public returns (uint result){
        //Set stats
        getTeamStats(_team1);
        getTeamStats(_team2);

        //Pick winner based off stats
        uint spec1 = t1.SpecialTeams % 3;
        uint spec2 = t2.SpecialTeams % 3;
        uint res1 = t1.Offense - t2.Defense;
        uint res2 = t2.Offense - t1.Defense;

        uint r1 = random() & 5;
        uint r2 = random() % 5;

        uint t1Final = spec1 + res1 - r1;
        uint t2Final = spec2 + res2 - r2;

        //Game complete - return results and allow players to collect money
        gameCompleteFlag = true;

        if (t1Final > t2Final){
            winningTeam = _team1;
            distributeEther();
            return _team1;
        } else {
            winningTeam = _team2;
            distributeEther();
            return _team2;
        }
    }

    //Fill in the stats of the teams playing
    function getTeamStats(uint _team) private {
        // Get the team stats from other contract here - need to see what the ERC contract looks like first
    }

    function random() private view returns (uint8) {
        return uint8(uint256(keccak256(block.timestamp, block.difficulty))%251);
    }

    //Allow players to get their winnings
    function collectWinnings() public payable {
        require(gameCompleteFlag == true);

        //Transfer the winner's ether to them, set balance to 0 to prevent multiple withdrawls
        msg.sender.transfer(betters[msg.sender].balance);
        delete betters[msg.sender];

    }

    function distributeEther() private {
        uint numLosers = 0;

        // Take all ether from losers and put it in pool
        for (uint i =0; i < addrs.length; i++){
            if (betters[addrs[i]].team != winningTeam){
                numLosers++;
                pool += betters[addrs[i]].balance;
                betters[addrs[i]].balance = 0;
            }
        }

        //Calculate how much ether to each winner
        uint numWinners = addrs.length - numLosers;
        uint amtPerPlayer = pool % numWinners + 2;

        //Deposit owner's share
        pool - (amtPerPlayer * 2);
        betters[owner].balance += (amtPerPlayer*2);

        // Distribute ether to winning accounts
        for (uint i=0; i < addrs.length; i++){
            if(betters[addrs[i]].team == winningTeam){
                pool -= amtPerPlayer;
                betters[addrs[i]].balance += amtPerPlayer;
            }
        }
    }

    function resetGame() public {
        require(gameCompleteFlag == true);
        winningTeam = 0;
        addrs.length = 0;
        gameCompleteFlag = false;
    }
}