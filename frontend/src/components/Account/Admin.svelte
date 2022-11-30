<script>
  export let contracts;
  export let selectedAccount;

  export let fetchData;
  export let luckyNumber;

  let firstWinners;
  let secondWinners;
  let thirdWinners;

  const pickWinner = async () => {
    try {
      $contracts.Lottery.methods
        .pickWinner()
        .send({
          from: $selectedAccount,
          gasLimit: 6721975,
          gasPrice: 30000000000,
        })
        .on("receipt", function (receipt) {
          // console.log("receipt:", receipt);

          fetchData();
        });
    } catch (err) {
      console.log(err);
    }

    console.log(luckyNumber);
  };

  const resetLottery = async () => {
    try {
      await $contracts.Lottery.methods
        .resetLottery()
        .send({ from: $selectedAccount });
    } catch (err) {
      console.log(err);
    }

    fetchData();
  };

  const fetchWinners = async () => {
    try {
      firstWinners = await $contracts.Lottery.methods.getFirstWinners().call();
      secondWinners = await $contracts.Lottery.methods
        .getSecondWinners()
        .call();
      thirdWinners = await $contracts.Lottery.methods.getThirdWinners().call();
    } catch (err) {
      console.log(err);
      throw new Error(err);
    }
  };
</script>

<div>
  {#await $contracts.Lottery.methods.getOwner().call()}
    there's no account...
    <br/>
  {:then owner}
    {#if owner.toLowerCase() == $selectedAccount.toLowerCase()}
      Admin Menu
      <div class="card">
        <button class="button" on:click={pickWinner}>Pick Winner</button>
        <!-- <button class="button" on:click={sendMoney}>Send Money</button> -->
        <button class="button" on:click={resetLottery}>Reset Lottery</button>
      </div>

      {#await fetchWinners()}
        {firstWinners} and {secondWinners} and {thirdWinners}
      {/await}
    {/if}
  {/await}
</div>

<style>
</style>
