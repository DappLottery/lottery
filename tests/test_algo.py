def main():
    contractBalance = 105_301_601_000  # 100 eth

    firstRanks = 25  # 1등 25명
    secondRanks = 85  # 2등 85명
    thirdRanks = 3947  # 3등 3947명

    totalMoney = contractBalance * 0.75  # 총 당첨금은 판매액의 75%

    firstMoney = totalMoney * 0.75 // firstRanks
    secondMoney = totalMoney * 0.125 // secondRanks
    thirdMoney = totalMoney * 0.125 // thirdRanks

    print(firstMoney, secondMoney, thirdMoney)
    print(totalMoney - firstMoney - secondMoney - thirdMoney)

    firstReceived = firstMoney * 25
    print(totalMoney, firstReceived)


if __name__ == "__main__":
    main()
