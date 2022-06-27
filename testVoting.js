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
            await votingInstance.startProposalsRegistering();
            await expectRevert(votingInstance.addProposal("", {from:accounts[1]}), 'vous ne pouvez pas mettre une valeur nulle');

        });
        
        it("good addProposal was accept", async () => {

            await votingInstance.addVoter(accounts[2]);
            await votingInstance.startProposalsRegistering();
            const resAddV = await votingInstance.addProposal("Lucky", {from:accounts[2]});
            expectEvent(resAddV, 'ProposalRegistered', { 
                proposalId: new BN(0),
            });

        });

    });

});

