<script>
  import { useNavigate } from "svelte-navigator";

  import LotteryInfoById from "./State/LotteryInfoById.svelte";
  import TicketListById from "./State/TicketListById.svelte";
  
  export let currentId;  // current lottery id
  export let lotteryId;

  const navigate = useNavigate();
</script>

<div>
  {#if isNaN(lotteryId) || lotteryId < 0}
    {navigate("/history/lottery")}
  {:else if lotteryId == currentId}
    {navigate("/current")}
  {:else}
    <LotteryInfoById {lotteryId} />
    <TicketListById {lotteryId} />
  {/if}
</div>