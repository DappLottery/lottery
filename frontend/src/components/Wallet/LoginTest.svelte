<script>
  export let connected;
  export let connect;
  export let pending;
  export let disconnect;
  export let selectedAccount;
  
  let isConnected = false;
  let isInstalled = false;
  let walletConnected = false;

  function isMetaMaskInstalled() {
    return Boolean(window.ethereum && window.ethereum.isMetaMask);
  }

  async function isMetaMaskConnected() {
    const {ethereum} = window;
    const accounts = await ethereum.request({method: 'eth_accounts'});
    return accounts && accounts.length > 0;
  }

  async function initialise() {
    isConnected = await isMetaMaskConnected();
    isInstalled = isMetaMaskInstalled();
    walletConnected = isInstalled && isConnected;

    if (!walletConnected) disconnect();
  }

  const checkConnection = () => {
    if (!walletConnected) {
      if ($connected) disconnect();
      return false;
    } else {
      
    }
  };

  async function connectWallet() {
    const { ethereum } = window;
    console.log('ethereum: ', ethereum);
    console.log('Connecting wallet');
    await ethereum
      .request({ method: 'eth_requestAccounts' })
      .then((accountList) => {
        console.log('wallet connected');
        console.log(accountList);
      })
      .catch((error) => {
        console.log('error connecting wallet');
      });
  }

  initialise();

  window.ethereum.on('accountsChanged', async () => {
    initialise();
  });
</script>

<div>
  {#if !$connected}
    {#await connect()}
      <div>
        {#if !isInstalled}
          <span>Please install MetaMask first.</span>
        {:else}
          <button class="button buttonMetaMask" on:click={connectWallet}>
            Connect MetaMask
          </button>
          <br/>
          <span class="req-msg">
            Please connect MetaMask first.
          </span>
        {/if}
      </div>
    {/await}
    {#if pending}connecting...{/if}
  {:else}
    <div>
      <button class="button buttonMetaMask" on:click={disconnect}>
        Disconnect MetaMask
      </button>
      <br/>
      <span class="account-addr">
        Accout: {$selectedAccount}
      </span>
    </div>
  {/if}
</div>

<style>
</style>
