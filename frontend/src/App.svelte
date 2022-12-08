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

  const LOTTERY_ON_GANACHE = "0x03186e96Df911767D921b1e98d9A0ff72c8f4664";

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
  //hansik
  let Order = ["First", "Second", "Third"];

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

  const buyTicket = async () => {
    try {
      $contracts.Lottery.methods
        .buyTicket()
        .send({
          from: $selectedAccount,
          value: $web3.utils.toWei("0.15", "ether"),
          gasLimit: 6721975,
          gasPrice: 30000000000,
        })
        .on("transactionHash", function (hash) {
          console.log("transactionHash:", HashChangeEvent);
        })
        .on("receipt", function (receipt) {
          ticketNumber = receipt.events.TicketsBought.returnValues.number;

          fetchData();

          console.log("receipt:", receipt);
        })
        .on("confirmation", function (confirmationNumber, receipt) {
          console.log("confirmation", confirmationNumber);
        })
        .on("error", console.error); // If a out of gas error, the second parameter is the receipt.;
      // console.log("tx:", tx);
      // if (tx.status === true) {
      //   // getTransactionReceiptMined(tx.transactionHash, 1000);
      //   console.log(ticketNumber);
      // }
    } catch (err) {
      console.log(err);
    }
  };

  const pickWinner = async () => {
    try {
      $contracts.Lottery.methods
        .pickWinner()
        .send({
          from: $selectedAccount,
          gasLimit: 6721975,
          gasPrice: 30000000000,
        })
        .on("receipt", function (receipt) {
          // console.log("receipt:", receipt);

          fetchData();
        });
    } catch (err) {
      console.log(err);
    }

    console.log(luckyNumber);
  };

  const resetLottery = async () => {
    try {
      await $contracts.Lottery.methods
        .resetLottery()
        .send({ from: $selectedAccount });
    } catch (err) {
      console.log(err);
    }

    fetchData();
  };

  const fetchWinners = async () => {
    try {
      firstWinners = await $contracts.Lottery.methods.getFirstWinners().call();
      secondWinners = await $contracts.Lottery.methods
        .getSecondWinners()
        .call();
      thirdWinners = await $contracts.Lottery.methods.getThirdWinners().call();
    } catch (err) {
      console.log(err);
      throw new Error(err);
    }
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
    } catch (err) {
      console.log(err);
      throw new Error(err);
    }
  };
  
  //hansik
  const fetchMyTickets = async () => {
    try{
    myTickets = await $contracts.Lottery.methods
        .getTickets($selectedAccount)
        .call();
    } catch (err) {
      console.log(err);
      throw new Error(err);
    }
  };
  
  import MetaMask from "./components/Wallet/MetaMask.svelte";
  import Current from "./components/LotteryInfo/Current.svelte";
  //hansik
  import MyTicketList from "./components/List/MyTicketList.svelte";
  import HistoryList from "./components/List/HistoryList.svelte";
</script>

<main>
  <!-- {#if /setprovider/.test(route)}
    <Providers /> -->

  {#if !$connected}
    {#await connect()}Welcome!<br />{/await}
    {#if pending}connecting...{/if}
    <!-- <h3>there's no metamask wallet...</h3> -->
  {:else}
    <h1>Lottery dApp</h1>

    <MetaMask {disconnect} />
    <Current {web3} {contracts} />

    {#await $contracts.Lottery.methods.getOwner().call()}
      Checking admin...
      <br/>
    {:then owner}
      {#if owner.toLowerCase() == $selectedAccount.toLowerCase()}
        Admin Menu
        <div class="card">
          <button class="button" on:click={pickWinner}>Pick Winner</button>
          <!-- <button class="button" on:click={sendMoney}>Send Money</button> -->
          <button class="button" on:click={resetLottery}>Reset Lottery</button>
        </div>

        {#await fetchWinners()}
          {firstWinners} and {secondWinners} and {thirdWinners}
        {/await}
      {/if}
    {/await}

    Ticket Menu
    <div class="card">
      <button class="button" on:click={buyTicket}>Buy Ticket</button>
      <!-- <button class="button" on:click={disconnect}>Logout</button> -->
      <br />{ticketNumber === undefined ? "" : "Your number: " + ticketNumber}
    </div>

    {#await fetchData()}
      Fetching contract dataset...
    {:then _}
      <div class="card">
        <span>
          Ticket Price: {ticketPrice} ETH
          <br />
          Number of tickets sold: {numTicketSold}
          <br />
          Players: {players}
          <br />
          Lucky Number: {luckyNumber === "" ? luckyNumber : "Not yet"}
          <br />
          Total Win Money: {winMoney} ETH
          <br />
        </span>
      </div>
    {/await}

    <button class="button" on:click={disconnect}>logout</button>

    <TicketList {selectedAccount} {contracts} />
  {/if}

  {#if !/^\/$/.test(route)}
    <self />
  {/if}
  
  <!-- hansik -->
  #await fetchMyTickets()}
      Fetching contract dataset...
    {:then _}
  <MyTicketList {selectedAccount} {contracts}/>
  {/await}
  {#await fetchWinners()}
      Fetching contract dataset...
    {:then _}
  <HistoryList tableData={firstWinners} order={"First"}/>
  <HistoryList tableData={secondWinners} order={"Second"}/>
  <HistoryList tableData={thirdWinners} order={"Third"}/>
  {/await}
  
</main>

<style>
</style>
