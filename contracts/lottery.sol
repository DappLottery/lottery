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
    address[] public players[];

    // 티켓 관련
    uint256 public ticketsBought = 0;
    uint64 ticketPrice = 0 finney;
    uint64 ticketMax = 1000;

    function Lottery() {
        currentPlayer = msg.sender;
    }

    // buyTickets 으로만 살 수 있어야 하니까
    function() payable public {
      revert();
    }
    
    // 다 팔림 modifier
    modifier allTicketsSold() {
      require(ticketsBought >= ticketMax);
      _;
    }

    // 한번에 최대 20장은 살 수 있음
    function buyTickets() payable public returns (bool) {
        // require() ...
        address buyer = msg.sender;
        ticketsBought++;
    }

    function sendMoney() {

    }

    function pickWinner() {
        
    }

}
