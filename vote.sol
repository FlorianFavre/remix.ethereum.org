// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable {
 
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }
    struct Proposal {
        string description;
        uint voteCount;
    }
    mapping (address => Voter) votantMap;
    address[] votantArray;
    Proposal[] proposalArr;
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }
    WorkflowStatus status = WorkflowStatus.RegisteringVoters;
    //id du gagnant
    uint winningProposalId = 0;

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted(address voter, uint proposalId);
    event Unregistered(address voterAddressLoose);
    event ProposalView(string propView);

    //retourne le gagnant
    function getWinner () public view returns (address){
        for(uint i = 0; i < votantArray.length; i++){
            if(votantMap[votantArray[i]].votedProposalId == winningProposalId){
                return votantArray[i];
            }
        }
    }

    //ajoute un votant
    function addVoter (address addMore) internal onlyOwner {
        
        votantMap[addMore] = Voter(true, false, 0);
        votantArray.push(addMore);
        emit VoterRegistered(addMore);
    }

    //initialise liste votant par défaut
    function createVoter() internal onlyOwner{

        addVoter(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        addVoter(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
        addVoter(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
        addVoter(0x617F2E2fD72FD9D5503197092aC168c91465E7f2);
        addVoter(0x17F6AD8Ef982297579C203069C1DbfFE4348c372);
        addVoter(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678);
        addVoter(0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7);
        addVoter(0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C);
        addVoter(0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC);
        addVoter(0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c);
        addVoter(0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C);
        addVoter(0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB);
        addVoter(0x583031D1113aD414F02576BD6afaBfb302140225);
        addVoter(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
    }
    

    //l'admin enregistre les votants ici puis j'attends les propositions
    function Admin1RegisteringVoters() public onlyOwner{

        if(status == WorkflowStatus.RegisteringVoters){
            createVoter();
            status == WorkflowStatus.ProposalsRegistrationStarted;
            emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
        }
    }

    // soumettre proposition
    function submitProposal (string memory proposalStr) public payable{

        if(status == WorkflowStatus.ProposalsRegistrationStarted){
            uint valPropArr = proposalArr.length;
            proposalArr.push(Proposal(proposalStr, 0));
            

            emit ProposalRegistered(valPropArr);
        }
    }

    //l'admin arrête la phase de proposition
    function Admin2ProposalsRegistrationEnded() public onlyOwner{

        if(status == WorkflowStatus.ProposalsRegistrationStarted){
            status == WorkflowStatus.ProposalsRegistrationEnded;
            emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
        }
    }

    //l'admin commence les votes
    function Admin3VotingSessionStarted() public onlyOwner{

        if(status == WorkflowStatus.ProposalsRegistrationEnded){
            status == WorkflowStatus.VotingSessionStarted;
            emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
        }
    }

    //L'électeur choisie sa proposition en donnant l'id voulue
    function chooseProposal(uint _idVote) public {

        if(status == WorkflowStatus.VotingSessionStarted && votantMap[msg.sender].hasVoted == false && votantMap[msg.sender].isRegistered == true){
            votantMap[msg.sender].hasVoted = true;
            votantMap[msg.sender].votedProposalId = _idVote;
            emit Voted(msg.sender, _idVote);
            proposalArr[_idVote].voteCount ++;
        }
    }

    //l'admin arrête la session des votes
    function Admin4VotingSessionEnded() public onlyOwner{

        if(status == WorkflowStatus.VotingSessionStarted){
            status == WorkflowStatus.VotingSessionEnded;
            emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
        }
    }

    //on compte les votes
    function Admin5VotesTallied() public onlyOwner{

        if(status == WorkflowStatus.VotingSessionEnded){
            status == WorkflowStatus.VotesTallied;
            emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);

            for(uint i = 0; i < proposalArr.length; i++){
                if(proposalArr[i].voteCount > proposalArr[winningProposalId].voteCount){
                    winningProposalId = i;
                }
            }
        }
    }

    //bonus
    function looseRegistered(address _addr) public onlyOwner(){

        votantMap[_addr].isRegistered = false;
        emit Unregistered(_addr);
    }

    function viewProposal() public{   

        for(uint i = 0; i < proposalArr.length; i++){
            emit ProposalView(proposalArr[i].description);
        }
    }

}
