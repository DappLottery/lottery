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
  {#await fetchData()}
    Fetching contract dataset_dev...
  {:then _}
    <br />
    List of mytickets
    <br />
    <br />
    <div class="ticket-info-list">
      <table
        border="1"
        bordercolor="white"
        width="700"
        height="100"
        align="center"
      >
        <thead>
          <tr>
            <th>#</th>
            <th>Ticket ID</th>
            <th>Ticket Number</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            {#each myTickets as myTicket, i}
              <th scope="row">{i}</th>
              <td>{myTicket.id}</td>
              <td>{myTicket.number}</td>
            {/each}
          </tr>
        </tbody>
      </table>
    </div>
  {/await}
</div>

<style>
</style>
