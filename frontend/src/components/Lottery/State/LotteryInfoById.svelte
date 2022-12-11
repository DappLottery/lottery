<script>
  import { web3 } from "svelte-web3";

  export let lotteryId;
  let lotteryInfo;

  const fetchData = async () => {
    try {
      await fetch(
        "http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/history",
        {
          method: "GET",
        }
      )
        .then(res => res.json())
        .then(result => (lotteryInfo = result[lotteryId]));
    } catch (err) {
      console.log(err);
      throw new Error(err);
    }
  };
</script>

<div>
  {#await fetchData()}
    Fetching contract dataset...
  {:then _}
    <div class="cur-info">
      <h3>{`${lotteryId}회차`}</h3>
      <span>
        {`매니저 주소 : ${lotteryInfo.manager}`}
        <br/>
        {`판매수량 : ${lotteryInfo.ticket_sold}개`}
        <br/>
        {`판매액 : ${$web3.utils.fromWei(lotteryInfo.game_money.toString(), "ether")} ETH`}
        <br/>
        {`당첨 번호 : ${lotteryInfo.lucky_number}`}
        <br/>
        {`1등 당첨자 : ${lotteryInfo.first_winner}`}
        <br/>
        {`2등 당첨자 : ${lotteryInfo.second_winner}`}
        <br/>
        {`3등 당첨자 : ${lotteryInfo.third_winner}`}
      <span/>
    </div>
  {/await}
</div>