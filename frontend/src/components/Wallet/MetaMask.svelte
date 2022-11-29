<script>
  export let disconnect;
  
  let connected = false;
  let installed = false;
  let walletConnected = false;

  let account;

  function isMetaMaskInstalled() {
    return Boolean(window.ethereum && window.ethereum.isMetaMask);
  }

  async function isMetaMaskConnected() {
    const {ethereum} = window;
    const accounts = await ethereum.request({method: 'eth_accounts'});
    return accounts && accounts.length > 0;
  }

  async function initialise() {
    connected = await isMetaMaskConnected();
    installed = isMetaMaskInstalled();
    walletConnected = installed && connected;

    if (!walletConnected) disconnect();
  }

  async function connectWallet() {
    walletConnected = false;
    const { ethereum } = window;
    console.log('ethereum: ', ethereum);
    console.log('Connecting wallet');
    await ethereum
    .request({ method: 'eth_requestAccounts' })
    .then((accountList) => {
      account = accountList[0];
      walletConnected = true;
      console.log('wallet connected');
      console.log(account);
    })
    .catch((error) => {
      walletConnected = false;
      console.log('error connecting wallet');
    });
  }

  initialise();

  window.ethereum.on('accountsChanged', async () => {
    initialise();
  });
</script>

<div>
  {#if installed}
    <div>
      {#if walletConnected}
        <div>
          <span class="dotConnected" />
          Connected Account: {account}
        </div>
      {:else} 
        <div>
          <button class="button buttonMetaMask" on:click={connectWallet}>
            Connect MetaMask
          </button>
          <br/>
          <span class="req-msg">
            Please connect MetaMask first.
          </span>
        </div>
        
      {/if}
    </div>
  {:else}
    <div>
      <span>Please install MetaMask...</span>
    </div>
  {/if}
</div>

<style>
</style>
