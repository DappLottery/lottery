// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

/**
 * @title Lottery
 * @dev Lottery 스마트 컨트랙트
 */
contract Lottery {
    struct PlayerList {
        bool playersSwitch;
        address payable[] players0;
        address payable[] players1;
    }

    struct Player {
        address payable _address;
        Ticket[] tickets;
    }

    struct Ticket {
        uint256 _id; // 현재 복권에서 몇 번째 티켓
        uint256[6] numbers;
    }

    struct LotteryNumber {
        uint _lotteryId;
        bool[46] flag;
        uint256[6] winningNumber;
    }

    struct LotteryInfo {
        uint256 lotteryId; // 몇 번째 복권
        uint256 lotteryStart;
        uint256 lotteryDuration;
        bool lotteryEnded;
        uint256 contractBalance; // SC 잔고
    }

    struct WinningInfo {
        uint _lotteryId;
        uint256 realTotalMoney; // 75%의 잔고
        address payable[] firstPlayers;
        address payable[] secondPlayers;
        address payable[] thirdPlayers;
    }

    // manager info
    address public manager;

    // player info
    PlayerList public playerList;
    mapping (address => Player) public ticketHolders;
    mapping (address => uint256) player2winnings;

    // 티켓 관련
    uint256 ticketPrice = .1 ether; // 가격
    uint256 ticketMax = 1000; // 최대 구입 가능

    // 복권 관련
    LotteryInfo public lotteryInfo;
    LotteryNumber public lotteryNumber;

    // 당첨자 관련
    WinningInfo public winningInfo;

    // 이벤트
    event TicketsBought(address indexed _from, uint256 _quantity);
    event ResetLottery();

    // receive() external payable {
    //     buyTickets();
    // }

    /** ------------ Modifiers ------------ **/

    // 다 팔림 modifier
    modifier allTicketsSold() {
        require(ticketHolders[msg.sender].tickets.length >= ticketMax);
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
        require(block.timestamp < lotteryInfo.lotteryStart + lotteryInfo.lotteryDuration);
        _;
    }

    // 로또 끝?
    modifier lotteryFinished() {
        require(block.timestamp > lotteryInfo.lotteryStart + lotteryInfo.lotteryDuration);
        _;
    }

    modifier enoughLottery() {
        if (lotteryInfo.contractBalance == 0) {
            revert();
        } else {
            _;
        }
    }

    /** ------------ Functions ------------ **/

    constructor() {
        manager = msg.sender;
        lotteryInfo.lotteryId = 0;
        lotteryInfo.lotteryStart = block.timestamp;
        lotteryInfo.lotteryDuration = 24 hours;
        playerList.playersSwitch = true;
    }

    fallback() external payable {
        buyTickets();
    }

    function enter() public payable enoughMoney {
        if (playerList.playersSwitch) {
            playerList.players1.push(payable(msg.sender));
        } else {
            playerList.players0.push(payable(msg.sender));
        }
    }

    // 한번에 최대 20장은 살 수 있음
    function buyTickets() public payable lotteryOngoing returns (bool success) {
        address payable buyer = payable(msg.sender);

        if (playerList.playersSwitch) {
            playerList.players1.push(buyer);
        } else {
            playerList.players0.push(buyer);
        }
        lotteryInfo.contractBalance += msg.value;

        // uint256 selectNum;

        // people[peopleCount++] = Person(selectNum, 0, toAddr);

        // buyer.send(.1 ether);
        emit TicketsBought(msg.sender, ticketHolders[msg.sender].tickets.length);
        return true;
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, (playerList.playersSwitch) ? playerList.players1 : playerList.players0)
                )
            );
    }

    function resetFlag() public {
        for (uint256 i = 1; i < 46; i++) lotteryNumber.flag[i] = false;
    }

    function lotteryForWinningNumber() public {
        // random number 6개. 1 ~ 45 범위 제한. 겹치지 않게. 
        resetFlag();

        for (uint256 i = 0; i < 6; i++) {
            uint256 rn;

            for (;;) {
                rn = (random() % 45) + 1;

                if (lotteryNumber.flag[rn] == false) break;
            }

            lotteryNumber.flag[rn] = true;
            lotteryNumber.winningNumber[i] = rn;
        }

        lotteryNumber.winningNumber = lotterySort(lotteryNumber.winningNumber);
    }

    function confiscateUnreceived(address payable[] memory _players) internal {
        for (uint256 i = 0; i < _players.length; i++) {
            uint256 remainWinnings = player2winnings[_players[i]];

            if (0 < remainWinnings) {
                lotteryInfo.contractBalance += remainWinnings;
            }

            player2winnings[_players[i]] = 0;
        }
    }

    function checkoutWinners(address payable[] memory _players) internal {
        for (uint256 i = 0; i < _players.length; i++) {
            Player memory playerInfo = ticketHolders[_players[i]];

            for (uint256 j = 0; j < playerInfo.tickets.length; j++) {
                uint256[6] memory playerNumber = lotterySort(playerInfo.tickets[j].numbers);
                int answerCnt = 0;
                int winningIdx = 0;

                for (int k = 0; k < 6; k++) {
                    while (winningIdx < 6 && lotteryNumber.winningNumber[uint(winningIdx)] < playerNumber[uint(k)]) {
                        winningIdx++;
                        continue;
                    }
                    if (winningIdx == 6) break;
                    if (lotteryNumber.winningNumber[uint(winningIdx)] == playerNumber[uint(k)]) answerCnt++;
                }

                if (answerCnt == 6) {
                    winningInfo.firstPlayers.push(playerInfo._address);
                } else if (answerCnt == 5) {
                    winningInfo.secondPlayers.push(playerInfo._address);
                } else if (answerCnt == 4) {
                    winningInfo.thirdPlayers.push(playerInfo._address);
                }
            }
        }
    }

    function divideMoney() public enoughLottery {
        winningInfo.realTotalMoney = lotteryInfo.contractBalance / 100 * 75; // 75%, fixed point도 없음;
        uint totalWinnings = winningInfo.realTotalMoney;

        uint firstMoneyToSend = totalWinnings / 100 * 70;
        firstMoneyToSend /= winningInfo.firstPlayers.length;
        for (uint i = 0; i < winningInfo.firstPlayers.length; i++) {
            player2winnings[winningInfo.firstPlayers[i]] += firstMoneyToSend;
        }

        uint secondMoneyToSend = totalWinnings / 100 * 15;
        secondMoneyToSend /= winningInfo.secondPlayers.length;
        for (uint i = 0; i < winningInfo.secondPlayers.length; i++) {
            player2winnings[winningInfo.secondPlayers[i]] += secondMoneyToSend;
        }

        uint thirdMoneyToSend = totalWinnings / 100 * 15;
        thirdMoneyToSend /= winningInfo.thirdPlayers.length;
        for (uint i = 0; i < winningInfo.thirdPlayers.length; i++) {
            player2winnings[winningInfo.thirdPlayers[i]] += thirdMoneyToSend;
        }

        lotteryInfo.contractBalance -= totalWinnings;
    }

    function pickWinner() public restricted {
        // 당첨 번호 추첨
        lotteryForWinningNumber();

        // 미수령 당첨금 압수 & 당첨자 확인
        if (playerList.playersSwitch) {
            confiscateUnreceived(playerList.players0);
            playerList.players0 = new address payable[](0);
            checkoutWinners(playerList.players1);
        } else {
            confiscateUnreceived(playerList.players1);
            playerList.players1 = new address payable[](0);
            checkoutWinners(playerList.players0);
        }

        // 당첨금 배부
        divideMoney();

        // 복권 초기화
        lotteryInfo.contractBalance = 0;
        resetLottery();
        playerList.playersSwitch = !playerList.playersSwitch;
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
        lotteryInfo.lotteryEnded = false;
        lotteryInfo.lotteryStart = block.timestamp;
        lotteryInfo.lotteryDuration = 24 hours;
        emit ResetLottery();
        return true;
    }

    function receiveWinnings() external {
        require(0 < player2winnings[msg.sender], "You have no winnings.");
        uint256 toReceive = player2winnings[msg.sender];
        player2winnings[msg.sender] = 0;
        payable(msg.sender).transfer(toReceive);
    }

    /** ------------ Getter ------------ **/

    // function getWinner() public view returns (address) {
    //     return lastWinner;
    // }

    function getPlayers() public view returns (address payable[] memory) {
        if (playerList.playersSwitch) {
            return playerList.players1;
        } else {
            return playerList.players0;
        }
    }

    function getExpected_1st() public view returns (uint256) {
        return lotteryInfo.contractBalance / 100 * 75 * 70 / 100;
    }

    function getExpected_2nd() public view returns (uint256) {
        return lotteryInfo.contractBalance / 100 * 75 * 15 / 100;
    }

    function getExpected_3rd() public view returns (uint256) {
        return lotteryInfo.contractBalance / 100 * 75 * 15 / 100;
    }

    // player가 자신의 당첨 금액 확인
    function getMyWinnings() external view returns (uint256) {
        return player2winnings[msg.sender];
    }

    /** ------------ Sort ------------ **/

    function quickSort(uint[6] memory arr, int left, int right) internal pure {
        int i = left;
        int j = right;
        if (i == j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }

    function lotterySort(uint[6] memory data) public pure returns (uint[6] memory) {
        quickSort(data, int(0), int(5));
        return data;
    }
}