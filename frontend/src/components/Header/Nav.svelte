<script>
  import {
    selectedAccount,
    contracts,
  } from "svelte-web3";
  import { Link } from "svelte-navigator";
</script>

<Link to="/">Info</Link>
<span> | </span>
<Link to="history">History</Link>
{#await $contracts.Lottery.methods.getOwner().call()}
  <div></div>
{:then owner}
  {#if owner.toLowerCase() == $selectedAccount.toLowerCase()}
    <span> | </span>
    <Link to="admin">Admin</Link>
  {/if}
{/await}