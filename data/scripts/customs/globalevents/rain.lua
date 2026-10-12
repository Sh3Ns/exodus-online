print(">> Rain System Loaded")

if configManager.getBoolean(configKeys.WEATHER_RAIN) then
	local weatherStartup = GlobalEvent("WeatherStartup")

	function weatherStartup.onStartup()
		if math.random(100) <= 15 then
			Game.setStorageValue('Weather', 1)
		else
			Game.setStorageValue('Weather', 0)
		end
		return true
	end

weatherStartup:register()

local weather = GlobalEvent("Weather")

local START_RAIN_CHANCE = 30  --  chance to start raining
local STOP_RAIN_CHANCE  = 10  --  chance to stop raining

function weather.onThink(interval, lastExecution)
	local current = Game.getStorageValue('Weather')
	if current == 1 then
		if math.random(100) <= STOP_RAIN_CHANCE then
			Game.setStorageValue('Weather', 0)
		end
	else
		if math.random(100) <= START_RAIN_CHANCE then
			Game.setStorageValue('Weather', 1)
		end
	end
	return true
end

weather:interval(100000)
weather:register()

local weatherRain = GlobalEvent("WeatherRain")

function weatherRain.onThink(interval, lastExecution)
	if Game.getStorageValue('Weather') == 1 then
		local players = Game.getPlayers()
		if #players == 0 then
			return true
		end
		for i = 1, #players do
			local player = players[i]
			player:sendWeatherEffect(weatherConfig.groundEffect, weatherConfig.fallEffect, weatherConfig.thunderEffect)
		end
	end
	return true
end

weatherRain:interval(500)
weatherRain:register()
end

local weatherThunder = GlobalEvent("WeatherThunder")

function weatherThunder.onThink(interval, lastExecution)
	if Game.getStorageValue('Weather') ~= 1 then
		return true
	end

	local players = Game.getPlayers()
	if #players == 0 then
		return true
	end

	local roll = math.random(100)
	local thunderCount = 1

	if roll <= 5 then
		thunderCount = 3
	elseif roll <= 30 then
		thunderCount = 2
	else
		thunderCount = 1
	end

	for t = 1, thunderCount do
		local player = players[math.random(#players)]
		if not player then
			break
		end

		local pos = player:getPosition()

		local basePos = player:getPosition()
		local thunderPos = Position(
			basePos.x + math.random(-7, 7),
			basePos.y + math.random(-5, 5),
			basePos.z
		)

		local tile
		for z = 1, 7 do
			thunderPos.z = z
			tile = Tile(thunderPos)
			if tile then
				break
			end
		end

		local tile = Tile(thunderPos)
		if tile	and not tile:hasFlag(TILESTATE_PROTECTIONZONE) and not tile:hasFlag(TILESTATE_HOUSE) then
			thunderPos:sendMagicEffect(weatherConfig.thunderEffect, player)

			local topCreature = tile:getTopCreature()
			if topCreature and topCreature:isPlayer() then
				doTargetCombatHealth(0,	topCreature, COMBAT_ENERGYDAMAGE, -weatherConfig.minDMG, -weatherConfig.maxDMG,	12)
			end
		end
	end

	return true
end

weatherThunder:interval(20000)
weatherThunder:register()