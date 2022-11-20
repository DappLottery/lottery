from brownie import Lottery, accounts, chain  # type: ignore

from random import randint

WEI = 1000000000000000000


def main():
    l = Lottery.deploy({"from": accounts[0]})

    print(dir(l))

    for _ in range(10):
        tx = l.buyTicket(
            {
                "from": accounts[randint(0, 9)],
                "value": l.getTicketPrice() * 10,
            },  # 1.5 ether
        )
        tx.wait(1)

    print(l.getWinMoney() // 1000000000000000000)

    chain.sleep(50)  # 50초 지남 게임 끝
    chain.mine()

    all_money = [acc.balance() / WEI for acc in accounts]
    print(f"Before: {all_money}")

    l.pickWinner()
    print(l.getPlayers())
    print()

    all_money = [acc.balance() / WEI for acc in accounts]
    print(f"After: {all_money}")


def time():
    l = Lottery.deploy({"from": accounts[0]})

    tx = l.buyTicket(
        {
            "from": accounts[randint(0, 9)],
            "value": l.getTicketPrice(),
        }
    )

    tx.wait(1)

    chain.sleep(90)  # 100초 동안 진행 되는 게임에서 90초 지남
    chain.mine()

    tx = l.buyTicket(
        {
            "from": accounts[randint(0, 9)],
            "value": l.getTicketPrice(),
        }
    )  # should work

    tx.wait(1)

    chain.sleep(90)
    chain.mine()

    tx = l.buyTicket(
        {
            "from": accounts[randint(0, 9)],
            "value": l.getTicketPrice(),
        }
    )  # should error

    tx.wait(1)
