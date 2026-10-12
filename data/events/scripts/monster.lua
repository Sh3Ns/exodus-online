function Monster:onDropLoot(corpse)
	local player = Player(corpse:getCorpseOwner())
	if hasEventCallback(EVENT_CALLBACK_ONDROPLOOT) then
		EventCallback(EVENT_CALLBACK_ONDROPLOOT, self, corpse)
	end
	if player then
		player:updateKillTracker(self, corpse)
	end
end

function Monster:onSpawn(position, startup, artificial)
	self:registerEvent("onDeath_randomTierDrops")
	self:registerEvent("onDeath_Bakragore")
	self:registerEvent("combatPowerLevel_Damage")
	self:registerEvent("combatPowerLevel_ManaDamage")
	self:registerEvent("onPaladinDamageBoost")
	if hasEventCallback(EVENT_CALLBACK_ONSPAWN) then
		return EventCallback(EVENT_CALLBACK_ONSPAWN, self, position, startup, artificial)
	else
		return true
	end
end
