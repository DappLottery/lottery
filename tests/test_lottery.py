from random import randint
from brownie import Lottery, accounts


def test_lottery_basic():
    account = accounts[0]
    lottery = Lottery.deploy({"from": account})
    print(dir(lottery))

    for i in range(1, len(accounts)):
        accounts[i].transfer(  # address differs
            "0x3194cBDC3dbcd3E11a07892e7bA5c3394048Cc87", f"{randint(1, 10)} ether"
        )

    assert lottery.getRealMoney() > 100

    lottery.divideMoney()
