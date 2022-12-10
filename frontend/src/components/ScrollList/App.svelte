<!-- https://github.com/sveltejs/svelte-virtual-list -->

<script>
	import List from './List.svelte';
	import {loadItems} from './data.js';
	
	let filter = ''
	let allItems = loadItems()
	$: items = allItems.filter(i => i.LotteryId.includes(filter))
</script>

<p>
	List length: {items.length}
</p>

<div class="row">
	
	<div class='col'>
		<em>filter list</em>
		<input type="text" bind:value={filter} placeholder="input your filter" />
		<List {items}></List>
	</div>
	
</div>


<style>
	:global(body) {
		height: 100vh;
		display: flex;
		flex-flow: column;
	}
	input {
		width: 100%;
	}
	.row {
		flex: 1;
		display: flex;
		justify-content: space-between;
		overflow: hidden;
	}
	.col {
		flex: 1;
		min-height: 200px;
		display: flex;
		flex-flow: column nowrap;
		margin: 0 .2rem;
	}
	.col :global(.List) {
		flex: 1
	}
</style>