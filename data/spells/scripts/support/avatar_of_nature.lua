function onCastSpell(creature, variant)
	local player = Player(creature)
	if not player or type(_G.WheelDestiny_castAvatar) ~= "function" then
		return false
	end
	return _G.WheelDestiny_castAvatar(player, "Avatar of Nature")
end
