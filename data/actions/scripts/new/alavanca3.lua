local BOSSc = "Destabilized Ferumbras"
local FERUMBRAS_COOLDOWN_STORAGE = 93521
local FERUMBRAS_COOLDOWN_TIME = 50 * 60
local roomc = {fromx = 33394, tox = 33426, fromy = 32274, toy = 32301, z = 14} -- boss room
 
local function isPlayerInArea(fromPos, toPos)
    for _x = fromPos.x, toPos.x do
        for _y = fromPos.y, toPos.y do
            for _z = fromPos.z, toPos.z do
                creaturec = getTopCreature({x = _x, y = _y, z = _z})
                    if (isPlayer(creaturec.uid)) then
                    return true
                end
            end
        end
    end
    return false
end


function AddBossc()

local bossc = 0
for x = roomc.fromx, roomc.tox do
for y = roomc.fromy, roomc.toy do
for z = roomc.z, roomc.z do

creaturec = {x = x, y = y, z = z}
mobc = getTopCreature(creaturec).uid

    if mobc > 0 then local name = getCreatureName(mobc) if name == BOSSc then 
		bossc = 1 
		end
	end
end
end
end
end

if bossc == 1 then
end

if bossc == 0 then
		local monster = Game.createMonster("Destabilized Ferumbras", Position(33409, 32286, 14))
		if not monster then return true	
end

return true
end


function onUse(cid, item, fromPosition, itemEx) 
	local player = Player(cid)
	if not player then
		return true
	end
	if(getGlobalStorageValue(93520) < 1) then	
        if item.itemid == 9825 then 
		
	        if player:getStorageValue(1) and not isPlayerInArea({x = 33400, y = 32279, z = 14, stackpos = 100}, {x = 33417, y = 32295, z = 14, stackpos = 100}) then
				pos1c = {x = 33380, y = 32308, z = getCreaturePosition(cid).z}
				pos2c = {x = 33381, y = 32308, z = getCreaturePosition(cid).z}
				pos3c = {x = 33382, y = 32308, z = getCreaturePosition(cid).z}
				pos4c = {x = 33383, y = 32308, z = getCreaturePosition(cid).z}
				pos5c = {x = 33384, y = 32308, z = getCreaturePosition(cid).z}
				pos6c = {x = 33385, y = 32308, z = getCreaturePosition(cid).z}
				pos7c = {x = 33386, y = 32308, z = getCreaturePosition(cid).z}
				pos8c = {x = 33387, y = 32308, z = getCreaturePosition(cid).z}
				pos9c = {x = 33388, y = 32308, z = getCreaturePosition(cid).z}
				pos10c = {x = 33389, y = 32308, z = getCreaturePosition(cid).z}
				
				if(isPlayer(getTopCreature(pos1c).uid)) then
				if(isPlayer(getTopCreature(pos2c).uid)) then
				if(isPlayer(getTopCreature(pos3c).uid)) then
				if(isPlayer(getTopCreature(pos4c).uid)) then
				if(isPlayer(getTopCreature(pos5c).uid)) then
				if(isPlayer(getTopCreature(pos6c).uid)) then
				if(isPlayer(getTopCreature(pos7c).uid)) then
				if(isPlayer(getTopCreature(pos8c).uid)) then
				if(isPlayer(getTopCreature(pos9c).uid)) then
				if(isPlayer(getTopCreature(pos10c).uid)) then
					playSound(cid, "lever.ogg")

				local players = {
					getTopCreature(pos1c).uid,
					getTopCreature(pos2c).uid,
					getTopCreature(pos3c).uid,
					getTopCreature(pos4c).uid,
					getTopCreature(pos5c).uid,
					getTopCreature(pos6c).uid,
					getTopCreature(pos7c).uid,
					getTopCreature(pos8c).uid,
					getTopCreature(pos9c).uid,
					getTopCreature(pos10c).uid
				}

				local teleportPositions = {
					{x = 33403, y = 32294, z = 14},
					{x = 33404, y = 32294, z = 14},
					{x = 33405, y = 32294, z = 14},
					{x = 33406, y = 32294, z = 14},
					{x = 33407, y = 32294, z = 14},
					{x = 33408, y = 32294, z = 14},
					{x = 33409, y = 32294, z = 14},
					{x = 33410, y = 32294, z = 14},
					{x = 33411, y = 32294, z = 14},
					{x = 33412, y = 32294, z = 14}
				}

				for i = 1, #players do
					doTeleportThing(players[i], teleportPositions[i])

					local participant = Player(players[i])
					if participant then
						participant:setStorageValue(FERUMBRAS_COOLDOWN_STORAGE, os.time() + FERUMBRAS_COOLDOWN_TIME)
					end
				end
		   setGlobalStorageValue(93520, 1)
		   addEvent(AddBossc, 5 * 1000)
		   addEvent(setGlobalStorageValue, 50*60*1000, 93520, 0)	
	 end
	 end
	 end
     end
	 end
	 end
	 end
	 end
	 end
	 end
	else PlayerSendTextMessage(cid,19,"There are players inside the room or is missing players here.")
end

end
else 
PlayerSendCancel(cid, "Please, wait 50 minutes counting the last use to start again.")
end
	return true
end