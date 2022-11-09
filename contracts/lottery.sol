pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Lottery
 * @dev Lottery 스마트 컨트랙트
 */
contract Lottery {
    // 플레이어 관련
    address public manager;
    address public lastWinner;
    // address payable[] public players;

    uint256 public contractBalance;

    /////////////////////////////////////////////////////
    // my code: 당첨자를 뽑는 코드
    mapping(uint256 => uint256) randomNumbers;

    uint256 peopleCount;

    struct Person {
        uint256 selectNumber;
        address payable addr;
        uint256 matchCount;
    }

    mapping(uint256 => Person) people;

    function setRandomNumber() public {
        // 랜덤 넘버: 4개, 2자리
        uint256 randomNumber = random();

        // 11 22 33 44
        randomNumber = randomNumber % 100000000;
        for (uint256 i = 0; i < 4; i++) {
            randomNumbers[i] = randomNumber % 100;
            randomNumber /= 100;
        }
    }

    ///////////////////////////////////////////////////////////////////////////

    // 티켓 관련
    uint256 public ticketsBought = 0; // 현재 유저가 몇개 샀는지
    uint256 ticketPrice = .0001 ether; // 가격
    uint64 ticketMax = 1000; // 최대 구입 가능
    uint256 public lotteryId;

    constructor() {}

    // buyTickets 으로만 살 수 있어야 하니까
    fallback() external payable {
        buyTickets();
    }

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
        if (msg.value < ticketPrice) {} else {
            _;
        }
    }

    /** ------------ Functions ------------ **/

    function enter() public payable enoughMoney {
        // players.push(payable(msg.sender));
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, players)
                )
            );
    }

    // 한번에 최대 20장은 살 수 있음
    function buyTickets() public payable returns (bool) {
        // 참여자는  매개변수에 8자리 번호를 넘긴다.

        contractBalance += msg.value;

        uint256 selectNum;
        people[peopleCount++] = Person(selectNum, payable(msg.sender));
        return true;
    }

    // 당첨자 임시 list
    mapping(uint256 => Person) winners;
    uint256 winnerCount;

    function pickWinner() public restricted {
        for (uint256 i = 0; i < peopleCount; i++) {
            uint256 matchCount = 0;
            uint256 selectNumber = people[i].selectNumber;
            address payable pAddr = people[i].addr;

            for (uint256 j = 0; j < 4; j++) {
                if (randomNumbers[j] == selectNumber % 100) matchCount++;
                selectNumber /= 100;
            }

            // match count에 따라서 차등 지급
            winners[winnerCount++] = Person(0, pAddr, matchCount);
        }
        // match count 에 따라 차등 지급
        transferToWinner();

        // reset lotto
        resetLottery();

        // people 초기화.
        peopleCount = 0;
    }

    function transferToWinner() public {
        // 4개 맞춘 사람: 40%
        // 3개 맞춘 사람: 30%
        // 2개 맞춘 사람: 20%
        // 1개 맞춘 사람: 10%
        uint256 _4 = contractBalance * 0.4;
        uint256 _3 = contractBalance * 0.3;
        uint256 _2 = contractBalance * 0.2;
        uint256 _1 = contractBalance * 0.1;

        for (uint256 i = 0; i < winnerCount; i++) {
            address payable pAddr = winners[i].addr;
            uint256 m = winners[i].matchCount;
            if (m == 1) {
                transfer(pAddr, _1);
            }
            if (m == 2) {
                transfer(pAddr, _2);
            }
            if (m == 3) {
                transfer(pAddr, _3);
            }
            if (m == 4) {
                transfer(pAddr, _4);
            }
        }
    }

    function transfer(address payable _to, uint256 _amount) public {
        // Note that "to" is declared as payable
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    function resetLottery() public returns (bool success) {
        return true;
    }

    /** ------------ Getter ------------ **/

    function getWinner() public view returns (address) {
        return lastWinner;
    }

    function getPlayers() public view returns (address payable[] memory) {
        // return players;
        return true;
    }
}
