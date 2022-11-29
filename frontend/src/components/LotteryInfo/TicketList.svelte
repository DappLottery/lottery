<script>
  export let selectedAccount;
  export let contracts;

  let myTickets;

  const fetchData = async () => {
    try {
      myTickets = await $contracts.Lottery.methods
        .getTickets($selectedAccount)
        .call();
    } catch (err) {
      console.log(err);
      throw new Error(err);
    }
  };
</script>

<div>

</div>

<style>
</style>
