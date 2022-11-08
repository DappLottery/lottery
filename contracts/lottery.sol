pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Lottery
 * @dev Lottery 스마트 컨트랙트
 */
contract Lottery {
    // 플레이어 관련
    address public manager;
    address public lastWinner;
    address payable[] public players;

    /////////////////////////////////////////////////////
    // my code: 당첨자를 뽑는 코드
    mapping(uint256 => uint256) randomNumbers;

    uint256 peopleCount;

    struct Person {
        uint256 selectNumber;
        address addr;
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

    // function enter(): 이 때 참여하는 사람이 랜덤 넘버를 선택하고, (사람주소: 랜덤넘버)를 매핑??
    function myEnter() public {
        // 참여자는 enter 시에 8자리 번호를 넘긴다.
        uint256 selectNum;
        people[peopleCount++] = Person(selectNum, msg.sender);
    }

    function myPickWinner() public restricted {
        uint256 matchCount = 0;
        for (uint256 i = 0; i < peopleCount; i++) {
            uint256 selectNumber = people[i].selectNumber;
            address pAddr = people[i].addr;

            for (uint256 j = 0; j < 4; j++) {
                if (randomNumbers[j] == selectNumber % 100) matchCount++;
                selectNumber /= 100;
            }

            // match count에 따라서 차등 지급
            if (matchCount == 1) {}
            if (matchCount == 2) {}
            if (matchCount == 3) {}
            if (matchCount == 4) {}
            // <---------------------------------->
        }
        // people 초기화.
        peopleCount = 0;
    }

    ///////////////////////////////////////////////////////////////////////////

    // 티켓 관련
    uint256 public ticketsBought = 0; // 현재 유저가 몇개 샀는지
    uint256 ticketPrice = .0001 ether; // 가격
    uint64 ticketMax = 1000; // 최대 구입 가능
    uint256 public lotteryId;

    constructor() {
        manager = msg.sender;
        lotteryId = 0;
    }

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

    // 한번에 최대 20장은 살 수 있음
    function buyTickets() public payable returns (bool) {
        // require() ...
        address buyer = msg.sender;
        ticketsBought++;
    }

    function pickWinner() public restricted {
        uint256 randomIndex = random() % players.length;
        players[randomIndex].transfer(address(this).balance);
        lastWinner = players[randomIndex];
        lotteryId++;

        // players 초기화
        players = new address payable[](0);
    }

    /** ------------ Getter ------------ **/

    function getWinner() public view returns (address) {
        return lastWinner;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }
}
