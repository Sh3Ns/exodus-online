local WARNING_EFFECT = 262

local profiles = {
	["Mimar Haffar"] = {
		fractures = 10,
		attacks = {
			{type = COMBAT_HOLYDAMAGE, effect = 210, shootEffect = 103},
			{type = COMBAT_FIREDAMAGE, effect = 443, shootEffect = 131},
			{type = COMBAT_HOLYDAMAGE, effect = 223, shootEffect = 103},
			{type = COMBAT_FIREDAMAGE, effect = 449, shootEffect = 121},
			{type = COMBAT_HOLYDAMAGE, effect = 270, shootEffect = 103}
		}
	},
	["Maior Domus"] = {
		fractures = 14,
		attacks = {
			{type = COMBAT_EARTHDAMAGE, effect = 342, shootEffect = 118},
			{type = COMBAT_PHYSICALDAMAGE, effect = 413, shootEffect = 107},
			{type = COMBAT_ENERGYDAMAGE, effect = 377, shootEffect = 104},
			{type = COMBAT_EARTHDAMAGE, effect = 304, shootEffect = 124},
			{type = COMBAT_PHYSICALDAMAGE, effect = 445, shootEffect = 115}
		}
	},
	["Maior Domus Echo"] = {
		fractures = 16,
		attacks = {
			{type = COMBAT_EARTHDAMAGE, effect = 387, shootEffect = 128},
			{type = COMBAT_PHYSICALDAMAGE, effect = 386, shootEffect = 119},
			{type = COMBAT_ENERGYDAMAGE, effect = 423, shootEffect = 71},
			{type = COMBAT_FIREDAMAGE, effect = 384, shootEffect = 131},
			{type = COMBAT_FIREDAMAGE, effect = 454, shootEffect = 121}
		}
	},
	["Phosphorus Manifestation"] = {
		fractures = 18,
		attacks = {
			{type = COMBAT_DEATHDAMAGE, effect = 451, shootEffect = 123},
			{type = COMBAT_ARCANEDAMAGE, effect = 442, shootEffect = 127},
			{type = COMBAT_WATERDAMAGE, effect = 440, shootEffect = 126},
			{type = COMBAT_DEATHDAMAGE, effect = 464, shootEffect = 123},
			{type = COMBAT_ARCANEDAMAGE, effect = 465, shootEffect = 112}
		}
	},
	["Phosphorus Ascendant"] = {
		fractures = 20,
		attacks = {
			{type = COMBAT_DEATHDAMAGE, effect = 441, shootEffect = 123},
			{type = COMBAT_ARCANEDAMAGE, effect = 457, shootEffect = 127},
			{type = COMBAT_WATERDAMAGE, effect = 444, shootEffect = 130},
			{type = COMBAT_PHYSICALDAMAGE, effect = 445, shootEffect = 115},
			{type = COMBAT_ENERGYDAMAGE, effect = 333, shootEffect = 104}
		}
	}
}

local directionOffsets = {
	[DIRECTION_NORTH] = {x = 0, y = -1},
	[DIRECTION_EAST] = {x = 1, y = 0},
	[DIRECTION_SOUTH] = {x = 0, y = 1},
	[DIRECTION_WEST] = {x = -1, y = 0},
	[DIRECTION_SOUTHWEST] = {x = -1, y = 1},
	[DIRECTION_SOUTHEAST] = {x = 1, y = 1},
	[DIRECTION_NORTHWEST] = {x = -1, y = -1},
	[DIRECTION_NORTHEAST] = {x = 1, y = -1}
}

local function positionData(position)
	return {x = position.x, y = position.y, z = position.z}
end

local function offsetPosition(origin, offsetX, offsetY)
	return Position(origin.x + offsetX, origin.y + offsetY, origin.z)
end

local function positionKey(position)
	return position.x .. ":" .. position.y .. ":" .. position.z
end

