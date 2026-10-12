local WHEEL_SLOT_COUNT = 36
local WHEEL_MAX_POINTS = 4000
local WHEEL_SIDES = { "topLeft", "topRight", "bottomLeft", "bottomRight" }
local WHEEL_ROOTS = { 15, 16, 21, 22 }

local function getIndexedValue(values, index, default)
    if type(values) ~= "table" then
        return default
    end
    local value = values[index]
    if value == nil then
        value = values[tostring(index)]
    end
    return value == nil and default or value
end

local function getSlotDefinition(id)
    return WheelDestiny.Slots and WheelDestiny.Slots[id] or nil
end

local function getSlotWidget(id)
    if not WheelDestiny.UI or not WheelDestiny.UI.main or not WheelDestiny.UI.main.wheel then
        return nil
    end
    return WheelDestiny.UI.main.wheel.base.front:getChildById(id)
end

local function getWheelSlotAt(point)
    if not WheelDestiny.UI or not WheelDestiny.UI.main or not WheelDestiny.UI.main.wheel or not point then
        return nil
    end

    local front = WheelDestiny.UI.main.wheel.base and WheelDestiny.UI.main.wheel.base.front
    if not front or type(front.recursiveGetChildByPos) ~= "function" then
        return nil
    end

    local widget = front:recursiveGetChildByPos(point, false)
    while widget and widget:getParent() ~= front do
        widget = widget:getParent()
    end

    if widget and getSlotDefinition(tonumber(widget:getId())) then
        return widget
    end
    return nil
end

local function widgetContainsPoint(widget, point)
    if not widget or not point then
        return false
    end
    if type(widget.isValidArea) == "function" then
        local ok, valid = pcall(function()
            return widget:isValidArea(point)
        end)
        if ok then
            return valid and true or false
        end
    end
    if type(widget.containsPoint) == "function" then
        return widget:containsPoint(point)
    end
    return false
end

local function setAlignedTooltip(widget, text, align)
    if not widget then
        return
    end

    if align and type(widget.setTooltipAlign) == "function" then
        local ok, err = pcall(function()
            widget:setTooltipAlign(align)
        end)
        if not ok and g_logger then
            g_logger.warning("[WheelDestiny] Tooltip alignment is unavailable: " .. tostring(err))
        end
    end

    if type(widget.setTooltip) == "function" then
        widget:setTooltip(text)
    end
end

local function formatSignedNumber(value, percent)
    value = tonumber(value) or 0
    if percent then
        if value == math.floor(value) then
            return string.format("%+d%%", value)
        end
        return string.format("%+.2f%%", value)
    end
    return string.format("%+d", value)
end

