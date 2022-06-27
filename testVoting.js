const Vote = artifacts.require("./Voting.sol");
const { BN, expectRevert, expectEvent } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');


contract('Voting2', accounts => {

    const owner = accounts[0];

    let VotingInstance;

    describe("test complet", function () {
        beforeEach(async function () {
            votingInstance = await Vote.new({from:owner});
        });


        it("WorkflowStatus equal to RegisteringVoters", async () => {

            expect((await votingInstance.workflowStatus()).toString()).to.equal(Vote.WorkflowStatus.RegisteringVoters.toString());
            
        });

        it("AddVoter event was done ", async () => {

            const resAddV = await votingInstance.addVoter(accounts[1]);
            expectEvent(resAddV, 'VoterRegistered', { 
                voterAddress: accounts[1],
            });

        });

        it("addProposal empty was test", async () => {

            await votingInstance.addVoter(accounts[1]);
            await votingInstance.startProposalsRegistering({from:owner});
            await expectRevert(votingInstance.addProposal("", {from:accounts[1]}), 'vous ne pouvez pas mettre une valeur nulle');

        });
        
        it("good addProposal was accept", async () => {

            await votingInstance.addVoter(accounts[2]);
            await votingInstance.startProposalsRegistering({from:owner});
            const resAddV = await votingInstance.addProposal("Lucky", {from:accounts[2]});
            expectEvent(resAddV, 'ProposalRegistered', { 
                proposalId: new BN(0),
            });

        });

        it("test vote have a winner", async () => {

            await votingInstance.addVoter(accounts[1]);
            await votingInstance.addVoter(accounts[2]);
            await votingInstance.addVoter(accounts[3]);
            await votingInstance.addVoter(accounts[4]);
            await votingInstance.addVoter(accounts[5]);
            await votingInstance.addVoter(accounts[6]);
            await votingInstance.addVoter(accounts[7]);
            
            await votingInstance.startProposalsRegistering({from:owner});
            await votingInstance.addProposal("Premiere proposition", {from:accounts[1]});
            await votingInstance.addProposal("Seconde proposition", {from:accounts[2]});
            await votingInstance.addProposal("Troisieme proposition", {from:accounts[3]});
            await votingInstance.addProposal("Quatrième proposition", {from:accounts[4]});

            
            await votingInstance.endProposalsRegistering({from:owner});
            await votingInstance.startVotingSession({from:owner});

            await votingInstance.setVote(0, {from:accounts[1]});
            await votingInstance.setVote(0, {from:accounts[2]});
            await votingInstance.setVote(1, {from:accounts[3]});
            await votingInstance.setVote(3, {from:accounts[4]});
            await votingInstance.setVote(2, {from:accounts[5]});
            await votingInstance.setVote(3, {from:accounts[6]});
            await votingInstance.setVote(3, {from:accounts[7]});

            await votingInstance.endVotingSession({from:owner});
            await votingInstance.tallyVotes({from:owner});

            expect( await votingInstance.winningProposalID.call()).to.be.bignumber.equal(new BN(3));

        });

    });

});

