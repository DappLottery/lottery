<script>
  import { selectedAccount } from 'svelte-web3';
	import { onMount } from "svelte";
	import { useNavigate } from "svelte-navigator";

  let myTickets = [];
  onMount(async () => {
    await fetch(
      `http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/ticket/addr/${$selectedAccount}`,
      {
        method: "GET",
      }
    )
      .then(res => res.json())
      .then(result => (myTickets = result));
    console.log(myTickets);
  });

	const navigate = useNavigate();
</script>

<h2>My Ticket History</h2>
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
			<th>PlayerAddr</th>
			<th>LotteryNumber</th>
		</tr>
	</thead>
	<tbody>
		{#each myTickets as myTicket}
			<tr>
				<th scope="row" on:click={() => navigate(`/history/lottery/${myTicket.game_number}`)}>{myTicket.game_number}</th>
				<td>{myTicket.player_address}</td>
				<td>{myTicket.lottery_number}</td>
			</tr>
		{/each}
	</tbody>
</table>

<style>
</style>