local function getConvictionTooltip(text, value, priority)
    text = tostring(text or "")

    if priority == 3 then
        return string.format("%s\n%s %s from completed Conviction Perks.\nRepeated perks stack.",
            text, formatSignedNumber(value, true), text)
    end

    if type(value) == "number" and WheelDestiny.Slots and WheelDestiny.Slots[value] then
        local slotPerk = WheelDestiny.Slots[value].perk and WheelDestiny.Slots[value].perk[WheelDestiny.vocation]
        local stages = {}
        for _, conviction in ipairs(slotPerk and slotPerk.convictions or {}) do
            local convictionText = tostring(conviction.text or "")
            if convictionText == text or (convictionText:sub(1, #text) == text and convictionText:sub(#text + 1, #text + 1) == "\n") then
                if convictionText:find("\n") then
                    table.insert(stages, convictionText)
                else
                    table.insert(stages, convictionText)
                end
            elseif tonumber(conviction.augmentation) then
                table.insert(stages, string.format("Stage %d: %s", tonumber(conviction.augmentation), convictionText))
            end
        end

        if #stages > 0 then
            local tooltip = table.concat(stages, "\n")
            if #stages > 1 then
                tooltip = tooltip .. "\n\n" .. WheelDestiny.MediumPerkInfos.AugGeneralInfo
            else
                tooltip = tooltip .. "\n\n" .. WheelDestiny.MediumPerkInfos.GeneralInfo
            end
            return tooltip
        end
    end

    if text:find("Vessel Resonance") then
        return text .. "\nUnlocks and improves this domain's vessel resonance. Higher vessel resonance allows stronger socketed gem effects."
    end

    if type(value) == "number" then
        return string.format("%s\nCurrent bonus: %s\nRepeated perks stack.",
            text, formatSignedNumber(value, text:find("Leech") ~= nil))
    end

    return text .. "\n\n" .. WheelDestiny.MediumPerkInfos.GeneralInfo
end

local function prepareWheelWindowInput()
    if not WheelDestiny.UI then
        return
    end

    if type(WheelDestiny.UI.setPhantom) == "function" then
        WheelDestiny.UI:setPhantom(false)
    end
    if type(WheelDestiny.UI.setDraggable) == "function" then
        WheelDestiny.UI:setDraggable(true)
    end

    local main = WheelDestiny.UI.main
    if main and type(main.setPhantom) == "function" then
        main:setPhantom(true)
    end

    local categories = { "wheel", "gem", "fragment" }
    for _, category in ipairs(categories) do
        local panel = main and main[category]
        if panel and type(panel.setPhantom) == "function" then
            panel:setPhantom(true)
        end
    end
end

local function setProgressImage(widget, basePath, value)
    if not widget then
        return
    end

    value = math.max(0, math.floor(tonumber(value) or 0))
    local candidate = string.format("%s/%d", basePath, value)
    if g_resources and g_resources.fileExists and not g_resources.fileExists(candidate .. ".png") then
        local fallback = value
        repeat
            fallback = fallback - 1
            candidate = string.format("%s/%d", basePath, math.max(0, fallback))
        until fallback <= 0 or g_resources.fileExists(candidate .. ".png")
    end
    widget:setImageSource(candidate)
end

local function currentAllocation()
    local values = {}
    for id = 1, #(WheelDestiny.Slots or {}) do
        local widget = getSlotWidget(id)
        values[id] = widget and (tonumber(widget.value) or 0) or 0
    end
    return values
end

local function getReachableSlots(values)
    local reached = {}
    local queue = {}
    for _, rootId in ipairs(WHEEL_ROOTS) do
        if getSlotDefinition(rootId) then
            reached[rootId] = true
            table.insert(queue, rootId)
        end
    end

    local queueIndex = 1
    while queueIndex <= #queue do
        local id = queue[queueIndex]
        queueIndex = queueIndex + 1
        local slot = getSlotDefinition(id)
        local value = tonumber(getIndexedValue(values, id, 0)) or 0
        if slot and value >= (tonumber(slot.max) or 0) then
            for _, adjacentId in ipairs(slot.adjacent or {}) do
                adjacentId = tonumber(adjacentId)
                if adjacentId and getSlotDefinition(adjacentId) and not reached[adjacentId] then
                    reached[adjacentId] = true
                    table.insert(queue, adjacentId)
                end
            end
        end
    end
    return reached
end

local function allocationIsReachable(values, pointLimit)
    if type(WheelDestiny.Slots) ~= "table" then
        return false, "Wheel configuration is unavailable."
    end

    local total = 0
    for id, slot in ipairs(WheelDestiny.Slots) do
        local value = math.floor(tonumber(getIndexedValue(values, id, 0)) or 0)
        local minimum = tonumber(slot.min) or 0
        local maximum = tonumber(slot.max) or 0
        if value < minimum or value > maximum then
            return false, string.format("Slot %d is outside its allowed range.", id)
        end
        total = total + value

    end

    if pointLimit and total > pointLimit then
        return false, "The allocation uses more promotion points than are available."
    end

    local reached = getReachableSlots(values)
    for id = 1, #WheelDestiny.Slots do
        if (tonumber(getIndexedValue(values, id, 0)) or 0) > 0 and not reached[id] then
            return false, string.format("Slot %d is disconnected from the center of the wheel.", id)
        end
    end
    return true, nil, total
end

function wheelDestinyUnlocked(id, values)
    local slot = getSlotDefinition(id)
    if not slot then
        return false
    end
    local predecessors = slot.brothers or slot.predecessors or {}
    if #predecessors == 0 then
        return true
    end

    for _, brother in ipairs(predecessors) do
        brother = tonumber(brother)
        local brotherDefinition = brother and getSlotDefinition(brother)
        local brotherValue
        if values then
            brotherValue = tonumber(getIndexedValue(values, brother, 0)) or 0
        else
            local brotherWidget = brother and getSlotWidget(brother)
            brotherValue = brotherWidget and (tonumber(brotherWidget.value) or 0) or 0
        end
        if brotherDefinition and brotherValue >= (tonumber(brotherDefinition.max) or 0) then
            return true
        end
    end
    return false
end

function wheelDestinyGetSideIdByName(id)
    local sides = {
        ["topLeft"] = 0,
        ["topRight"] = 1,
        ["bottomLeft"] = 2,
        ["bottomRight"] = 3,
    }

    if sides[id] == nil then
        return nil
    end

    return sides[id]
end

function wheelDestinyGetGemGrade(grade)
    local grades = {
        [0] = "I",
        [1] = "II",
        [2] = "III",
        [3] = "IV"
    }

    return grades[grade]
end

function wheelDestinyGetVesselLevel(affinity)
    local levels = {
        [0] = "Sealed",
        [1] = "Dormant",
        [2] = "Awakened",
        [3] = "Radiant"
    }

    local count = 0
    for slot, data in pairs(WheelDestiny.GemSlots or {}) do
        if affinity == data.affinity then
            local slotDefinition = getSlotDefinition(slot)
            local slotWidget = getSlotWidget(slot)
            local max = slotDefinition and (tonumber(slotDefinition.max) or 0) or 0
            local value = slotWidget and (tonumber(slotWidget.value) or 0) or 0

            if value >= max then
                count = count + 1
            end
        end
    end

    count = math.min(count, 3)
    return count, levels[count] or levels[0]
end

function wheelDestinyGetSideBySlot(id)
    for side, data in pairs(WheelDestiny.Sides or {}) do
        for _, child in pairs(data.child or {}) do
            if child == id then
                return side
            end
        end
    end

    return nil
end

function wheelDestinyGetSlotById(id)
    return getSlotWidget(id)
end

function wheelDestinySetSlotPoints(id, points)
    local slot = wheelDestinyGetSlotById(id)
    local side = wheelDestinyGetSideBySlot(id)

    if not slot then
        return false
    end

    slot.value = math.max(0, math.floor(tonumber(points) or 0))
    setProgressImage(slot.full, string.format("/modules/game_wheel/images/area/%s", id), slot.value)
    if side and WheelDestiny.sidePoints[side] then
        WheelDestiny.sidePoints[side].points = WheelDestiny.sidePoints[side].points + slot.value
    end
    return true
end

function wheelDestinyCheckCircle(list, index, click)
    local widget = list[index]
    if not widget then
        return false
    end

    if widget:getId() ~= "front" and widget:getId() ~= "vocation" then
        if widgetContainsPoint(widget.value, click) then
            wheelDestinySelectCircle(widget)
            return true
        end

        if widgetContainsPoint(widget.gem, click) then
            wheelDestinySelectGem(widget)
            return true
        end
    end

    if index + 1 > #list then
        return false
    end

    return wheelDestinyCheckCircle(list, index + 1, click)
end

function wheelDestinyIsChanged()
    for i, _ in ipairs(WheelDestiny.Slots or {}) do
        local slot = wheelDestinyGetSlotById(i)
        if slot and (tonumber(slot.value) or 0) ~= (tonumber(WheelDestiny.slots[i]) or 0) then
            return true
        end
    end

    for affinity = 0, 3 do
        local active = WheelDestiny.ActivedGem and WheelDestiny.ActivedGem[affinity]
        local activeIndex = active and tonumber(active:getId()) or -1
        local savedIndex = WheelDestiny.SavedActiveGemIndices and tonumber(WheelDestiny.SavedActiveGemIndices[affinity]) or -1
        if activeIndex ~= savedIndex then
            return true
        end
    end
    return false
end

function wheelDestinyCheck(list, index, click)
    local widget = list[index]
    if not widget then
        return wheelDestinyCheckCircle(WheelDestiny.UI.main.wheel.base:getChildren(), 1, click)
    end

    if widget:getId() ~= "base" then
        if widgetContainsPoint(widget.unlocked, click) then
            wheelDestinySelect(widget)
            return true
        end
    end

    if index + 1 > #list then
        return wheelDestinyCheckCircle(WheelDestiny.UI.main.wheel.base:getChildren(), 1, click)
    end
    
    return wheelDestinyCheck(list, index + 1, click)
end


function wheelDestinyOnParseWheelOfDestiny(data, slots, deferRefresh)
    if not WheelDestiny.UI or type(WheelDestiny.Slots) ~= "table" then
        g_logger.error("[WheelDestiny] Cannot parse wheel state without UI and slot configuration.")
        return false
    end

    data = type(data) == "table" and data or {}
    slots = type(slots) == "table" and slots or {}

    local backdrops = {
        [1] = "/modules/game_wheel/images/backdrop_knight",
        [2] = "/modules/game_wheel/images/backdrop_paladin",
        [3] = "/modules/game_wheel/images/backdrop_sorcerer",
        [4] = "/modules/game_wheel/images/backdrop_druid",
        [5] = "/modules/game_wheel/images/backdrop_monk"
    }

    WheelDestiny.state = tonumber(data.state) or 0
    WheelDestiny.vocation = tonumber(data.vocation) or 1
    WheelDestiny.totalPoints = math.min(WHEEL_MAX_POINTS, math.max(0, math.floor(tonumber(data.points) or 0)))

    for _, side in ipairs(WHEEL_SIDES) do
        WheelDestiny.sidePoints[side].points = 0
    end

    local normalizedSlots = {}
    local remaining = WheelDestiny.totalPoints
    for id, slotDefinition in ipairs(WheelDestiny.Slots) do
        local value = math.max(0, math.floor(tonumber(getIndexedValue(slots, id, 0)) or 0))
        value = math.min(value, tonumber(slotDefinition.max) or 0, remaining)
        normalizedSlots[id] = value
        remaining = remaining - value
    end

    local valid, reason = allocationIsReachable(normalizedSlots, WheelDestiny.totalPoints)
    if not valid then
        g_logger.error("[WheelDestiny] Server sent an unreachable allocation: " .. tostring(reason))
        local reached = getReachableSlots(normalizedSlots)
        for id, value in ipairs(normalizedSlots) do
            if value > 0 and not reached[id] then
                normalizedSlots[id] = 0
            end
        end
    end

    WheelDestiny.usedPoints = 0
    for id = 1, #WheelDestiny.Slots do
        local value = normalizedSlots[id] or 0
        wheelDestinySetSlotPoints(id, value)
        WheelDestiny.usedPoints = WheelDestiny.usedPoints + value
    end
    WheelDestiny.availablePoints = math.max(0, WheelDestiny.totalPoints - WheelDestiny.usedPoints)
    WheelDestiny.slots = normalizedSlots

    WheelDestiny.UI.main.resetButton:setEnabled(WheelDestiny.state == 1 and not WheelDestiny.PendingRequest)

    WheelDestiny.UI.main.applyButton:setEnabled(false)
    WheelDestiny.UI.main.okButton:setEnabled(false)

    wheelDestinyChangeOption(WheelDestiny.UI.main.wheel.test.buttons.information, true)

    if backdrops[WheelDestiny.vocation] then
        WheelDestiny.UI.main.wheel.base.vocation:setImageSource(backdrops[WheelDestiny.vocation])
    end

    WheelDestiny.selected = nil
    WheelDestiny.selectedHover = nil
    wheelDestinyResetSelected()
    wheelDestinyResetCircleSelected()

    if not deferRefresh then
        wheelDestinyUpdate()
        wheelDestinyUpdateWheelGem()
        wheelDestinyUpdateCurrentPreset()
    end
    return true
end

function wheelDestinySend(hide)
    if WheelDestiny.PendingRequest or WheelDestiny.state == 0 or WheelDestiny.preview then
        return false
    end

    local slots = currentAllocation()
    local valid, reason = allocationIsReachable(slots, WheelDestiny.totalPoints)
    if not valid then
        displayErrorBox(tr("Wheel of Destiny"), tr(reason or "The selected allocation is invalid."))
        return false
    end

    if WheelDestiny.state ~= 1 then
        for id = 1, #WheelDestiny.Slots do
            if (tonumber(slots[id]) or 0) < (tonumber(WheelDestiny.slots[id]) or 0) then
                displayErrorBox(tr("Wheel of Destiny"),
                    tr("Outside a temple you can only spend unused promotion points."))
                return false
            end
        end
        for affinity = 0, 3 do
            local active = WheelDestiny.ActivedGem and WheelDestiny.ActivedGem[affinity]
            local activeIndex = active and tonumber(active:getId()) or -1
            local savedIndex = WheelDestiny.SavedActiveGemIndices and
                tonumber(WheelDestiny.SavedActiveGemIndices[affinity]) or -1
            if activeIndex ~= savedIndex then
                displayErrorBox(tr("Wheel of Destiny"),
                    tr("Vessel changes can only be applied inside a temple."))
                return false
            end
        end
    end

    local gems = {}
    for affinity = 0, 3 do
        local gem = WheelDestiny.ActivedGem[affinity]
        table.insert(gems, {
            affinity = affinity,
            index = gem and (tonumber(gem:getId()) or -1) or -1
        })
    end

    local currentPreset = WheelDestiny.CurrentPreset or WheelDestiny.currentPreset
    local selectedPreset = WheelDestiny.SelectedPreset
    local presetBox = WheelDestiny.UI and WheelDestiny.UI.main and WheelDestiny.UI.main.wheel and
        WheelDestiny.UI.main.wheel.test and WheelDestiny.UI.main.wheel.test.presetBox
    local presetSaveTarget = currentPreset
    if presetBox and presetBox:isVisible() and selectedPreset then
        presetSaveTarget = selectedPreset
    end

    local sent = WheelDestiny.requestSave(slots, gems, hide)
    if sent and presetSaveTarget then
        WheelDestiny.PendingPresetSaveName = presetSaveTarget.presetName
        WheelDestiny.CurrentPresetName = presetSaveTarget.presetName
    end
    return sent
end

function wheelDestinyUpdateImages()
    local function showHover(target, overlay)
        WheelDestiny.disable()
        if overlay then overlay:setVisible(true) end
        WheelDestiny.hoverVerify = true
        WheelDestiny.hoverWidget = target

        local infoRoot = WheelDestiny.UI.main.wheel.test
        if not infoRoot.presetBox:isVisible() then
            infoRoot.informationBox:setVisible(true)
            infoRoot.defaultBox:setVisible(false)
        end
        wheelDestinyUpdateHoverInformation()
    end

    local function clearHover(target)
        if WheelDestiny.hoverWidget ~= target then
            return
        end
        WheelDestiny.disable()
        WheelDestiny.hoverVerify = false
        WheelDestiny.hoverWidget = nil
        WheelDestiny.selectedHover = nil
        local infoRoot = WheelDestiny.UI.main.wheel.test
        infoRoot.informationBox:setVisible(false)
        if not infoRoot.presetBox:isVisible() then
            infoRoot.defaultBox:setVisible(true)
        end
    end

    for _, widget in ipairs(WheelDestiny.UI.main.wheel.base.front:getChildren()) do
        if widget:getId() ~= "base" then
            if not widget.value then
                widget.value = 0
            end

            local unlock = widget.unlocked
            local id = tonumber(widget:getId())

            if id and type(widget.setImageSource) == "function" then
                widget:setImageSource(string.format("/modules/game_wheel/images/area/%d_full", id))
                widget.wheelPixelMask = true
            end
            if type(widget.setImageColor) == "function" then
                widget:setImageColor("alpha")
            end
            if type(widget.setPixelTesting) == "function" then
                widget:setPixelTesting(true)
            end

            widget.onMouseMove = function(self, mousePos)
                if getWheelSlotAt(mousePos) == widget or (not self.wheelPixelMask and widgetContainsPoint(unlock, mousePos)) then
                    showHover(widget, widget.hover)
                end
            end
            widget.onHoverChange = function(self, hovered)
                if not hovered then clearHover(widget) end
            end

            widget.onClick = function(self, pos)
                local parent = self:getParent()
                local clickedSlot = getWheelSlotAt(pos)

                if clickedSlot then
                    wheelDestinySelect(clickedSlot)
                elseif not self.wheelPixelMask and widgetContainsPoint(unlock, pos) then
                    wheelDestinySelect(self)
                else
                    wheelDestinyCheck(parent:getChildren(), 1, pos)
                end
            end

            widget.onMouseRelease = function(self, pos, mouseButton)
                local parent = self:getParent()

                if mouseButton == MouseRightButton then
                    local clickedSlot = getWheelSlotAt(pos)
                    if clickedSlot then
                        wheelDestinySelect(clickedSlot)
                    elseif not self.wheelPixelMask and widgetContainsPoint(unlock, pos) then
                        wheelDestinySelect(self)
                    else
                        wheelDestinyCheck(parent:getChildren(), 1, pos)
                    end

                    local selected = WheelDestiny.selected
                    local selectedId = selected and tonumber(selected:getId())
                    if selectedId and wheelDestinyUnlocked(selectedId) then
                        if WheelDestiny.selected.value > 0 then
                            wheelDestinyDecrementButton(true)
                        else
                            wheelDestinyIncrementButton(true)
                        end

                        if WheelDestiny.GemSlots and WheelDestiny.GemSlots[selectedId] then
                            wheelDestinyUpdateSockets()
                            wheelDestinyUpdateWheelGem()
                        end
                    end
                end
            end

            local slot = WheelDestiny.Slots[id]
            if slot and slot.perk and not table.empty(slot.perk) then
                local vocationPerk = slot.perk[WheelDestiny.vocation]
                if vocationPerk and vocationPerk.mediumClip and vocationPerk.smallClip then
                    local mediumClip = 30 * vocationPerk.mediumClip
                    local smallClip = 16 * vocationPerk.smallClip

                    local affinity
                    local data = WheelDestiny.GemSlots and WheelDestiny.GemSlots[tonumber(widget:getId())]
                    if data then
                        affinity = data.affinity
                    end

                    if widget and widget.mediumPerk and widget.mediumPerk.smallPerk then
                        if not WheelDestiny.ActivedGem[affinity] then
                            widget.mediumPerk:setImageClip(torect(string.format("%d 0 30 30", mediumClip)))
                            widget.mediumPerk.smallPerk:setImageClip(torect(string.format("%d 0 16 16", smallClip)))
                        end
                    end
                end
            end
        end
    end

    for side, data in pairs(WheelDestiny.Sides or {}) do
        local widget = WheelDestiny.UI.main.wheel.base and WheelDestiny.UI.main.wheel.base[side]

        if widget and data and data.perks and WheelDestiny.vocation and data.perks[WheelDestiny.vocation] then
            widget:setPhantom(false)
            for _, child in ipairs(widget:getChildren()) do
                child:setPhantom(true)
                child:setFocusable(false)
            end
            local perkData = data.perks[WheelDestiny.vocation]
            local largeClip = perkData.largeClip and (34 * perkData.largeClip) or 0

            if widget.perk then
                widget.perk:setImageClip(torect(string.format("%d 0 34 34", largeClip)))
            end

            widget.onMouseMove = function(self, mousePos)
                if widgetContainsPoint(widget.value, mousePos) then
                    showHover(widget, widget.hover)
                    return
                end

                if widgetContainsPoint(widget.gem, mousePos) then
                    showHover(widget.gem, widget.socketHover)
                end
            end

            widget.onHoverChange = function(self, hovered)
                if not hovered then
                    clearHover(widget)
                    if widget.gem then clearHover(widget.gem) end
                end
            end

            widget.onClick = function(self, pos)
                if widgetContainsPoint(self.gem, pos) then
                    wheelDestinySelectGem(self)
                elseif widgetContainsPoint(self.value, pos) then
                    wheelDestinySelectCircle(self)
                end
            end
        end
    end

end

function wheelDestinyUpdate()
    if not WheelDestiny.UI or type(WheelDestiny.Slots) ~= "table" or type(WheelDestiny.Sides) ~= "table" then
        return
    end

    if WheelDestiny.preview then
        WheelDestiny.UI:setText('Wheel of Destiny - Preview')
        WheelDestiny.UI.main.applyButton:setVisible(false)
        WheelDestiny.UI.main.okButton:setVisible(false)
        WheelDestiny.UI.main.resetButton:setVisible(false)
    else
        WheelDestiny.UI:setText('Wheel of Destiny')
        WheelDestiny.UI.main.applyButton:setVisible(true)
        WheelDestiny.UI.main.okButton:setVisible(true)
        WheelDestiny.UI.main.resetButton:setVisible(true)
    end

    wheelDestinyVerifyButtons()
    wheelDestinyVerifySlots()
    wheelDestinyUpdateProgress()
    wheelDestinyUpdateDedications()
    wheelDestinyUpdateConvictions()
    wheelDestinyUpdateRevelations()
    wheelDestinyVerifyPerks()
    wheelDestinyUpdatePerks()
    wheelDestinyUpdateImages()
    wheelDestinyUpdateSockets()
end

function wheelDestinyReset()
    if WheelDestiny.state ~= 1 or WheelDestiny.PendingRequest then
        return
    end

    for _, widget in ipairs(WheelDestiny.UI.main.wheel.base.front:getChildren()) do
        if widget:getId() ~= "base" then
            widget.value = 0
            setProgressImage(widget.full, string.format("/modules/game_wheel/images/area/%s", widget:getId()), 0)
        end
    end

    WheelDestiny.usedPoints = 0
    WheelDestiny.availablePoints = WheelDestiny.totalPoints
    wheelDestinyResetCircles()
    wheelDestinyUpdate()
    WheelDestiny.UI.main.applyButton:setEnabled(wheelDestinyIsChanged())
    WheelDestiny.UI.main.okButton:setEnabled(wheelDestinyIsChanged())
end

function wheelDestinyUpdateRevelations()
    local UI = WheelDestiny.UI.main.wheel.revelation
    if not UI then return end

    local function getStage(side)
        local sideData = WheelDestiny.sidePoints[side]
        local usedPoints = sideData and sideData.points or 0
        if usedPoints >= 1000 then
            return 3
        elseif usedPoints < 250 then
            return 0
        elseif usedPoints < 500 then
            return 1
        else
            return 2
        end
    end

    local function format(side)
        local stage = getStage(side)
        return stage == 0 and "Locked" or string.format("Stage %d", stage)
    end

    local buff = {
        [0] = 0,
        [1] = 4,
        [2] = 9,
        [3] = 20
    }

    local damage = 0
    local healing = 0

    local function safeSet(index, side)
        local sideData = WheelDestiny.Sides[side]
        local perk = sideData and sideData.perks and sideData.perks[WheelDestiny.vocation]
        local text = perk and perk.revelation or "N/A"
        if UI[index] then UI[index]:setText(text) end
        if UI[index .. "_value"] then UI[index .. "_value"]:setText(format(side)) end
        local stage = getStage(side)
        if UI[index .. "_info"] then
            local tooltip = perk and perk.text or text
            tooltip = string.format("%s\n\nCurrent: %s\nCurrent Damage and Healing bonus: +%d%%",
                tooltip, format(side), buff[stage] or 0)
            setAlignedTooltip(UI[index .. "_info"], tooltip, AlignTopLeft)
        end
        damage = damage + buff[stage]
        healing = healing + buff[stage]
    end

    safeSet("1", "bottomRight")
    safeSet("2", "bottomLeft")
    safeSet("3", "topRight")
    safeSet("4", "topLeft")

    if UI["5_value"] then
        UI["5_value"]:setText(string.format("+%d", damage))
    end
    if UI["5_info"] then
        setAlignedTooltip(UI["5_info"], string.format(
            "Revelation Bonus\nTotal Damage and Healing bonus from unlocked Revelation stages: +%d%%\n\nStage values per domain:\nLocked: +0%%\nStage 1: +4%%\nStage 2: +9%%\nStage 3: +20%%",
            damage), AlignTopLeft)
    end
end

function wheelDestinyUpdateConvictions()
    local UI = WheelDestiny.UI.main.wheel.conviction
    if not UI or not UI.descriptions then
        print("Erro: UI ou UI.descriptions estão nil em updateConvictions")
        return
    end

    UI.descriptions:destroyChildren()
    local convictions = {}

    for id, data in ipairs(WheelDestiny.Slots) do
        local widget = wheelDestinyGetSlotById(id)

        if widget and widget.value and data and data.max and widget.value >= data.max then
            local vocationPerks = data.perk and data.perk[WheelDestiny.vocation]
            if vocationPerks and vocationPerks.convictions then
                for _, v in ipairs(vocationPerks.convictions) do
                    if v.priority then
                        convictions[v.priority] = convictions[v.priority] or {}

                        if v.quantity then
                            local text = v.text
                            if v.priority == 2 then
                                text = v.text:match("%a+$")
                            end
                            convictions[v.priority][text] = (convictions[v.priority][text] or 0) + v.quantity
                        else
                            convictions[v.priority][v.text] = id
                        end
                    end
                end
            end
        end
    end

    local first = true
    local resistances = true
    for i, descriptions in pairs(convictions) do
        for text, v in pairs(descriptions) do
            if i == 2 then
                if resistances then
                    local resistance = g_ui.createWidget("ConvictionLabel", UI.descriptions)
                    resistance.text:setText("Ressistances: ")
                    resistance.text:setMarginLeft(3)
                    resistance.text:setColor('#C0C0C0')
                    resistance:setMarginTop(5)
                    resistances = false
                end

                local label = g_ui.createWidget("ConvictionLabel", UI.descriptions)
                label:setMarginLeft(10)
                label:setMarginTop(2)
                label.text:setColor('#C0C0C0')
                local setText = text
                if setText:len() > 20 then
                    setText = text:sub(1, 17) .. "..."
                end
                label.text:setText(setText)
                label.text:setTextAutoResize(true)

                label.value:setColor('#C0C0C0')
                label.value:setMarginRight(15)
                label.value:setText(string.format("+%d%%", v))
            else
                local label = g_ui.createWidget("ConvictionLabel", UI.descriptions)

                local function format(str)
                    local augmentedPos = str:find("Augmented")
                    local newlinePos = str:find("\n")
                    if augmentedPos and (not newlinePos or augmentedPos < newlinePos) then
                        return str:gsub("Augmented", "Aug.")
                    elseif newlinePos then
                        return str:sub(1, newlinePos - 1)
                    else
                        return str
                    end
                end

                local setText = text
                if setText:len() > 20 then
                    setText = text:sub(1, 17) .. "..."
                end

                label.text:setText(format(setText))
                label.text:setTextAutoResize(true)
                label.text:setColor('#C0C0C0')

                if i == 1 then
                    label.infoIcon:setVisible(true)
                    setAlignedTooltip(label.infoIcon, getConvictionTooltip(text, v, i), AlignTopLeft)
                end

                if i == 1 or i == 3 then
                    label.value:setColor('#C0C0C0')
                    label.value:setMarginRight(20)
                    label.value:setMarginTop(-1)
                    if i == 3 then
                        label.value:setText(string.format("+%.2f%%", v))
                    elseif text and text:find("Skill") then
                        label.value:setText(string.format("+%d", v))
                    else
                        label.value:setText("I")
                    end
                end
            end
        end
    end
end

function wheelDestinyUpdateDedications()
    local UI = WheelDestiny.UI.main.wheel.dedication

    local attributes = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0
    }

    for id, data in ipairs(WheelDestiny.Slots) do
        local child = WheelDestiny.UI.main.wheel.base.front:getChildById(id)
        local value = child and child.value or 0

        if data.perk and data.perk[WheelDestiny.vocation] and data.perk[WheelDestiny.vocation].dedications then
            for _, v in ipairs(data.perk[WheelDestiny.vocation].dedications) do
                if attributes[v.text] ~= nil then
                    attributes[v.text] = attributes[v.text] + (v.quantity * value)
                end
            end
        end
    end

    for i, v in ipairs(attributes) do
        local sum = v > 0 and "+" or ""
        if i == 1 then
            UI.hitpoints:setText(string.format("%s%d", sum, v))
        elseif i == 2 then
            UI.mana:setText(string.format("%s%d", sum, v))
        elseif i == 3 then
            UI.capacity:setText(string.format("%s%d", sum, v))
        elseif i == 4 then
            UI.mitigation:setText(v > 0 and string.format("+%.2f%%", v) or "0%")
        end
    end

    setAlignedTooltip(UI.info, string.format(
        "Mitigation Multiplier\nIncreases your mitigation multiplicatively.\nCurrent bonus: %s\n\nThis value comes from completed mitigation dedication slices.",
        attributes[4] > 0 and string.format("+%.2f%%", attributes[4]) or "0%"), AlignTopLeft)
end


function wheelDestinyChangeOption(self, force)
    if self:isChecked() and not force then
        return
    end
    local identifier = {
        ["information"] = "presets",
        ["presets"] = "information"
    }
    local brother = self:getParent()[identifier[self:getId()]]
    if brother:isChecked() then
        brother:setChecked(false)
        if brother.larged then
            brother:setWidth(34)
            brother.larged = false
            brother.text:setVisible(false)
            brother:setIconOffsetX(3)
            brother:setIconOffsetY(0)
        end
    end
    self:setChecked(true)
    if not self.larged then
        self:setWidth(self.expandW)
        self.larged = true
        self:setIconOffsetX(5)
        self:setIconOffsetY(2)
        self.text:setVisible(true)
    end

    local isPresset = (self:getId() == "presets")
    WheelDestiny.UI.main.wheel.test.presetBox:setVisible(isPresset)
    WheelDestiny.UI.main.wheel.test.defaultBox:setVisible(not isPresset)
    WheelDestiny.UI.main.wheel.test.informationBox:setVisible(false)
end

local refreshPresetList

function wheelDestinyShowPresets()
    if not WheelDestiny.UI or not WheelDestiny.UI.main or not WheelDestiny.UI.main.wheel then
        return false
    end

    if WheelDestiny.changeHome and WheelDestiny.UI.buttons and WheelDestiny.UI.buttons.wheelButton then
        WheelDestiny.changeHome(WheelDestiny.UI.buttons.wheelButton, true)
    end

    local presetButton = WheelDestiny.UI.main.wheel.test and
        WheelDestiny.UI.main.wheel.test.buttons and
        WheelDestiny.UI.main.wheel.test.buttons.presets
    if presetButton then
        wheelDestinyChangeOption(presetButton, true)
    end

    if refreshPresetList then
        refreshPresetList(WheelDestiny.CurrentPreset or WheelDestiny.SelectedPreset)
    end
    return true
end

function wheelDestinyResetSelected()
    local slots = WheelDestiny.UI.main.wheel.base.selectors.front
    for i = 1, slots:getChildCount() do
        local child = slots:getChildByIndex(i)
        if child:getId() ~= "base" then
            child.selected:setVisible(false)
        end
    end
end

function wheelDestinyResetGemSelected()
    for side, data in pairs(WheelDestiny.Sides) do
        local widget = WheelDestiny.UI.main.wheel.base[side]
        widget.socketMark:setVisible(false)
    end
end

function wheelDestinyResetCircleSelected()
    for side, data in pairs(WheelDestiny.Sides) do
        local widget = WheelDestiny.UI.main.wheel.base[side]
        widget.selected:setVisible(false)
    end
end

function wheelDestinyVerifySlots()
    if not WheelDestiny.Slots then
        return
    end

    for _, widget in ipairs(WheelDestiny.UI.main.wheel.base.front:getChildren()) do
        if widget:getId() ~= "base" then
            local id = tonumber(widget:getId())
            local value = widget.value
            widget.unlocked:setVisible(wheelDestinyUnlocked(id))
        end
    end

    WheelDestiny.UI.main.wheel.selection.points:setText(string.format("%d / %d", WheelDestiny.availablePoints,
        WheelDestiny.totalPoints))
end

function wheelDestinyResetCircles()
    local sides = {
        ["topLeft"] = "TL",
        ["topRight"] = "TR",
        ["bottomLeft"] = "BL",
        ["bottomRight"] = "BR"
    }

    for side, prefix in pairs(sides) do
        WheelDestiny.sidePoints[side].points = 0
        WheelDestiny.UI.main.wheel.base[side].base:setImageSource(string.format(
            '/modules/game_wheel/images/backdrop_skillwheel_largebonus_front%d_%s', 0, prefix))
        setProgressImage(WheelDestiny.UI.main.wheel.base[side].value,
            string.format('/modules/game_wheel/images/area/circle/%s', side), 0)
    end
end

function wheelDestinyUpdatePerks()
    local sides = {"topLeft", "topRight", "bottomLeft", "bottomRight"}

    for _, side in pairs(sides) do
        local usedPoints = WheelDestiny.sidePoints[side].points

        local stage
        local positionInStage
        local backdrop = {
            ["topLeft"] = "TL",
            ["topRight"] = "TR",
            ["bottomLeft"] = "BL",
            ["bottomRight"] = "BR"
        }

        if usedPoints < 250 then
            stage = 0
            positionInStage = usedPoints % 250
        elseif usedPoints < 500 then
            stage = 1
            positionInStage = usedPoints % 250
        else
            stage = 2
            positionInStage = usedPoints % 500
        end

        if stage == 2 then
            positionInStage = math.floor(positionInStage / 2)
        end

        if usedPoints == 1000 then
            stage = 3
        end

        if stage == 3 then
            WheelDestiny.UI.main.wheel.base[side].value:setImageSource(string.format('/modules/game_wheel/images/area/circle/%s/max', side))
        else
            setProgressImage(WheelDestiny.UI.main.wheel.base[side].value,
                string.format('/modules/game_wheel/images/area/circle/%s', side), positionInStage)
        end

        WheelDestiny.UI.main.wheel.base[side].stage = stage
        WheelDestiny.UI.main.wheel.base[side].base:setImageSource(string.format(
            '/modules/game_wheel/images/backdrop_skillwheel_largebonus_front%d_%s', stage, backdrop[side]))
    end
end

function wheelDestinyVerifyPerks()
    local widget = WheelDestiny.selected
    if not widget then
        return
    end

    local side = wheelDestinyGetSideBySlot(tonumber(widget:getId()))
    local usedPoints = WheelDestiny.sidePoints[side].points
    local stage
    local positionInStage
    local backdrop = {
        ["topLeft"] = "TL",
        ["topRight"] = "TR",
        ["bottomLeft"] = "BL",
        ["bottomRight"] = "BR"
    }

    if usedPoints < 250 then
        stage = 0
        positionInStage = usedPoints % 250
    elseif usedPoints < 500 then
        stage = 1
        positionInStage = usedPoints % 250
    else
        stage = 2
        positionInStage = usedPoints % 500
    end

    if stage == 2 then
        positionInStage = math.floor(positionInStage / 2)
    end

    if usedPoints == 1000 then
        stage = 3
    end

    if stage == 3 then
        WheelDestiny.UI.main.wheel.base[side].value:setImageSource(string.format('/modules/game_wheel/images/area/circle/%s/max', side))
    else
        setProgressImage(WheelDestiny.UI.main.wheel.base[side].value,
            string.format('/modules/game_wheel/images/area/circle/%s', side), positionInStage)
    end

    WheelDestiny.UI.main.wheel.base[side].stage = stage
    WheelDestiny.UI.main.wheel.base[side].base:setImageSource(string.format(
        '/modules/game_wheel/images/backdrop_skillwheel_largebonus_front%d_%s', stage, backdrop[side]))
end

function wheelDestinyVerifyButtons()
    local ui = WheelDestiny.UI.main.wheel.selection.selected
    local id = WheelDestiny.selected and tonumber(WheelDestiny.selected:getId())
    local definition = id and WheelDestiny.Slots and WheelDestiny.Slots[id]
    if not definition then
        ui.maxButton:setEnabled(false)
        ui.oneButton:setEnabled(false)
        ui.maxNegativeButton:setEnabled(false)
        ui.negativeOnebutton:setEnabled(false)
        return
    end
    local value = tonumber(WheelDestiny.selected.value) or 0

    local max = tonumber(definition.max) or 0
    local min = tonumber(definition.min) or 0
    local canAddPoints = WheelDestiny.state ~= 0 and not WheelDestiny.preview and not WheelDestiny.PendingRequest
    local canRemovePoints = WheelDestiny.state == 1 and not WheelDestiny.preview and not WheelDestiny.PendingRequest

    local canAdd = canAddPoints and value < max and wheelDestinyUnlocked(id) and WheelDestiny.availablePoints > 0
    ui.maxButton:setEnabled(canAdd)
    ui.oneButton:setEnabled(canAdd)

    local candidate = currentAllocation()
    candidate[id] = math.max(min, value - 1)
    local canRemove = canRemovePoints and value > min and allocationIsReachable(candidate, WheelDestiny.totalPoints)
    ui.maxNegativeButton:setEnabled(canRemove)
    ui.negativeOnebutton:setEnabled(canRemove)
end

function wheelDestinyIncrementButton(full)
    if WheelDestiny.state == 0 or WheelDestiny.preview or WheelDestiny.PendingRequest then
        return false
    end

    local widget = WheelDestiny.selected
    local id = widget and tonumber(widget:getId())
    local definition = id and getSlotDefinition(id)
    local side = wheelDestinyGetSideBySlot(id)

    if not widget or not definition or not side or not wheelDestinyUnlocked(id) then
        return false
    end

    local remaining = (tonumber(definition.max) or 0) - (tonumber(widget.value) or 0)
    local pointsToAdd = full and math.min(WheelDestiny.availablePoints, remaining) or math.min(1, remaining)
    if pointsToAdd <= 0 then
        return false
    end

    local candidate = currentAllocation()
    candidate[id] = candidate[id] + pointsToAdd
    local valid = allocationIsReachable(candidate, WheelDestiny.totalPoints)
    if not valid then
        return false
    end

    widget.value = widget.value + pointsToAdd
    WheelDestiny.usedPoints = WheelDestiny.usedPoints + pointsToAdd
    WheelDestiny.sidePoints[side].points = WheelDestiny.sidePoints[side].points + pointsToAdd
    WheelDestiny.availablePoints = WheelDestiny.availablePoints - pointsToAdd

    if WheelDestiny.selectedHover and WheelDestiny.selectedHover:getId() == widget:getId() then
        wheelDestinyUpdateHoverInformation(true)
    end

    setProgressImage(widget.full, string.format("/modules/game_wheel/images/area/%s", id), widget.value)
    wheelDestinyUpdate()
    WheelDestiny.UI.main.applyButton:setEnabled(wheelDestinyIsChanged())
    WheelDestiny.UI.main.okButton:setEnabled(wheelDestinyIsChanged())
    return true
end

function wheelDestinyDecrementButton(full)
    if WheelDestiny.state ~= 1 or WheelDestiny.preview or WheelDestiny.PendingRequest then
        return false
    end

    local widget = WheelDestiny.selected
    local id = widget and tonumber(widget:getId())
    local definition = id and getSlotDefinition(id)
    local side = wheelDestinyGetSideBySlot(id)

    if not widget or not definition or not side then
        return false
    end

    local minimum = tonumber(definition.min) or 0
    local pointsToRemove = full and ((tonumber(widget.value) or 0) - minimum) or 1
    pointsToRemove = math.min(pointsToRemove, (tonumber(widget.value) or 0) - minimum)
    if pointsToRemove <= 0 then
        return false
    end

    local candidate = currentAllocation()
    candidate[id] = candidate[id] - pointsToRemove
    local valid = allocationIsReachable(candidate, WheelDestiny.totalPoints)
    if not valid then
        return false
    end

    widget.value = widget.value - pointsToRemove
    WheelDestiny.usedPoints = WheelDestiny.usedPoints - pointsToRemove
    WheelDestiny.sidePoints[side].points = WheelDestiny.sidePoints[side].points - pointsToRemove
    WheelDestiny.availablePoints = WheelDestiny.availablePoints + pointsToRemove

    if WheelDestiny.selectedHover and WheelDestiny.selectedHover:getId() == widget:getId() then
        wheelDestinyUpdateHoverInformation(true)
    end

    setProgressImage(widget.full, string.format("/modules/game_wheel/images/area/%s", id), widget.value)
    wheelDestinyUpdate()
    WheelDestiny.UI.main.applyButton:setEnabled(wheelDestinyIsChanged())
    WheelDestiny.UI.main.okButton:setEnabled(wheelDestinyIsChanged())
    return true
end

function wheelDestinySelect(widget)
    if not widget or not tonumber(widget:getId()) or not getSlotDefinition(tonumber(widget:getId())) then
        return false
    end
    local parent = widget:getParent()
    local id = widget:getId()
    local base = parent.base

    if not WheelDestiny.UI.main.wheel.selection.selected:isVisible() then
        WheelDestiny.UI.main.wheel.selection.selected:setVisible(true)
    end

    parent:moveChildToIndex(widget, parent:getChildCount())
    parent:moveChildToIndex(base, parent:getChildCount() - 1)

    wheelDestinyResetGemSelected()
    wheelDestinyResetSelected()
    wheelDestinyResetCircleSelected()
    
    widget.selected:setVisible(false)
    WheelDestiny.selected = widget

    local selectBase = WheelDestiny.UI.main.wheel.base.selectors.front:getChildById(id)
    if selectBase and selectBase.selected then
        selectBase.selected:setVisible(true)
    end

    wheelDestinyVerifyButtons()
    wheelDestinyUpdateProgress()
    return true
end

function wheelDestinySelectCircle(widget)
    if not widget or not WheelDestiny.Sides or not WheelDestiny.Sides[widget:getId()] then
        return false
    end
    if not WheelDestiny.UI.main.wheel.selection.selected:isVisible() then
        WheelDestiny.UI.main.wheel.selection.selected:setVisible(true)
    end

    wheelDestinyResetGemSelected()
    wheelDestinyResetCircleSelected()
    wheelDestinyResetSelected()
    widget.selected:setVisible(true)
    WheelDestiny.selected = widget

    wheelDestinyUpdateProgress(true)
    return true
end

function wheelDestinySelectGem(widget)
    if not widget or not wheelDestinyGetSideIdByName(widget:getId()) then
        return false
    end
    if not WheelDestiny.UI.main.wheel.selection.selected:isVisible() then
        WheelDestiny.UI.main.wheel.selection.selected:setVisible(true)
    end

    wheelDestinyResetGemSelected()
    wheelDestinyResetCircleSelected()
    wheelDestinyResetSelected()
    widget.socketMark:setVisible(true)
    WheelDestiny.selected = widget

    wheelDestinyUpdateProgress(false, true)
    return true
end

local function populateWheelGemDescriptions(container, gem, affinity)
    if not container or not gem or not gem.data then
        return
    end

    container:destroyChildren()
    local addSpacing = false
    for index = 1, tonumber(gem.data.size) or 0 do
        local attribute = Gem_Atelier.getGemAttribute(index)
        local clip = attribute and gem.data.object[attribute]
        local isSupreme = index == 3
        local grades = isSupreme and Fragment_Workshop.GreaterFragments or Fragment_Workshop.LesserFragments
        local catalog = isSupreme and Fragment_Workshop.Supreme_Modifiers or Fragment_Workshop.Basic_Modifiers
        local modifier = catalog and catalog[clip]
        local grade = grades and (tonumber(grades[clip]) or 0) or 0

        if modifier and type(modifier.descriptions) == "table" then
            for _, object in ipairs(modifier.descriptions) do
                local label = g_ui.createWidget("Label", container)
                local values = object.values or {}
                local value = values[grade]
                if value == nil then value = values[grade + 1] end
                label:setText(string.format("%s %s (%s)", tostring(value or ""),
                    tostring(object.text or ""), tostring(wheelDestinyGetGemGrade(grade) or "")))
                label:setEnabled(false)

                for _, active in pairs(WheelDestiny.ActivedGemSlots[affinity] or {}) do
                    if active and active.clip == clip and (active.modType == nil or active.modType == (isSupreme and 3 or 2)) then
                        label:setEnabled(true)
                        break
                    end
                end

                if addSpacing then
                    label:setMarginTop(5)
                    addSpacing = false
                end
            end
        end
        addSpacing = true
    end
end

local function addAugmentationIcon(label, conviction, nodeWidget, nodeDefinition)
    local augmentation = tonumber(conviction and conviction.augmentation)
    if not augmentation or (augmentation ~= 1 and augmentation ~= 2) then
        return false
    end

    local pairedId = tonumber(conviction.pairedSlot)
    local pairedWidget = pairedId and wheelDestinyGetSlotById(pairedId) or nil
    local pairedDefinition = pairedId and getSlotDefinition(pairedId) or nil
    local currentUnlocked = nodeWidget and (tonumber(nodeWidget.value) or 0) >= (tonumber(nodeDefinition.max) or 0)
    local pairedUnlocked = pairedWidget and pairedDefinition and
        (tonumber(pairedWidget.value) or 0) >= (tonumber(pairedDefinition.max) or 0)
    local active = currentUnlocked and (augmentation == 1 or pairedUnlocked)

    local icon = g_ui.createWidget("UIWidget", label)
    icon:setImageSource(string.format('/modules/game_wheel/images/icon-augmentation%d-%s',
        augmentation, active and 'active' or 'inactive'))
    icon:addAnchor(AnchorTop, "parent", AnchorTop)
    icon:addAnchor(AnchorLeft, "parent", AnchorLeft)
    icon:setMarginTop(2)

    if active then
        label:setColor('#C0C0C0')
    else
        label:setColor('#707070')
    end
    return true
end

function wheelDestinyUpdateHoverInformation(force)
    local widget = WheelDestiny.hoverWidget
    local circles = {"topLeft", "topRight", "bottomLeft", "bottomRight"}

    if not force then
        if not widget or widget == WheelDestiny.selectedHover then
            return
        end
    end

    local UI = WheelDestiny.UI.main.wheel.test.informationBox

    if not widget then
        return
    end

    if table.contains(circles, widget:getId()) then
        local stage = widget.stage and widget.stage or 0
        local points = WheelDestiny.sidePoints[widget:getId()].points

        UI.dedication:setVisible(false)
        UI.conviction:setVisible(false)
        UI.revelation:setVisible(true)
        UI.bottomText:setVisible(false)
        UI.gem:setVisible(false)
        UI.progress:setVisible(true)

        local limits = {
            [0] = 250,
            [1] = 500,
            [2] = 1000,
            [3] = 1000
        }

        local rect = {
            x = 0,
            y = 0,
            width = (((points > limits[stage]) and limits[stage] or points) / limits[stage]) * 190,
            height = 12
        }
        if points >= 0 and rect.width < 1 then
            UI.progress.fill:setVisible(false)
        else
            UI.progress.fill:setVisible(true)
        end

        UI.progress.fill:setImageRect(rect)
        UI.progress.fill:setImageClip(rect)

        if points >= 1000 then
            UI.progress.fill:setImageSource("/modules/game_wheel/images/fill-completed")
        else
            UI.progress.fill:setImageSource("/modules/game_wheel/images/fill")
        end

        UI.progress.value:setText(string.format("%d / %d", points, limits[stage]))

        if stage == 0 then
            UI.revelation.stage:setText("Locked")
            UI.revelation.text:setColor('#707070')
        else
            UI.revelation.stage:setText(string.format("Stage %d", stage))
            UI.revelation.text:setColor('#C0C0C0')
        end

        UI.revelation.text:setText(WheelDestiny.Sides[widget:getId()].perks[WheelDestiny.vocation].text)
    elseif widget:getId() == "gem" then
        UI.dedication:setVisible(false)
        UI.conviction:setVisible(false)
        UI.revelation:setVisible(false)
        UI.bottomText:setVisible(false)
        UI.progress:setVisible(false)
        UI.gem:setVisible(true)
        UI.gem.descriptions:destroyChildren()
        
        local affinity = wheelDestinyGetSideIdByName(widget:getParent():getId())
        local gem = WheelDestiny.ActivedGem[affinity]

        local level, stage = wheelDestinyGetVesselLevel(affinity)
        if level <= 0 then
            UI.gem.vessel:setText(string.format("%s Vessel (VR 0)", stage))
        else
            UI.gem.vessel:setText(string.format("%s Vessel (VR %s)", stage, wheelDestinyGetGemGrade(level -1)))
        end
        
        if level >= 3 then
            UI.gem.attribute:setEnabled(true)
        else
            UI.gem.attribute:setEnabled(false)
        end

        if not gem then
            UI.gem.name:setText("Vessel contains no gem")
            UI.gem.attribute:setVisible(false)
            return
        end

        populateWheelGemDescriptions(UI.gem.descriptions, gem, affinity)

        UI.gem.attribute:setVisible(true)
        UI.gem.name:setText(gem.data.details.name)
    else
        UI.dedication:setVisible(true)
        UI.conviction:setVisible(true)
        UI.bottomText:setVisible(true)
        UI.revelation:setVisible(false)
        UI.progress:setVisible(true)
        UI.gem:setVisible(false)

        local id = tonumber(widget:getId())
        local slot = WheelDestiny.Slots[id]
        local max = slot.max

        local rect = {
            x = 0,
            y = 0,
            width = (((widget.value > max) and max or widget.value) / max) * 190,
            height = 12
        }
        if widget.value >= 0 and rect.width < 1 then
            UI.progress.fill:setVisible(false)
        else
            UI.progress.fill:setVisible(true)
        end

        UI.progress.fill:setImageRect(rect)
        UI.progress.fill:setImageClip(rect)

        if widget.value >= max then
            UI.progress.fill:setImageSource("/modules/game_wheel/images/fill-completed")
        else
            UI.progress.fill:setImageSource("/modules/game_wheel/images/fill")
        end

        if UI.progress and UI.progress.value and widget and widget.value and max then
            UI.progress.value:setText(string.format("%d / %d", widget.value, max))
        end

        if UI.dedication and UI.dedication.descriptions then
            UI.dedication.descriptions:destroyChildren()
        end

        local slotPerk = slot and slot.perk and slot.perk[WheelDestiny.vocation]
        if not slotPerk or not slotPerk.dedications then
            return
        end

        

        for i, data in ipairs(slotPerk.dedications or {}) do
            local label = g_ui.createWidget("Label", UI.dedication.descriptions)
            label:setId(i)

            local percent = ""
            if data.percent then
                percent = "%"
            end

            local attributes = {
                [1] = "Hit Points",
                [2] = "Mana",
                [3] = "Capacity",
                [4] = "Mitigation Multiplier"
            }

            local formattedQuantity
            local text = attributes[data.text]
            if widget.value == 0 then
                formattedQuantity = string.format("+%d%s %s", data.quantity * widget.value, percent, text)
            elseif data.quantity == math.floor(data.quantity) then
                formattedQuantity = string.format("+%d%s %s", data.quantity * widget.value, percent, text)
            else
                formattedQuantity = string.format("+%.2f%s %s", data.quantity * widget.value, percent, text)
            end

            label:setText(formattedQuantity)

            if i == 1 then
                label:addAnchor(AnchorTop, "parent", AnchorTop)
                label:addAnchor(AnchorLeft, "parent", AnchorLeft)
                label:setMarginTop(3)
            else
                label:addAnchor(AnchorTop, "prev", AnchorBottom)
                label:addAnchor(AnchorLeft, "prev", AnchorLeft)
            end
            label:setTextAutoResize(true)

            if widget.value <= 0 then
                label:setColor('#707070')
            else
                label:setColor('#C0C0C0')
            end
        end
        UI.conviction.descriptions:destroyChildren()
        for i, data in ipairs(slotPerk.convictions or {}) do
            local label = g_ui.createWidget("ConvictionLabel", UI.conviction.descriptions)
            label:setId(i)
            label:setFont("pVerdana Bold-11px")

            local hasAugmentation = tonumber(data.augmentation)
            local percent = ""
            if data.percent then
                percent = "%"
            end

            local icon = ""
            if data.augmentation then
                icon = "   :"
            end

            if data.quantity then
                local formattedQuantity
                if math.floor(data.quantity) == data.quantity then
                    formattedQuantity = string.format("+%d%s %s", data.quantity, percent, data.text)
                else
                    formattedQuantity = string.format("+%.2f%s %s", data.quantity, percent, data.text)
                end
                if formattedQuantity:len() >= 165 then
                    formattedQuantity = formattedQuantity:sub(1, 160) .. "..."
                end
                label:setText(formattedQuantity)
            else
                local setText = string.format("%s%s", icon, data.text)
                if setText:len() >= 165 then
                    setText = setText:sub(1, 160) .. "..."
                end
                label:setText(setText)
            end

            if i > 1 then
                label:setColor('#707070')
                if hasAugmentation then
                    addAugmentationIcon(label, data, widget, slot)
                end
            end
            label:setTextAlign(AlignLeft)
            label:setTextWrap(true)
            label:setTextVerticalAutoResize(true)
            label:setMarginTop(1)

            if hasAugmentation then
            else
                if widget.value <= 0 then
                    label:setColor('#707070')
                else
                    label:setColor('#C0C0C0')
                end
            end
        end
    end

    WheelDestiny.selectedHover = widget
end

function wheelDestinyToggleSelectionButtons(show)
    local UI = WheelDestiny.UI.main.wheel.selection.selected

    UI.maxNegativeButton:setVisible(show)
    UI.negativeOnebutton:setVisible(show)
    UI.maxButton:setVisible(show)
    UI.oneButton:setVisible(show)
end

function wheelDestinyUpdateProgress(isCircle, isGem)
    local widget = WheelDestiny.selected
    if not widget then
        return
    end

    local UI = WheelDestiny.UI.main.wheel.selection.selected
    if isCircle then
        local stage = widget.stage and widget.stage or 0
        local points = WheelDestiny.sidePoints[widget:getId()].points

        UI.dedication:setVisible(false)
        UI.conviction:setVisible(false)
        UI.revelation:setVisible(true)
        UI.progress:setVisible(true)
        UI.gem:setVisible(false)
        wheelDestinyToggleSelectionButtons(false)

        local limits = {
            [0] = 250,
            [1] = 500,
            [2] = 1000,
            [3] = 1000
        }

        local rect = {
            x = 0,
            y = 0,
            width = (((points > limits[stage]) and limits[stage] or points) / limits[stage]) * 190,
            height = 14
        }
        if points >= 0 and rect.width < 1 then
            UI.progress.fill:setVisible(false)
        else
            UI.progress.fill:setVisible(true)
        end

        UI.progress.fill:setImageRect(rect)
        UI.progress.fill:setImageClip(rect)

        if points >= 1000 then
            UI.progress.fill:setImageSource("/modules/game_wheel/images/fill-completed")
        else
            UI.progress.fill:setImageSource("/modules/game_wheel/images/fill")
        end

        UI.progress.value:setText(string.format("%d / %d", points, limits[stage]))

        if stage == 0 then
            UI.revelation.stage:setText("Locked")
            UI.revelation.text:setColor('#707070')
        else
            UI.revelation.stage:setText(string.format("Stage %d", stage))
            UI.revelation.text:setColor('#C0C0C0')
        end

        UI.revelation.text:setText(WheelDestiny.Sides[widget:getId()].perks[WheelDestiny.vocation].text)
    elseif isGem then
        UI.dedication:setVisible(false)
        UI.conviction:setVisible(false)
        UI.revelation:setVisible(false)
        UI.progress:setVisible(false)
        wheelDestinyToggleSelectionButtons(false)
        UI.gem:setVisible(true)
        UI.gem.descriptions:destroyChildren()
        
        local affinity = wheelDestinyGetSideIdByName(widget:getId())
        local gem = WheelDestiny.ActivedGem[affinity]

        local level, stage = wheelDestinyGetVesselLevel(affinity)
        if level <= 0 then
            UI.gem.vessel:setText(string.format("%s Vessel (VR 0)", stage))
        else
            UI.gem.vessel:setText(string.format("%s Vessel (VR %s)", stage, wheelDestinyGetGemGrade(level -1)))
        end
        
        if level >= 3 then
            UI.gem.attribute:setEnabled(true)
        else
            UI.gem.attribute:setEnabled(false)
        end

        if not gem then
            UI.gem.name:setText("Vessel contains no gem")
            UI.gem.attribute:setVisible(false)
            return
        end

        populateWheelGemDescriptions(UI.gem.descriptions, gem, affinity)

        UI.gem.attribute:setVisible(true)
        UI.gem.name:setText(gem.data.details.name)
    else
        UI.dedication:setVisible(true)
        UI.conviction:setVisible(true)
        UI.revelation:setVisible(false)
        UI.progress:setVisible(true)
        UI.gem:setVisible(false)
        wheelDestinyToggleSelectionButtons(true)

        local id = tonumber(widget:getId())
        if not id then
            return
        end

        local slot = WheelDestiny.Slots[id]
        if not slot then
            return
        end

        local vocationPerk = slot.perk and slot.perk[WheelDestiny.vocation] or {}

        local max = slot.max or 1

        local value = widget.value or 0
        local rect = {
            x = 0,
            y = 0,
            width = ((value > max and max or value) / max) * 192,
            height = 12
        }

        if value >= 0 and rect.width < 1 then
            UI.progress.fill:setVisible(false)
        else
            UI.progress.fill:setVisible(true)
        end

        UI.progress.fill:setImageRect(rect)
        UI.progress.fill:setImageClip(rect)

        if value >= max then
            UI.progress.fill:setImageSource("/modules/game_wheel/images/fill-completed")
        else
            UI.progress.fill:setImageSource("/modules/game_wheel/images/fill")
        end


        UI.progress.value:setText(string.format("%d / %d", widget.value, max))

        local hasMit = false
        local tooltip = "Per promotion point:"

        UI.dedication.descriptions:destroyChildren()
        for i, data in ipairs(vocationPerk.dedications or {}) do
            local label = g_ui.createWidget("Label", UI.dedication.descriptions)
            label:setId(i)

            local percent = ""
            if data.percent then
                percent = "%"
            end

            local formattedQuantity
            local dedication = WheelDestiny.Dedications and WheelDestiny.Dedications[data.text]
            local text = dedication and dedication.text or tostring(data.text or "")

            if WDMit ~= nil and data.text == WDMit then
                hasMit = true
            end

            if widget.value == 0 then
                formattedQuantity = string.format("+%d%s %s", data.quantity * widget.value, percent, text)
            elseif data.quantity == math.floor(data.quantity) then
                formattedQuantity = string.format("+%d%s %s", data.quantity * widget.value, percent, text)
            else
                formattedQuantity = string.format("+%.2f%s %s", data.quantity * widget.value, percent, text)
            end
            tooltip = tooltip .. "\n+" .. (data.quantity or 1) .. " " .. text
            label:setText(formattedQuantity)

            if i == 1 then
                label:addAnchor(AnchorTop, "parent", AnchorTop)
                label:addAnchor(AnchorLeft, "parent", AnchorLeft)
                label:setMarginTop(3)
            else
                label:addAnchor(AnchorTop, "prev", AnchorBottom)
                label:addAnchor(AnchorLeft, "prev", AnchorLeft)
            end
            label:setTextAutoResize(true)

            if widget.value <= 0 then
                label:setColor('#707070')
            else
                label:setColor('#C0C0C0')
            end
        end

        if hasMit then
            tooltip = "Increases your mitigation multiplicatively\n\n" .. tooltip
        end

        setAlignedTooltip(UI.dedication.info, tooltip, AlignTopLeft)
        
        UI.conviction.descriptions:destroyChildren()

        local hasAug = false
        for i, data in ipairs(vocationPerk.convictions or {}) do
            local label = g_ui.createWidget("UIWidget", UI.conviction.descriptions)
            label:setId(i)
            label:setFont("pVerdana Bold-11px")
            label:setTextAlign(AlignLeft)
            label:setTextWrap(true)
            label:setTextVerticalAutoResize(true)

            local hasAugmentation = tonumber(data.augmentation)
            hasAug = hasAug or hasAugmentation ~= nil
            local percent = ""
            if data.percent then
                percent = "%"
            end
            local text = data.text

            local icon = ""
            if data.augmentation then
                icon = "   :"
                text = " " .. text
            end

            if data.quantity then
                local formattedQuantity
                if math.floor(data.quantity) == data.quantity then
                    formattedQuantity = string.format("+%d%s %s", data.quantity, percent, text)
                else
                    formattedQuantity = string.format("+%.2f%s %s", data.quantity, percent, text)
                end
                label:setText(formattedQuantity)
            else
                if #text > 85 then
                    text = text:sub(1, 85) .. "..."
                end

                label:setText(string.format("%s%s", icon, text))
            end

            if i > 1 then
                label:setColor('#707070')

                if hasAugmentation then
                    addAugmentationIcon(label, data, widget, slot)
                end
            end
            label:setTextVerticalAutoResize(true)
            label:setMarginTop(1)

            if not hasAugmentation then
                if widget.value <= 0 then
                    label:setColor('#707070')
                else
                    label:setColor('#C0C0C0')
                end
            end
        end

        if hasAug then
            setAlignedTooltip(UI.conviction.info, WheelDestiny.MediumPerkInfos.AugGeneralInfo, AlignTopLeft)
        else
            setAlignedTooltip(UI.conviction.info, WheelDestiny.MediumPerkInfos.GeneralInfo, AlignTopLeft)
        end
    end
end

function wheelDestinyUpdateGems()
    local UI = WheelDestiny.UI.main.wheel.base
    local sides = {
        [0] = "topLeft",
        [1] = "topRight",
        [2] = "bottomLeft",
        [3] = "bottomRight"
    }

    for i = 0, 3 do
        local side = sides[i]
        local widget = WheelDestiny.ActivedGem[i]

        if widget and widget.data then
            UI[side].gem:setVisible(true)
            UI[side].gem:setImageClip(torect(string.format("%d %d %d %d", (32 * widget.data.details.clip), 0, 32, 32)))
        else
            UI[side].gem:setVisible(false)
        end
    end
end

function wheelDestinyUpdateWheelGem()
    WheelDestiny.ActivedGemSlots = {
        [0] = {}, [1] = {}, [2] = {}, [3] = {}
    }

    for id, data in pairs(WheelDestiny.GemSlots or {}) do
        local gem = WheelDestiny.ActivedGem[data.affinity]
        local widget = wheelDestinyGetSlotById(id)
        local slotDefinition = getSlotDefinition(id)
        if widget and slotDefinition then
            local max = tonumber(slotDefinition.max) or 0
            local position = tonumber(data.position)
            local gemSize = gem and gem.data and tonumber(gem.data.size) or 0
            local attribute = position and Gem_Atelier.getGemAttribute(position)
            local clip = gem and gem.data and gem.data.object and attribute and
                tonumber(gem.data.object[attribute]) or nil

            if (tonumber(widget.value) or 0) >= max and position and position >= 1 and
                position <= gemSize and clip ~= nil then
                WheelDestiny.ActivedGemSlots[data.affinity][position] = {
                    id = id,
                    clip = clip,
                    modType = position == 3 and 3 or 2
                }
                if position == 3 then
                    widget.mediumPerk:setImageSource("/modules/game_wheel/images/icons-skillwheel-suprememods")
                    widget.mediumPerk:setSize({ width = 35, height = 35 })
                    widget.mediumPerk:setImageClip(torect(string.format("%d 0 35 35", 35 * clip)))
                else
                    widget.mediumPerk:setImageSource("/modules/game_wheel/images/icons-skillwheel-basicmods")
                    widget.mediumPerk:setSize({ width = 30, height = 30 })
                    widget.mediumPerk:setImageClip(torect(string.format("%d 0 30 30", 30 * clip)))
                end
            else
                widget.mediumPerk:setImageSource("/modules/game_wheel/images/icons-skillwheel-mediumperks")
                local vocationPerk = slotDefinition.perk and slotDefinition.perk[WheelDestiny.vocation]
                local mediumClip = 30 * (vocationPerk and vocationPerk.mediumClip or 0)
                widget.mediumPerk:setImageClip(torect(string.format("%d 0 30 30", mediumClip)))
                widget.mediumPerk:setSize({ width = 30, height = 30 })
            end
        end
    end
end

function wheelDestinyUpdateSockets()
    local values = {
        [0] = 0,
        [1] = 0,
        [2] = 0,
        [3] = 0
    }

    for id, data in pairs(WheelDestiny.GemSlots or {}) do
        local slot = WheelDestiny.UI.main.wheel.base.front:getChildById(id)
        local slotDefinition = getSlotDefinition(id)
        if slot and slotDefinition then
            local max = tonumber(slotDefinition.max) or 0
            if slot.value >= max then
                values[data.affinity] = values[data.affinity] + 1
            end
        end
    end

    for side, value in pairs(values) do
        local affinity = Gem_Atelier.getAffinityName(side)
        local gemSocket = affinity and Gem_Atelier.UI.vessels.base[affinity.."Socket"] or nil
        local widget = affinity and WheelDestiny.UI.main.wheel.base[affinity] or nil
        local disabled = WheelDestiny.ActivedGem[side] == nil

        local tiers = WheelDestiny.SocketsTier and WheelDestiny.SocketsTier[side]
        local socketData = tiers and tiers[value]

        if affinity and gemSocket and widget then
            if value > 0 and socketData then
                widget:setChecked(true)
                gemSocket:setVisible(true)
                widget.socket:setVisible(true)

                if disabled then
                    gemSocket:setImageClip(torect(string.format("%d %d %d %d", (34 * socketData.disabled), 0, 34, 34)))
                    widget.socket:setImageClip(torect(string.format("%d %d %d %d", (34 * socketData.disabled), 0, 34, 34)))
                else
                    gemSocket:setImageClip(torect(string.format("%d %d %d %d", (34 * socketData.enabled), 0, 34, 34)))
                    widget.socket:setImageClip(torect(string.format("%d %d %d %d", (34 * socketData.enabled), 0, 34, 34)))
                end
            else
                widget:setChecked(false)
                gemSocket:setVisible(false)
                widget.socket:setVisible(false)
            end
        end
    end
end

function wheelDestinyUpdateBalance()
    local gold = WheelDestiny.Resources[0]
    local value = comma_value(gold)
    WheelDestiny.UI.main.goldBalance.value:setText(value)
end

function wheelDestinyOnChangeGem()
    local widget = WheelDestiny.selected
    local side = widget and wheelDestinyGetSideIdByName(widget:getId())
    if side == nil then
        return
    end

    local gem = WheelDestiny.ActivedGem[side]
    WheelDestiny.changeHome(WheelDestiny.UI.buttons.gemButton, true)
    if gem then
        Gem_Atelier.onVesselFilter(side)
    else
        Gem_Atelier.UI.affinityFilter:setCurrentOption("All Affinities")
        Gem_Atelier.UI.qualityFilter:setCurrentOption("All Qualities")
    end
end

function wheelDestinyToggle(Forced)
    if not WheelDestiny.UI then
        return false
    end

    if WheelDestiny.UI:isVisible() then
        WheelDestiny.UI:hide()
        if WheelDestiny.Button then WheelDestiny.Button:setOn(false) end
        return true
    end

    if Forced then
        local player = g_game.getLocalPlayer()
        local highEnough = false
        local premium = true

        if player then
            highEnough = not player.getLevel or (tonumber(player:getLevel()) or 0) >= 51
            if player.isPremium then
                premium = player:isPremium()
            end
        end

        WheelDestiny.preview = not (highEnough and premium)

        if not WheelDestiny.preview then
            WheelDestiny.UI:show()
            WheelDestiny.UI:raise()
            prepareWheelWindowInput()
            if WheelDestiny.Button then WheelDestiny.Button:setOn(true) end
        else
            local confirmWindow = nil

            local function yesCallback()
                if confirmWindow then
                    confirmWindow:destroy()
                    confirmWindow = nil
                    WheelDestiny.UI:show()
                    WheelDestiny.UI:raise()
                    prepareWheelWindowInput()
                    if WheelDestiny.Button then WheelDestiny.Button:setOn(true) end
                end

            end

            local function noCallback()
                if confirmWindow then
                    confirmWindow:destroy()
                    confirmWindow = nil
                end
                if WheelDestiny.Button then WheelDestiny.Button:setOn(false) end
            end

            if not confirmWindow then
                confirmWindow = displayGeneralBox(tr('Info'), tr(
                    'To be able to use the Wheel of Destiny, a character must be at least level 51, be promoted and have active\nPremium Time.\n\nClick on "Ok" to see a preview of the Wheel of Destiny for your vocation.'),
                    {
                        { text = tr('Ok'), callback = yesCallback },
                        { text = tr('Cancel'), callback = noCallback },
                        anchor = AnchorHorizontalCenter
                    }, yesCallback, noCallback)
            end
        end
        WheelDestiny.requestFetch()
        return true
    end
    return false
end

local function trimPresetText(value)
    return tostring(value or ""):match("^%s*(.-)%s*$") or ""
end

local function isValidWheelBase64(value)
    value = tostring(value or "")
    if value == "" or (#value % 4) ~= 0 then
        return false
    end
    return value:match("^[%w%+%/]+=?=?$") ~= nil and value:match("=.+[^=]") == nil
end

local function copyPresetArray(values, count, default)
    local result = {}
    for index = 1, count do
        result[index] = tonumber(getIndexedValue(values, index, default)) or default
    end
    return result
end

local function getPresetStorageKey()
    local player = g_game.getLocalPlayer()
    local name = player and player:getName() or "offline"
    name = name:lower():gsub("[^%w]+", "_")
    return string.format("wheel_destiny_presets_%s_%d", name, tonumber(WheelDestiny.vocation) or 0)
end

local function isDefaultPresetName(name)
    return trimPresetText(name):lower() == "default-preset"
end

local function snapshotWheelPreset(name)
    local slots = currentAllocation()
    local gems = {}
    local usedPoints = 0
    for id = 1, WHEEL_SLOT_COUNT do
        slots[id] = math.max(0, math.floor(tonumber(slots[id]) or 0))
        usedPoints = usedPoints + slots[id]
    end
    for affinity = 0, 3 do
        local gem = WheelDestiny.ActivedGem and WheelDestiny.ActivedGem[affinity]
        gems[affinity + 1] = gem and (tonumber(gem:getId()) or -1) or -1
    end
    return {
        presetName = name or "Default-Preset",
        vocation = tonumber(WheelDestiny.vocation) or 0,
        maxPoints = tonumber(WheelDestiny.totalPoints) or 0,
        usedPoints = usedPoints,
        slots = slots,
        gems = gems
    }
end

local function normalizePresetData(data, name)
    if type(data) ~= "table" then
        return nil
    end
    local slots = copyPresetArray(data.slots or data.pointInvested, WHEEL_SLOT_COUNT, 0)
    local gems = copyPresetArray(data.gems or data.equippedGems or data.equipedGems, 4, -1)
    local usedPoints = 0
    for id, slot in ipairs(WheelDestiny.Slots or {}) do
        slots[id] = math.max(0, math.min(math.floor(slots[id]), tonumber(slot.max) or 0))
        usedPoints = usedPoints + slots[id]
    end
    if #slots ~= WHEEL_SLOT_COUNT or not allocationIsReachable(slots, tonumber(data.maxPoints) or usedPoints) then
        return nil
    end
    return {
        presetName = trimPresetText(name or data.presetName),
        vocation = tonumber(data.vocation) or tonumber(WheelDestiny.vocation) or 0,
        maxPoints = math.max(usedPoints, tonumber(data.maxPoints) or usedPoints),
        usedPoints = usedPoints,
        slots = slots,
        gems = gems
    }
end

local loadWheelPresets

local function buildPersistedPresetList()
    local presets = {}
    local defaultPreset = normalizePresetData(WheelDestiny.StoredDefaultPreset or
        WheelDestiny.DefaultPreset or snapshotWheelPreset("Default-Preset"), "Default-Preset")
    if defaultPreset then
        defaultPreset.presetName = "Default-Preset"
        presets[#presets + 1] = defaultPreset
    end
    for _, preset in ipairs(WheelDestiny.InternalPreset or {}) do
        if preset and not preset.isDefault and not isDefaultPresetName(preset.presetName) then
            presets[#presets + 1] = preset
        end
    end
    return presets
end

local function saveWheelPresets()
    local persistedPresets = buildPersistedPresetList()
    if g_settings and WheelDestiny.PresetStorageKey then
        g_settings.setNode(WheelDestiny.PresetStorageKey, persistedPresets)
        if type(g_settings.save) == "function" then
            g_settings.save()
        end
    end

    if WheelDestiny.requestPresetSave and not WheelDestiny.PendingRequest then
        WheelDestiny.requestPresetSave(persistedPresets)
    end
end

local function updateStoredPresetFromCurrent(presetName)
    presetName = trimPresetText(presetName)
    if presetName == "" then
        return false
    end

    loadWheelPresets()
    if isDefaultPresetName(presetName) then
        local snapshot = normalizePresetData(snapshotWheelPreset("Default-Preset"), "Default-Preset")
        if not snapshot then
            return false
        end
        snapshot.presetName = "Default-Preset"
        snapshot.isDefault = true
        WheelDestiny.StoredDefaultPreset = snapshot
        WheelDestiny.DefaultPreset = snapshot
        WheelDestiny.CurrentPreset = snapshot
        WheelDestiny.currentPreset = snapshot
        WheelDestiny.CurrentPresetName = "Default-Preset"
        saveWheelPresets()
        return true
    end

    for _, preset in ipairs(WheelDestiny.InternalPreset or {}) do
        if preset.presetName == presetName and not preset.isDefault then
            local snapshot = normalizePresetData(snapshotWheelPreset(presetName), presetName)
            if not snapshot then
                return false
            end
            preset.vocation = snapshot.vocation
            preset.maxPoints = snapshot.maxPoints
            preset.usedPoints = snapshot.usedPoints
            preset.slots = snapshot.slots
            preset.gems = snapshot.gems
            WheelDestiny.CurrentPresetName = preset.presetName
            saveWheelPresets()
            return true
        end
    end
    return false
end

function wheelDestinyCommitPendingPresetSave()
    local presetName = WheelDestiny.PendingPresetSaveName
    WheelDestiny.PendingPresetSaveName = nil
    if not presetName then
        return false
    end
    return updateStoredPresetFromCurrent(presetName)
end

loadWheelPresets = function()
    local storageKey = getPresetStorageKey()
    if WheelDestiny.PresetStorageKey == storageKey and not WheelDestiny.PresetsNeedReload then
        return
    end
    WheelDestiny.PresetStorageKey = storageKey
    WheelDestiny.PresetsNeedReload = false
    WheelDestiny.InternalPreset = {}
    WheelDestiny.StoredDefaultPreset = nil
    local stored = {}
    if WheelDestiny.ServerPresetsLoaded then
        stored = WheelDestiny.ServerPresets or {}
        if not next(stored) and not WheelDestiny.LocalPresetsMigratedToServer and g_settings then
            local localStored = g_settings.getNode(storageKey) or {}
            if type(localStored) == "table" and next(localStored) then
                stored = localStored
                WheelDestiny.LocalPresetsMigratedToServer = true
            end
        end
    else
        stored = g_settings and g_settings.getNode(storageKey) or {}
    end
    for _, data in pairs(type(stored) == "table" and stored or {}) do
        local preset = normalizePresetData(data)
        if preset and preset.presetName ~= "" and preset.vocation == WheelDestiny.vocation then
            if isDefaultPresetName(preset.presetName) then
                preset.presetName = "Default-Preset"
                preset.isDefault = true
                WheelDestiny.StoredDefaultPreset = preset
            else
                table.insert(WheelDestiny.InternalPreset, preset)
            end
        end
    end
    table.sort(WheelDestiny.InternalPreset, function(left, right)
        return left.presetName:lower() < right.presetName:lower()
    end)

    if WheelDestiny.ServerPresetsLoaded and WheelDestiny.LocalPresetsMigratedToServer and
        WheelDestiny.requestPresetSave and not WheelDestiny.PendingRequest then
        WheelDestiny.requestPresetSave(buildPersistedPresetList())
    end
end

local function samePreset(left, right)
    if not left or not right then return false end
    for id = 1, WHEEL_SLOT_COUNT do
        if tonumber(left.slots[id]) ~= tonumber(right.slots[id]) then return false end
    end
    for index = 1, 4 do
        if tonumber(left.gems[index]) ~= tonumber(right.gems[index]) then return false end
    end
    return true
end

local function findInternalPresetByName(name)
    name = trimPresetText(name)
    if name == "" then
        return nil
    end
    if isDefaultPresetName(name) then
        return WheelDestiny.DefaultPreset or WheelDestiny.StoredDefaultPreset
    end
    for _, preset in ipairs(WheelDestiny.InternalPreset or {}) do
        if preset.presetName == name then
            return preset
        end
    end
    return nil
end

local function findUniquePresetMatchingCurrent()
    local match = nil
    for _, preset in ipairs(WheelDestiny.InternalPreset or {}) do
        if samePreset(preset, WheelDestiny.DefaultPreset) then
            if match then
                return nil
            end
            match = preset
        end
    end
    return match
end

local function selectPresetRow(preset)
    WheelDestiny.SelectedPreset = preset
    if not WheelDestiny.UI then return end
    local presetBox = WheelDestiny.UI.main.wheel.test.presetBox
    local list = presetBox.presetList
    if list then
        for _, row in ipairs(list:getChildren()) do
            local selected = row.preset == preset or (preset and row.preset and row.preset.presetName == preset.presetName)
            if row.setBackgroundColor then
                row:setBackgroundColor(selected and "#5a5145" or "#00000000")
            end
            if row.setColor then
                row:setColor(selected and "#fff2b0" or "#dfdfdf")
            end
        end
    end
    local editable = preset and not preset.isDefault
    presetBox.renamePreset:setEnabled(editable)
    presetBox.deletePreset:setEnabled(editable)
    presetBox.applyPresetChanges:setEnabled(preset ~= nil and WheelDestiny.state ~= 0 and not WheelDestiny.preview)
end

refreshPresetList = function(preferred)
    if not WheelDestiny.UI then return end
    local list = WheelDestiny.UI.main.wheel.test.presetBox.presetList
    list:destroyChildren()
    local presets = {}
    if WheelDestiny.DefaultPreset then table.insert(presets, WheelDestiny.DefaultPreset) end
    for _, preset in ipairs(WheelDestiny.InternalPreset or {}) do table.insert(presets, preset) end

    local focusRow = nil
    for _, preset in ipairs(presets) do
        local row = g_ui.createWidget("Label", list)
        row:setHeight(16)
        row:setFocusable(true)
        row:setBackgroundColor("#00000000")
        row:setColor("#dfdfdf")
        row:setText(string.format("%s  (%d)", preset.presetName, tonumber(preset.usedPoints) or 0))
        row.preset = preset
        row.onFocusChange = function(self, focused)
            if focused then selectPresetRow(self.preset) end
        end
        row.onDoubleClick = function(self)
            selectPresetRow(self.preset)
            wheelDestinyApplyPresetChanges()
            return true
        end
        if preset == preferred or (preferred and preset.presetName == preferred.presetName) then
            focusRow = row
        end
    end
    focusRow = focusRow or list:getFirstChild()
    if focusRow then focusRow:focus() else selectPresetRow(nil) end

    local current = WheelDestiny.CurrentPreset or WheelDestiny.DefaultPreset
    WheelDestiny.UI.main.presetLabel:setText(string.format("Current preset: %s",
        current and current.presetName or "Default-Preset"))
    if WheelDestiny.PresetNew then
        WheelDestiny.PresetNew.contentPanel.copyPreset:setText(string.format("Copy preset '%s'",
            current and current.presetName or "Default-Preset"))
    end
end

function wheelDestinyShowNewPreset(isImport)
    if not WheelDestiny.UI or not WheelDestiny.PresetNew then return false end
    WheelDestiny.UI:hide()
    WheelDestiny.PresetNew:show()
    WheelDestiny.PresetNew:raise()
    WheelDestiny.PresetNew:focus()
    WheelDestiny.PresetNew:lock()
    WheelDestiny.PresetNew.contentPanel.presetName:clearText()
    WheelDestiny.PresetNew.contentPanel.presetCode:clearText()
    WheelDestiny.SelectedNewPresetRadio:selectWidget(isImport and
        WheelDestiny.PresetNew.contentPanel.import or WheelDestiny.PresetNew.contentPanel.useEmpty)
    wheelDestinyOnNewPresetSelectionChange()
    return true
end

function wheelDestinyHideNewPreset()
    if not WheelDestiny.PresetNew then return false end
    WheelDestiny.PresetNew:unlock()
    WheelDestiny.PresetNew:hide()
    if WheelDestiny.UI then
        WheelDestiny.UI:show()
        WheelDestiny.UI:raise()
        prepareWheelWindowInput()
    end
    return true
end

function wheelDestinyShowRenamePreset()
    local preset = WheelDestiny.SelectedPreset
    if not preset or preset.isDefault or not WheelDestiny.PresetRename then return false end
    WheelDestiny.UI:hide()
    WheelDestiny.PresetRename:show()
    WheelDestiny.PresetRename:raise()
    WheelDestiny.PresetRename:focus()
    WheelDestiny.PresetRename:lock()
    WheelDestiny.PresetRename.contentPanel.presetName:setText(preset.presetName)
    WheelDestiny.PresetRename.contentPanel.ok:setEnabled(false)
    return true
end

function wheelDestinyHideRenamePreset()
    if not WheelDestiny.PresetRename then return false end
    WheelDestiny.PresetRename:unlock()
    WheelDestiny.PresetRename:hide()
    if WheelDestiny.UI then
        WheelDestiny.UI:show()
        WheelDestiny.UI:raise()
        prepareWheelWindowInput()
    end
    return true
end

local function applyPresetTooltips()
    local newPanel = WheelDestiny.PresetNew and WheelDestiny.PresetNew.contentPanel
    if newPanel then
        setAlignedTooltip(newPanel.presetNameTooltip,
            "Preset name\nMust be unique and between 2 and 30 characters.", AlignTopLeft)
        setAlignedTooltip(newPanel.importTooltip,
            "Import preset\nPaste a Wheel of Destiny export code here to create a preset from it.", AlignTopLeft)
    end

    local renamePanel = WheelDestiny.PresetRename and WheelDestiny.PresetRename.contentPanel
    if renamePanel then
        setAlignedTooltip(renamePanel.presetNameTooltip,
            "Preset name\nMust be unique and between 2 and 30 characters.", AlignTopLeft)
    end
end

function wheelDestinyPresetInit()
    applyPresetTooltips()

    if WheelDestiny.SelectedNewPresetRadio then
        WheelDestiny.SelectedNewPresetRadio:destroy()
    end
    WheelDestiny.SelectedNewPresetRadio = UIRadioGroup.create()
    WheelDestiny.SelectedNewPresetRadio:addWidget(WheelDestiny.PresetNew.contentPanel.useEmpty)
    WheelDestiny.SelectedNewPresetRadio:addWidget(WheelDestiny.PresetNew.contentPanel.copyPreset)
    WheelDestiny.SelectedNewPresetRadio:addWidget(WheelDestiny.PresetNew.contentPanel.import)
    WheelDestiny.SelectedNewPresetRadio.onSelectionChange = wheelDestinyOnNewPresetSelectionChange

    WheelDestiny.PresetNew.contentPanel.presetName.onTextChange = function()
        wheelDestinyOnNewPresetSelectionChange()
    end
    WheelDestiny.PresetNew.contentPanel.presetCode.onTextChange = function()
        WheelDestiny.SelectedNewPresetRadio:selectWidget(WheelDestiny.PresetNew.contentPanel.import)
        wheelDestinyOnNewPresetSelectionChange()
    end
    WheelDestiny.PresetRename.contentPanel.presetName.onTextChange = function(self, text)
        local preset = WheelDestiny.SelectedPreset
        WheelDestiny.PresetRename.contentPanel.ok:setEnabled(
            preset ~= nil and wheelDestinyCheckPresetName(text, preset.presetName))
    end
end

function wheelDestinyOnImportConfig(base64Data)
    if not isValidWheelBase64(base64Data) then
        return {}
    end
    local okDecode, decodedData = pcall(base64.decode, base64Data)
    if not okDecode or type(decodedData) ~= "string" then return {} end

    if decodedData:sub(1, 1) == "{" then
        local okJson, data = pcall(json.decode, decodedData)
        if not okJson then return {} end
        return normalizePresetData(data) or {}
    end

    if #decodedData < 42 then return {} end
    local low, high = decodedData:byte(1, 2)
    local slots, gems = {}, {}
    for index = 1, WHEEL_SLOT_COUNT do slots[index] = decodedData:byte(index + 2) or 0 end
    for index = 1, 4 do
        local value = decodedData:byte(index + 38) or 255
        gems[index] = value == 255 and -1 or value
    end
    return normalizePresetData({
        maxPoints = low + (high * 256),
        slots = slots,
        gems = gems,
        vocation = WheelDestiny.vocation
    }) or {}
end

function wheelDestinyValidadeImportCode(code)
    code = trimPresetText(code):gsub("%s+", "")
    if #code < 3 then return "Export code does not match a valid Wheel of Destiny." end
    local vocationId = tonumber(code:sub(1, 2))
    if vocationId ~= tonumber(WheelDestiny.vocation) then
        return "Export code does not match the character's vocation."
    end
    local base64Data = code:sub(3)
    if not isValidWheelBase64(base64Data) or not next(wheelDestinyOnImportConfig(base64Data)) then
        return "Export code does not match a valid Wheel of Destiny."
    end
    return ""
end

function wheelDestinyCheckPresetName(text, ignoredName)
    text = trimPresetText(text)
    if #text < 2 or #text > 30 then return false end
    if isDefaultPresetName(text) and not isDefaultPresetName(ignoredName) then return false end
    for _, data in pairs(WheelDestiny.InternalPreset or {}) do
        if data.presetName:lower() == text:lower() and data.presetName ~= ignoredName then return false end
    end
    return true
end

function wheelDestinyOnNewPresetSelectionChange()
    if not WheelDestiny.PresetNew or not WheelDestiny.SelectedNewPresetRadio then return false end
    local panel = WheelDestiny.PresetNew.contentPanel
    local selectedOption = WheelDestiny.SelectedNewPresetRadio:getSelectedWidget()
    local importing = selectedOption == panel.import
    panel.presetCode:setEnabled(importing)
    local errorText = importing and wheelDestinyValidadeImportCode(panel.presetCode:getText()) or ""
    panel.importTooltip:setVisible(true)
    if errorText ~= "" then
        panel.importTooltip:setTooltip(errorText)
    else
        panel.importTooltip:setTooltip("Paste a Wheel of Destiny export code here to create a preset from it.")
    end
    panel.ok:setEnabled(selectedOption ~= nil and
        wheelDestinyCheckPresetName(panel.presetName:getText()) and errorText == "")
    return true
end

function wheelDestinyCreatePreset()
    local panel = WheelDestiny.PresetNew and WheelDestiny.PresetNew.contentPanel
    if not panel then return false end
    local name = trimPresetText(panel.presetName:getText())
    if not wheelDestinyCheckPresetName(name) then return false end
    local selected = WheelDestiny.SelectedNewPresetRadio:getSelectedWidget()
    local preset
    if selected == panel.import then
        if wheelDestinyValidadeImportCode(panel.presetCode:getText()) ~= "" then return false end
        local code = trimPresetText(panel.presetCode:getText()):gsub("%s+", "")
        preset = wheelDestinyOnImportConfig(code:sub(3))
    elseif selected == panel.copyPreset then
        preset = snapshotWheelPreset(name)
    else
        preset = snapshotWheelPreset(name)
        preset.slots = copyPresetArray({}, WHEEL_SLOT_COUNT, 0)
        preset.gems = copyPresetArray({}, 4, -1)
        preset.usedPoints = 0
    end
    preset = normalizePresetData(preset, name)
    if not preset then return false end
    preset.presetName = name
    table.insert(WheelDestiny.InternalPreset, preset)
    table.sort(WheelDestiny.InternalPreset, function(left, right)
        return left.presetName:lower() < right.presetName:lower()
    end)
    saveWheelPresets()
    wheelDestinyHideNewPreset()
    refreshPresetList(preset)
    return true
end

function wheelDestinyRenamePreset()
    local preset = WheelDestiny.SelectedPreset
    if not preset or preset.isDefault then return false end
    local oldName = preset.presetName
    local name = trimPresetText(WheelDestiny.PresetRename.contentPanel.presetName:getText())
    if not wheelDestinyCheckPresetName(name, preset.presetName) then return false end
    preset.presetName = name
    if WheelDestiny.CurrentPreset == preset or WheelDestiny.CurrentPresetName == oldName then
        WheelDestiny.CurrentPresetName = name
    end
    saveWheelPresets()
    wheelDestinyHideRenamePreset()
    refreshPresetList(preset)
    return true
end

function wheelDestinyDeletePreset()
    local preset = WheelDestiny.SelectedPreset
    if not preset or preset.isDefault then return false end
    local function removePreset()
        for index, item in ipairs(WheelDestiny.InternalPreset or {}) do
            if item == preset then table.remove(WheelDestiny.InternalPreset, index) break end
        end
        if WheelDestiny.CurrentPreset == preset or WheelDestiny.CurrentPresetName == preset.presetName then
            WheelDestiny.CurrentPreset = WheelDestiny.DefaultPreset
            WheelDestiny.CurrentPresetName = nil
        end
        saveWheelPresets()
        refreshPresetList(WheelDestiny.CurrentPreset)
    end
    local confirmWindow
    local function yes()
        if confirmWindow then confirmWindow:destroy() end
        removePreset()
    end
    local function no()
        if confirmWindow then confirmWindow:destroy() end
    end
    confirmWindow = displayGeneralBox(tr("Delete Preset"),
        tr(string.format("Delete preset '%s'?", preset.presetName)), {
            { text = tr("Yes"), callback = yes },
            { text = tr("No"), callback = no }
        }, yes, no)
    return true
end

function wheelDestinyApplyPresetChanges()
    local preset = normalizePresetData(WheelDestiny.SelectedPreset)
    if not preset or WheelDestiny.state == 0 or WheelDestiny.preview then return false end
    if preset.vocation ~= tonumber(WheelDestiny.vocation) then return false end
    if preset.usedPoints > tonumber(WheelDestiny.totalPoints) then
        displayErrorBox(tr("Wheel of Destiny"), tr("This preset requires more promotion points than are available."))
        return false
    end
    if WheelDestiny.state ~= 1 then
        for id = 1, WHEEL_SLOT_COUNT do
            if preset.slots[id] < (tonumber(WheelDestiny.slots[id]) or 0) then
                displayErrorBox(tr("Wheel of Destiny"), tr("Outside a temple, presets may only add unused points."))
                return false
            end
        end
        for index = 1, 4 do
            if preset.gems[index] ~= (tonumber(WheelDestiny.SavedActiveGemIndices[index - 1]) or -1) then
                displayErrorBox(tr("Wheel of Destiny"), tr("Vessel changes can only be made inside a temple."))
                return false
            end
        end
    end

    WheelDestiny.usedPoints = 0
    for _, side in ipairs(WHEEL_SIDES) do WheelDestiny.sidePoints[side].points = 0 end
    for id = 1, WHEEL_SLOT_COUNT do
        local value = preset.slots[id]
        wheelDestinySetSlotPoints(id, value)
        WheelDestiny.usedPoints = WheelDestiny.usedPoints + value
    end
    WheelDestiny.availablePoints = WheelDestiny.totalPoints - WheelDestiny.usedPoints

    if WheelDestiny.state == 1 and Gem_Atelier.reset then
        Gem_Atelier.reset()
        for index = 1, 4 do
            local gemIndex = preset.gems[index]
            local widget = gemIndex >= 0 and Gem_Atelier.UI.gems:getChildById(gemIndex) or nil
            if widget and widget.data and widget.data.object.affinity == (index - 1) then
                Gem_Atelier.onPlaceVessel(widget.data, widget, Gem_Atelier.getAffinityName(index - 1), true)
            end
        end
    end

    WheelDestiny.CurrentPreset = WheelDestiny.SelectedPreset
    WheelDestiny.currentPreset = WheelDestiny.CurrentPreset
    WheelDestiny.CurrentPresetName = WheelDestiny.CurrentPreset and WheelDestiny.CurrentPreset.presetName or nil
    wheelDestinyUpdate()
    wheelDestinyUpdateWheelGem()
    Fragment_Workshop.updateActivedMods()
    refreshPresetList(WheelDestiny.CurrentPreset)

    if wheelDestinyIsChanged() then
        return wheelDestinySend(false)
    end

    WheelDestiny.UI.main.applyButton:setEnabled(false)
    WheelDestiny.UI.main.okButton:setEnabled(false)
    return true
end

local function buildPresetExportCode(preset)
    preset = normalizePresetData(preset or snapshotWheelPreset("Export"))
    if not preset then return nil end
    local payload = json.encode({
        version = 1,
        vocation = preset.vocation,
        maxPoints = preset.maxPoints,
        slots = preset.slots,
        gems = preset.gems
    })
    return string.format("%02d%s", preset.vocation, base64.encode(payload))
end

function wheelDestinyExportCode()
    if WheelDestiny.ExportCodeWindow then WheelDestiny.ExportCodeWindow:destroy() end
    if not WheelDestiny.UI then return false end
    WheelDestiny.UI:hide()

    local function closeExport(copy)
        if WheelDestiny.ExportCodeWindow then
            WheelDestiny.ExportCodeWindow:unlock()
            WheelDestiny.ExportCodeWindow:destroy()
            WheelDestiny.ExportCodeWindow = nil
        end
        WheelDestiny.UI:show()
        WheelDestiny.UI:raise()
        prepareWheelWindowInput()
        if copy then wheelDestinyOnExportConfig() end
    end
    WheelDestiny.ExportCodeWindow = displayGeneralBox(tr("Copy to Clipboard"),
        tr("Copy the selected preset's export code to the clipboard."), {
            { text = tr("Code"), callback = function() closeExport(true) end },
            { text = tr("Cancel"), callback = function() closeExport(false) end }
        }, function() closeExport(true) end, function() closeExport(false) end)
    WheelDestiny.ExportCodeWindow:lock()
    return true
end

function wheelDestinyOnExportConfig()
    local code = buildPresetExportCode(WheelDestiny.SelectedPreset or WheelDestiny.CurrentPreset)
    if not code then return false end
    g_window.setClipboardText(code)
    modules.game_textmessage.displayGameMessage(tr("Wheel preset code copied to the clipboard."))
    return code
end

function wheelDestinyUpdateCurrentPreset()
    loadWheelPresets()
    WheelDestiny.DefaultPreset = normalizePresetData(WheelDestiny.StoredDefaultPreset, "Default-Preset") or
        snapshotWheelPreset("Default-Preset")
    WheelDestiny.DefaultPreset.presetName = "Default-Preset"
    WheelDestiny.DefaultPreset.isDefault = true

    local activeName = trimPresetText(WheelDestiny.CurrentPresetName or
        (WheelDestiny.CurrentPreset and WheelDestiny.CurrentPreset.presetName))
    local activePreset = findInternalPresetByName(activeName)
    if not activePreset and activeName == "" then
        activePreset = findUniquePresetMatchingCurrent()
    end

    WheelDestiny.CurrentPreset = activePreset or WheelDestiny.DefaultPreset
    WheelDestiny.CurrentPresetName = (activePreset or WheelDestiny.DefaultPreset).presetName
    WheelDestiny.currentPreset = WheelDestiny.CurrentPreset
    refreshPresetList(WheelDestiny.CurrentPreset)
end



WheelDestiny = WheelDestiny or {}
WheelDestiny.Unlocked = wheelDestinyUnlocked
WheelDestiny.GetSideIdByName = wheelDestinyGetSideIdByName
WheelDestiny.GetGemGrade = wheelDestinyGetGemGrade
WheelDestiny.GetVesselLevel = wheelDestinyGetVesselLevel
WheelDestiny.GetSideBySlot = wheelDestinyGetSideBySlot
WheelDestiny.GetSlotById = wheelDestinyGetSlotById
WheelDestiny.SetSlotPoints = wheelDestinySetSlotPoints
WheelDestiny.CheckCircle = wheelDestinyCheckCircle
WheelDestiny.isChanged = wheelDestinyIsChanged
WheelDestiny.Check = wheelDestinyCheck
WheelDestiny.onParseWheelOfDestiny = wheelDestinyOnParseWheelOfDestiny
WheelDestiny.send = wheelDestinySend
WheelDestiny.updateImages = wheelDestinyUpdateImages
WheelDestiny.update = wheelDestinyUpdate
WheelDestiny.reset = wheelDestinyReset
WheelDestiny.updateRevelations = wheelDestinyUpdateRevelations
WheelDestiny.updateConvictions = wheelDestinyUpdateConvictions
WheelDestiny.updateDedications = wheelDestinyUpdateDedications
WheelDestiny.changeOption = wheelDestinyChangeOption
WheelDestiny.resetSelected = wheelDestinyResetSelected
WheelDestiny.resetGemSelected = wheelDestinyResetGemSelected
WheelDestiny.resetCircleSelected = wheelDestinyResetCircleSelected
WheelDestiny.verifySlots = wheelDestinyVerifySlots
WheelDestiny.resetCircles = wheelDestinyResetCircles
WheelDestiny.updatePerks = wheelDestinyUpdatePerks
WheelDestiny.verifyPerks = wheelDestinyVerifyPerks
WheelDestiny.verifyButtons = wheelDestinyVerifyButtons
WheelDestiny.incrementButton = wheelDestinyIncrementButton
WheelDestiny.decrementButton = wheelDestinyDecrementButton
WheelDestiny.select = wheelDestinySelect
WheelDestiny.selectCircle = wheelDestinySelectCircle
WheelDestiny.selectGem = wheelDestinySelectGem
WheelDestiny.updateHoverInformation = wheelDestinyUpdateHoverInformation
WheelDestiny.ToggleSelectionButtons = wheelDestinyToggleSelectionButtons
WheelDestiny.updateProgress = wheelDestinyUpdateProgress
WheelDestiny.updateGems = wheelDestinyUpdateGems
WheelDestiny.updateWheelGem = wheelDestinyUpdateWheelGem
WheelDestiny.updateSockets = wheelDestinyUpdateSockets
WheelDestiny.updateBalance = wheelDestinyUpdateBalance
WheelDestiny.onChangeGem = wheelDestinyOnChangeGem
WheelDestiny.Toggle = wheelDestinyToggle
WheelDestiny.ShowNewPreset = wheelDestinyShowNewPreset
WheelDestiny.HideNewPreset = wheelDestinyHideNewPreset
WheelDestiny.ShowRenamePreset = wheelDestinyShowRenamePreset
WheelDestiny.HideRenamePreset = wheelDestinyHideRenamePreset
WheelDestiny.PresetInit = wheelDestinyPresetInit
WheelDestiny.ShowPresets = wheelDestinyShowPresets
WheelDestiny.OnImportConfig = wheelDestinyOnImportConfig
WheelDestiny.ValidadeImportCode = wheelDestinyValidadeImportCode
WheelDestiny.CheckPresetName = wheelDestinyCheckPresetName
WheelDestiny.OnNewPresetSelectionChange = wheelDestinyOnNewPresetSelectionChange
WheelDestiny.CreatePreset = wheelDestinyCreatePreset
WheelDestiny.RenamePreset = wheelDestinyRenamePreset
WheelDestiny.DeletePreset = wheelDestinyDeletePreset
WheelDestiny.ApplyPresetChanges = wheelDestinyApplyPresetChanges
WheelDestiny.ExportCode = wheelDestinyExportCode
WheelDestiny.OnExportConfig = wheelDestinyOnExportConfig
WheelDestiny.UpdateCurrentPreset = wheelDestinyUpdateCurrentPreset
WheelDestiny.CommitPendingPresetSave = wheelDestinyCommitPendingPresetSave
