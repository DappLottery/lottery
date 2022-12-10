<script>
  import { web3, selectedAccount, contracts } from "svelte-web3";

  export let fetchData;
  export let lotteryId;
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

          let lotteryNumber = "";
          Object.keys(ticketNumber).forEach(
            prop => (lotteryNumber += prop + "-")
          );
          lotteryNumber = lotteryNumber.substring(0, lotteryNumber.length - 1);

          fetchData();

          let temp = JSON.stringify([
            // Array of game
            {
              game_number: lotteryId,
              player_address: $selectedAccount,
              lottery_number: lotteryNumber,
            },
          ]);
          console.log(temp);

          fetch(
            "http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/game/upload",
            {
              method: "POST",
              body: JSON.stringify([
                // Array of game
                {
                  game_number: lotteryId,
                  player_address: $selectedAccount,
                  lottery_number: lotteryNumber,
                },
              ]),
              headers: {
                "Content-Type": "application/json",
              },
            }
          ).then(result => result.json());

          // console.log("receipt:", receipt);
        })
        .on("confirmation", function (confirmationNumber, receipt) {
          console.log("confirmation", confirmationNumber);
        })
        .on("error", console.error); // If a out of gas error, the second parameter is the receipt.;
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
