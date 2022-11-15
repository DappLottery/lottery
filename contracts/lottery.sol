// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

/**
 * @title Lottery
 * @dev Lottery 스마트 컨트랙트
 */
contract Lottery {
    // ticket struct

    // 플레이어 관련
    struct Player {
        address payable _address;
        uint256 matchCount;
        uint256 _tickets;
    }

    address public manager;
    address public lastWinner;

    address payable[] public players;
    mapping(address => Player) public ticketHolders;

    // 티켓 관련
    uint256 public ticketsBought = 0; // 현재 유저가 몇개 샀는지
    uint256 ticketPrice = .01 ether; // 가격
    uint256 private ticketMax = 1000; // 최대 구입 가능
    uint256 public lotteryId; // 몇개의 티켓
    uint256 public lotteryStart;
    uint256 public lotteryDuration;
    bool public lotteryEnded;
    uint256 public contractBalance = 0; // SC 잔고

    // SEOK 당첨 관련
    uint256 public realTotalMoney = 0; // 75%의 잔고

    uint256 public firstRanks;
    uint256 public secondRanks;
    uint256 public thirdRanks;

    uint256 public lastFirstMoney;
    uint256 public lastSecondMoney;
    uint256 public lastThirdMoney;
    // SEOK 당첨 관련

    // 이벤트
    event TicketsBought(address indexed _from, uint256 _quantity);
    event ResetLottery();

    // receive() external payable {
    //     buyTickets();
    // }

    // Modifiers

    // 다 팔림 modifier
    modifier allTicketsSold() {
        require(ticketsBought >= ticketMax);
        _;
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    modifier enoughMoney() {
        if (msg.value < ticketPrice) {
            revert();
        } else {
            _;
        }
    }

    // 로또 진행 중?
    modifier lotteryOngoing() {
        require(block.timestamp < lotteryStart + lotteryDuration);
        _;
    }

    // 로또 끝?
    modifier lotteryFinished() {
        require(block.timestamp > lotteryStart + lotteryDuration);
        _;
    }

    modifier enoughLottery() {
        if (contractBalance == 0) {
            revert();
        } else {
            _;
        }
    }

    /** ------------ Functions ------------ **/

    constructor() public {
        manager = msg.sender;
        lotteryId = 0;
        lotteryStart = block.timestamp;
        lotteryDuration = 24 hours;
    }

    fallback() external payable {
        buyTickets();
    }

    function enter() public payable enoughMoney {
        players.push(payable(msg.sender));
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, players)
                )
            );
    }

    function setRandomNumber() public {
        // 랜덤 넘버: 4개, 2자리
        // uint256 randomNumber = random();
        // // 11 22 33 44
        // randomNumber = randomNumber % 100000000;
        // for (uint256 i = 0; i < 4; i++) {
        //     randomNumbers[i] = randomNumber % 100;
        //     randomNumber /= 100;
        // }
    }

    // 한번에 최대 20장은 살 수 있음
    function buyTickets() public payable lotteryOngoing returns (bool success) {
        // players에 있는지 loop 할 것

        address payable buyer = payable(msg.sender);

        ticketsBought += ticketHolders[msg.sender]._tickets;

        players.push(buyer);
        contractBalance += msg.value;

        uint256 selectNum;

        emit TicketsBought(msg.sender, ticketHolders[msg.sender]._tickets);
        return true;
    }

    // SEOK 당첨 관련
    function divideMoney() public enoughLottery {
        realTotalMoney = contractBalance / 100 * 75; // 75%, fixed point도 없음;

        uint firstMoneyToSend = realTotalMoney / 100 * 70;
        lastFirstMoney = firstMoneyToSend/(firstRanks);

        uint secondMoneyToSend = realTotalMoney / 100 * 15;
        lastSecondMoney = realTotalMoney/(secondRanks);

        uint thirdMoneyToSend = realTotalMoney / 100 * 15;
        lastThirdMoney = realTotalMoney/(thirdRanks);

        contractBalance -= realTotalMoney;
        
        // players 들 loop 해서
        // nMoneyToSend 씩 주면 됨
        // ex) 1등 loop -> firstMoneyToSend 씩 주면 firstRanks 만큼의 돈이 나감

        // realTotalMoney 보여주기 위해 초기화 안함
    }
    // SEOK 당첨 관련

    function pickWinner() public restricted {
        // TODO 어떻게 뽑을지
        uint256 randomIndex = random() % players.length;

        // players[randomIndex].transfer(address(this).balance);
        lastWinner = players[randomIndex];


        // contractBalance = 0;
        resetLottery();
        // players 초기화
        players = new address payable[](0);

        // for (uint256 i = 0; i < peopleCount; i++) {
        //     uint256 matchCount = 0;
        //     uint256 selectNumber = people[i].selectNumber;
        //     address payable pAddr = people[i].addr;

        //     for (uint256 j = 0; j < 4; j++) {
        //         if (randomNumbers[j] == selectNumber % 100) matchCount++;
        //         selectNumber /= 100;
        //     }

        //     // match count에 따라서 차등 지급
        //     winners[winnerCount++] = Person(0, matchCount, pAddr);
        // }
        // // match count 에 따라 차등 지급
        // transferToWinner();

        // // reset lotto
        // resetLottery();

        // // people 초기화.
        // peopleCount = 0;
    }

    function transferToWinner() public {
        // 4개 맞춘 사람: 40%
        // 3개 맞춘 사람: 30%
        // 2개 맞춘 사람: 20%
        // 1개 맞춘 사람: 10%
        // uint256 _1 = (contractBalance / 10);
        // uint256 _2 = ((2 * contractBalance) / 10);
        // uint256 _3 = ((3 * contractBalance) / 10);
        // uint256 _4 = ((4 * contractBalance) / 10);
        // for (uint256 i = 0; i < winnerCount; i++) {
        //     address payable pAddr = winners[i].addr;
        //     uint256 m = winners[i].matchCount;
        //     if (m == 1) {
        //         transfer(pAddr, _1);
        //     }
        //     if (m == 2) {
        //         transfer(pAddr, _2);
        //     }
        //     if (m == 3) {
        //         transfer(pAddr, _3);
        //     }
        //     if (m == 4) {
        //         transfer(pAddr, _4);
        //     }
        // }
    }

    function transfer(address payable _to, uint256 _amount) public {
        _to.transfer(_amount);
    }

    function resetLottery() public lotteryFinished returns (bool success) {
        lotteryEnded = false;
        lotteryStart = block.timestamp;
        lotteryDuration = 24 hours;
        emit ResetLottery();
        return true;
    }

    /** ------------ Getter ------------ **/

    function getWinner() public view returns (address) {
        return lastWinner;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getFirstPlace() public view returns (uint256) {
        return firstRanks;
    }

    function getSecondPlace() public view returns (uint256) {
        return secondRanks;
    }

    function getThirdPlace() public view returns (uint256) {
        return thirdRanks;
    }

    function getFirstMoney() public view returns (uint256) {
        return lastFirstMoney;
    }

    function getSecondMoney() public view returns (uint256) {
        return lastSecondMoney;
    }

    function getThirdMoney() public view returns (uint256) {
        return lastThirdMoney;
    }
}
