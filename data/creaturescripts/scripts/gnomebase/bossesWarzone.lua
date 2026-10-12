local bosses = {
	['deathstrike'] = {
		status = 2,
		rewardStorage = Storage.BigfootBurden.Warzone1Reward,
		cooldownStorage = 790015
	},
	['gnomevil'] = {
		status = 3,
		rewardStorage = Storage.BigfootBurden.Warzone2Reward,
		cooldownStorage = 790014
	},
	['abyssador'] = {
		status = 4,
		rewardStorage = Storage.BigfootBurden.Warzone3Reward,
		cooldownStorage = 790016
	},
}

local cooldownTime = 10 * 60 * 60 -- 10 hours

function onKill(creature, target)
	if not target or not target:isMonster() then
		return true
	end

	local targetMonster = target:getMonster()
	if not targetMonster then
		return true
	end

	local bossConfig = bosses[targetMonster:getName():lower()]
	if not bossConfig then
		return true
	end

	for pid, _ in pairs(targetMonster:getDamageMap()) do
		local attackerPlayer = Player(pid)
		if attackerPlayer then
			if attackerPlayer:getStorageValue(Storage.BigfootBurden.WarzoneStatus) < bossConfig.status then
				attackerPlayer:setStorageValue(Storage.BigfootBurden.WarzoneStatus, bossConfig.status)
			end

			attackerPlayer:setStorageValue(bossConfig.rewardStorage, 1)
			attackerPlayer:setStorageValue(bossConfig.cooldownStorage, os.time() + cooldownTime)
		end
	end

	return true
end