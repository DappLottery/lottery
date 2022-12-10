<script>
  import {
    selectedAccount,
    contracts,
  } from "svelte-web3";

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
    <h2>My tickets list</h2>
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>Ticket ID</th>
            <th>Ticket Number</th>
          </tr>
        </thead>
        <tbody>
          {#each Object.values(myTickets) as row, i}
            <tr>
                <th scope="#">{i + 1}</th>
                {#each Object.values(row) as cell}
                    <td>{cell}</td>
                {/each}
            </tr>
        {/each}
        </tbody>
      </table>
  {/await}
  
  <h2>A list of all-time winners</h2>
</div>

<style>
  h2 {
        position: relative;
        float: left;
        right: 400px;
    }
    table,
    th,
    td {
        border: 1px solid;
        border-collapse: collapse;
        margin-bottom: 10px;
    }
    
    table {
        position: relative;
        right: 400px;
        border: 2px solid #2069ad;
        background-color: #ffffff;
        width: 250%;
        text-align: center;
        border-collapse: collapse;
    }
    td,
    th {
        border: 1px solid #AAAAAA;
        padding: 3px 2px;
    }
    tbody td {
        font-size: 13px;
    }
    tr:nth-child(even) {
        background: #dbdce4;
    }
    thead {
        background: #0844a4;
        background: -moz-linear-gradient(
            top,
            #2baab6 0%,
            #2069ad 66%,
            #0844a4 100%
        );
        background: -webkit-linear-gradient(
            top,
            #2baab6 0%,
            #2069ad 66%,
            #0844a4 100%
        );
        background: linear-gradient(
            to bottom,
            #2baab6 0%,
            #2069ad 66%,
            #0844a4 100%
        );
    }
    thead th {
        font-size: 19px;
        font-weight: bold;
        color: #FFFFFF;
        text-align: center;
        border-left: 2px solid #2069ad;
    }
    thead th:first-child {
        border-left: none;
    }
</style>