local function getProfile(creature, attackIndex)
	local profile = profiles[creature:getName()]
	if not profile then
		return nil, nil
	end

	local monsterValues = ScriptedMonsterCombatValues and ScriptedMonsterCombatValues[creature:getName()]
	local combatValues = monsterValues and monsterValues[attackIndex]
	if not combatValues then
		return nil, nil
	end

	local attack = profile.attacks[attackIndex]
	attack.minDamage = math.min(math.abs(combatValues.minDamage), math.abs(combatValues.maxDamage))
	attack.maxDamage = math.max(math.abs(combatValues.minDamage), math.abs(combatValues.maxDamage))
	if attack.maxDamage == 0 then
		return nil, nil
	end
	return profile, attack
end

local function getCaster(casterId, casterName)
	local caster = Creature(casterId)
	if not caster or not caster:isMonster() or caster:getName() ~= casterName then
		return nil
	end
	return caster
end

local function schedule(caster, delay, callback)
	local casterId = caster:getId()
	local casterName = caster:getName()
	addEvent(function()
		local currentCaster = getCaster(casterId, casterName)
		if currentCaster then
			callback(currentCaster)
		end
	end, delay)
end

local function uniquePositions(positions)
	local unique = {}
	local result = {}
	for _, position in ipairs(positions) do
		local key = positionKey(position)
		if not unique[key] then
			unique[key] = true
			result[#result + 1] = position
		end
	end
	return result
end

local function showEffect(positions, effect)
	for _, position in ipairs(uniquePositions(positions)) do
		if Tile(position) then
			position:sendMagicEffect(effect)
		end
	end
end

local function sendMissile(fromPosition, toPosition, attack)
	if attack.shootEffect and Tile(fromPosition) and Tile(toPosition) then
		fromPosition:sendDistanceEffect(toPosition, attack.shootEffect)
	end
end

local function damagePositions(caster, positions, attack)
	local damaged = {}
	for _, position in ipairs(uniquePositions(positions)) do
		local tile = Tile(position)
		if tile then
			position:sendMagicEffect(attack.effect)
			for _, target in ipairs(tile:getCreatures() or {}) do
				if target:isPlayer() and not damaged[target:getId()] then
					damaged[target:getId()] = true
					doTargetCombatHealth(caster, target, attack.type,
						-attack.minDamage, -attack.maxDamage, CONST_ME_NONE)
				end
			end
		end
	end
end

local function getAimPosition(creature, distance)
	local target = creature:getTarget()
	if target then
		return positionData(target:getPosition())
	end

	local origin = creature:getPosition()
	local direction = directionOffsets[creature:getDirection()] or directionOffsets[DIRECTION_NORTH]
	return {
		x = origin.x + direction.x * distance,
		y = origin.y + direction.y * distance,
		z = origin.z
	}
end

local function waveRow(origin, direction, distance)
	local centerX = direction.x * distance
	local centerY = direction.y * distance
	local perpendicularX = -direction.y
	local perpendicularY = direction.x
	local positions = {}
	for width = -1, 1 do
		positions[#positions + 1] = offsetPosition(origin,
			centerX + perpendicularX * width, centerY + perpendicularY * width)
	end
	return positions
end

local function castReturningSurge(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	local direction = directionOffsets[creature:getDirection()] or directionOffsets[DIRECTION_NORTH]
	local sequence = {1, 2, 3, 4, 5, 4, 3, 2, 1}
	for step, distance in ipairs(sequence) do
		local currentDistance = distance
		local previousDistance = step == 1 and 0 or sequence[step - 1]
		schedule(creature, (step - 1) * 170, function(caster)
			local fromPosition = offsetPosition(origin,
				direction.x * previousDistance, direction.y * previousDistance)
			local toPosition = offsetPosition(origin,
				direction.x * currentDistance, direction.y * currentDistance)
			sendMissile(fromPosition, toPosition, attack)
			damagePositions(caster, waveRow(origin, direction, currentDistance), attack)
		end)
	end
	return true
end

local function ringPositions(origin, radius)
	if radius == 0 then
		return {offsetPosition(origin, 0, 0)}
	end
	return {
		offsetPosition(origin, -radius, -radius),
		offsetPosition(origin, 0, -radius),
		offsetPosition(origin, radius, -radius),
		offsetPosition(origin, radius, 0),
		offsetPosition(origin, radius, radius),
		offsetPosition(origin, 0, radius),
		offsetPosition(origin, -radius, radius),
		offsetPosition(origin, -radius, 0)
	}
end

local function castCollapsingHalo(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	for radius = 4, 0, -1 do
		local currentRadius = radius
		local delay = (4 - currentRadius) * 240
		schedule(creature, delay, function(caster)
			local missileRadius = currentRadius + 1
			for _, vector in ipairs({
				{x = 1, y = 0}, {x = -1, y = 0},
				{x = 0, y = 1}, {x = 0, y = -1}
			}) do
				sendMissile(
					offsetPosition(origin, vector.x * missileRadius, vector.y * missileRadius),
					offsetPosition(origin, vector.x * currentRadius, vector.y * currentRadius),
					attack
				)
			end
			damagePositions(caster, ringPositions(origin, currentRadius), attack)
		end)
	end
	return true
end

local function crossPositions(origin, radius)
	local positions = {offsetPosition(origin, 0, 0)}
	for distance = 1, radius do
		positions[#positions + 1] = offsetPosition(origin, distance, 0)
		positions[#positions + 1] = offsetPosition(origin, -distance, 0)
		positions[#positions + 1] = offsetPosition(origin, 0, distance)
		positions[#positions + 1] = offsetPosition(origin, 0, -distance)
	end
	return positions
end

local function castAstralCross(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local source = positionData(creature:getPosition())
	local origin = getAimPosition(creature, 4)
	sendMissile(offsetPosition(source, 0, 0), offsetPosition(origin, 0, 0), attack)
	showEffect(crossPositions(origin, 5), WARNING_EFFECT)
	for distance = 0, 5 do
		local currentDistance = distance
		schedule(creature, 650 + currentDistance * 120, function(caster)
			local positions
			if currentDistance == 0 then
				positions = {offsetPosition(origin, 0, 0)}
			else
				positions = {
					offsetPosition(origin, currentDistance, 0),
					offsetPosition(origin, -currentDistance, 0),
					offsetPosition(origin, 0, currentDistance),
					offsetPosition(origin, 0, -currentDistance)
				}
			end
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local rotatingVectors = {
	{x = 1, y = 0},
	{x = 1, y = 1},
	{x = 0, y = 1},
	{x = 1, y = -1}
}

local function riftLine(origin, vector, includeCenter)
	local positions = {}
	for distance = -5, 5 do
		if includeCenter or distance ~= 0 then
			positions[#positions + 1] = offsetPosition(origin,
				vector.x * distance, vector.y * distance)
		end
	end
	return positions
end

local function castRotatingRifts(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	for index, vector in ipairs(rotatingVectors) do
		local currentVector = vector
		local currentPositions = riftLine(origin, currentVector, index == 1)
		showEffect(currentPositions, WARNING_EFFECT)
		schedule(creature, 500 + (index - 1) * 260, function(caster)
			sendMissile(offsetPosition(origin, 0, 0),
				offsetPosition(origin, currentVector.x * 5, currentVector.y * 5), attack)
			sendMissile(offsetPosition(origin, 0, 0),
				offsetPosition(origin, currentVector.x * -5, currentVector.y * -5), attack)
			damagePositions(caster, currentPositions, attack)
		end)
	end
	return true
end

local function getFracturePositions(origin, count)
	local candidates = {}
	for offsetX = -5, 5 do
		for offsetY = -5, 5 do
			local position = offsetPosition(origin, offsetX, offsetY)
			local tile = Tile(position)
			if tile and tile:isWalkable() then
				candidates[#candidates + 1] = position
			end
		end
	end

	for index = #candidates, 2, -1 do
		local randomIndex = math.random(index)
		candidates[index], candidates[randomIndex] = candidates[randomIndex], candidates[index]
	end

	local positions = {}
	for index = 1, math.min(count, #candidates) do
		positions[#positions + 1] = candidates[index]
	end
	return positions
end

local function castFracturedGround(creature, attackIndex)
	local profile, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local source = positionData(creature:getPosition())
	local origin = getAimPosition(creature, 3)
	local positions = getFracturePositions(origin, profile.fractures)
	showEffect(positions, WARNING_EFFECT)
	for index = 1, math.min(5, #positions) do
		sendMissile(offsetPosition(source, 0, 0), positions[index], attack)
	end
	schedule(creature, 1000, function(caster)
		damagePositions(caster, positions, attack)
	end)
	return true
end

local function castExpandingHalo(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	for radius = 0, 4 do
		local currentRadius = radius
		schedule(creature, currentRadius * 220, function(caster)
			local positions = ringPositions(origin, currentRadius)
			if currentRadius > 0 then
				sendMissile(offsetPosition(origin, 0, 0), positions[2], attack)
			end
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castAdvancingCone(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	local direction = directionOffsets[creature:getDirection()] or directionOffsets[DIRECTION_NORTH]
	local perpendicular = {x = -direction.y, y = direction.x}
	for distance = 1, 5 do
		local currentDistance = distance
		local positions = {}
		for width = -math.min(currentDistance, 3), math.min(currentDistance, 3) do
			positions[#positions + 1] = offsetPosition(origin,
				direction.x * currentDistance + perpendicular.x * width,
				direction.y * currentDistance + perpendicular.y * width)
		end
		schedule(creature, (currentDistance - 1) * 190, function(caster)
			sendMissile(offsetPosition(origin, 0, 0), positions[math.ceil(#positions / 2)], attack)
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castDualLanes(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	local direction = directionOffsets[creature:getDirection()] or directionOffsets[DIRECTION_NORTH]
	local perpendicular = {x = -direction.y, y = direction.x}
	for distance = 1, 6 do
		local currentDistance = distance
		local positions = {
			offsetPosition(origin, direction.x * currentDistance + perpendicular.x * 2,
				direction.y * currentDistance + perpendicular.y * 2),
			offsetPosition(origin, direction.x * currentDistance - perpendicular.x * 2,
				direction.y * currentDistance - perpendicular.y * 2)
		}
		schedule(creature, (currentDistance - 1) * 180, function(caster)
			for _, position in ipairs(positions) do
				sendMissile(offsetPosition(origin, 0, 0), position, attack)
			end
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castSweepingWall(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	local direction = directionOffsets[creature:getDirection()] or directionOffsets[DIRECTION_NORTH]
	local perpendicular = {x = -direction.y, y = direction.x}
	local offsets = {-4, -2, 0, 2, 4}
	for step, forwardOffset in ipairs(offsets) do
		local currentOffset = forwardOffset
		local positions = {}
		for width = -5, 5 do
			positions[#positions + 1] = offsetPosition(origin,
				direction.x * currentOffset + perpendicular.x * width,
				direction.y * currentOffset + perpendicular.y * width)
		end
		showEffect(positions, WARNING_EFFECT)
		schedule(creature, 550 + (step - 1) * 240, function(caster)
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castCheckerFloor(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = getAimPosition(creature, 3)
	local groups = {{}, {}}
	for offsetX = -4, 4 do
		for offsetY = -4, 4 do
			local position = offsetPosition(origin, offsetX, offsetY)
			local tile = Tile(position)
			if tile and tile:isWalkable() then
				local group = ((offsetX + offsetY) % 2 == 0) and 1 or 2
				groups[group][#groups[group] + 1] = position
			end
		end
	end

	showEffect(groups[1], WARNING_EFFECT)
	schedule(creature, 700, function(caster)
		damagePositions(caster, groups[1], attack)
		showEffect(groups[2], WARNING_EFFECT)
	end)
	schedule(creature, 1250, function(caster)
		damagePositions(caster, groups[2], attack)
	end)
	return true
end

local function castZigzag(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	local direction = directionOffsets[creature:getDirection()] or directionOffsets[DIRECTION_NORTH]
	local perpendicular = {x = -direction.y, y = direction.x}
	local previous = offsetPosition(origin, 0, 0)
	for distance = 1, 7 do
		local currentDistance = distance
		local side = currentDistance % 2 == 0 and 2 or -2
		local center = offsetPosition(origin,
			direction.x * currentDistance + perpendicular.x * side,
			direction.y * currentDistance + perpendicular.y * side)
		local fromPosition = previous
		previous = center
		local positions = {
			center,
			offsetPosition(positionData(center), perpendicular.x, perpendicular.y),
			offsetPosition(positionData(center), -perpendicular.x, -perpendicular.y)
		}
		schedule(creature, (currentDistance - 1) * 190, function(caster)
			sendMissile(fromPosition, center, attack)
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local eightDirections = {
	{x = 0, y = -1}, {x = 1, y = -1}, {x = 1, y = 0}, {x = 1, y = 1},
	{x = 0, y = 1}, {x = -1, y = 1}, {x = -1, y = 0}, {x = -1, y = -1}
}

local function castStarBurst(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	for distance = 1, 5 do
		local currentDistance = distance
		local positions = {}
		for _, vector in ipairs(eightDirections) do
			positions[#positions + 1] = offsetPosition(origin,
				vector.x * currentDistance, vector.y * currentDistance)
		end
		schedule(creature, (currentDistance - 1) * 180, function(caster)
			for _, position in ipairs(positions) do
				sendMissile(offsetPosition(origin, 0, 0), position, attack)
			end
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castDiagonalCross(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = getAimPosition(creature, 4)
	local warnings = {}
	for distance = 0, 5 do
		warnings[#warnings + 1] = offsetPosition(origin, distance, distance)
		warnings[#warnings + 1] = offsetPosition(origin, distance, -distance)
		warnings[#warnings + 1] = offsetPosition(origin, -distance, distance)
		warnings[#warnings + 1] = offsetPosition(origin, -distance, -distance)
	end
	showEffect(warnings, WARNING_EFFECT)

	for distance = 0, 5 do
		local currentDistance = distance
		local positions = {
			offsetPosition(origin, currentDistance, currentDistance),
			offsetPosition(origin, currentDistance, -currentDistance),
			offsetPosition(origin, -currentDistance, currentDistance),
			offsetPosition(origin, -currentDistance, -currentDistance)
		}
		schedule(creature, 600 + currentDistance * 130, function(caster)
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castTargetRain(creature, attackIndex)
	local profile, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local source = positionData(creature:getPosition())
	local origin = getAimPosition(creature, 3)
	local positions = getFracturePositions(origin, math.max(9, math.floor(profile.fractures * 0.75)))
	for round = 1, 3 do
		local currentRound = round
		local group = {}
		for index = currentRound, #positions, 3 do
			group[#group + 1] = positions[index]
		end
		showEffect(group, WARNING_EFFECT)
		schedule(creature, 650 + (currentRound - 1) * 320, function(caster)
			for index = 1, math.min(3, #group) do
				sendMissile(offsetPosition(source, 0, 0), group[index], attack)
			end
			damagePositions(caster, group, attack)
		end)
	end
	return true
end

local function castSpiral(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	for step = 1, 10 do
		local currentStep = step
		local radius = 1 + ((currentStep - 1) % 5)
		local baseIndex = ((currentStep - 1) % 8) + 1
		local positions = {}
		for arm = 0, 3 do
			local vectorIndex = ((baseIndex - 1 + arm * 2) % 8) + 1
			local vector = eightDirections[vectorIndex]
			positions[#positions + 1] = offsetPosition(origin, vector.x * radius, vector.y * radius)
		end
		schedule(creature, (currentStep - 1) * 150, function(caster)
			for _, position in ipairs(positions) do
				sendMissile(offsetPosition(origin, 0, 0), position, attack)
			end
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castRecoilNova(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	local sequence = {1, 2, 3, 4, 5, 4, 3, 2, 1, 0}
	for step, radius in ipairs(sequence) do
		local currentRadius = radius
		schedule(creature, (step - 1) * 160, function(caster)
			damagePositions(caster, ringPositions(origin, currentRadius), attack)
		end)
	end
	return true
end

local function castOrbitingComets(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	local previous = offsetPosition(origin, 0, -4)
	for step = 1, 8 do
		local currentStep = step
		local vector = eightDirections[currentStep]
		local opposite = eightDirections[((currentStep + 3) % 8) + 1]
		local first = offsetPosition(origin, vector.x * 4, vector.y * 4)
		local second = offsetPosition(origin, opposite.x * 4, opposite.y * 4)
		local fromPosition = previous
		previous = first
		schedule(creature, (currentStep - 1) * 190, function(caster)
			sendMissile(fromPosition, first, attack)
			sendMissile(offsetPosition(origin, 0, 0), second, attack)
			damagePositions(caster, {first, second}, attack)
		end)
	end
	return true
end

local function castEnergyCollapse(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = getAimPosition(creature, 3)
	for step, radius in ipairs({5, 3, 1}) do
		local currentRadius = radius
		local positions = ringPositions(origin, currentRadius)
		showEffect(positions, WARNING_EFFECT)
		schedule(creature, 550 + (step - 1) * 350, function(caster)
			damagePositions(caster, positions, attack)
		end)
	end

	local center = {}
	for offsetX = -1, 1 do
		for offsetY = -1, 1 do
			center[#center + 1] = offsetPosition(origin, offsetX, offsetY)
		end
	end
	showEffect(center, WARNING_EFFECT)
	schedule(creature, 1600, function(caster)
		damagePositions(caster, center, attack)
	end)
	return true
end

local function castDeathTide(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	local direction = directionOffsets[creature:getDirection()] or directionOffsets[DIRECTION_NORTH]
	local perpendicular = {x = -direction.y, y = direction.x}
	local sequence = {1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1}
	for step, distance in ipairs(sequence) do
		local currentDistance = distance
		local positions = {}
		for width = -2, 2 do
			positions[#positions + 1] = offsetPosition(origin,
				direction.x * currentDistance + perpendicular.x * width,
				direction.y * currentDistance + perpendicular.y * width)
		end
		schedule(creature, (step - 1) * 150, function(caster)
			sendMissile(offsetPosition(origin, 0, 0), positions[3], attack)
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castAbyssalSweep(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = getAimPosition(creature, 3)
	local offsets = {-4, -2, 0, 2, 4}
	for step, offset in ipairs(offsets) do
		local currentOffset = offset
		local positions = {}
		for distance = -5, 5 do
			if step % 2 == 1 then
				positions[#positions + 1] = offsetPosition(origin, distance, currentOffset)
			else
				positions[#positions + 1] = offsetPosition(origin, currentOffset, distance)
			end
		end
		showEffect(positions, WARNING_EFFECT)
		schedule(creature, 600 + (step - 1) * 260, function(caster)
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castSoulRain(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local source = positionData(creature:getPosition())
	local origin = getAimPosition(creature, 3)
	local centers = {
		{x = -3, y = 0},
		{x = 3, y = 0},
		{x = 0, y = 3}
	}
	for round, centerOffset in ipairs(centers) do
		local center = {
			x = origin.x + centerOffset.x,
			y = origin.y + centerOffset.y,
			z = origin.z
		}
		local positions = getFracturePositions(center, 6)
		showEffect(positions, WARNING_EFFECT)
		schedule(creature, 650 + (round - 1) * 380, function(caster)
			for index = 1, math.min(2, #positions) do
				sendMissile(offsetPosition(source, 0, 0), positions[index], attack)
			end
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castAstralImplosion(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = getAimPosition(creature, 3)
	for step = 1, 10 do
		local currentStep = step
		local radius = 5 - math.floor((currentStep - 1) / 2)
		local baseIndex = ((currentStep - 1) % 8) + 1
		local positions = {}
		for arm = 0, 3 do
			local vector = eightDirections[((baseIndex - 1 + arm * 2) % 8) + 1]
			positions[#positions + 1] = offsetPosition(origin, vector.x * radius, vector.y * radius)
		end
		schedule(creature, (currentStep - 1) * 160, function(caster)
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castArcaneCrown(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local source = positionData(creature:getPosition())
	local origin = getAimPosition(creature, 3)
	local crownOffsets = {
		{-4, 0}, {-3, -2}, {-1, -3}, {1, -3}, {3, -2}, {4, 0},
		{3, 2}, {1, 3}, {-1, 3}, {-3, 2}
	}
	for phase = 1, 2 do
		local positions = {}
		for _, offset in ipairs(crownOffsets) do
			local multiplier = phase == 1 and 1 or 0.5
			positions[#positions + 1] = offsetPosition(origin,
				math.ceil(offset[1] * multiplier), math.ceil(offset[2] * multiplier))
		end
		showEffect(positions, WARNING_EFFECT)
		schedule(creature, 650 + (phase - 1) * 450, function(caster)
			for index = 1, math.min(4, #positions) do
				sendMissile(offsetPosition(source, 0, 0), positions[index], attack)
			end
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castTidalJudgment(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = getAimPosition(creature, 3)
	local sequence = {-5, 5, -3, 3, -1, 1, 0}
	for step, rowOffset in ipairs(sequence) do
		local currentOffset = rowOffset
		local positions = {}
		for width = -4, 4 do
			positions[#positions + 1] = offsetPosition(origin, width, currentOffset)
		end
		showEffect(positions, WARNING_EFFECT)
		schedule(creature, 500 + (step - 1) * 210, function(caster)
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function castIronExtinction(creature, attackIndex)
	local _, attack = getProfile(creature, attackIndex)
	if not attack then
		return false
	end

	local origin = positionData(creature:getPosition())
	for radius = 5, 0, -1 do
		local currentRadius = radius
		local positions = {}
		if currentRadius == 0 then
			positions[1] = offsetPosition(origin, 0, 0)
		else
			for _, vector in ipairs(eightDirections) do
				positions[#positions + 1] = offsetPosition(origin,
					vector.x * currentRadius, vector.y * currentRadius)
			end
		end
		schedule(creature, (5 - currentRadius) * 210, function(caster)
			damagePositions(caster, positions, attack)
		end)
	end
	return true
end

local function registerBossSpell(name, words, callback)
	local spell = Spell("instant")
	spell.onCastSpell = function(creature, variant)
		return callback(creature)
	end
	spell:name(name)
	spell:words(words)
	spell:isAggressive(true)
	spell:blockWalls(true)
	spell:needDirection(false)
	spell:needLearn(false)
	spell:register()
end

local function useAttack(callback, attackIndex)
	return function(creature)
		return callback(creature, attackIndex)
	end
end

registerBossSpell("mimar solar return", "###1201", useAttack(castReturningSurge, 1))
registerBossSpell("mimar flame corona", "###1202", useAttack(castExpandingHalo, 2))
registerBossSpell("mimar radiant cross", "###1203", useAttack(castAstralCross, 3))
registerBossSpell("mimar dancing flames", "###1204", useAttack(castSpiral, 4))
registerBossSpell("mimar consecrated ground", "###1205", useAttack(castFracturedGround, 5))

registerBossSpell("domus earthen advance", "###1206", useAttack(castAdvancingCone, 1))
registerBossSpell("domus crushing halo", "###1207", useAttack(castCollapsingHalo, 2))
registerBossSpell("domus voltaic lanes", "###1208", useAttack(castDualLanes, 3))
registerBossSpell("domus tectonic sweep", "###1209", useAttack(castSweepingWall, 4))
registerBossSpell("domus shrapnel floor", "###1210", useAttack(castCheckerFloor, 5))

registerBossSpell("domus echo root serpent", "###1211", useAttack(castZigzag, 1))
registerBossSpell("domus echo iron star", "###1212", useAttack(castStarBurst, 2))
registerBossSpell("domus echo storm saltire", "###1213", useAttack(castDiagonalCross, 3))
registerBossSpell("domus echo flame wheel", "###1214", useAttack(castRotatingRifts, 4))
registerBossSpell("domus echo infernal rain", "###1215", useAttack(castTargetRain, 5))

registerBossSpell("manifestation death tide", "###1216", useAttack(castDeathTide, 1))
registerBossSpell("manifestation arcane orbit", "###1217", useAttack(castOrbitingComets, 2))
registerBossSpell("manifestation abyssal sweep", "###1218", useAttack(castAbyssalSweep, 3))
registerBossSpell("manifestation soul rain", "###1219", useAttack(castSoulRain, 4))
registerBossSpell("manifestation astral spiral", "###1220", useAttack(castAstralImplosion, 5))

registerBossSpell("ascendant death recoil", "###1221", useAttack(castRecoilNova, 1))
registerBossSpell("ascendant arcane crown", "###1222", useAttack(castArcaneCrown, 2))
registerBossSpell("ascendant tidal judgment", "###1223", useAttack(castTidalJudgment, 3))
registerBossSpell("ascendant iron extinction", "###1224", useAttack(castIronExtinction, 4))
registerBossSpell("ascendant energy collapse", "###1225", useAttack(castEnergyCollapse, 5))
