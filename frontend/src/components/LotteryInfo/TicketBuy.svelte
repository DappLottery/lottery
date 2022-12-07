<script>
  import {
    web3,
    selectedAccount,
    contracts,
  } from "svelte-web3";

  export let fetchData;

  let ticketNumber;

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
</script>

Ticket Menu
<div class="card">
  <button class="button" on:click={buyTicket}>Buy Ticket</button>
  <!-- <button class="button" on:click={disconnect}>Logout</button> -->
  <br />{ticketNumber === undefined ? "" : "Your number: " + ticketNumber}
</div>