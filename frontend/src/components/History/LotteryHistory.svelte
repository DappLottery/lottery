<script>
	import { web3 } from "svelte-web3";
	import { onMount } from "svelte";
	import { useNavigate } from "svelte-navigator";

  let myTickets = [];
  onMount(async () => {
    await fetch(
      "http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/history",
      {
        method: "GET",
      }
    )
      .then(res => res.json())
      .then(result => {
        myTickets = result;
        // rows.forEach((object, i) => {
        //   object.id = i;
        // });
      });

    console.log(myTickets);
  });

	const navigate = useNavigate();
</script>

<h2>Lottery History</h2>
<table
	border="1"
	bordercolor="white"
	width="700"
	height="100"
	align="center"
>
	<thead>
		<tr>
			<th>LotteryID</th>
			<th>TicketSold</th>
			<th>GameMoney</th>
			<th>LuckyNumber</th>
		</tr>
	</thead>
	<tbody>
		{#each myTickets as myTicket, i}
			<tr>
				<th scope="row" on:click={() => navigate(`${i}`)}>{i}</th>
				<td>{myTicket.ticket_sold}</td>
				<td>{$web3.utils.fromWei(myTicket.game_money.toString(), "ether")}</td>
				<td>{myTicket.lucky_number}</td>
			</tr>
		{/each}
	</tbody>
</table>

<style>
</style>