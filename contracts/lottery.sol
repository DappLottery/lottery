// SPDX-License-Identifier: MIT;

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Lottery
 * @dev Lottery 스마트 컨트랙트
 */
contract Lottery {
    // 플레이어 관련
    address currentPlayer;
    address public winner;
    address[] public players;

    // 티켓 관련
    uint256 public ticketsBought = 0; // 현재 유저가 몇개 샀는지
    uint64 ticketPrice = 0; // 가격
    uint64 ticketMax = 1000; // 최대 구입 가능

    function Lottery() {
        currentPlayer = msg.sender;
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

    // 한번에 최대 20장은 살 수 있음
    function buyTickets() public payable returns (bool) {
        // require() ...
        address buyer = msg.sender;
        ticketsBought++;
    }

    function sendMoney() {}

    function pickWinner() {}
}
