local spell = Spell("instant")

local function getFreePositionNearBoss(bossPos)
	local positions = {
		Position(bossPos.x + 1, bossPos.y, bossPos.z),
		Position(bossPos.x - 1, bossPos.y, bossPos.z),
		Position(bossPos.x, bossPos.y + 1, bossPos.z),
		Position(bossPos.x, bossPos.y - 1, bossPos.z),
		Position(bossPos.x + 1, bossPos.y + 1, bossPos.z),
		Position(bossPos.x - 1, bossPos.y - 1, bossPos.z),
		Position(bossPos.x + 1, bossPos.y - 1, bossPos.z),
		Position(bossPos.x - 1, bossPos.y + 1, bossPos.z)
	}

	for _, pos in ipairs(positions) do
		local tile = Tile(pos)
		if tile then
			local creatures = tile:getCreatures()
			if creatures then
				if #creatures == 0 then
					return pos
				end
			end
		end
	end
	return bossPos
end

function spell.onCastSpell(creature, var)

	if not creature then
		return false
	end

	local bossPos = creature:getPosition()
	if not bossPos then
		return false
	end

	local spectators = Game.getSpectators(bossPos, false, true, 7, 7, 7, 7)
	if not spectators then
		return true
	end

	creature:say("Come closer!", TALKTYPE_MONSTER_YELL)

	for _, target in ipairs(spectators) do
		if target then
			if target:isPlayer() then
				local targetPos = target:getPosition()
				if targetPos then
					local distance = math.max(
						math.abs(targetPos.x - bossPos.x),
						math.abs(targetPos.y - bossPos.y)
					)
					if distance >= 1 then
						local newPos = getFreePositionNearBoss(bossPos)
						targetPos:sendMagicEffect(CONST_ME_POFF)
						target:teleportTo(newPos, true)
						newPos:sendMagicEffect(CONST_ME_TELEPORT)
					end
				end
			end
		end
	end
	return true
end

spell:name("kraxxis spell")
spell:words("###1133")
spell:isAggressive(true)
spell:blockWalls(true)
spell:needLearn(false)
spell:register()