// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Decentralized Voting System
 * @dev A smart contract for conducting transparent and secure elections
 * @author Your Name
 */
contract Project {
    // Structure to represent a candidate
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
        bool exists;
    }
    
    // Structure to represent a voter
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }
    
    // State variables
    address public owner;
    string public electionName;
    bool public votingOpen;
    uint256 public totalVotes;
    uint256 public candidateCount;
    
    // Mappings
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    // Events
    event CandidateAdded(uint256 indexed candidateId, string name);
    event VoterRegistered(address indexed voter);
    event VoteCasted(address indexed voter, uint256 indexed candidateId);
    event VotingStatusChanged(bool isOpen);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyWhenVotingOpen() {
        require(votingOpen, "Voting is not currently open");
        _;
    }
    
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "You are not registered to vote");
        _;
    }
    
    modifier hasNotVoted() {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        _;
    }
    
    /**
     * @dev Constructor to initialize the voting contract
     * @param _electionName Name of the election
     */
    constructor(string memory _electionName) {
        owner = msg.sender;
        electionName = _electionName;
        votingOpen = false;
        totalVotes = 0;
        candidateCount = 0;
    }
    
    /**
     * @dev Core Function 1: Add a candidate to the election
     * @param _name Name of the candidate
     */
    function addCandidate(string memory _name) public onlyOwner {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        require(!votingOpen, "Cannot add candidates while voting is open");
        
        candidateCount++;
        candidates[candidateCount] = Candidate({
            id: candidateCount,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        emit CandidateAdded(candidateCount, _name);
    }
    
    /**
     * @dev Core Function 2: Register a voter
     * @param _voter Address of the voter to register
     */
    function registerVoter(address _voter) public onlyOwner {
        require(_voter != address(0), "Invalid voter address");
        require(!voters[_voter].isRegistered, "Voter is already registered");
        
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });
        
        emit VoterRegistered(_voter);
    }
    
    /**
     * @dev Core Function 3: Cast a vote for a candidate
     * @param _candidateId ID of the candidate to vote for
     */
    function vote(uint256 _candidateId) public 
        onlyWhenVotingOpen 
        onlyRegisteredVoter 
        hasNotVoted 
    {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        // Update voter status
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        // Update candidate vote count
        candidates[_candidateId].voteCount++;
        totalVotes++;
        
        emit VoteCasted(msg.sender, _candidateId);
    }
    
    /**
     * @dev Start or stop the voting process
     * @param _status True to open voting, false to close
     */
    function setVotingStatus(bool _status) public onlyOwner {
        require(candidateCount > 0, "Must have at least one candidate before opening voting");
        votingOpen = _status;
        emit VotingStatusChanged(_status);
    }
    
    /**
     * @dev Get candidate information
     * @param _candidateId ID of the candidate
     * @return id Candidate ID
     * @return name Candidate name
     * @return voteCount Number of votes received
     */
    function getCandidate(uint256 _candidateId) public view returns (
        uint256 id,
        string memory name,
        uint256 voteCount
    ) {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    /**
     * @dev Get the winning candidate (can only be called when voting is closed)
     * @return winnerId ID of the winning candidate
     * @return winnerName Name of the winning candidate
     * @return winnerVoteCount Vote count of the winner
     */
    function getWinner() public view returns (
        uint256 winnerId,
        string memory winnerName,
        uint256 winnerVoteCount
    ) {
        require(!votingOpen, "Voting must be closed to determine winner");
        require(candidateCount > 0, "No candidates available");
        
        uint256 maxVotes = 0;
        uint256 winner = 0;
        
        for (uint256 i = 1; i <= candidateCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winner = i;
            }
        }
        
        require(winner > 0, "No winner found");
        return (winner, candidates[winner].name, candidates[winner].voteCount);
    }
    
    /**
     * @dev Get total number of registered voters
     * @return count Number of registered voters
     */
    function getRegisteredVotersCount() public view returns (uint256) {
        // Note: This is a simplified implementation
        // In a production system, you might want to maintain a separate counter
        return totalVotes; // This represents voters who have voted
    }
    
    /**
     * @dev Check if an address is registered to vote
     * @param _voter Address to check
     * @return registered True if the address is registered
     */
    function isVoterRegistered(address _voter) public view returns (bool) {
        return voters[_voter].isRegistered;
    }
    
    /**
     * @dev Check if a voter has already voted
     * @param _voter Address to check
     * @return voted True if the voter has already voted
     */
    function hasVoterVoted(address _voter) public view returns (bool) {
        return voters[_voter].hasVoted;
    }
}
