{
	"Name": "Bidding Tycoon",
	"Remotes": {
		"GetData": {
			"Arguments": [
				{
					"Name": "name",
					"DataType": "string",

					"Presets": [
						"Game",
						"VeryLongNameThatYouDon\"tWantToTypeEveryTime"
					]
				}
			]
		},

		"Purchase": {
			"Arguments": [
				{
					"Name": "itemName",
					"DataType": "string",

					"Presets": [
						"Donut",
						"Dynamite",
						"BloxyCola"
					]
				},

				{
					"Name": "amount",
					"DataType": "integer"
				}
			]
		},

		"Settings": {
			"Arguments": [
				{
					"Name": "data",
					"DataType": "table",

					"Presets": ["{\"Run\": \"Shift+W\", \"Walk\": [\"Shift\", \"Alt\"]}"]
				}
			]
		},

		"Bid": {
			"Arguments": [
				{
					"Name": "itemName",
					"DataType": "string",

					"Presets": [
						"Hat",
						"Gear",
						"Audio",
						"Golden Super Fly Boombox"
					]
				},

				{
					"Name": "amount",
					"DataType": "integer"
				},

				{
					"Name": "price",
					"DataType": "integer"
				}
			]
		}
	}
}
