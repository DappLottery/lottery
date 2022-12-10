<script>
  import {
    web3,
    contracts,
    selectedAccount,
  } from "svelte-web3";

  import CurrentLotteryInfo from "./Current/CurrentLotteryInfo.svelte";
  import CurrentTicketList from "./Current/CurrentTicketList.svelte";
  import BuyTicket from "./Current/BuyTicket.svelte";

  let ticketPrice;
  let numTicketSold;
  let winMoney;
  let myTickets;

  const fetchData = async () => {
    try {
      ticketPrice = $web3.utils.fromWei(
        await $contracts.Lottery.methods.getTicketPrice().call(),
        "ether"
      );
      numTicketSold = await $contracts.Lottery.methods.getLottoId().call();
      winMoney = $web3.utils.fromWei(
        await $contracts.Lottery.methods.getWinMoney().call(),
        "ether"
      );
      myTickets = await $contracts.Lottery.methods
        .getTickets($selectedAccount)
        .call();
    } catch (err) {
      console.log(err);
      throw new Error(err);
    }
  };

  const repeatFetch = async () => {
    try {
      numTicketSold = await $contracts.Lottery.methods.getLottoId().call();
      winMoney = $web3.utils.fromWei(
        await $contracts.Lottery.methods.getWinMoney().call(),
        "ether"
      );
      myTickets = await $contracts.Lottery.methods
        .getTickets($selectedAccount)
        .call();
    } catch (err) {
      console.log(err);
      throw new Error(err);
    }
  };

  setInterval(() => {
    repeatFetch();
  }, 30 * 1000);
</script>

<div class="cur-lottery">
  {#await fetchData()}
    Fetching contract dataset...
  {:then _}
    <CurrentLotteryInfo bind:numTicketSold={numTicketSold} bind:winMoney={winMoney} />
    <CurrentTicketList bind:myTickets={myTickets} />
    <BuyTicket fetchData={repeatFetch} />
  {/await}
</div>