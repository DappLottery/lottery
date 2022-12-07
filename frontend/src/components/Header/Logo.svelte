<script>
  import {
    selectedAccount,
  } from "svelte-web3";

  const accountSubstring = () => {
    let _accountAddr = $selectedAccount;
    let addr = "";
    
    for (let i = 0; i < 5; i++) addr += _accountAddr[i];
    addr += "..";
    for (let i = 0; i < 5; i++) addr += _accountAddr[37 + i];

    return addr;
  };
  let accountAddr = accountSubstring();

  setInterval(() => {
    accountAddr = accountSubstring();
  }, 1000);
</script>

<h3 class="title-logo">dApp Lottery</h3>
<span>User: {accountAddr}</span>
<!-- <br/>
<span>User: {typeof $selectedAccount}</span> -->

<style>
  .title-logo {
    margin: 0px;
  }
</style>