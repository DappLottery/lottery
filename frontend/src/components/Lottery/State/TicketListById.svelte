<script>
  import SvelteTable from 'svelte-table';
  import { onMount } from "svelte";

  export let lotteryId;

  let rows = [];
  onMount(async () => {
    await fetch(
      `http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/ticket/game/${lotteryId}`,
      {
        method: "GET",
      }
    )
      .then(res => res.json())
      .then(result => (rows = result));
    console.log(rows);
  });

	// define column configs
	const columns = [
		{
			key: "LotteryId",
			title: "LotteryId",
			value: v => v.game_number,
			filterOptions: rows => {
				let nums = {};
				rows.forEach(row => {
					let num = row.game_number;
					if (nums[num] === undefined)
						nums[num] = {name: num, value: num};
				});
				// fix order
				nums = Object.entries(nums)
					.sort()
					.reduce((o, [k, v]) => ((o[k] = v), o), {});
				return Object.values(nums);
			},
			filterValue: v => v.game_number,
			sortable: true,
		},
		{
			key: "PlayerAddr",
			title: "PlayerAddr",
			value: v => v.player_address,
			filterOptions: rows => {
				let nums = {};
				rows.forEach(row => {
					let num = row.player_address;
					if (nums[num] === undefined)
						nums[num] = {name: num, value: num};
				});
				// fix order
				nums = Object.entries(nums)
					.sort()
					.reduce((o, [k, v]) => ((o[k] = v), o), {});
				return Object.values(nums);
			},
			filterValue: v => v.player_address.toLowerCase(),
			sortable: true,
		},
		{
			key: "LotteryNumber",
			title: "LotteryNumber",
			value: v => v.lottery_number,
			sortable: true,
		}
	];
</script>

<SvelteTable columns="{columns}" rows="{rows}"></SvelteTable>

<style>
</style>