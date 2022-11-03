// SPDX-License-Identifier: MIT;

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Lottery
 * @dev Lottery 스마트 컨트랙트
 */
contract Lottery {
    // 플레이어 관련
    address manager;
    address public winner;
    address[] public players;

    // 티켓 관련
    uint256 public ticketsBought = 0; // 현재 유저가 몇개 샀는지
    uint64 ticketPrice = 0; // 가격
    uint64 ticketMax = 1000; // 최대 구입 가능

    constructor() {
        manager = msg.sender;
    }

    // buyTickets 으로만 살 수 있어야 하니까
    fallback() external payable {
        revert();
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

    function enter() public payable {
        require(msg.value > .001 eth);
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

    function sendMoney() {}

    function pickWinner() public restricted {
        uint256 index = random() % players.length;
        currentWinner = players[index];
        players[index].transfer(address(this).balance);
        players = new address payable[](0);
    }
}
