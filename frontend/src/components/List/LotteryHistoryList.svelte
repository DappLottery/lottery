<script>
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
        .then(result => (rows = result));
      console.log(rows);
    });

	import SvelteTable from 'svelte-table';

	// define column configs
	const columns = [
		{
			key: "FirstWinners",
			title: "FirstWinners",
			value: v => v.first_winner,
			sortable: true,
		},
		{
			key: "SecondWinners",
			title: "SecondWinners",
			value: v => v.second_winner,
			sortable: true,
		},
		{
			key: "ThirdWinners",
			title: "ThirdWinners",
			value: v => v.third_winner,
			sortable: true,
		}
	];
</script>

<SvelteTable columns="{columns}" rows="{rows}"></SvelteTable>


<style>
	:global(tbody) {
		height:250px;
		overflow:auto;
		display: block;
	}
	:global(thead, tbody tr) {
		display:table;
		width:80%;
		table-layout:fixed;
	}
	:global(th:nth-child(4), td:nth-child(4)) {
		width: 60%;
	}
</style>
