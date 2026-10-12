local FIRST_LOGIN_MARKS_STORAGE = 153077

local mapMarks = {
  { pos = Position(32347, 31116, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32461, 31264, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32590, 31035, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32417, 31490, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32127, 31668, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32017, 31710, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32044, 31597, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32098, 31935, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32194, 31950, 7), icon = 25, text = "Boat Area" },
  { pos = Position(31915, 32029, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32115, 32233, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32157, 32545, 7), icon = 25, text = "Boat Area" },
  { pos = Position(31976, 32884, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32230, 33022, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32321, 32871, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33084, 32881, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33340, 32536, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33281, 32473, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33485, 32552, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33382, 32220, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33484, 31978, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33490, 31700, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33646, 31474, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33705, 31194, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33458, 31820, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33212, 32118, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33140, 32313, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32935, 32488, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32816, 32486, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32535, 32793, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32320, 32870, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32327, 32623, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32438, 32550, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32491, 32389, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32318, 32217, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32941, 32027, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33045, 31922, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33169, 31775, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33022, 31376, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32794, 31272, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32995, 30978, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32814, 30927, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32590, 31035, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32863, 31429, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32857, 31552, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32859, 31865, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32717, 31672, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32489, 31592, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32389, 31813, 7), icon = 25, text = "Boat Area" },
  { pos = Position(32247, 31533, 7), icon = 25, text = "Boat Area" },
  { pos = Position(33440, 31423, 7), icon = 25, text = "Boat Area" },
}

local loginMarks = CreatureEvent("LoginBoatMapMarks")

function loginMarks.onLogin(player)
  if player:getStorageValue(FIRST_LOGIN_MARKS_STORAGE) == 1 then
    return true
  end

  player:setStorageValue(FIRST_LOGIN_MARKS_STORAGE, 1)

  for _, mark in ipairs(mapMarks) do
    player:addMapMark(mark.pos, mark.icon or 25, mark.text or "Boat Area")
  end

  return true
end

loginMarks:register()