<script>
  import { onMount } from "svelte";
  import {
    defaultEvmStores as evm,
    connected,
    web3,
    // evmProviderType,
    selectedAccount,
    chainId,
    chainData,
    contracts,
  } from "svelte-web3";
  import { Stretch } from "svelte-loading-spinners";
  import { Router, Route } from "svelte-navigator";

  // super basic router
  let route = window.location.pathname || "/";
  function click(e) {
    var x = e.target.closest("a"),
      y = x && x.getAttribute("href");
    if (
      e.ctrlKey ||
      e.metaKey ||
      e.altKey ||
      e.shiftKey ||
      e.button ||
      e.defaultPrevented
    )
      return;
    if (!y || x.target || x.host !== location.host || y[0] == "#") return;
    e.preventDefault();
    history.pushState(y, "", y);
    route = y;
  }
  addEventListener("click", click);

  import LOTTERY from "./abis/Lottery.json";

  const LOTTERY_ON_GANACHE = "0x6852E606C00BdEcc49E699DBA84CaAB5e2e810F9";

  evm.attachContract("Lottery", LOTTERY_ON_GANACHE, LOTTERY.abi);

  let pending = false;
  let ticketPrice;
  let ticketNumber;
  let numTicketSold;
  let players;
  let luckyNumber;
  let winMoney;
  let firstWinners;
  let secondWinners;
  let thirdWinners;
  let myTickets;

  const connect = async () => {
    pending = true;
    try {
      await evm.setProvider();

      // Browser: () => evm.setProvider(),
      // Localhost4: () => evm.setProvider("http://127.0.0.1:8545", 4),
      // LocalhostNull: () => evm.setProvider("http://127.0.0.1:8545", null),
      // Gnosis: () => evm.setProvider("https://rpc.gnosischain.com"),
      // Arbitrum: () => evm.setProvider("https://arb1.arbitrum.io/rpc"),

      pending = false;
    } catch (e) {
      console.log(e);
      pending = false;
    }
  };

  const disconnect = async () => {
    await evm.disconnect();
    pending = false;
  };

  onMount(async () => {
    await connect();
    fetchExpireDate();
  });

  let expiration;
  const fetchExpireDate = async () => {
    expiration = await $contracts.Lottery.methods.getEndTime().call();
    console.log(expiration);
  };

  const getTransactionReceiptMined = (txHash, interval) => {
    const self = this;
    const transactionReceiptAsync = function (resolve, reject) {
      self.getTransactionReceipt(txHash, (error, receipt) => {
        if (error) {
          reject(error);
        } else if (receipt == null) {
          setTimeout(
            () => transactionReceiptAsync(resolve, reject),
            interval ? interval : 500
          );
        } else {
          resolve(receipt);
        }
      });
    };

    if (Array.isArray(txHash)) {
      return Promise.all(
        txHash.map(oneTxHash =>
          self.getTransactionReceiptMined(oneTxHash, interval)
        )
      );
    } else if (typeof txHash === "string") {
      return new Promise(transactionReceiptAsync);
    } else {
      throw new Error("Invalid Type: " + txHash);
    }
  };

  const waitForFunds = async () => {
    return new Promise((resolve, reject) => {
      $web3.eth.subscribe("pendingTransactions").on("data", resolve);
    });
  };

  const fetchData = async () => {
    try {
      ticketPrice = $web3.utils.fromWei(
        await $contracts.Lottery.methods.getTicketPrice().call(),
        "ether"
      );
      numTicketSold = await $contracts.Lottery.methods.getLottoId().call();
      players = await $contracts.Lottery.methods.getPlayers().call();

      luckyNumber = await $contracts.Lottery.methods.getLuckyNumber().call();
      winMoney = $web3.utils.fromWei(
        await $contracts.Lottery.methods.getWinMoney().call(),
        "ether"
      );

      myTickets = await $contracts.Lottery.methods
        .getTickets($selectedAccount)
        .call();
    } catch (err) {
      console.log(err);
      throw new Error(err);
    }
  };

  // import MetaMask from "./components/Wallet/MetaMask.svelte";
  // import LoginTest from "./components/Wallet/LoginTest.svelte";
  import Header from "./components/Header/Header.svelte";
  import CurrentLottery from "./components/LotteryInfo/CurrentLottery.svelte";
  import Admin from "./components/Account/Admin.svelte";
</script>

{#if !$connected}
  <!-- {#await connect()}Welcome!<br />{/await}
  {#if pending}connecting...{/if} -->
  <h1>Loading MetaMask...</h1>
  <Stretch size="600" color="#FF3E00" duration="2s" />
{:else}
  <Router>
    <Header />

    <main>
      <Route path="/">
        <CurrentLottery />
      </Route>

      <Route path="history">
        <div></div>
      </Route>
  
      <Route path="admin">
        <Admin {contracts} {selectedAccount} {fetchData} {luckyNumber} />
      </Route>
    </main>
  </Router>
{/if}

{#if !/^\/$/.test(route)}
  <self />
{/if}

<style>
</style>
