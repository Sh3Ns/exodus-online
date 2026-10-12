local restrictedBadges        = {
    27803,27804,27805,27806,27807,27808,27809,27810,27811,27812,27813,
    27814,27815,27816,27817,27818,27819,27820,27821,27822,27823,27824,
    27825,27826,27827,27828,27829,27830,27831,27832,27833,27834,27835,
    27836,27837,27838,27839,27840,27841,27842
  }
  local storageKeyBadgeEquipped = 249578
  
  local restrictedBelts = {29578,29591,29592,29593,29594,29595,29596,29597,29598,29914,29915,29916}
  local storageKeyBeltEquipped = 249574
  
  local restrictedGloves = {29577,29582,29583,29584,29586,29587,29588,29589,29590,29917,29918,29919}
  local storageKeyGloveEquipped = 249572
  
  local function inList(id, list)
      for _, v in ipairs(list) do
        if v == id then return true end
      end
      return false
    end

function onEquip(player, item, slot, isCheck)
    local id = item:getId()
    
      if inList(id, restrictedBadges) then
        if isCheck then
          if player:getStorageValue(storageKeyBadgeEquipped) > 0 then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "You can only equip one badge at a time.")
            return false
          end
          return true
        end
        player:setStorageValue(storageKeyBadgeEquipped, id)
        return true
      elseif inList(id, restrictedBelts) then
        if isCheck then
          if player:getStorageValue(storageKeyBeltEquipped) > 0 then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "You can only equip one belt at a time.")
            return false
          end
          return true
        end
        player:setStorageValue(storageKeyBeltEquipped, id)
        return true
      elseif inList(id, restrictedGloves) then
        if isCheck then
          if player:getStorageValue(storageKeyGloveEquipped) > 0 then
            player:sendTextMessage(MESSAGE_INFO_DESCR, "You can only equip one glove at a time.")
            return false
          end
          return true
        end
        player:setStorageValue(storageKeyGloveEquipped, id)
        return true
      else

    player:addSpecialSkill(SPECIALSKILL_LIFELEECHCHANCE, 0)
    player:addSpecialSkill(SPECIALSKILL_LIFELEECHAMOUNT, 0)
    player:addSpecialSkill(SPECIALSKILL_MANALEECHCHANCE, 0)
    player:addSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT, 0)
    return true
    end
end

function onDeEquip(player, item, slot, isCheck)
    local id = item:getId()
    
      if inList(id, restrictedBadges) then
        if isCheck then return true end
        if player:getStorageValue(storageKeyBadgeEquipped) == id then
          player:setStorageValue(storageKeyBadgeEquipped, -1)
        end
        return true
      elseif inList(id, restrictedBelts) then
        if isCheck then return true end
        if player:getStorageValue(storageKeyBeltEquipped) == id then
          player:setStorageValue(storageKeyBeltEquipped, -1)
        end
        return true
      elseif inList(id, restrictedGloves) then
        if isCheck then return true end
        if player:getStorageValue(storageKeyGloveEquipped) == id then
          player:setStorageValue(storageKeyGloveEquipped, -1)
        end
        return true
      else
    player:addSpecialSkill(SPECIALSKILL_LIFELEECHCHANCE, -0)
    player:addSpecialSkill(SPECIALSKILL_LIFELEECHAMOUNT, -0)
    player:addSpecialSkill(SPECIALSKILL_MANALEECHCHANCE, -0)
    player:addSpecialSkill(SPECIALSKILL_MANALEECHAMOUNT, -0)
return true
      end
end


--- How To Register: 
--- On movements.xml add script="special_skills/name of file you created with custom value",  onEquip, and also add the script on deEquip.
--- Reset Server and voila. 