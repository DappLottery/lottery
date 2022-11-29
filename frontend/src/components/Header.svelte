<script>
  import Current from "./LotteryInfo/Current.svelte";

  export let web3;
  export let contracts;
</script>

<div>
  <h1>Lottery dApp</h1>
  <Current {web3} {contracts} />
</div>

<style>
</style>
