// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

/**
 * @title Lottery
 * @dev Lottery 스마트 컨트랙트
 */
contract Lottery {
    // ticket struct
    struct Ticket {
        uint256 _id;
        uint256[6] _numbers;
    }

    // 플레이어 관련
    struct Player {
        address payable _address;
        Ticket[] _tickets;
    }

    // manager info
    address public manager;

    // player info
    bool public playersSwitch;
    address payable[] public players0;
    address payable[] public players1;
    mapping (address => Player) public ticketHolders;
    mapping (address => uint256) player2winnings;

    // 티켓 관련
    uint256 ticketPrice = .1 ether; // 가격
    uint256 ticketMax = 1000; // 최대 구입 가능

    // 복권 관련
    uint256 public lotteryId; // 몇개의 티켓
    uint256 public lotteryStart;
    uint256 public lotteryDuration;
    bool public lotteryEnded;
    uint256 public contractBalance; // SC 잔고

    // 복권 번호 관련
    bool[46] public flag;
    uint256[6] public winningNumber;

    // 당첨자 관련
    address payable[] public firstPlayers;
    address payable[] public secondPlayers;
    address payable[] public thirdPlayers;

    // 이벤트
    event TicketsBought(address indexed _from, uint256 _quantity);
    event ResetLottery();

    // receive() external payable {
    //     buyTickets();
    // }

    /** ------------ Modifiers ------------ **/

    // 다 팔림 modifier
    modifier allTicketsSold() {
        require(ticketHolders[msg.sender]._tickets.length >= ticketMax);
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
        playersSwitch = true;
    }

    fallback() external payable {
        buyTickets();
    }

    function enter() public payable enoughMoney {
        if (playersSwitch) {
            players1.push(payable(msg.sender));
        } else {
            players0.push(payable(msg.sender));
        }
    }

    // 한번에 최대 20장은 살 수 있음
    function buyTickets() public payable lotteryOngoing returns (bool success) {
        address payable buyer = payable(msg.sender);

        if (playersSwitch) {
            players1.push(buyer);
        } else {
            players0.push(buyer);
        }
        contractBalance += msg.value;

        // uint256 selectNum;

        // people[peopleCount++] = Person(selectNum, 0, toAddr);

        // buyer.send(.1 ether);
        emit TicketsBought(msg.sender, ticketHolders[msg.sender]._tickets.length);
        return true;
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, (playersSwitch) ? players1 : players0)
                )
            );
    }

    function resetFlag() public {
        for (uint256 i = 1; i < 46; i++) flag[i] = false;
    }

    function lotteryForWinningNumber() public {
        // random number 6개. 1 ~ 45 범위 제한. 겹치지 않게. 
        resetFlag();

        for (uint256 i = 0; i < 6; i++) {
            uint256 rn;

            for (;;) {
                rn = (random() % 45) + 1;

                if (flag[rn] == false) break;
            }

            flag[rn] = true;
            winningNumber[i] = rn;
        }

        winningNumber = lotterySort(winningNumber);
    }

    function confiscateUnreceived(address payable[] memory _players) internal {
        for (uint256 i = 0; i < _players.length; i++) {
            uint256 remainWinnings = player2winnings[_players[i]];

            if (0 < remainWinnings) {
                contractBalance += remainWinnings;
            }

            player2winnings[_players[i]] = 0;
        }
    }

    function checkoutWinners(address payable[] memory _players) internal {
        for (uint256 i = 0; i < _players.length; i++) {
            Player memory playerInfo = ticketHolders[_players[i]];

            for (uint256 j = 0; j < playerInfo._tickets.length; j++) {
                uint256[6] memory playerNumber = lotterySort(playerInfo._tickets[j]._numbers);
                int answerCnt = 0;
                int winningIdx = 0;

                for (int k = 0; k < 6; k++) {
                    while (winningIdx < 6 && winningNumber[uint(winningIdx)] < playerNumber[uint(k)]) {
                        winningIdx++;
                        continue;
                    }
                    if (winningIdx == 6) break;
                    if (winningNumber[uint(winningIdx)] == playerNumber[uint(k)]) answerCnt++;
                }

                if (answerCnt == 6) {
                    firstPlayers.push(playerInfo._address);
                } else if (answerCnt == 5) {
                    secondPlayers.push(playerInfo._address);
                } else if (answerCnt == 4) {
                    thirdPlayers.push(playerInfo._address);
                }
            }
        }
    }

    function pickWinner() public restricted {
        // 당첨 번호 추첨
        lotteryForWinningNumber();

        // 미수령 당첨금 압수 & 당첨자 확인
        if (playersSwitch) {
            confiscateUnreceived(players0);
            players0 = new address payable[](0);
            checkoutWinners(players1);
        } else {
            confiscateUnreceived(players1);
            players1 = new address payable[](0);
            checkoutWinners(players0);
        }

        // 당첨금 적축

        // 복권 초기화
        contractBalance = 0;
        resetLottery();
        playersSwitch = !playersSwitch;
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
        lotteryEnded = false;
        lotteryStart = block.timestamp;
        lotteryDuration = 24 hours;
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
        if (playersSwitch) {
            return players1;
        } else {
            return players0;
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /** ------------ Getter ------------ **/

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