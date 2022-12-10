<script>
  import { onMount } from "svelte";

  export let lotteryId;

  let games = [];

  onMount(async () => {
    await fetch(
      "http://ec2-3-39-168-175.ap-northeast-2.compute.amazonaws.com:8010/history",
      {
        method: "GET",
      }
    )
      .then(res => res.json())
      .then(result => (games = result));

    console.log(games);
  });
</script>

<ul>
    {#each games as game}
      <li>
        {game.id} | {game.winner}
      </li>
    {/each}
</ul>

<div class="lotto-hist">
  <br/>
  <div>scrollable list using DB</div>
  <br/>
</div>
