local modalWindowHelper = CreatureEvent("ModalWindowHelper")
function modalWindowHelper.onModalWindow(player, modalWindowId, buttonId, choiceId)
	local modalWindow = modalWindows.getWindowById and modalWindows.getWindowById(modalWindowId) or nil

	if not modalWindow then
		return true
	end

	local playerId = player:getId()
	if not modalWindow.players[playerId] then
		return true
	end
	modalWindow.players[playerId] = nil

	local choice = modalWindow.choices[choiceId]
	for _, button in ipairs(modalWindow.buttons) do
		if button.id == buttonId then
			local callback = button.callback or modalWindow.defaultCallback
			if callback then
				callback(button, choice)
				break
			end
		end
	end

	if not next(modalWindow.players) and modalWindow.destroy then
		modalWindow:destroy()
	end
	return true
end
modalWindowHelper:register()
