## Overview

The `Lottery` contract is a smart contract for a Dapp lottery application. It allows users to purchase tickets and participate in lottery games using Ethereum.

The contract includes structures for storing information about tickets, players, and lottery games. It also includes mappings for accessing player and ticket data, as well as arrays for storing the addresses of past winners.

The contract includes several event definitions, as well as modifiers for enforcing certain conditions on function calls (e.g. the caller must have enough tickets or money).

## Structures

- `Ticket`: stores information about a ticket, including its ID and number.
- `Player`: stores information about a player, including their Ethereum address and their tickets for each prize tier (first, second, and third).

## Mappings and Arrays

- `players`: an array of `Player` structures representing all players.
- `ticketMap`: a mapping from player addresses to arrays of `Ticket` structures, allowing for fast retrieval of a player's tickets.
- `playerChecks`: a mapping from player addresses to a boolean value indicating whether the player has already purchased tickets for the current game.
- `firstWinners`, `secondWinners`, `thirdWinners`: arrays storing the addresses of past winners in each prize tier.

## Events

- `TicketsBought`: emitted when a player buys tickets, indicating the player's address and the ticket numbers.
- `ResetLottery`: emitted when the current game ends and a new game begins.
- `LuckyNumber`: emitted when the lucky numbers for the current game are drawn.

## Modifiers
- `enoughTicket`: ensures that the caller has not exceeded the maximum number of tickets allowed per game.
- `restricted`: allows only the contract owner to call the function.
- `enoughMoney`: ensures that the caller has paid the required amount for a ticket.
- `onlyBefore`: allows the function to be called only before a specified time.
- `onlyAfter`: allows the function to be called only after a specified time.
- `enoughLottery`: ensures that there are enough tickets and funds available for a new game.

## Functions

- `buyTicket`: allows a player to purchase tickets for the current game. The function takes a single bytes32 parameter representing the player's ticket ID. The function requires the `enoughMoney` and `enoughTicket` modifiers to be satisfied, and emits the `TicketsBought` event upon success.
- `drawLuckyNumber`: draws the lucky numbers for the current game. This function can only be called by the contract owner and requires the `restricted` and `onlyAfter` modifiers to be satisfied. The function emits the `LuckyNumber` event upon success.
- `payout`: distributes prizes to the winners of the current game. This function can only be called by the contract owner and requires the `restricted` and `onlyAfter` modifiers to be satisfied. The function calculates the prize amounts based on the percentage of the game's profits allocated to each prize tier, and sends the appropriate amounts to the winners' Ethereum addresses.
- `resetLottery`: ends the current game and starts a new game. This function can only be called by the contract owner and requires the `restricted` and `onlyAfter` modifiers to be satisfied. The function resets the `lotteryId`, `lastLotteryId`, and `players` arrays, and emits the `ResetLottery` event.
- `getPlayers`: returns the `players` array as a tuple.
- `getFirstWinners`: returns the `firstWinners` array as a tuple.
- `getSecondWinners`: returns the `secondWinners` array as a tuple.
- `getThirdWinners`: returns the `thirdWinners` array as a tuple.
- `getPlayersLength`: returns the length of the `players` array.
- `getFirstWinnersLength`: returns the length of the `firstWinners` array.
- `getSecondWinnersLength`: returns the length of the `secondWinners` array.
- `getThirdWinnersLength`: returns the length of the `thirdWinners` array.
