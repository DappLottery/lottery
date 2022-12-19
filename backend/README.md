# Dapp Lottery Backend

## Welcome to the Dapp Lottery Backend project!

This project is a backend system for a Dapp lottery application, built using the Rust programming language, MongoDB for data storage, and a Kakao chatbot for user convenience.

The Dapp lottery application allows users to purchase tickets and participate in lottery games using Ethereum. The backend system is responsible for managing game history and ticket records, as well as facilitating communication between the Dapp and users through the Kakao chatbot.

We hope you find this project useful and look forward to your feedback and contributions!

# API Reference
This API allows users to access information about game history and ticket records stored in a database. The following APIs are available:

## GET /history
Retrieves a list of all game history records from the database.

### Example response:

```json
[{
   "mangaer":"0x3211881...",
   "ticket_sold":10,
   "game_money":1500000,
   "lucky_number":"1-2-3-4-5-6",
   "first_winner":[
      "0x123",
      "0x3344"
   ],
   "second_winner":[
      
   ],
   "third_winner":[
      "0x123"
   ]
},
{
   "mangaer":"0x42321...",
   "ticket_sold":800,
   "game_money": 3400000,
   "lucky_number":"1-5-3-4-5-3",
   "first_winner":[],
   "second_winner":[],
   "third_winner":[
      "0x433423"
   ]
}]
```

## POST /history/upload
Uploads a list of game history records to the database. The request body should be a JSON array of objects, with each object representing a single game history record.

### Example request body:

```json
[{
   "mangaer":"0x42321...",
   "ticket_sold":800,
   "game_money": 3400000,
   "lucky_number":"1-5-3-4-5-3",
   "first_winner":[],
   "second_winner":[],
   "third_winner":[
      "0x433423"
   ]
}]
```

## POST /game/upload
Uploads a list of game ticket records to the database.

The request body should be a JSON array of objects, with each object representing a single game ticket record.

### Example request body:

```json
[{
   "game_number": 1,
   "player_address": "0x4449...",
   "lottery_number": "1-5-3-4-5-3"
}]
```

## GET /ticket
Retrieves a list of all game ticket records from the database.

### Example response:

```json
[{
   "game_number": 1,
   "player_address": "0x4449...",
   "lottery_number": "1-5-3-4-5-3"
},
{
   "game_number": 1,
   "player_address": "0x3243429...",
   "lottery_number": "6-5-3-4-5-3"
},
{
   "game_number": 3,
   "player_address": "0x5541e...",
   "lottery_number": "4-3-2-1-5-3"
}]
```

## GET /ticket/addr/{address}
Retrieves a list of game ticket records for the specified Ethereum address. The address parameter should be a valid Ethereum address.

### Example request: /ticket/addr/0x123...

### Example response:

```json
[{
   "game_number": 1,
   "player_address": "0x5541e...",
   "lottery_number": "1-5-3-4-5-3"
},
{
   "game_number": 1,
   "player_address": "0x5541e...",
   "lottery_number": "6-5-3-4-5-3"
},
{
   "game_number": 3,
   "player_address": "0x5541e...",
   "lottery_number": "4-3-2-1-5-3"
}]
```

## GET /ticket/game/{number}
Retrieves a list of game ticket records for the specified game number. The number parameter should be a valid unsigned integer.

### Example request: /ticket/game/3...

### Example response:


```json
[{
   "game_number": 1,
   "player_address": "0xff5541e...",
   "lottery_number": "1-5-3-4-5-3"
},
{
   "game_number": 1,
   "player_address": "0xeeeq1f41e...",
   "lottery_number": "6-5-3-4-5-3"
},
{
   "game_number": 1,
   "player_address": "0xasdf5541e...",
   "lottery_number": "4-3-2-1-5-3"
}]
```
