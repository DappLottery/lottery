// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lottery
 * @dev Lottery 스마트 컨트랙트
 */
contract Lottery2 {
    // ticket struct
    struct Ticket {
        uint256 id;
        uint8[] number;
    }

    // 플레이어 관련
    struct Player {
        address payable addr;
        Ticket[] boughtTickets;
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
    mapping(address => Player) public playersMap; // 플레이어 찾을 때 (gas fee 위해)
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

    constructor() public {
        owner = msg.sender;
        lotteryId = 0;
    }

    // 주소로 바로 돈 보낼 때
    fallback() external payable {
        buyTickets();
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, players)
                )
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
    // lotteryOngoing
    function buyTickets(uint256 amount)
        public
        payable
        restricted
        returns (bool success)
    {
        Player player;
        if (playerChecks[msg.sender] == false) {
            player = Player(payable(msg.sender), [], []);
            playerChecks[msg.sender] = true;
        } else {
            // 없으면 일단 entry 넣음
            // TODO array check
        }

        if (msg.value < amount * ticketPrice) {
            return false; // 또는 돈 만큼 티켓 사주기
        }

        address payable buyer = payable(msg.sender);
        contractBalance += msg.value;
        lotteryId++; // dApp 에서 로또 총 몇개 팔렸는지 쉽게

        emit TicketsBought(msg.sender, amount);
        return true;
    }

    function pickWinner() public enoughLottery restricted {
        for (uint256 i = 0; i < players.length; i++) {
            Player player = players[i];
            if (player.boughtTickets.length == 0) continue;

            for (uint256 j = 0; j < player.boughtTickets.length; j++) {
                Ticket ticket = player.boughtTickets[j];
                uint8 counts = 0;

                for (uint8 t = 0; t < 6; t++) {
                    if (luckyNumber[t] == ticket.number[t]) counts++;
                }

                if (counts == 6) {
                    firstWinner++;
                    player.firstTickets.push(ticket);
                }
            }
        }
    }

    // SEOK 당첨 관련
    function divideMoney() public enoughLottery {
        realTotalMoney = (contractBalance / 100) * 75; // 75%, fixed point도 없음;

        uint256 firstMoneyToSend = (realTotalMoney / 100) * 70;
        lastFirstMoney = firstMoneyToSend / (firstRanks);

        uint256 secondMoneyToSend = (realTotalMoney / 100) * 15;
        lastSecondMoney = secondMoneyToSend / (secondRanks);

        uint256 thirdMoneyToSend = (realTotalMoney / 100) * 15;
        lastThirdMoney = thirdMoneyToSend / (thirdRanks);

        contractBalance -= realTotalMoney;

        // players 들 loop 해서
        // nMoneyToSend 씩 주면 됨
        // ex) 1등 loop -> firstMoneyToSend 씩 주면 firstRanks 만큼의 돈이 나감

        // realTotalMoney 보여주기 위해 초기화 안함
    }

    // SEOK 당첨 관련

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
