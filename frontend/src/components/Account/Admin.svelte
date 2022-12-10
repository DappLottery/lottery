<script>
  import { contracts, selectedAccount } from "svelte-web3";

  import { useNavigate } from "svelte-navigator";

  // export let fetchData;

  let firstWinners = [];
  let secondWinners = [];
  let thirdWinners = [];

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
        });
    } catch (err) {
      console.log(err);
    }

    fetchWinners();
    // Post history to backend

    await fetch(
      "http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/history/upload",
      {
        method: "POST",
        body: JSON.stringify([
          // Array of history
          {
            first_winner: firstWinners,
            second_winner: secondWinners,
            third_winner: thirdWinners,
          },
        ]),
      }
    );
  };

  const resetLottery = async () => {
    try {
      await $contracts.Lottery.methods
        .resetLottery()
        .send({ from: $selectedAccount });
    } catch (err) {
      console.log(err);
    }

    firstWinners = [];
    secondWinners = [];
    thirdWinners = [];
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

  const navigate = useNavigate();
</script>

<div>
  {#await $contracts.Lottery.methods.getOwner().call()}
    there's no account...
    <br />
  {:then owner}
    {#if owner.toLowerCase() == $selectedAccount.toLowerCase()}
      Admin Menu
      <div class="card">
        <button class="button" on:click={pickWinner}>Pick Winner</button>
        <!-- <button class="button" on:click={sendMoney}>Send Money</button> -->
        <button class="button" on:click={resetLottery}>Reset Lottery</button>
      </div>

      {#await fetchWinners()}
        Fetching contract dataset...
      {:then _}
        {firstWinners} and {secondWinners} and {thirdWinners}
      {/await}
    {:else}
      <!-- 권한이 없는 페이지 입니다. -->
      {navigate("/")}
    {/if}
  {/await}
</div>

<style>
</style>
