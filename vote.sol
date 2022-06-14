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
    WorkflowStatus status;
    //id du gagnant
    uint winningProposalId;

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted(address voter, uint proposalId);
    event Unregistered(address voterAddressLoose);
    event ProposalView(uint numberPropal, string propView);
    event VotantView(address votantAddress, uint votedProposalId);
    event WorkflowStatusView(string statusWas);
    event WinnerIs(uint winningPropID);
    event WinnerProposalIs(string proposalWin);

    constructor() {

        votantArray.push(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);//le owner a le droit de voter et proposer
        votantArray.push(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        votantArray.push(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
        votantArray.push(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
        votantArray.push(0x617F2E2fD72FD9D5503197092aC168c91465E7f2);
        votantArray.push(0x17F6AD8Ef982297579C203069C1DbfFE4348c372);
        votantArray.push(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678);
        votantArray.push(0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7);
        votantArray.push(0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C);
        votantArray.push(0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC);
        votantArray.push(0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c);
        votantArray.push(0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C);
        votantArray.push(0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB);
        votantArray.push(0x583031D1113aD414F02576BD6afaBfb302140225);
        votantArray.push(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        winningProposalId = 0;
        status = WorkflowStatus.RegisteringVoters;
        //je rajoute le vote nul en indice 0 car pour chaque votant votedProposalId étant initialisé à 0 on ne pouvait pas savoir si un votant avait effectivement voter pour la proposition zero  
        proposalArr.push(Proposal("Nul",0));
    }

    //ajoute un votant
    function addVoter (address addMore) internal onlyOwner {
        
        votantMap[addMore] = Voter(true, false, 0);
        emit VoterRegistered(addMore);
    }

    //l'admin enregistre les votants ici puis j'attends les propositions
    function Admin1RegisteringVoters() public onlyOwner{

        if(status != WorkflowStatus.RegisteringVoters)
            revert("Not the moment for registering votes");

        //parcours votantArray
        for(uint i = 0; i < votantArray.length; i++){
            addVoter(votantArray[i]);
        }
        status = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
        
    }

    //les votent soumettent une proposition
    function submitProposal (string memory _proposalStr) public payable{

        if(status == WorkflowStatus.ProposalsRegistrationStarted && votantMap[msg.sender].isRegistered == true){

            proposalArr.push(Proposal(_proposalStr, 0));
            emit ProposalRegistered(proposalArr.length);        
        }else{
            revert("Not the good account OR not the moment for submit a proposal");
        }
    }

    //l'admin arrête la phase de proposition
    function Admin2ProposalsRegistrationEnded() public onlyOwner{

        if(status != WorkflowStatus.ProposalsRegistrationStarted)
            revert("Not the moment for ProposalsRegistrationStarted");

        status = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
        
    }

    //l'admin commence les votes
    function Admin3VotingSessionStarted() public onlyOwner{

        if(status != WorkflowStatus.ProposalsRegistrationEnded)
            revert("Not the moment for ProposalsRegistrationEnded");


        status = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
        
    }

    //L'électeur choisie sa proposition en donnant l'id voulue
    function chooseProposal(uint _idVote) public {

        if(status == WorkflowStatus.VotingSessionStarted && votantMap[msg.sender].hasVoted == false && votantMap[msg.sender].isRegistered == true){

            votantMap[msg.sender].hasVoted = true;
            votantMap[msg.sender].votedProposalId = _idVote;
            emit Voted(msg.sender, _idVote);
            proposalArr[_idVote].voteCount ++;
        }else{
            revert("Choose proposal not accepted");
        }
    }

    //l'admin arrête la session des votes
    function Admin4VotingSessionEnded() public onlyOwner{

        if(status != WorkflowStatus.VotingSessionStarted)
            revert("Not the moment for VotingSessionStarted");

        status = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
        
    }

    //on compte les votes
    function Admin5VotesTallied() public onlyOwner{

        if(status != WorkflowStatus.VotingSessionEnded)
            revert("Not the moment for VotingSessionEnded");

        status = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);

        for(uint i = 0; i < proposalArr.length; i++){

            if(proposalArr[i].voteCount > proposalArr[winningProposalId].voteCount){

                winningProposalId = i;
            }
        }

        emit WinnerIs(winningProposalId);
        
    }

    function getWinner() public {

        if(status != WorkflowStatus.VotesTallied)
            revert("Not the moment for VotesTallied");

            emit WinnerProposalIs(proposalArr[winningProposalId].description);
        
    }

    //bonus
    function looseRegistered(address _addr) public onlyOwner(){

        votantMap[_addr].isRegistered = false;
        emit Unregistered(_addr);
    }

    //voir les proprositions
    function viewProposal() public{   

        if(votantMap[msg.sender].isRegistered != true)
            revert("Not the good user");

        for(uint i = 0; i < proposalArr.length; i++){
            emit ProposalView(i, proposalArr[i].description);
        }
        
    }

    //voir les résultats des votes, pour ne pas influencer les votants nous ne pouvons pas voir les votes faits tant qu'ils ne sont pas cloturés
    function viewVotes() public{

        if(votantMap[msg.sender].isRegistered != true)
            revert("Not the good user");
        
        if(status != WorkflowStatus.VotingSessionEnded || status != WorkflowStatus.VotesTallied) )
            revert("Not the moment for viewVotes");

        for(uint i = 0; i < votantArray.length; i++){
            emit VotantView(votantArray[i], votantMap[votantArray[i]].votedProposalId);
        }
        
    }

    //voir où nous en sommes du status du vote
    function viewStatus() public{

        if(status == WorkflowStatus.RegisteringVoters)
            emit WorkflowStatusView("RegisteringVoters");
        if(status == WorkflowStatus.ProposalsRegistrationStarted)
            emit WorkflowStatusView("ProposalsRegistrationStarted");
        if(status == WorkflowStatus.ProposalsRegistrationEnded)
            emit WorkflowStatusView("ProposalsRegistrationEnded");
        if(status == WorkflowStatus.VotingSessionStarted)
            emit WorkflowStatusView("VotingSessionStarted");
        if(status == WorkflowStatus.VotingSessionEnded)
            emit WorkflowStatusView("VotingSessionEnded");
        if(status == WorkflowStatus.VotesTallied)
            emit WorkflowStatusView("VotesTallied");
    }

}
