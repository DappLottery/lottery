const assert = require('assert');
const Lottery = artifacts.require('Lottery');

contract('Lottery', (accounts) => {
  let contract;

  beforeEach(async () => {
    contract = await Lottery.new();
  });

  it('should set the owner of the contract to the deploying address', async () => {
    const owner = await contract.owner();
    assert.equal(owner, accounts[0]);
  });

  it('should allow players to buy tickets', async () => {
    await contract.buyTicket({ value: web3.utils.toWei('0.15', 'ether'), from: accounts[1] });
    const player = await contract.players(accounts[1]);
    assert.equal(player.firstTickets.length, 1);
  });

  it('should not allow players to buy more than 20 tickets', async () => {
    for (let i = 0; i < 21; i++) {
      await contract.buyTicket({ value: web3.utils.toWei('0.15', 'ether'), from: accounts[1] });
    }
    const player = await contract.players(accounts[1]);
    assert.equal(player.firstTickets.length, 20);
  });

  it('should not allow players to buy tickets after the game has started', async () => {
    await contract.startGame();
    try {
      await contract.buyTicket({ value: web3.utils.toWei('0.15', 'ether'), from: accounts[1] });
      assert.fail('Expected buyTicket to throw an error');
    } catch (err) {
      assert.ok(/revert/.test(err.message));
    }
  });

  it('should not allow players to buy tickets with insufficient funds', async () => {
    try {
      await contract.buyTicket({ value: web3.utils.toWei('0.1', 'ether'), from: accounts[1] });
      assert.fail('Expected buyTicket to throw an error');
    } catch (err) {
      assert.ok(/revert/.test(err.message));
    }
  });
});
