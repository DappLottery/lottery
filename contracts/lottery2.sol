// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lottery
 * @dev Lottery 스마트 컨트랙트
 */
contract Lottery2 {
    // 티켓 관련
    struct Ticket {
        uint256 id;
        uint8[6] number;
    }

    // 플레이어 관련
    struct Player {
        address payable addr;
        Ticket[] firstTickets;
        Ticket[] secondTickets;
        Ticket[] thirdTickets;
    }

    // Lottery 관련
    address public owner;
    uint256 lotteryId = 0; // 게임 복권 갯수
    uint256 contractBalance = 0;
    uint256 private nextGameBalance = 0;

    uint256 private ticketMax = 30;
    uint256 private ticketPrice = .1 ether;
    uint256 private cutRate = 75; // 75%, float 없음

    uint8[] private luckyNumber; // private이 그 private 아님

    // mapping(address => Player) public players;
    Player[] public players; // 모든 플레이어 돌 때 용
    mapping(address => Ticket[]) public ticketMap; // 플레이어 찾을 때 (gas fee 위해)
    mapping(address => bool) public playerChecks; // solidity mapping existence 개념 없음

    uint256 actualPrice = 0;
    uint256 eventMoney = 0;
    uint256 firstWinner = 0;
    uint256 secondWinner = 0;
    uint256 thirdWinner = 0;
    uint256 firstMoney = 0;
    uint256 secondMoney = 0;
    uint256 thirdMoney = 0;
    //

    // 이벤트
    event TicketsBought(address indexed _from, uint256 _quantity);
    event ResetLottery();

    // Modifiers

    // 다 팔림 modifier
    // modifier allTicketsSold() {
    //     require(ticketsBought >= ticketMax);
    //     _;
    // }

    modifier restricted() {
        require(msg.sender == owner);
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
    // modifier lotteryOngoing() {
    //     require(block.timestamp < lotteryStart + lotteryDuration);
    //     _;
    // }

    // // 로또 끝?
    // modifier lotteryFinished() {
    //     require(block.timestamp > lotteryStart + lotteryDuration);
    //     _;
    // }

    modifier enoughLottery() {
        if (contractBalance == 0 || lotteryId == 0) {
            revert();
        } else {
            _;
        }
    }

    /** ------------ Functions ------------ **/

    constructor() public payable {
        owner = msg.sender;
        lotteryId = 0;
    }

    // 주소로 바로 돈 보낼 때
    // fallback() external payable {
    //     buyTickets();
    // }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(block.difficulty, block.timestamp))
            );
    }

    // function enter() public payable enoughMoney {
    //     if (playerChecks[msg.sender] == false) {
    //         players.push(Player(payable(msg.sender), [], []));
    //         playerChecks[msg.sender] = true;
    //     } else {
    //         revert(); // 이미 존재
    //     }
    // }

    // 일반적 절차: BUY - PICK - SEND
    // 한번에 최대 20장은 살 수 있음
    // dApp에서 넘버 생성 누르면 번호 뜨고 그 옆에 몇 장 살껀지도
    // lotteryOngoing
    function buyTickets() external payable returns (bool success) {
        // if (msg.value < amount * ticketPrice) {
        //     return false; // 또는 돈 만큼 티켓 사주기
        // }

        payable(msg.sender).transfer(msg.value);

        playerChecks[msg.sender] = true;

        uint8[6] memory number = [1, 2, 3, 4, 5, 6];
        ticketMap[msg.sender].push(Ticket(random(), number));

        contractBalance += msg.value;
        lotteryId++; // dApp 에서 로또 총 몇개 팔렸는지 쉽게        emit TicketsBought(msg.sender, amount);
        return true;
    }

    function pickWinner() public enoughLottery restricted {
        // 플레이어 없음
        if (lotteryId == 0) {
            revert();
        }

        for (uint256 i = 0; i < players.length; i++) {
            Player storage player = players[i];
            if (ticketMap[player.addr].length == 0) continue;

            for (uint256 j = 0; j < ticketMap[player.addr].length; j++) {
                Ticket memory ticket = ticketMap[player.addr][j];
                uint8 counts = 0;

                for (uint8 t = 0; t < 6; t++) {
                    if (luckyNumber[t] == ticket.number[t]) counts++;
                }

                if (counts == 6) {
                    firstWinner++;
                    player.firstTickets.push(ticket);
                } else if (counts >= 4) {
                    // 차피 6은 포함 안된 if
                    secondWinner++;
                    player.secondTickets.push(ticket);
                } else if (counts >= 2) {
                    thirdWinner++;
                    player.thirdTickets.push(ticket);
                }
            }
        }
    }

    function sendMoney() private restricted enoughLottery {
        actualPrice = (contractBalance / 100) * cutRate; // 75%, fixed point도 없음;

        if (firstWinner == 0) {
            nextGameBalance += (actualPrice / 100) * 70;
        } else {
            firstMoney = ((actualPrice / 100) * 70) / firstWinner;
        }

        if (secondWinner == 0) {
            nextGameBalance += (actualPrice / 100) * 15;
        } else {
            secondMoney = ((actualPrice / 100) * 15) / secondWinner;
        }

        if (thirdWinner == 0) {
            nextGameBalance += (actualPrice / 100) * 15;
        } else {
            thirdMoney = ((actualPrice / 100) * 15) / thirdWinner;
        }

        for (uint256 i = 0; i < players.length; i++) {
            Player storage player = players[i];
            eventMoney += player.firstTickets.length * firstMoney;
            player.addr.transfer(player.firstTickets.length * firstMoney);

            eventMoney += player.secondTickets.length * secondMoney;
            player.addr.transfer(player.secondTickets.length * secondMoney);

            eventMoney += player.thirdTickets.length * thirdMoney;
            player.addr.transfer(player.thirdTickets.length * thirdMoney);
        }

        resetLottery();
    }

    // lotteryFinished
    function resetLottery() public returns (bool success) {
        // lotteryEnded = false;
        // lotteryStart = block.timestamp;
        // lotteryDuration = 24 hours;
        emit ResetLottery();
        return true;
    }

    /** ------------ Getter ------------ **/

    // function getWinner() public view returns (address) {
    //     return lastWinner;
    // }

    function getPlayers() public view returns (Player[] memory) {
        return players;
    }

    function getWinMoney() public view returns (uint256) {
        return contractBalance;
    }

    function getFirstMoney() public view returns (uint256) {
        return firstMoney;
    }

    function getSecondMoney() public view returns (uint256) {
        return secondMoney;
    }

    function getThirdMoney() public view returns (uint256) {
        return thirdMoney;
    }
}
