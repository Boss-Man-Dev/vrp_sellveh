
local lang = {
	menu = {
		titles = {
			main = {
				name = "Personal Vehicles",
				info = "List of all Owned Vehicles",
			},
			veh = {
				name = "My Vehicles",
				sell = "Sell Vehicle to {1}",
				value = "Estimated resale value is ${1} ({2}%)",
			},
			options = {
				name = "Options",
				list = "Nearby Players",
				nearby = "Sell to Nearby players",
				player = "Sell to Players via Name",
				users = "{1}",
				error = "No Players Nearby",
				dis = "Move closer to Player",
			},
		},
	},
	sell = {
		user = {
			dead = "~r~The buyer is dead",
			decline = "~r~The offer was declined.",
			canceled = "~r~You cant give it away for free.",
			money = "~r~Player cannot afford that price!",
			owned = "The buyer already owns this vehicle",
			offer = "The offer was sent to the nearest player",
			players = "~r~No player near to sell {1}",
			prompt = "Sell {1} for how much? (must be more than {2})",
			sold = "You sold your {1} for ~r~${2}",
		},
		nuser = {
			bought = "You bought a {1} for ~g~${2}",
			dead = "~r~You are dead and cannot accept the offer",
			decline = "~r~You declined the offer.",
			money = "~r~Not enough Money!",
			owned = "You already own the vehicle",
			offer = "Accept offer to buy a {1} vehicle for ${2}?",
			store = "~r~You are currently in a vehicle or dead so we stored your new {1} in a garage.",
		},
	},
}

return lang
