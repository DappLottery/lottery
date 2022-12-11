<script>
  import {
    web3,
    contracts,
    selectedAccount,
  } from "svelte-web3";

  import CurrentLotteryInfo from "./Current/CurrentLotteryInfo.svelte";
  import CurrentTicketList from "./Current/CurrentTicketList.svelte";
  import BuyTicket from "./Current/BuyTicket.svelte";

  export let lotteryId;
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
      
      await fetch(
        "http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/history",
        {
          method: "GET",
        }
      )
        .then(res => res.json())
        .then(result => (lotteryId = result.length));

      await fetch(
        `http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/ticket/game/${lotteryId}`,
        {
          method: "GET",
        }
      )
        .then(res => res.json())
        .then(result => (myTickets = result));
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

      await fetch(
        `http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/ticket/game/${lotteryId}`,
        {
          method: "GET",
        }
      )
        .then(res => res.json())
        .then(result => (myTickets = result));
    } catch (err) {
      console.log(err);
      throw new Error(err);
    }
  };
</script>

<div class="cur-lottery">
  {#await fetchData()}
    Fetching contract dataset...
  {:then _}
    <CurrentLotteryInfo bind:lotteryId={lotteryId} bind:numTicketSold={numTicketSold} bind:winMoney={winMoney} />
    <CurrentTicketList bind:rows={myTickets} />
    <BuyTicket bind:lotteryId={lotteryId} fetchData={repeatFetch} />
  {/await}
</div>
