# Voting Test 
## Système de vote

Nous allons ici lire les tests pour Truffle réalisées sur le fichier testVoting.js, ce fichier étant lié au contrat Voting.sol fourni par l'école Alyra. Le but est de vérifier les fonctions proposées. 

- expect
- expectEvent
- expectRevert

L'instanciation du contrat est réalisée au préalable lors d'un *beforeEach*
```js
beforeEach(async function () {
    votingInstance = await Vote.new({from:owner});
});
```

## Bonus

- Test complet jusqu'à la désignation du gagnant attendu

## Expect
- WorkflowStatus equal to RegisteringVoters

Si le statuts de l'application de vote, au moment de la création, permet d'enregistrer les votants nous avons un retour positif de cette fonction Expect.
```js
it("WorkflowStatus equal to RegisteringVoters", async () => {
    expect((await votingInstance.workflowStatus()).toString()).to.equal(Vote.WorkflowStatus.RegisteringVoters.toString());
});
```
Nous testons ici l'égalité entre l'objet de type enum **workflowStatus** lié à l'instance de vote **votingInstance** correspond en tant que chaine de caractère à l'état **RegisteringVoters** lui aussi converti en chaine de caractère. 
À noter que ces éléments  doivent être convertis car sinon ils ne peuvent être comparés.

Ce test est ici un succès.


## expectEvent

Nous testons ici l’évènement qui apparait lors de l'appel de la fonction **addVoter**

```js
it("AddVoter event was done ", async () => {
    const resAddV = await votingInstance.addVoter(accounts[1]);
    expectEvent(resAddV, 'VoterRegistered', { 
        voterAddress: accounts[1],
    });
});
```
Nous prenons comme paramètre de fonction le second compte fourni par l'environnement de test (ganache pour ma part), le premier étant le owner (*accounts[0]*), je préfere utiliser un compte plus neutre pour la suite.

On appelle la fonction (stocké dans la constante *resAddV*) et la passe en paramètre ainsi que le nom de l'event souhaité *VoterRegistered* en indiquant le nom de la variable *voterAddress* qui est présent dans l'event ainsi que la donnée de départ *accounts[1]* pour vérifier que les informations correspondent bien.

Ce test est ici un succès.

## expectRevert

```js
it("addProposal empty was test", async () => {
    await votingInstance.addVoter(accounts[1]);
    await votingInstance.startProposalsRegistering({from:owner});
    await expectRevert(votingInstance.addProposal("", {from:accounts[1]}), 'vous ne pouvez pas mettre une valeur nulle');
});
```

A nouveau je dois faire appel à la fonction **addVoter** et je lui passe en paramètre **accounts[1]**.
Je dois activé la fonction **startProposalsRegistering** en paramètre **{from:owner}** car je suis le propriétaire de ce contrat, (par défaut ne rien indiquer marche aussi dans cette version mais étant prudent et par souci de lecture je souhaite le spécifier) pour pouvoir arriver au moment voulu de cette application.

Je peux maintenant faire une proposition car **accounts[1]** est inscrit en tant que votant.
Je désire tester ce *require* avec **expectRevert** qui est présent dans Contrat.sol
```js
require(keccak256(abi.encode(_desc)) != keccak256(abi.encode("")), 'Vous ne pouvez pas ne rien proposer');
```
Je lui passe donc une proposition vide qui revient logiquement en failed dans le terminal
```js
Contract: Voting2
   test complet
     addProposal empty was test:

  Wrong kind of exception received
  + expected - actual

  -Vous ne pouvez pas ne rien proposer -- Reason given: Vous ne pouvez pas ne rien proposer.
  +vous ne pouvez pas mettre une valeur nulle
  
  at expectException (/home/fiurino/node_modules/@openzeppelin/test-helpers/src/expectRevert.js:20:30)
  at expectRevert (/home/fiurino/node_modules/@openzeppelin/test-helpers/src/expectRevert.js:75:3)
  at Context.<anonymous> (test/testVoting.js:37:13)
```

- Test expectEvent pour vérifier la réussite
Je teste ensuite si en envoyant une proposition non nulle pour que le test fonctionne
```js
it("good addProposal was accept", async () => {
    await votingInstance.addVoter(accounts[2]);
    await votingInstance.startProposalsRegistering({from:owner});
    const resAddV = await votingInstance.addProposal("Lucky", {from:accounts[2]});
    expectEvent(resAddV, 'ProposalRegistered', { 
        proposalId: new BN(0),
    });
});
```

Et c'est une réussite
```js
 ✔ good addProposal was accept (301ms)
```

# Test de l'application jusqu'à désignation d'un gagnant

J'exécute donc toutes les fonctions de l'application pour pouvoir vérifier l'ensemble du processus de vote.
Elles sont découpées comme suit :
- J'ajoute les comptes des votants
```js
await votingInstance.addVoter(accounts[1]);
await votingInstance.addVoter(accounts[2]);
await votingInstance.addVoter(accounts[3]);
await votingInstance.addVoter(accounts[4]);
await votingInstance.addVoter(accounts[5]);
await votingInstance.addVoter(accounts[6]);
await votingInstance.addVoter(accounts[7]);
```

- Je vais à l'enregistrement des propositions et je les enregistre
```js
await votingInstance.startProposalsRegistering({from:owner});
await votingInstance.addProposal("Premiere proposition", {from:accounts[1]});
await votingInstance.addProposal("Seconde proposition", {from:accounts[2]});
await votingInstance.addProposal("Troisieme proposition", {from:accounts[3]});
await votingInstance.addProposal("Quatrième proposition", {from:accounts[4]});
```

- Je les clos pour commence les votes
```js
await votingInstance.endProposalsRegistering({from:owner});
await votingInstance.startVotingSession({from:owner});
```
- Les votes sont enregistrés sur la blockchain
```js
await votingInstance.setVote(0, {from:accounts[1]});
await votingInstance.setVote(0, {from:accounts[2]});
await votingInstance.setVote(1, {from:accounts[3]});
await votingInstance.setVote(3, {from:accounts[4]});
await votingInstance.setVote(2, {from:accounts[5]});
await votingInstance.setVote(3, {from:accounts[6]});
await votingInstance.setVote(3, {from:accounts[7]});
```
- Je finis la séance de vote et je départage le gagnant
```js
await votingInstance.endVotingSession({from:owner});
await votingInstance.tallyVotes({from:owner});
expect( await votingInstance.winningProposalID.call()).to.be.bignumber.equal(new BN(3));
```
Si le gagnant correspond à 3 dans l'indice du tableau, c'est à dire à **Quatrième proposition** c'est que le test s'est correctement déroulé
