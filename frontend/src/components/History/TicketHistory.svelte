<script>
	import { onMount } from "svelte";
	import { useNavigate } from "svelte-navigator";

  let tickets = [];
  onMount(async () => {
    await fetch(
      "http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/ticket",
      {
        method: "GET",
      }
    )
      .then(res => res.json())
      .then(result => (tickets = result));
    console.log(tickets);
  });

	const navigate = useNavigate();
</script>

<h2>Ticket History</h2>
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
		{#each tickets as ticket}
			<tr>
				<th scope="row" on:click={() => navigate(`/history/lottery/${ticket.game_number}`)}>{ticket.game_number}</th>
				<td>{ticket.player_address}</td>
				<td>{ticket.lottery_number}</td>
			</tr>
		{/each}
	</tbody>
</table>

<style>
</style>