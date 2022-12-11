<script>
  import { onMount } from "svelte";
  import {
    defaultEvmStores as evm,
    connected,
    web3,
    // evmProviderType,
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

  const LOTTERY_ON_GANACHE = "0xe2C3662e046a7b627E098e0F6568EeE612550554";

  evm.attachContract("Lottery", LOTTERY_ON_GANACHE, LOTTERY.abi);

  let pending = false;
  let lotteryId = 0;

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

  import Header from "./components/Header/Header.svelte";
  import InfoNav from "./components/Header/InfoNav.svelte";
  import HistoryNav from "./components/Header/HistoryNav.svelte";

  import CurrentLottery from "./components/Lottery/CurrentLottery.svelte";
  import LotteryState from "./components/Lottery/LotteryState.svelte";

  import LotteryHistory from "./components/History/LotteryHistory.svelte";
  import TicketHistory from "./components/History/TicketHistory.svelte";
  import MyTicketHistory from "./components/History/MyTicketHistory.svelte";

  import Admin from "./components/Account/Admin.svelte";

  import Exception from "./components/Error/Exception.svelte";
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
      <Route path="history/*">
        <HistoryNav />

        <Route path="lottery/*">
          <Route path="/">
            <LotteryHistory />
          </Route>
          <Route path="/:id" let:params>
            <LotteryState bind:currentId={lotteryId} lotteryId={params.id} />
          </Route>
        </Route>
        <Route path="ticket/*">
          <Route path="all">
            <TicketHistory />
          </Route>
          <Route path="my">
            <MyTicketHistory />
          </Route>
          <Route path="*">
            <Exception defaultPath={"/history/ticket/all"} />
          </Route>
        </Route>
        <Route path="*">
          <Exception defaultPath={"/history/lottery"} />
        </Route>
      </Route>

      <Route path="admin/*">
        <Admin />
      </Route>

      <Route basepath="/">
        <InfoNav />

        <Route path="current">
          <CurrentLottery bind:lotteryId />
        </Route>
        <Route path="previous">
          <LotteryState bind:currentId={lotteryId} lotteryId={lotteryId - 1} />
        </Route>
        <Route path="*">
          <Exception defaultPath={"/current"} />
        </Route>
      </Route>
    </main>
  </Router>
{/if}

{#if !/^\/$/.test(route)}
  <self />
{/if}

<style>
</style>
