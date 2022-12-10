<script>
  import { useNavigate } from "svelte-navigator";
  
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
    <span>{lotteryId}</span>
    <span>{typeof lotteryId}</span>
  {/if}
</div>