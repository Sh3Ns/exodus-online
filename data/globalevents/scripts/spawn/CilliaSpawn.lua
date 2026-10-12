-- Should Cillia spawn as in real tibia?
local spawnByDay = true
local spawnDay = 'Sunday'
local spawnPosition = Position(32392, 32197, 8)
local weekdays = {'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'}

local function getWeekdayName()
	return weekdays[tonumber(os.date('%w')) + 1]
end

function onStartup()
	if spawnByDay then
		if getWeekdayName() == spawnDay then
			Game.createNpc('Cillia', spawnPosition, false, true)
		end
	else
		Game.createNpc('Cillia', spawnPosition, false, true)
	end

	return true
end
