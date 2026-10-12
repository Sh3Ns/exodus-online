SupplyStash = SupplyStash or {}

SupplyStash.config = {
	opcode = 238,
	itemId = 31900,
	unitsPerSlot = 100,
	freeAccountSlots = 2000,
	premiumAccountSlots = 15000,
	stackSize = 1000,
	maxWithdrawalAmount = 1500000,
	requirePremiumToStow = true,
}

-- Add only NPC names here that are XML if not then should be added manually on the second list
SupplyStash.npcSellerNames = {
	"Khadin",
	"Esrik",
	"Fiona",
	"Gladys",
	"Grizzly Adams", 
	"Irmana", 
	"Luna",
	"Malunga",
	"Rock in a Hard Place",
	"Telas",
	"Tothdral",
	"Yasir",
	"Alesar",
	"Yaman",
	"Asnarus",
	"Estherya",
	"Rashid",
	"Nah'bob",
	"Haroun",
	"Tamoril",
	"Hanna"
}

-- Optional fallback for NPC shops whose sell list is created in Lua instead of XML Shop 
-- Use server item IDs 
SupplyStash.npcSellerOverrides = {
	-- [5877] = { "Grizzly Adams" },
}
