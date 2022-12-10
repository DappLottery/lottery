<script>
  import { useNavigate } from "svelte-navigator";
  
  export let currentId;  // current lottery id
  export let lotteryId;

  const navigate = useNavigate();
</script>

<div>
  {#if lotteryId < 0}
    Wrong lottery id...
  {:else if lotteryId == currentId}
    {navigate("/current")}
  {:else}
    <span>{lotteryId}</span>
  {/if}
</div>