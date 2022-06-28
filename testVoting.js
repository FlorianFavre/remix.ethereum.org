const Vote = artifacts.require("./Voting.sol");
const { BN, expectRevert, expectEvent } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');


contract('Voting2', accounts => {

    const owner = accounts[0];
    const voter1 = accounts[1];
    const voter2 = accounts[2];

    let VotingInstance;

    describe("tests pour l'enregistrement des votants", function () {

        beforeEach(async function () {

            votingInstance = await Vote.new({from:owner});

        });

        it("WorkflowStatus equal to RegisteringVoters", async () => {

            expect((await votingInstance.workflowStatus()).toString()).to.equal(Vote.WorkflowStatus.RegisteringVoters.toString());
            
        });

        it("AddVoter event was done ", async () => {

            const resAddV = await votingInstance.addVoter(voter1);
            expectEvent(resAddV, 'VoterRegistered', { 
                voterAddress: voter1,
            });

            const storedData = await votingInstance.getVoter(voter1, {from:voter1});
            await expect(storedData.isRegistered).to.equal(true);

        });

    });

    describe("tests pour l'enregistrement des votants", function () {

        beforeEach(async function () {

            votingInstance = await Vote.new({from:owner});
            await votingInstance.addVoter(voter1);
            await votingInstance.startProposalsRegistering({from:owner});

        });
        

        it("addProposal empty was test", async () => {

            await expectRevert(votingInstance.addProposal("", {from:voter1}), 'Vous ne pouvez pas ne rien proposer');

        });
        
        it("good addProposal was accept", async () => {
            
            const resAddV = await votingInstance.addProposal("Lucky", {from:voter1});
            expectEvent(resAddV, 'ProposalRegistered', { 
                proposalId: new BN(0),
            });

        });

    });

    describe("test complet", function () {

        before(async function () {

            votingInstance = await Vote.deployed({from:owner});
            expect((await votingInstance.workflowStatus()).toString()).to.equal(Vote.WorkflowStatus.RegisteringVoters.toString());
            await votingInstance.addVoter(voter1);
            await votingInstance.addVoter(voter2);
            await votingInstance.addVoter(accounts[3]);
            await votingInstance.addVoter(accounts[4]);
            await votingInstance.addVoter(accounts[5]);
            await votingInstance.addVoter(accounts[6]);
            await votingInstance.addVoter(accounts[7]);

        });


        it("test vote have a winner", async () => {
                        
            await votingInstance.startProposalsRegistering({from:owner});

            expect((await votingInstance.workflowStatus()).toString()).to.equal(Vote.WorkflowStatus.ProposalsRegistrationStarted.toString());
            await votingInstance.addProposal("Premiere proposition", {from:voter1});
            await votingInstance.addProposal("Seconde proposition", {from:voter2});
            await votingInstance.addProposal("Troisieme proposition", {from:accounts[3]});
            await votingInstance.addProposal("Quatrième proposition", {from:accounts[4]});            
            await votingInstance.endProposalsRegistering({from:owner});

            expect((await votingInstance.workflowStatus()).toString()).to.equal(Vote.WorkflowStatus.ProposalsRegistrationEnded.toString());
            await votingInstance.startVotingSession({from:owner});
            
            expect((await votingInstance.workflowStatus()).toString()).to.equal(Vote.WorkflowStatus.VotingSessionStarted.toString());
            await votingInstance.setVote(0, {from:voter1});
            await votingInstance.setVote(0, {from:voter2});
            await votingInstance.setVote(1, {from:accounts[3]});
            await votingInstance.setVote(3, {from:accounts[4]});
            await votingInstance.setVote(2, {from:accounts[5]});
            await votingInstance.setVote(3, {from:accounts[6]});
            await votingInstance.setVote(3, {from:accounts[7]});

            await votingInstance.endVotingSession({from:owner});
            expect((await votingInstance.workflowStatus()).toString()).to.equal(Vote.WorkflowStatus.VotingSessionEnded.toString());
            
            await votingInstance.tallyVotes({from:owner});

        });

        after( async function (){
            expect( await votingInstance.winningProposalID.call()).to.be.bignumber.equal(new BN(3));
            
        })

    });

});

