local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

function onCreatureAppear(cid)
	npcHandler:onCreatureAppear(cid)
end
function onCreatureDisappear(cid)
	npcHandler:onCreatureDisappear(cid)
end
function onCreatureSay(cid, type, msg)
	npcHandler:onCreatureSay(cid, type, msg)
end
function onThink()
	npcHandler:onThink()
end

local shop = {
	{id=29938, buy=50, sell=0, name='nunchaku of destruction'},
	{id=30040, buy=50, sell=0, name='blade of destruction'},
	{id=30041, buy=50, sell=0, name='slayer of destruction'},
	{id=30042, buy=50, sell=0, name='axe of destruction'},
	{id=30043, buy=50, sell=0, name='chopper of destruction'},
	{id=30044, buy=50, sell=0, name='mace of destruction'},
	{id=30045, buy=50, sell=0, name='hammer of destruction'},
	{id=30046, buy=50, sell=0, name='bow of destruction'},
	{id=30047, buy=50, sell=0, name='crossbow of destruction'},
	{id=30048, buy=50, sell=0, name='wand of destruction'},
	{id=30049, buy=50, sell=0, name='rod of destruction'},

}

local function setNewTradeTable(table)
	local items, item = {}
	for i = 1, #table do
		item = table[i]
		items[item.id] = {id = item.id, buy = item.buy, sell = item.sell, subType = 0, name = item.name}
	end
	return items
end

local function onBuy(cid, item, subType, amount, ignoreCap, inBackpacks)
	local player = Player(cid)
	local itemsTable = setNewTradeTable(shop)
	if not ignoreCap and player:getFreeCapacity() < ItemType(itemsTable[item].id):getWeight(amount) then
		return player:sendTextMessage(MESSAGE_INFO_DESCR, "You don't have enough cap.")
	end
	if itemsTable[item].buy then
		if player:removeItem(25377, amount * itemsTable[item].buy) then
			if amount > 1 then
				currencyName = ItemType(25377):getPluralName():lower()
			else
				currencyName = ItemType(25377):getName():lower()
			end
			player:addItem(itemsTable[item].id, amount)
			return player:sendTextMessage(MESSAGE_INFO_DESCR,
						"Bought "..amount.."x "..itemsTable[item].name.." for "..itemsTable[item].buy * amount.." "..currencyName..".")
		else
			return player:sendTextMessage(MESSAGE_INFO_DESCR, "You don't have enough Gold Tokens.")
		end
	end

	return true
end

local function onSell(cid, item, subType, amount, ignoreCap, inBackpacks)
	return true
end


local function greetCallback(cid)
    return true
end

local voices = {
	{ text = 'Trading tokens! First-class bargains!' },
	{ text = 'Bespoke armor for all vocations! For the cost of some tokens only!' },
	{ text = 'Tokens! Bring your tokens!' }
}

npcHandler:addModule(VoiceModule:new(voices))

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end
	local player = Player(cid)
	if not player then
		return false
	end
	if msgcontains(msg, 'token') or msgcontains(msg, 'tokens') then
		npcHandler:say("If you have any {gold} tokens with you, let's have a look! Maybe I can offer you something in exchange.", cid)
	elseif msgcontains(msg, 'information') then
		npcHandler:say("With pleasure. <bows> I trade {token}s. There are several ways to obtain the {token}s I am interested in - killing certain bosses, for example. In exchange for a certain amount of tokens, I can offer you some first-class items.", cid)
	elseif msgcontains(msg, 'gold') then
		local player = Player(cid)
        player:sendExtendedOpcode(ServerOpcodes.currencyType, "GT")
        local coinAmount = player:getItemCount(25377) or 0
        player:sendExtendedOpcode(ServerOpcodes.coinAmount, tostring(coinAmount))
		openShopWindow(cid, shop, onBuy, onSell)
		npcHandler:say({"Here's the deal, " .. player:getName() .. ". For 50 of your gold tokens, I can offer you some first-class weapons of destruction."}, cid)
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
