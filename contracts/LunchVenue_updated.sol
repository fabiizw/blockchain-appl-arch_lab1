/// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title Contract to agree on the lunch venue
/// @author Dilum Bandara, CSIRO's Data61

contract LunchVenue_updated{
    
    struct Friend {
        string name;
        bool voted; //Vote state
    }
    
    struct Vote {
        address voterAddress;
        uint restaurant;
    }

    enum Stage { CREATE, VOTE_OPEN, VOTE_CLOSED }
    Stage public currentStage = Stage.CREATE; //set 'CREATE' as the beginning stage

    mapping (uint => string) public restaurants; //List of restaurants (restaurant no, name)
    mapping(address => Friend) public friends;  //List of friends (address, Friend)
    uint public numRestaurants = 0;
    uint public numFriends = 0;
    uint public numVotes = 0;
    address public manager;                     //Contract manager
    string public votedRestaurant = "";         //Where to have lunch

    mapping (uint => Vote) public votes;        //List of votes (vote no, Vote)
    mapping (uint => uint) private _results;    //List of vote counts (restaurant no, no of votes)
    bool public voteOpen = true;                //voting is open

    /**
     * @dev Set manager when contract starts
     */
    constructor () {
        manager = msg.sender;                   //Set contract creator as manager
    }

    /**
    * @notice Starts the vote stage
    */
    function startVote() public restricted inStage(Stage.CREATE) {
        currentStage = Stage.VOTE_OPEN;
    }

    /**
    * @notice Ends the vote stage
    */
    function endVote() public restricted inStage(Stage.VOTE_OPEN) quorumIsMet { //only end it when quorum is met
        currentStage = Stage.VOTE_CLOSED;
        finalResult();
    }

    /**
     * @notice Add a new restaurant
     * @dev To simplify the code, duplication of restaurants isn't checked --> now implemented with restaurantAlreadyExists modifier
     *
     * @param name Restaurant name
     * @return Number of restaurants added so far
     */
    function addRestaurant(string memory name) public restricted restaurantAlreadyExists(name) inStage(Stage.CREATE) returns (uint){
        numRestaurants++;
        restaurants[numRestaurants] = name;
        return numRestaurants;
    }

    /**
     * @notice Add a new friend to voter list
     * @dev To simplify the code duplication of friends is not checked --> now implemented with friendAlreadyExists modifier
     *
     * @param friendAddress Friend's account/address
     * @param name Friend's name
     * @return Number of friends added so far
     */
    function addFriend(address friendAddress, string memory name) public restricted friendAlreadyExists(friendAddress) inStage(Stage.CREATE) returns (uint){
        Friend memory f;
        f.name = name;
        f.voted = false;
        friends[friendAddress] = f;
        numFriends++;
        return numFriends;
    }

    /** 
     * @notice Vote for a restaurant
     * @dev To simplify the code duplicate votes by a friend is not checked --> now implemented with votedAlready modifier
     *
     * @param restaurant Restaurant number being voted
     * @return validVote Is the vote valid? A valid vote should be from a registered 
     * friend to a registered restaurant
    */
    function doVote(uint restaurant) public votingOpen votedAlready(msg.sender) inStage(Stage.VOTE_OPEN) returns (bool validVote){
        validVote = false;                                  //Is the vote valid?
        if (bytes(friends[msg.sender].name).length != 0) {  //Does friend exist?
            if (bytes(restaurants[restaurant]).length != 0) {   //Does restaurant exist?
                validVote = true;
                friends[msg.sender].voted = true;
                Vote memory v;
                v.voterAddress = msg.sender;
                v.restaurant = restaurant;
                numVotes++;
                votes[numVotes] = v;
            }
        }
        
        /*
        if (numVotes >= numFriends/2 + 1) { //Quorum is met
            finalResult();
        }
        */
        
        return validVote;
    }

    /** 
     * @notice Determine winner restaurant
     * @dev If top 2 restaurants have the same no of votes, result depends on vote order
    */
    function finalResult() private{
        uint highestVotes = 0;
        uint highestRestaurant = 0;
        
        for (uint i = 1; i <= numVotes; i++){   //For each vote
            uint voteCount = 1;
            if(_results[votes[i].restaurant] > 0) { // Already start counting
                voteCount += _results[votes[i].restaurant];
            }
            _results[votes[i].restaurant] = voteCount;
        
            if (voteCount > highestVotes){ // New winner
                highestVotes = voteCount;
                highestRestaurant = votes[i].restaurant;
            }
        }
        votedRestaurant = restaurants[highestRestaurant];   //Chosen restaurant
        voteOpen = false;                                   //Voting is now closed
    }
    
    /** 
     * @notice Only the manager can do
     */
    modifier restricted() {
        require (msg.sender == manager, "Can only be executed by the manager");
        _;
    }
    
    /**
     * @notice Only when voting is still open
     */
    modifier votingOpen() {
        require(voteOpen == true, "Can vote only while voting is open.");
        _;
    }

    /**
     * @notice Only vote one time
     */
    modifier votedAlready(address friendAddress) {
        require(friends[friendAddress].voted == false, "Can only vote once."); //checks the 'voted' property of the friend
        _;
    }

    /**
     * @notice Only add restaurants once
     */
    modifier restaurantAlreadyExists(string memory name) {
        bool restaurantAlreadyExists = false;

        for (uint i = 1; i <= numRestaurants; i++) { //iterate over every restaurant in the list
            if (keccak256(abi.encodePacked(restaurants[i])) == keccak256(abi.encodePacked(name))) { //compare the strings (names of the restaurants) using keccak156 function
                restaurantAlreadyExists = true;
                break; //breaks the foor loop as soon as one match was found
            }
        }
        require(!restaurantAlreadyExists, "Restaurant already exists.");
        _; 
    }
    
    

    /**
     * @notice Only add friends once
     */
    modifier friendAlreadyExists(address friendAddress) {
        require(bytes(friends[friendAddress].name).length == 0, "Friend already exists");
        _;
        /*

        bool friendAlreadyExists = false;

        for (uint i = 1; i <= numFriends; i++) { //iterate over every friend in the list
            if (keccak256(abi.encodePacked(friends[i].name)) == keccak256(abi.encodePacked(name))) { //compare the strings (names) using keccak156 function
                friendAlreadyExists = true;
                break; //breaks the foor loop as soon as one match was found
            }
        }
        require(!friendAlreadyExists, "Friend already exists.");
        _; 

        */
    }

    /**
     * @notice Only call functions in the correct stage
     */
    modifier inStage(Stage stage) {
        require(currentStage == stage, "Function can not be called in this stage.");
        _;
    }

    /**
     * @notice Voting quorum has to be met
     */
    modifier quorumIsMet () {
        bool quorumIsMet = false;
        if (numVotes >= numFriends/2 + 1) { //Quorum is met
            quorumIsMet = true;
        }
        require(!quorumIsMet, "Voting quorum is not met. Keep voting.");
        _;
    }
}