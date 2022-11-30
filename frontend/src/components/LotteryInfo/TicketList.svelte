<script>
  export let myTickets;
</script>

<div>
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
        {#each myTickets as myTicket, i}
        <tr>
            <th scope="row">{i+1}</th>
            <td>{myTicket.id}</td>
            <td>{myTicket.number}</td>
        </tr>
        {/each}
      </tbody>
    </table>
  </div>
</div>

<style>
</style>
