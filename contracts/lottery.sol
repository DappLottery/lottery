// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

/**
 * @title Lottery
 * @dev Lottery 스마트 컨트랙트
 */
contract Lottery {
    // 플레이어 관련
    struct Player {
        address _address;
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

    // 한번에 최대 20장은 살 수 있음
    function buyTickets() public payable lotteryOngoing returns (bool success) {
        address payable buyer = payable(msg.sender);

        ticketsBought += ticketHolders[msg.sender];

        players.push(buyer);
        contractBalance += msg.value;

        // buyer.send(.1 ether);
        emit TicketsBought(msg.sender, ticketHolders[msg.sender]);
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
