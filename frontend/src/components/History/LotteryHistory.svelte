<script>
  import { onMount } from "svelte";

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

<div class="lotto-hist">
  <ul>
    {#each games as game}
      <li>
        {game.id} | {game.first_winner}
      </li>
    {/each}
  </ul>
</div>