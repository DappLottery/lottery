<script>
  import {
    web3,
    contracts,
    selectedAccount,
  } from "svelte-web3";

  import Current from "./Current.svelte";
  import TicketBuy from "./TicketBuy.svelte";
  import TicketList from "./TicketList.svelte";

  export let lotteryId;
  let ticketPrice;
  let numTicketSold;
  let winMoney;
  let myTickets;

  const fetchData = async () => {
    try {
      numTicketSold = await $contracts.Lottery.methods.getLottoId().call();
      winMoney = $web3.utils.fromWei(
        await $contracts.Lottery.methods.getWinMoney().call(),
        "ether"
      );

      ticketPrice = $web3.utils.fromWei(
        await $contracts.Lottery.methods.getTicketPrice().call(),
        "ether"
      );
      myTickets = await $contracts.Lottery.methods
        .getTickets($selectedAccount)
        .call();
      
      await fetch(
        "http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/history",
        {
          method: "GET",
        }
      )
        .then(res => res.json())
        .then(result => (lotteryId = result.length));

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
    <Current bind:numTicketSold={numTicketSold} bind:winMoney={winMoney} />
    <TicketBuy {fetchData} />
    <TicketList bind:myTickets={myTickets} />
  {/await}
</div>
