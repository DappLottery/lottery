<script>
  import {
    web3,
    contracts,
  } from "svelte-web3";

  export let numTicketSold;
  export let winMoney;

  let lotteryId = 0;
  let finishDate;
  let nowDate;
  let remainTime = {
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
  };
  let managerAddr;

  const fetchData = async () => {
    try {
      // lotteryId = await $contracts.Lottery.methods.getLottoId().call();
      finishDate = await $contracts.Lottery.methods.getEndTime().call();
      finishDate = Math.trunc(finishDate);
      nowDate = Math.trunc((new Date()).getTime() / 1000);
      managerAddr = await $contracts.Lottery.methods.getOwner().call();
      
      numTicketSold = await $contracts.Lottery.methods.getLottoId().call();
      winMoney = $web3.utils.fromWei(
        await $contracts.Lottery.methods.getWinMoney().call(),
        "ether"
      );

      calcRemain();
    } catch (err) {
      console.log(err);
      throw new Error(err);
    }
  };

  const incrNow = () => { nowDate += 1 };

  const calcRemain = () => {
    let remainSeconds = finishDate - nowDate - 1;

    remainTime.days = Math.trunc(remainSeconds / 86400);
    remainSeconds %= 86400;

    remainTime.hours = Math.trunc(remainSeconds / 3600);
    remainSeconds %= 3600;

    remainTime.minutes = Math.trunc(remainSeconds / 60);
    remainSeconds %= 60;

    remainTime.seconds = Math.trunc(remainSeconds);
  }

  const updateRemain = () => {
    incrNow();
    calcRemain();
  }

  const ms = 1000;
  let clear;
  $: {
    clearInterval(clear)
    clear = setInterval(updateRemain, ms)
  }

  setInterval(() => {
    fetchData();
  }, 30 * 1000)
</script>

<div>
  {#await fetchData()}
    Fetching contract dataset...
  {:then _}
    <div class="cur-info">
      <h3>{`${lotteryId}회차`}</h3>
      <span>
        {`종료 일자 : ${finishDate}`}
        <br/>
        {`현재 시간 : ${nowDate}`}
        <br/>
        {`남은 시간 : ${remainTime.days}일 ${remainTime.hours}시간 ${remainTime.minutes}분 ${remainTime.seconds}초`}
        <br/>
        {`판매액 : ${winMoney} ETH`}
        <br/>
        {`판매수량 : ${numTicketSold}개`}
        <br/>
        {`매니저 주소 : ${managerAddr}`}
      <span/>
    </div>
  {/await}
</div>