<script>
	import { web3 } from "svelte-web3";
  import SvelteTable from 'svelte-table';
	import { onMount } from "svelte";

  let rows = [];
  onMount(async () => {
    await fetch(
      "http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/history",
      {
        method: "GET",
      }
    )
      .then(res => res.json())
      .then(result => {
        rows = result;
        rows.forEach((object, i) => {
          object.id = i;
        });
      });

    console.log(rows);
  });

	// define column configs
	const columns = [
		{
			key: "LotteryID",
			title: "LotteryID",
			value: v => v.id,
			sortable: true,
		},
		{
			key: "TicketSold",
			title: "TicketSold",
			value: v => v.ticket_sold,
			sortable: true,
		},
		{
			key: "GameMoney",
			title: "GameMoney",
			value: v => $web3.utils.fromWei(v.game_money.toString(), "ether"),
			sortable: true,
		},
		{
			key: "LuckyNumber",
			title: "LuckyNumber",
			value: v => v.lucky_number,
			sortable: true,
		},
	];
</script>

<SvelteTable columns="{columns}" rows="{rows}"></SvelteTable>

<style>
</style>