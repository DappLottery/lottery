// SPDX-License-Identifier: MIT

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
    mapping (address => uint256) player2winnings;

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
        require(msg.value < ticketPrice);
        _;
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
    
    function receiveWinnings() external {
        require(0 < player2winnings[msg.sender], "You have no winnings.");
        uint256 toReceive = player2winnings[msg.sender];
        player2winnings[msg.sender] = 0;
        payable(msg.sender).transfer(toReceive);
    }
}
