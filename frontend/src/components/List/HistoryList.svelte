<script>
    export let tableData = [
        {
            vitae: "dolorem",
            lectus: "ipsum",
            quisquam: "quia",
        },
        {
            vitae: "amet",
            lectus: "consectetur",
            quisquam: "adipisci",
        },
    ];
    export let order;
</script>

<table>
    <thead>
        <tr>
            <th>#</th>
            <th>{order} winners</th>
        </tr>
    </thead>
    <tbody>
        {#each Object.values(tableData) as row, i}
            <tr>
                <th scope="#">{i + 1}</th>
                {#each Object.values(row) as cell}
                    <td>{cell}</td>
                {/each}
            </tr>
        {/each}
    </tbody>
</table>

<style>
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
		border: 1px solid #1C6EA4;
		background-color: #EEEEEE;
		width: 250%;
		text-align: center;
		border-collapse: collapse;
	}
	table td, table th {
		border: 1px solid #AAAAAA;
		padding: 3px 2px;
	}
	table tbody td {
		font-size: 13px;
	}
	table tr:nth-child(even) {
		background: #D0E4F5;
	}
	table thead {
		background: #1C6EA4;
		background: -moz-linear-gradient(top, #5592bb 0%, #327cad 66%, #1C6EA4 100%);
		background: -webkit-linear-gradient(top, #5592bb 0%, #327cad 66%, #1C6EA4 100%);
		background: linear-gradient(to bottom, #5592bb 0%, #327cad 66%, #1C6EA4 100%);
		border-bottom: 2px solid #444444;
	}
	table thead th {
		font-size: 15px;
		font-weight: bold;
		color: #FFFFFF;
		border-left: 2px solid #D0E4F5;
	}
	table thead th:first-child {
		border-left: none;
	}

</style>

