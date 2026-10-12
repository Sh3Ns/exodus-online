local ec = EventCallback

ec.onGainExperience = function(self, source, exp, rawExp)
	return math.max(0, tonumber(exp) or 0)
end

ec:register()
