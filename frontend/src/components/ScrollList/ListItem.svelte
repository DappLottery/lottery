<script>
	export let item;
</script>

<!-- data control-->
<div class='ListItem'>
	<p>Lottery ID : {item.LotteryId}</p>
	<p>Ticket ID : {item.TicketId}</p>
	<p>Ticket Number : {item.TicketNumber}</p>
</div>

<style>
	.ListItem {
		position: relative;
		margin: 0.2em 0;
		padding: 0.2em;
		border: 1px solid #eee;
		height: 4rem; /* without this is unstable */
		overflow: auto;
	}

	p {
		margin: 0;
		font-size: 14px;
	}
</style>