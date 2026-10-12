local modalId = 1000
local confirmButtonId = 100
local unlockErrorMessage = "You need unlock this familiar first."

local allChoiceStorages = {
    Expeditions.NormalFamiliarChoice,
    Expeditions.BlackDracadetPetChoice,
    Expeditions.BlackDracadetPetChoice2,
    Expeditions.BlackDracadetPetChoice3,
    Expeditions.FrostDracadetPetChoice,
    Expeditions.FrostDracadetPetChoice2,
    Expeditions.FrostDracadetPetChoice3,
    Expeditions.SwampDracadetPetChoice,
    Expeditions.SwampDracadetPetChoice2,
    Expeditions.SwampDracadetPetChoice3,
    Expeditions.StoneDracadetPetChoice,
    Expeditions.StoneDracadetPetChoice2,
    Expeditions.StoneDracadetPetChoice3,
    Expeditions.FireDracadetPetChoice,
    Expeditions.FireDracadetPetChoice2,
    Expeditions.FireDracadetPetChoice3,
}

local familiarChoices = {
    [1] = {
        selectedStorage = Expeditions.NormalFamiliarChoice,
        unlockStorage = nil,
        successMessage = "You have chosen Normal Familiar as your Familiar.",
    },
    [2] = {
        selectedStorage = Expeditions.BlackDracadetPetChoice,
        unlockStorage = Expeditions.BlackDracadetPet,
        successMessage = "You have chosen Black Dracadet as your Familiar.",
    },
    [3] = {
        selectedStorage = Expeditions.BlackDracadetPetChoice2,
        unlockStorage = Expeditions.BlackDracadetPet2,
        successMessage = "You have chosen Black Dracadet [2] as your Familiar.",
    },
    [4] = {
        selectedStorage = Expeditions.BlackDracadetPetChoice3,
        unlockStorage = Expeditions.BlackDracadetPet3,
        successMessage = "You have chosen Black Dracadet [3] as your Familiar.",
    },
    [5] = {
        selectedStorage = Expeditions.FrostDracadetPetChoice,
        unlockStorage = Expeditions.FrostDracadetPet,
        successMessage = "You have chosen Frost Dracadet as your Familiar.",
    },
    [6] = {
        selectedStorage = Expeditions.FrostDracadetPetChoice2,
        unlockStorage = Expeditions.FrostDracadetPet2,
        successMessage = "You have chosen Frost Dracadet [2] as your Familiar.",
    },
    [7] = {
        selectedStorage = Expeditions.FrostDracadetPetChoice3,
        unlockStorage = Expeditions.FrostDracadetPet3,
        successMessage = "You have chosen Frost Dracadet [3] as your Familiar.",
    },
    [8] = {
        selectedStorage = Expeditions.SwampDracadetPetChoice,
        unlockStorage = Expeditions.SwampDracadetPet3,
        successMessage = "You have chosen Swamp Dracadet [3] as your Familiar.",
    },
    [9] = {
        selectedStorage = Expeditions.SwampDracadetPetChoice2,
        unlockStorage = Expeditions.SwampDracadetPet2,
        successMessage = "You have chosen Swamp Dracadet [3] as your Familiar.",
    },
    [10] = {
        selectedStorage = Expeditions.SwampDracadetPetChoice3,
        unlockStorage = Expeditions.SwampDracadetPet,
        successMessage = "You have chosen Swamp Dracadet [3] as your Familiar.",
    },
    [11] = {
        selectedStorage = Expeditions.StoneDracadetPetChoice,
        unlockStorage = Expeditions.StoneDracadetPet3,
        successMessage = "You have chosen Stone Dracadet [3] as your Familiar.",
    },
    [12] = {
        selectedStorage = Expeditions.StoneDracadetPetChoice2,
        unlockStorage = Expeditions.StoneDracadetPet2,
        successMessage = "You have chosen Stone Dracadet [3] as your Familiar.",
    },
    [13] = {
        selectedStorage = Expeditions.StoneDracadetPetChoice3,
        unlockStorage = Expeditions.StoneDracadetPet,
        successMessage = "You have chosen Stone Dracadet [3] as your Familiar.",
    },
    [14] = {
        selectedStorage = Expeditions.FireDracadetPetChoice,
        unlockStorage = Expeditions.FireDracadetPet3,
        successMessage = "You have chosen Fire Dracadet [3] as your Familiar.",
    },
    [15] = {
        selectedStorage = Expeditions.FireDracadetPetChoice2,
        unlockStorage = Expeditions.FireDracadetPet2,
        successMessage = "You have chosen Fire Dracadet [3] as your Familiar.",
    },
    [16] = {
        selectedStorage = Expeditions.FireDracadetPetChoice3,
        unlockStorage = Expeditions.FireDracadetPet,
        successMessage = "You have chosen Fire Dracadet [3] as your Familiar.",
    },
}

local function resetFamiliarChoices(player)
    for i = 1, #allChoiceStorages do
        player:setStorageValue(allChoiceStorages[i], 0)
    end
end

local function canUseChoice(player, choice)
    return not choice.unlockStorage or player:getStorageValue(choice.unlockStorage) == 1
end

function onModalWindow(player, modalWindowId, buttonId, choiceId)
    player:unregisterEvent("choiceFamiliar")

    if modalWindowId ~= modalId then
        return
    end

    if buttonId ~= confirmButtonId then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "You cancelled the selection.")
        return
    end

    local choice = familiarChoices[choiceId]
    if not choice then
        return
    end

    if not canUseChoice(player, choice) then
        player:sendTextMessage(MESSAGE_INFO_DESCR, unlockErrorMessage)
        return
    end

    resetFamiliarChoices(player)
    player:setStorageValue(choice.selectedStorage, 1)
    player:sendTextMessage(MESSAGE_INFO_DESCR, choice.successMessage)
end
