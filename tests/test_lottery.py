# Python 3.10+

from dataclasses import dataclass
from random import randint
from typing import List

from eth_hash.auto import keccak  # pip install eth-hash[pycryptodome]


@dataclass
class Ticket:
    id: str
    number: List[int]

    def __repr__(self):
        return f"Ticket(id={self.id[:4]}..., {'-'.join([str(num) for num in self.number])})"

    def __eq__(self, __t: object) -> bool:
        if isinstance(__t, Ticket):
            return False
        return self.number == __t.number  # type: ignore


@dataclass
class Player:
    address: bytes
    boughtTicket: List[Ticket]
    money: int  # ether, msg.value
    firstTickets: List[Ticket]  # 1등 티켓 수
    secondTickets: List[Ticket]  # 2등 티켓 수
    thirdTickets: List[Ticket]  # 3등 티켓 수

    def __repr__(self):
        return f"0x{self.address.hex()[:12]}"

    def __str__(self):
        return f"0x{self.address.hex()[:12]}"

    def reset(self):
        self.address = keccak(randint(1, 10).to_bytes(36, "big"))
        self.money = randint(50000, 100000)
        self.boughtTicket = []
        self.firstTickets = []
        self.secondTickets = []
        self.thirdTickets = []


class Lottery:
    LUKCY_NUMBER = tuple(randint(1, 45) for _ in range(6))
    LOTTERY_ID = 0

    CONTRACT_BALANCE = 0
    NEXT_GAME_BALANCE = 0  # 이전 게임에서 다음 게임으로 돈 얼마나 넘기는 지

    TICKET_FEE = 3
    PLAYERS: List[Player] = [
        Player(
            keccak(randint(1, 10).to_bytes(36, "big")),
            [],
            randint(50000, 100000),
            [],
            [],
            [],
        )
        for _ in range(randint(100, 1000))
    ]  # 랜덤 플레이어 n명 생성

    # Rule
    ACTUAL_PRICE = 0  # 75% 떼먹은 돈
    EVENT_MONEY = 0  # 지난 게임 1,2,3등 총 상금

    FIRST_WINNER = 0  # 1등 몇명인지
    SECOND_WINNER = 0
    THIRD_WINNER = 0

    FIRST_MONEY = 0  # 1등 1명 당 돈 계산 용도
    SECOND_MONEY = 0
    THIRD_MONEY = 0

    CUT_RATE = 0.75  # 총 상금의 75% 로 상금 분배

    def enter(self, player: Player):
        self.PLAYERS.append(player)

    def buy_ticket(self, player: Player, amount: int) -> bool:
        if player not in self.PLAYERS:
            self.enter(player)

        if player.money < amount * self.TICKET_FEE:
            return False  # 아니면 자동으로 가능한 만큼 사주기

        # 충분한 돈 있다고 가정
        player.boughtTicket.append(
            Ticket(
                keccak(randint(256, 256**2).to_bytes(8, "big")).hex(),
                [randint(1, 45) for _ in range(6)],
            )
        )
        player.money -= amount * self.TICKET_FEE  # SC 에선 자동
        self.CONTRACT_BALANCE += player.money  # address(this).balance
        self.LOTTERY_ID += 1

        # print(f"{player} bought {amount} tickets!")  # emit
        return True

    def pick_winner(self):
        """1, 2, 3 등 뽑기
        자리 수도 같아야 함

            1등: 6개 전부 동일
            2등: 4개 동일
            3등: 2개 동일"""
        if not self.PLAYERS:  # 플레이어 없음
            return

        for player in self.PLAYERS:
            if not player.boughtTicket:  # 티켓 없음
                continue

            for ticket in player.boughtTicket:
                counts = sum(x == y for x, y in zip(self.LUKCY_NUMBER, ticket.number))
                if counts == 6:
                    self.FIRST_WINNER += 1
                    player.firstTickets.append(ticket)
                elif 4 <= counts < 6:
                    self.SECOND_WINNER += 1
                    player.secondTickets.append(ticket)
                elif 2 <= counts < 4:
                    self.THIRD_WINNER += 1
                    player.thirdTickets.append(ticket)

    def send_money(self):
        """
        1. 돈 계산
        2. 돈 보냄
        """
        self.ACTUAL_PRICE = int(self.CONTRACT_BALANCE * self.CUT_RATE)

        if self.FIRST_WINNER == 0:
            self.NEXT_GAME_BALANCE += self.ACTUAL_PRICE * 0.70
        else:
            self.FIRST_MONEY = (self.ACTUAL_PRICE * 0.70) // self.FIRST_WINNER

        if self.SECOND_WINNER == 0:
            self.NEXT_GAME_BALANCE += self.ACTUAL_PRICE * 0.15
        else:
            self.SECOND_MONEY = (self.ACTUAL_PRICE * 0.15) // self.SECOND_WINNER

        if self.THIRD_WINNER == 0:
            self.NEXT_GAME_BALANCE += self.ACTUAL_PRICE * 0.15
        else:
            self.THIRD_MONEY = (self.ACTUAL_PRICE * 0.15) // self.THIRD_WINNER

        self.NEXT_GAME_BALANCE = int(self.NEXT_GAME_BALANCE)

        print(self.ACTUAL_PRICE)  # 75% 컷
        print(self.NEXT_GAME_BALANCE)  # n등 당첨자 없음, 다음 게임으로 넘김
        print(self.THIRD_MONEY * self.THIRD_WINNER)  # 3등 돈 * 3등 당첨자 수

        # transfer
        # n등 티켓 수 * n등 머니
        for player in self.PLAYERS:
            before_money = player.money

            player.money += (
                len(player.firstTickets) * self.FIRST_MONEY
            )  # contract.transfer(player)
            player.money += len(player.secondTickets) * self.SECOND_MONEY
            player.money += len(player.thirdTickets) * self.THIRD_MONEY
            if player.money != before_money:
                print(
                    f"\tEVENT - {player} 플레이어\n\t\t{len(player.firstTickets) * self.FIRST_MONEY}의 1등 상금\n\t\t{len(player.secondTickets) * self.SECOND_MONEY}의 2등 상금\n\t\t{len(player.thirdTickets) * self.THIRD_MONEY}의 3등 상금\n"
                )

                self.EVENT_MONEY += player.money - before_money

        # ORDER: BUY - PICK - SEND
        self.print_result()
        self.reset_lottery()

    def gen_lucky_number(self):
        """당첨 넘버 생성"""
        self.LUKCY_NUMBER = tuple(randint(1, 45) for _ in range(6))

    def reset_lottery(self):
        """게임 라운드 리셋"""
        self.CONTRACT_BALANCE -= self.EVENT_MONEY

        self.gen_lucky_number()

        for player in self.PLAYERS:
            player.reset()

        self.LOTTERY_ID = 0
        self.CONTRACT_BALANCE = 0

        # temp 값들 초기화
        self.FIRST_WINNER = 0
        self.SECOND_WINNER = 0
        self.THIRD_WINNER = 0

        self.FIRST_MONEY = 0
        self.SECOND_MONEY = 0
        self.THIRD_MONEY = 0

        self.ACTUAL_PRICE = 0
        self.EVENT_MONEY = 0

    def print_luckey_number(self):
        print("-*" * 30)
        print(f"Lucky number: {'-'.join([str(num) for num in self.LUKCY_NUMBER])}\n\n")

    def print_result(self):
        self.print_luckey_number()
        print(
            f"Total game money: {self.ACTUAL_PRICE}, win money: {self.EVENT_MONEY}, left: {self.ACTUAL_PRICE - self.EVENT_MONEY}"
        )
        print(f"Total tickets sold: {self.LOTTERY_ID}\n")
        for player in self.PLAYERS:
            if player.firstTickets or player.secondTickets or player.thirdTickets:
                print(
                    f"\t{player} has {len(player.boughtTicket)} tickets\n\t\t{player.firstTickets}, {player.secondTickets}, {player.thirdTickets}"
                )

        print(
            f"\n\n\tGame END: entry({self.LOTTERY_ID} th) 1st({self.FIRST_WINNER} ppl), 2nd({self.SECOND_WINNER} ppl), 3rd({self.THIRD_WINNER} ppl)"
        )

        with open("log.txt", "a", encoding="utf-8") as log:
            log.write(
                f"Game END: entry({self.LOTTERY_ID} th)\t1st({self.FIRST_WINNER} ppl)\t2nd({self.SECOND_WINNER} ppl)\t3rd({self.THIRD_WINNER} ppl)\n"
            )


def main():
    lottery = Lottery()
    # lottery.print_luckey_number()

    SIMUATIONS = 1

    for _ in range(SIMUATIONS):
        for _ in range(randint(500, 1000)):
            lottery.buy_ticket(
                lottery.PLAYERS[randint(0, len(lottery.PLAYERS) - 1)], randint(1, 20)
            )

        lottery.pick_winner()
        lottery.send_money()


if __name__ == "__main__":
    main()
