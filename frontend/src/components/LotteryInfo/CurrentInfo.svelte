<script>
  import Current from "./Current.svelte";
  import TicketBuy from "./TicketBuy.svelte";

  export let fetchData;
</script>

<div class="cur-info">
  <Current />
  <TicketBuy {fetchData} />
</div>