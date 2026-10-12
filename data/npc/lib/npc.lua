-- Including the Advanced NPC System
dofile('data/npc/lib/npcsystem/npcsystem.lua')
dofile('data/npc/lib/npcsystem/customModules.lua')

isPlayerPremiumCallback = Player.isPremium

function msgcontains(message, keyword)
	local message, keyword = message:lower(), keyword:lower()
	if message == keyword then
		return true
	end

	return message:find(keyword) and not message:find('(%w+)' .. keyword)
end

function doNpcSellItem(cid, itemid, amount, subType, ignoreCap, inBackpacks, backpack)
    local amount = amount or 1
    local subType = subType or 0

    if ItemType(itemid):isStackable() then
        local remaining = amount

        if inBackpacks then
            local container = Game.createItem(backpack, 1)
            while remaining > 0 do
                local stack = math.min(1000, remaining)
                container:addItem(itemid, stack)
                remaining = remaining - stack
            end

            if Player(cid):addItemEx(container, ignoreCap) ~= RETURNVALUE_NOERROR then
                return 0, 0
            end

            return amount, 1
        end

        local given = 0
        while remaining > 0 do
            local stack = math.min(1000, remaining)
            local item = Game.createItem(itemid, stack)

            if Player(cid):addItemEx(item, ignoreCap) ~= RETURNVALUE_NOERROR then
                break
            end

            given = given + stack
            remaining = remaining - stack
        end

        return given, 0
    end

    local a = 0
    if inBackpacks then
        local container, b = Game.createItem(backpack, 1), 1
        for i = 1, amount do
            local item = container:addItem(itemid, subType)
            if table.contains({(ItemType(backpack):getCapacity() * b), amount}, i) then
                if Player(cid):addItemEx(container, ignoreCap) ~= RETURNVALUE_NOERROR then
                    b = b - 1
                    break
                end

                a = i
                if amount > i then
                    container = Game.createItem(backpack, 1)
                    b = b + 1
                end
            end
        end
        return a, b
    end

    for i = 1, amount do
        local item = Game.createItem(itemid, subType)
        if Player(cid):addItemEx(item, ignoreCap) ~= RETURNVALUE_NOERROR then
            break
        end
        a = i
    end

    return a, 0
end


local func = function(cid, text, type, e, pcid)
	if Player(pcid):isPlayer() then
		local creature = Creature(cid)
		creature:say(text, type, false, pcid, creature:getPosition())
		e.done = true
	end
end

function doCreatureSayWithDelay(cid, text, type, delay, e, pcid)
	if Player(pcid):isPlayer() then
		e.done = false
		e.event = addEvent(func, delay < 1 and 1000 or delay, cid, text, type, e, pcid)
	end
end

function PlayerTakeItem(cid, itemid, count)
	local player = Player(cid)
	if player:getItemCount(itemid) < count then
		return false
	end

	while count > 0 do
		local tempcount = 0
		if ItemType(itemid):isStackable() then
			tempcount = math.min (1000, count)
		else
			tempcount = 1
		end

		local ret = player:removeItem(itemid, tempcount)
		if ret then
			count = count - tempcount
		else
			return false
		end
	end

	if count ~= 0 then
		return false
	end
	return true
end

function doPlayerSellItem(cid, itemid, count, cost)
	local player = Player(cid)
	if player:removeItem(itemid, count) then
		local payout = math.max(0, tonumber(cost) or 0)
		if not player:addMoney(payout) then
			error('Could not add money to ' .. player:getName() .. '(' .. payout .. 'gp)')
		end
		return true
	end
	return false
end

function doPlayerBuyItemContainer(cid, containerid, itemid, count, cost, charges)
	local player = Player(cid)
	local totalCost = math.max(0, tonumber(cost) or 0)
	if not player:removeTotalMoney(totalCost) then
		return false
	end

	for i = 1, count do
		local container = Game.createItem(containerid, 1)
		for x = 1, ItemType(containerid):getCapacity() do
			container:addItem(itemid, charges)
		end

		if player:addItemEx(container, true) ~= RETURNVALUE_NOERROR then
			return false
		end
	end
	return true
end

function getCount(string)
	local b, e = string:find("%d+")
	return b and e and tonumber(string:sub(b, e)) or -1
end

function Player.removeTotalMoney(self, amount)
	local moneyCount = self:getMoney()
	local bankCount = self:getBankBalance()

	if amount <= moneyCount then
		self:removeMoney(amount)
		return true

	elseif amount <= (moneyCount + bankCount) then
		if moneyCount ~= 0 then
			self:removeMoney(moneyCount)
			local remains = amount - moneyCount
			self:setBankBalance(bankCount - remains)
			self:sendTextMessage(MESSAGE_INFO_DESCR, "Paid " .. tostring(moneyCount) .. " from inventory and " .. tostring(amount - moneyCount) .. " gold from bank account. Your account balance is now " .. tostring(self:getBankBalance()) .. " gold.")
			return true
		else
			self:setBankBalance(bankCount - amount)
			self:sendTextMessage(MESSAGE_INFO_DESCR, "Paid " .. tostring(amount) .. " gold from bank account. Your account balance is now " .. tostring(self:getBankBalance()) .. " gold.")
			return true
		end
	end
	return false
end

function Player.getTotalMoney(self)
	return self:getMoney() + self:getBankBalance()
end
