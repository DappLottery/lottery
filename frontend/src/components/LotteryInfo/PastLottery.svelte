<script>
  export let lotteryId;
</script>

<div>
  {#if lotteryId == 0}
    There is no previous lottery
  {:else}
    <span>{lotteryId}</span>
  {/if}
</div>