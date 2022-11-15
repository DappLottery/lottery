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
    uint256 ticketPrice = .1 ether; // 가격
    uint256 ticketMax = 1000; // 최대 구입 가능
    uint256 public lotteryId; // 몇개의 티켓
    uint256 public lotteryStart;
    uint256 public lotteryDuration;
    bool public lotteryEnded;
    uint256 public contractBalance; // SC 잔고

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

    /** ------------ Functions ------------ **/

    constructor() {
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

    mapping(uint256 => bool) public flag;
    mapping(uint256 => uint256) public winningNumber;

    function lotteryForWinningNumber() public {
        // 랜덤 넘버: 4개, 2자리
        // uint256 randomNumber = random();
        // // 11 22 33 44
        // randomNumber = randomNumber % 100000000;
        // for (uint256 i = 0; i < 4; i++) {
        //     randomNumbers[i] = randomNumber % 100;
        //     randomNumber /= 100;
        // }
        // random number 6개, 1~45 제한 겹치지 않게

        resetFlag();

        for (uint256 i = 0; i < 6; i++) {
            uint256 rn;

            for (;;) {
                rn = (random() % 45) + 1;

                if (flag[rn] == false) break;
            }

            flag[rn] = true;
            winningNumber[i] = rn;
        }
    }

    function resetFlag() public {
        for (uint256 i = 1; i < 46; i++) flag[i] = false;
    }

    // 한번에 최대 20장은 살 수 있음
    function buyTickets() public payable lotteryOngoing returns (bool success) {
        address payable buyer = payable(msg.sender);

        ticketsBought += ticketHolders[msg.sender]._tickets;

        players.push(buyer);
        contractBalance += msg.value;

        uint256 selectNum;

        // people[peopleCount++] = Person(selectNum, 0, toAddr);

        // buyer.send(.1 ether);
        emit TicketsBought(msg.sender, ticketHolders[msg.sender]._tickets);
        return true;
    }

    function pickWinner() public restricted {
        // TODO 어떻게 뽑을지
        uint256 randomIndex = random() % players.length;
        players[randomIndex].transfer(address(this).balance);
        lastWinner = players[randomIndex];

        contractBalance = 0;
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
}
