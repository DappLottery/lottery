//임시 data
let data =([{"LotteryId": 1, "TicketId": "#dasd1", "TicketNumber": 111111},
					 {"LotteryId": 2, "TicketId": "#dasd2", "TicketNumber":222222},
					 {"LotteryId": 3, "TicketId": "#dasd3", "TicketNumber":333333},
					 {"LotteryId": 4, "TicketId": "#dasd4", "TicketNumber":444444},
					 {"LotteryId": 5, "TicketId": "#dasd5", "TicketNumber":555555}]);

let id = 0;

//data control
function fill(len) {
	const fn = () => {
		const item = {
			id,
			LotteryId: `${data[id].LotteryId}`,
			TicketId: data[id].TicketId,
			TicketNumber: `${data[id].TicketNumber}`
		}
		id++
		return item
	}
	return Array(len).fill().map(_ => fn())
}

//data배열의 길이만큼 인덱스 추가.
export let loadItems = () => (fill(data.length));