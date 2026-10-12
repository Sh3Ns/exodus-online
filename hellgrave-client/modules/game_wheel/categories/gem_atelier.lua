local sides = {
    [0] = "topLeft",
    [1] = "topRight",
    [2] = "bottomLeft",
    [3] = "bottomRight"
}

local REVEAL_COSTS = {
    [0] = { gold = 125000, resource = 81 },
    [1] = { gold = 1000000, resource = 82 },
    [2] = { gold = 6000000, resource = 83 }
}

local SWITCH_COSTS = {
    [0] = 125000,
    [1] = 250000,
    [2] = 500000
}

local function setWidgetTooltip(widget, text)
    if not widget then
        return
    end
    if type(widget.setTooltip) == "function" then
        widget:setTooltip(text)
    end
    if widget.icon and type(widget.icon.setTooltip) == "function" then
        widget.icon:setTooltip(text)
    end
    if widget.value and type(widget.value.setTooltip) == "function" then
        widget.value:setTooltip(text)
    end
end

local function selectedGem()
    local selected = Gem_Atelier.SelectedGem
    if not selected or not selected.widget or not selected.data then
        return nil, nil
    end
    return selected.widget, selected.data
end

local function normalizedText(value)
    return tostring(value or ""):lower()
end

local function gemMatchesSearch(widget)
    local query = normalizedText(Gem_Atelier.searchText)
    if query == "" then
        return true
    end
    local data = widget and widget.data
    if not data then
        return false
    end
    return normalizedText(data.details and data.details.name):find(query, 1, true) ~= nil or
        normalizedText(data.object and data.object.index):find(query, 1, true) ~= nil
end

local function normalizeActiveGemIndices(activedGems)
    local result = { [0] = -1, [1] = -1, [2] = -1, [3] = -1 }
    if type(activedGems) ~= "table" then
        return result
    end

    for key, active in pairs(activedGems) do
        local index = -1
        local affinity = nil

        if type(active) == "table" then
            index = tonumber(active.index or active.gemIndex or active.gemID) or -1
            affinity = tonumber(active.affinity)
        else
            index = tonumber(active) or -1
        end

        local numericKey = tonumber(key)
        if affinity == nil and numericKey ~= nil then
            if numericKey >= 0 and numericKey <= 3 and activedGems[0] ~= nil then
                affinity = numericKey
            elseif numericKey >= 1 and numericKey <= 4 then
                affinity = numericKey - 1
            end
        end

        if affinity ~= nil and affinity >= 0 and affinity <= 3 then
            result[affinity] = index
        end
    end

    return result
end

local function setupGemPageButtons()
    if not Gem_Atelier.UI then
        return
    end

    local function bind(buttonWidget, action)
        if not buttonWidget then
            return
        end
        if type(buttonWidget.setPhantom) == "function" then
            buttonWidget:setPhantom(false)
        end
        if type(buttonWidget.setDraggable) == "function" then
            buttonWidget:setDraggable(false)
        end
        if type(buttonWidget.setTooltip) == "function" then
            buttonWidget:setTooltip(action == 1 and "Next page" or "Previous page")
        end

        buttonWidget.onMousePress = function(self, mousePos, mouseButton)
            if mouseButton ~= MouseLeftButton then
                return false
            end
            gemAtelierOnSelectPage(action)
            return true
        end
        buttonWidget.onMouseRelease = function()
            return true
        end
        buttonWidget.onClick = function()
            return true
        end
    end

    bind(Gem_Atelier.UI.nextButton, 1)
    bind(Gem_Atelier.UI.prevButton, 2)
end

local function getSwitchPrice(quality)
    quality = tonumber(quality) or 0
    local configured = Gem_Atelier.SwitchPrice and Gem_Atelier.SwitchPrice[quality]
    if configured ~= nil then
        return tonumber(configured) or 0
    end
    return SWITCH_COSTS[quality] or 0
end

function gemAtelierGetGemAttribute(index)
    local attributes = {
        [1] = "firstAttribute",
        [2] = "secondAttribute",
        [3] = "thirdAttribute"
    }

    return attributes[index]
end

local function getGemsSize(data)
    local count = 0
    if data.firstAttribute then
        count = count + 1
    end

    if data.secondAttribute then
        count = count + 1
    end

    if data.thirdAttribute then
        count = count + 1
    end

    return count
end

local function getHoverRect(tier)
    local hovers = {
        [0] = 4,
        [1] = 5,
        [2] = 6,
        [3] = 7
    }
    return hovers[tier]
end

function gemAtelierOnLock(widget)
    widget = widget or selectedGem()
    if not widget or not widget.data or WheelDestiny.PendingRequest or
        WheelDestiny.state ~= 1 or WheelDestiny.preview then
        return false
    end
    gemAtelierOnSelectGem(widget)
    return WheelDestiny.requestGemAction(3, tonumber(widget:getId()))
end

function gemAtelierUpdateFilters()
    if not Gem_Atelier.UI then
        return
    end

    local gems = Gem_Atelier.UI.gems
    local showAllQuality = Gem_Atelier.activeQualityFilter == 1
    local showAllAffinity = Gem_Atelier.activeAffinityFilter == 1
    local lockedOnly = Gem_Atelier.UI.lockedCheck:isChecked()
    local first = nil

    local qualityOptions = {
        [2] = 0,
        [3] = 1,
        [4] = 2
    }

    local affinityOptions = {
        [2] = 0,
        [3] = 1,
        [4] = 2,
        [5] = 3
    }

    for _, widget in pairs(gems:getChildren()) do
        local data = widget.data
        local passesQualityFilter = data and (showAllQuality or
            qualityOptions[Gem_Atelier.activeQualityFilter] == tonumber(data.object.quality))
        local passesAffinityFilter = data and (showAllAffinity or
            affinityOptions[Gem_Atelier.activeAffinityFilter] == tonumber(data.object.affinity))
        local passesLockedFilter = data and (not lockedOnly or (widget.locked and widget.locked:isOn()))
        local passesSearch = data and gemMatchesSearch(widget)

        if passesQualityFilter and passesAffinityFilter and passesLockedFilter and passesSearch then
            if not first then
                first = widget
            end
            widget:setVisible(true)
            data.visible = true
        else
            widget:setVisible(false)
            if data then data.visible = false end
        end
    end

    if first then
        gemAtelierOnSelectGem(first)

        Gem_Atelier.UI.view.selectedEmpty:setVisible(false)
        Gem_Atelier.UI.view.selected:setVisible(true)
    else
        Gem_Atelier.UI.view.selectedEmpty:setVisible(true)
        Gem_Atelier.UI.view.selected:setVisible(false)
    end

    local count = 0
    local widgetsPerPage = 15
    Gem_Atelier.Info = Gem_Atelier.Info or {}
    Gem_Atelier.Info.pages = 1
    Gem_Atelier.Info.actualPage = 1

    for _, child in ipairs(gems:getChildren()) do
        if child.data and child.data.visible then
            count = count + 1
            child.data.page = math.ceil(count / widgetsPerPage)
    
            if child.data.page > Gem_Atelier.Info.pages then
                Gem_Atelier.Info.pages = child.data.page
            end
        end

        if not child.data or child.data.page ~= Gem_Atelier.Info.actualPage then
            child:setVisible(false)
        end
    end
    
    Gem_Atelier.Info.count = count
    gemAtelierUpdatePage()
end

function gemAtelierOnSearch(text)
    Gem_Atelier.searchText = text or ""
    gemAtelierUpdateFilters()
end

function gemAtelierClearSearch()
    if not Gem_Atelier.UI or not Gem_Atelier.UI.search then
        return
    end
    Gem_Atelier.UI.search:clearText()
    Gem_Atelier.searchText = ""
    gemAtelierUpdateFilters()
end

function gemAtelierOnLockedFilter()
    gemAtelierUpdateFilters()
end

function gemAtelierOnQualityFilter(option)
    Gem_Atelier.activeQualityFilter = option
    gemAtelierUpdateFilters()
end

function gemAtelierOnAffinityFilter(option)
    Gem_Atelier.activeAffinityFilter = option
    gemAtelierUpdateFilters()
end

function gemAtelierReset()
    WheelDestiny.ActivedGemSlots = {
        [0] = { [1] = nil, [2] = nil, [3] = nil},
        [1] = { [1] = nil, [2] = nil, [3] = nil},
        [2] = { [1] = nil, [2] = nil, [3] = nil},
        [3] = { [1] = nil, [2] = nil, [3] = nil}
    }

    Gem_Atelier.SelectedGem = nil
    if not Gem_Atelier.UI or not Gem_Atelier.UI.vessels then
        return
    end
    for i = 0, 3 do
        local side = sides[i]
        local gem = Gem_Atelier.UI.vessels.base[side].gem
        local border = Gem_Atelier.UI.vessels.base[side.."Border"]

        gem:setVisible(false)
        border:setVisible(false)

        WheelDestiny.ActivedGem[i] = nil
    end

    if Gem_Atelier.UI.gems then
        for _, widget in ipairs(Gem_Atelier.UI.gems:getChildren()) do
            if widget.data then widget.data.selected = false end
            if widget.affinity then widget.affinity:setVisible(false) end
        end
    end

    WheelDestiny.updateGems()
    WheelDestiny.updateSockets()
    WheelDestiny.updateWheelGem()
    WheelDestiny.updateProgress(false, true)
end

function gemAtelierOnVesselAction()
    local widget, data = selectedGem()
    if not widget or WheelDestiny.state ~= 1 or WheelDestiny.PendingRequest then
        return false
    end
    local selected = Gem_Atelier.UI.view.selected

    local side = sides[data.object.affinity]
    if data.selected then
        gemAtelierOnRemoveVessel(widget, side)
        selected.placeButton:setText("Place in Vessel")

        Gem_Atelier.UI.view.selected.switchButton:setEnabled(true)
        Gem_Atelier.UI.view.selected.dismantleButton:setEnabled(true)
    else
        gemAtelierOnPlaceVessel(data, widget, side)
        selected.placeButton:setText("Remove from Vessel")

        Gem_Atelier.UI.view.selected.switchButton:setEnabled(false)
        Gem_Atelier.UI.view.selected.dismantleButton:setEnabled(false)
    end

    WheelDestiny.UI.main.applyButton:setEnabled(true)
    WheelDestiny.UI.main.okButton:setEnabled(true)
    return true
end

function gemAtelierOnRemoveVessel(widget, side)
    if not widget or not widget.data or not side then
        return false
    end
    local gem = Gem_Atelier.UI.vessels.base[side].gem
    local border = Gem_Atelier.UI.vessels.base[side.."Border"]

    widget.data.selected = false
    gem:setVisible(false)
    widget.affinity:setVisible(false)
    border:setVisible(false)

    WheelDestiny.ActivedGem[widget.data.object.affinity] = nil

    WheelDestiny.updateGems()
    WheelDestiny.updateSockets()
    WheelDestiny.updateWheelGem()
    WheelDestiny.updateProgress(false, true)
    Fragment_Workshop.updateActivedMods()
    return true
end

function gemAtelierOnPlaceVessel(data, widget, side, load)
    if not data or not widget or not side then
        return false
    end
    if not load then
        local activedGem = WheelDestiny.ActivedGem[data.object.affinity]
        if activedGem then
            gemAtelierOnRemoveVessel(activedGem, side)
        end
    end

    local gem = Gem_Atelier.UI.vessels.base[side].gem
    local border = Gem_Atelier.UI.vessels.base[side.."Border"]
    
    widget.data.selected = true
    gem:setImageClip(torect(string.format("%d %d %d %d", (32 * data.details.clip), 0, 32, 32)))
    gem:setVisible(true)
    widget.affinity:setVisible(true)
    border:setVisible(true)

    WheelDestiny.ActivedGem[widget.data.object.affinity] = widget
    WheelDestiny.updateGems()
    WheelDestiny.updateSockets()
    WheelDestiny.updateWheelGem()
    WheelDestiny.updateProgress(false, true)

    if not load then
        WheelDestiny.UI.main.applyButton:setEnabled(true)
        WheelDestiny.UI.main.okButton:setEnabled(true)
        Fragment_Workshop.updateActivedMods()
    end
    return true
end

function gemAtelierResetBorderVessel()
    for _, side in pairs(sides) do
        local border = Gem_Atelier.UI.vessels.base[side.."Border"]
        border:setVisible(false)
    end
end

function gemAtelierOnSelectGem(widget)
    if not widget or not widget.data then
        return false
    end
    if widget:isChecked() then
        return true
    end

    local data = widget.data
    if not data then
        return
    end
    local parent = widget:getParent()
    local UI = Gem_Atelier.UI.view.selected

    for _, child in pairs(parent:getChildren()) do
        child:setChecked(false)
    end
    
    widget:setChecked(true)
    UI.gemText:setText(data.details.name)

    local side = sides[data.object.affinity]
    local vesselBorder = Gem_Atelier.UI.vessels.base[side.."Border"]
    Gem_Atelier.SelectedGem = {
        data = data,
        widget = widget
    }

    gemAtelierResetBorderVessel()
    vesselBorder:setVisible(data.selected)

    if data.selected then
        UI.placeButton:setText("Remove from Vessel")
    else
        UI.placeButton:setText("Place in Vessel")
    end

    local state = WheelDestiny.state == 1 and not WheelDestiny.preview and not WheelDestiny.PendingRequest
    local enabled = state and not widget.locked:isOn()
    local switchPrice = getSwitchPrice(data.object.quality)
    local canAffordSwitch = (tonumber(WheelDestiny.Resources[0]) or 0) >= switchPrice

    UI.placeButton:setEnabled(state)
    UI.dismantleButton:setEnabled(enabled)
    UI.switchButton:setEnabled(enabled and canAffordSwitch)

    UI.gem:setImageClip(torect(string.format("%d %d %d %d", (32 * data.details.clip), 0, 32, 32)))
    UI.affinity:setImageClip(torect(string.format("%d %d %d %d", (26 * data.object.affinity), 0, 26, 26)))
    UI.price.value:setText(comma_value(switchPrice))
    UI.price.value:setEnabled(canAffordSwitch)

    local activedGem = WheelDestiny.ActivedGem[data.object.affinity]
    if activedGem then
        if activedGem:getId() == widget:getId() then
            UI.switchButton:setEnabled(false)
            UI.dismantleButton:setEnabled(false)
        end
    end

    UI.mods:destroyChildren()

    for i = 1, widget.data.size do
        local attribute = gemAtelierGetGemAttribute(i)
        local clip = data.object[attribute]
        local grade = 0

        local gem = g_ui.createWidget("GemView", UI.mods)

        gem.base.onHoverChange = function(self, hovered)
            local hover = getHoverRect(0)
            gem.hover:setImageClip(torect(string.format("%d %d %d %d", (50 * hover), 0, 50, 50)))
            gem.hover:setVisible(hovered)
        end

        gem:setEnabled(false)

        if i == 3 then
            gem.base.mod:setImageSource("/modules/game_wheel/images/icons-skillwheel-suprememods")
            gem.base.mod:setSize({ width = 35, height = 35 })
            gem.base.mod:setImageClip(torect(string.format("%d %d %d %d", (35 * clip), 0, 35, 35)))
            gem.base.mod:setMarginBottom(2)
            gem.base.mod:setMarginLeft(2)
            grade = Fragment_Workshop.GreaterFragments[clip] or 0
        else
            gem.base.mod:setImageSource("/modules/game_wheel/images/icons-skillwheel-basicmods")
            gem.base.mod:setImageClip(torect(string.format("%d %d %d %d", (30 * clip), 0, 30, 30)))
            grade = Fragment_Workshop.LesserFragments[clip] or 0
        end

        gem.base:setImageClip(torect(string.format("%d %d %d %d", (50 * grade), 0, 50, 50)))

        local descriptions = nil
        if i == 3 then
            local modifier = Fragment_Workshop.Supreme_Modifiers and Fragment_Workshop.Supreme_Modifiers[clip]
            descriptions = modifier and modifier.descriptions
        else
            local modifier = Fragment_Workshop.Basic_Modifiers and Fragment_Workshop.Basic_Modifiers[clip]
            descriptions = modifier and modifier.descriptions
        end

        gem.descriptions:destroyChildren()
        for _, description in ipairs(descriptions or {}) do
            local widgetDescription = g_ui.createWidget("ModGemDescription", gem.descriptions)
            local values = description.values or {}
            local value = values[grade]
            if value == nil then value = values[grade + 1] end
            widgetDescription:setText(string.format("%s %s", tostring(value or ""), tostring(description.text or "")))
        end

    end
    return true
end

function gemAtelierOnVesselFilter(action)
    local affinityFilter = {
        [0] = "Top Left",
        [1] = "Top Right",
        [2] = "Bottom Left",
        [3] = "Bottom Right"
    }

    local qualityFilter = {
        [0] = "Lesser",
        [1] = "Regular",
        [2] = "Greater"
    }

    Gem_Atelier.UI.affinityFilter:setCurrentOption(affinityFilter[action])
    local widget = WheelDestiny.ActivedGem[action]
    if widget and widget.data then
        local quality = widget.data.object.quality
        Gem_Atelier.UI.qualityFilter:setCurrentOption(qualityFilter[quality])
    end
end

function gemAtelierOnSelectPage(action)
    if not Gem_Atelier.Info then
        return false
    end
    local gems = Gem_Atelier.UI.gems

    if action == 1 then
        Gem_Atelier.Info.actualPage = math.min(Gem_Atelier.Info.pages, Gem_Atelier.Info.actualPage + 1)
    else
        Gem_Atelier.Info.actualPage = math.max(1, Gem_Atelier.Info.actualPage - 1)
    end

    for _, child in ipairs(gems:getChildren()) do
        if child.data and child.data.visible then
            if child.data.page ~= Gem_Atelier.Info.actualPage then
                child:setVisible(false)
            else
                child:setVisible(true)
            end
        end
    end
    gemAtelierUpdatePage()
    return true
end

function gemAtelierUpdatePage()
    setupGemPageButtons()
    local nextButton = Gem_Atelier.UI.nextButton
    local prevButton = Gem_Atelier.UI.prevButton

    Gem_Atelier.Info = Gem_Atelier.Info or { actualPage = 1, pages = 1, count = 0 }
    if Gem_Atelier.Info.actualPage <= 1 then
        Gem_Atelier.Info.actualPage = 1

        prevButton:setEnabled(Gem_Atelier.Info.pages > 1)
        if Gem_Atelier.Info.pages <= 1 then
            nextButton:setEnabled(false)
        else
            nextButton:setEnabled(true)
        end
    else
        prevButton:setEnabled(true)

        if Gem_Atelier.Info.actualPage >= Gem_Atelier.Info.pages then
            nextButton:setEnabled(false)
        else
            nextButton:setEnabled(true)
        end
    end

    local info = Gem_Atelier.Info
    Gem_Atelier.UI.pageCount:setText(string.format("Page %d / %d (%d Gems)", info.actualPage, info.pages, info.count))
end

function gemAtelierGetAffinityName(id)
    local affinities = {
        [0] = "topLeft",
        [1] = "topRight",
        [2] = "bottomLeft",
        [3] = "bottomRight"
    }

    if not affinities[id] then
        return nil
    end

    return affinities[id]
end

function gemAtelierUpdateBalance()
    if not Gem_Atelier.UI then
        return
    end
    local gemData = Gem_Atelier.VocationGems and Gem_Atelier.VocationGems[WheelDestiny.vocation]
    if not gemData then
        return
    end

    local revelation = Gem_Atelier.UI.revelation
    if not revelation then
        return
    end

    local lesser = WheelDestiny.Resources[81] or 0
    local medium = WheelDestiny.Resources[82] or 0
    local greater = WheelDestiny.Resources[83] or 0
    local gold = WheelDestiny.Resources[0] or 0
    local canAttemptReveal = not WheelDestiny.PendingRequest
    local canAct = WheelDestiny.state == 1 and not WheelDestiny.preview and not WheelDestiny.PendingRequest

    for index, value in ipairs(gemData) do
        if index == 1 and revelation.first then
            local enabled = gold >= 125000
            revelation.first:setItemId(value.item)
            revelation.firstText:setText(string.format("%s\nGem (x %d)", value.name, lesser))
            setWidgetTooltip(revelation.first, string.format("%s Gem Token\nRequired to reveal a Lesser Gem in the Gem Atelier.", value.name))
            setWidgetTooltip(revelation.firstGold, "Gold\nReveal cost for this Lesser Gem.")
            revelation.firstGold.value:setEnabled(enabled)
            revelation.firstReveal:setEnabled(canAttemptReveal and enabled and lesser > 0)
        elseif index == 2 and revelation.second then
            local enabled = gold >= 1000000
            revelation.second:setItemId(value.item)
            revelation.secondText:setText(string.format("%s\nGem (x %d)", value.name, medium))
            setWidgetTooltip(revelation.second, string.format("%s Gem Token\nRequired to reveal a Regular Gem in the Gem Atelier.", value.name))
            setWidgetTooltip(revelation.secondGold, "Gold\nReveal cost for this Regular Gem.")
            revelation.secondGold.value:setEnabled(enabled)
            revelation.secondReveal:setEnabled(canAttemptReveal and enabled and medium > 0)
        elseif index == 3 and revelation.third then
            local enabled = gold >= 6000000
            revelation.third:setItemId(value.item)
            revelation.thirdText:setText(string.format("%s\nGem (x %d)", value.name, greater))
            setWidgetTooltip(revelation.third, string.format("%s Gem Token\nRequired to reveal a Greater Gem in the Gem Atelier.", value.name))
            setWidgetTooltip(revelation.thirdGold, "Gold\nReveal cost for this Greater Gem.")
            revelation.thirdGold.value:setEnabled(enabled)
            revelation.thirdReveal:setEnabled(canAttemptReveal and enabled and greater > 0)
        end
    end

    local view = Gem_Atelier.UI.view
    if view and view.selected and view.selected.price and view.selected.price.value then
        local widget, data = selectedGem()
        if widget and data then
            local price = getSwitchPrice(data.object.quality)
            local affordable = gold >= price
            local active = data.selected
            local unlocked = widget.locked and not widget.locked:isOn()
            view.selected.price.value:setText(comma_value(price))
            view.selected.price.value:setEnabled(affordable)
            setWidgetTooltip(view.selected.price, "Gold\nCost to switch the selected gem.")
            view.selected.placeButton:setEnabled(canAct)
            view.selected.switchButton:setEnabled(canAct and unlocked and affordable and not active)
            view.selected.dismantleButton:setEnabled(canAct and unlocked and not active)
        else
            view.selected.placeButton:setEnabled(false)
            view.selected.switchButton:setEnabled(false)
            view.selected.dismantleButton:setEnabled(false)
        end
    end
end

function gemAtelierSetPending(pending)
    gemAtelierUpdateBalance()
end


function gemAtelierRevealGem(type)
    type = tonumber(type)
    local cost = type and REVEAL_COSTS[type]
    if not cost or WheelDestiny.PendingRequest then
        return false
    end

    if WheelDestiny.state ~= 1 or WheelDestiny.preview then
        displayErrorBox(tr("Gem Atelier"), tr("Gem Revelation can only be used inside a temple."))
        return false
    end

    if (WheelDestiny.Resources[0] or 0) < cost.gold then
        displayErrorBox(tr("Gem Atelier"), tr("Not enough gold to reveal this gem."))
        return false
    end

    if (WheelDestiny.Resources[cost.resource] or 0) < 1 then
        displayErrorBox(tr("Gem Atelier"), tr("You do not have this unrevealed gem token."))
        return false
    end

    return WheelDestiny.requestGemAction(1, type)
end

function gemAtelierDismantleGem()
    local widget, data = selectedGem()
    if not widget or data.selected or widget.locked:isOn() or WheelDestiny.PendingRequest or
        WheelDestiny.state ~= 1 or WheelDestiny.preview then
        return false
    end
    return WheelDestiny.requestGemAction(0, tonumber(widget:getId()))
end

function gemAtelierSwitchGem()
    local widget, data = selectedGem()
    if not widget or data.selected or widget.locked:isOn() or WheelDestiny.PendingRequest or
        WheelDestiny.state ~= 1 or WheelDestiny.preview then
        return false
    end
    if (WheelDestiny.Resources[0] or 0) < getSwitchPrice(data.object.quality) then
        return false
    end
    return WheelDestiny.requestGemAction(2, tonumber(widget:getId()))
end

function gemAtelierUpdateModsGrades()
    if not Gem_Atelier.UI or not Gem_Atelier.UI.gems then
        return
    end
    local gems = Gem_Atelier.UI.gems
    for _, widget in pairs(gems:getChildren()) do
        local data = widget.data
        if data then
            for _, child in pairs(widget.gems:getChildren()) do
                local gradeTable = child.modType == 3 and
                    Fragment_Workshop.GreaterFragments or Fragment_Workshop.LesserFragments
                local grade = tonumber(gradeTable and gradeTable[child.clip]) or 0
                child.base:setImageClip(torect(string.format("%d %d %d %d", 50 * grade, 0, 50, 50)))
                child.grade = grade
            end
        end
    end

    local selected = Gem_Atelier.SelectedGem
    if selected and selected.widget and selected.widget.data then
        selected.widget:setChecked(false)
        gemAtelierOnSelectGem(selected.widget)
    end
end

function gemAtelierOnReceiveData(activedGems, revealedGems, vocation)
    if type(revealedGems) ~= "table" or not tonumber(vocation) or not Gem_Atelier.UI then
        return false
    end

    local gems = Gem_Atelier.UI.gems
    if not gems then
        return false
    end

    gemAtelierReset()
    if Fragment_Workshop.resetInventory then
        Fragment_Workshop.resetInventory()
    else
        Fragment_Workshop.Fragments = { [1] = {}, [2] = {} }
    end

    Gem_Atelier.Info = {
        actualPage = 1,
        pages = 1,
        count = 0
    }

    gems:destroyChildren()
    local validWidgets = {}
    local gemConfig = Gem_Atelier.Gems and Gem_Atelier.Gems[tonumber(vocation)]
    for _, object in ipairs(revealedGems) do
        local data = type(object) == "table" and object or {}
        data.index = tonumber(data.index)
        data.affinity = tonumber(data.affinity)
        data.quality = tonumber(data.quality)
        data.locked = data.locked == true or tonumber(data.locked) == 1

        local details = gemConfig and gemConfig[data.affinity] and gemConfig[data.affinity][data.quality]
        local size = getGemsSize(data)
        if data.index ~= nil and data.affinity ~= nil and data.affinity >= 0 and data.affinity <= 3 and
            data.quality ~= nil and data.quality >= 0 and data.quality <= 2 and details and size > 0 then
            local widget = g_ui.createWidget("GemWindow", gems)

            widget.data = {
                size = size,
                details = details,
                page = 1,
                visible = true,
                selected = false,
                object = data
            }

            widget.affinity:setImageClip(torect(string.format("%d %d %d %d", 26 * data.affinity, 0, 26, 26)))
            widget.locked:setOn(data.locked)
            widget:setId(data.index)
            widget.gem:setImageClip(torect(string.format("%d %d %d %d", 32 * details.clip, 0, 32, 32)))
            widget.gems:setWidth(size * 53)

            for i = 1, size do
                local attribute = gemAtelierGetGemAttribute(i)
                local clip = tonumber(data[attribute])
                if clip ~= nil then
                    local gem = g_ui.createWidget("Gem", widget.gems)
                    gem:setId(i)
                    gem.clip = clip
                    gem.affinity = data.affinity
                    gem.quality = data.quality
                    gem.modType = i == 3 and 3 or 2

                    local gradeTable = gem.modType == 3 and
                        Fragment_Workshop.GreaterFragments or Fragment_Workshop.LesserFragments
                    gem.grade = tonumber(gradeTable and gradeTable[clip]) or 0
                    gem.base:setImageClip(torect(string.format("%d %d %d %d", 50 * gem.grade, 0, 50, 50)))

                    local fragmentIndex = gem.modType == 3 and 1 or 2
                    Fragment_Workshop.Fragments[fragmentIndex][clip] =
                        (Fragment_Workshop.Fragments[fragmentIndex][clip] or 0) + 1

                    local modImg = gem.modType == 3 and
                        "icons-skillwheel-suprememods" or "icons-skillwheel-basicmods"
                    local clipSize = gem.modType == 3 and 35 or 30
                    gem.base.mod:setImageSource("/modules/game_wheel/images/" .. modImg)
                    gem.base.mod:setImageClip(torect(string.format("%d %d %d %d", clipSize * clip, 0, clipSize, clipSize)))
                    gem.base.mod:setSize({ width = clipSize, height = clipSize })
                    gem.base.mod:setMarginBottom(gem.modType == 3 and 2 or 0)
                    gem.base.mod:setMarginLeft(gem.modType == 3 and 2 or 0)
                end
            end

            table.insert(validWidgets, widget)
        end
    end

    WheelDestiny.SavedActiveGemIndices = normalizeActiveGemIndices(activedGems)
    for affinity = 0, 3 do
        local index = WheelDestiny.SavedActiveGemIndices[affinity]
        local activeGem = index and gems:getChildById(index) or nil
        if activeGem and activeGem.data and activeGem.data.object then
            local actualAffinity = activeGem.data.object.affinity
            if affinity == actualAffinity then
                local side = sides[actualAffinity]
                if side then
                    gemAtelierOnPlaceVessel(activeGem.data, activeGem, side, true)
                end
            end
        end
    end

    if Fragment_Workshop.refreshInventoryCounts then
        Fragment_Workshop.refreshInventoryCounts()
    end

    local view = Gem_Atelier.UI.view
    if view and #validWidgets == 0 then
        view.selectedEmpty:setVisible(true)
        view.selected:setVisible(false)
    end

    Gem_Atelier.Info.count = #validWidgets
    gemAtelierUpdateFilters()
    gemAtelierUpdateBalance()
    WheelDestiny.updateWheelGem()
    if Fragment_Workshop.updateActivedMods then
        Fragment_Workshop.updateActivedMods()
    end
    return true
end


Gem_Atelier.getGemAttribute = gemAtelierGetGemAttribute
Gem_Atelier.onLock = gemAtelierOnLock
Gem_Atelier.updateFilters = gemAtelierUpdateFilters
Gem_Atelier.onSearch = gemAtelierOnSearch
Gem_Atelier.clearSearch = gemAtelierClearSearch
Gem_Atelier.onLockedFilter = gemAtelierOnLockedFilter
Gem_Atelier.onQualityFilter = gemAtelierOnQualityFilter
Gem_Atelier.onAffinityFilter = gemAtelierOnAffinityFilter
Gem_Atelier.reset = gemAtelierReset
Gem_Atelier.onVesselAction = gemAtelierOnVesselAction
Gem_Atelier.onRemoveVessel = gemAtelierOnRemoveVessel
Gem_Atelier.onPlaceVessel = gemAtelierOnPlaceVessel
Gem_Atelier.resetBorderVessel = gemAtelierResetBorderVessel
Gem_Atelier.onSelectGem = gemAtelierOnSelectGem
Gem_Atelier.onVesselFilter = gemAtelierOnVesselFilter
Gem_Atelier.onSelectPage = gemAtelierOnSelectPage
Gem_Atelier.updatePage = gemAtelierUpdatePage
Gem_Atelier.getAffinityName = gemAtelierGetAffinityName
Gem_Atelier.updateBalance = gemAtelierUpdateBalance
Gem_Atelier.setPending = gemAtelierSetPending
Gem_Atelier.revealGem = gemAtelierRevealGem
Gem_Atelier.dismantleGem = gemAtelierDismantleGem
Gem_Atelier.switchGem = gemAtelierSwitchGem
Gem_Atelier.updateModsGrades = gemAtelierUpdateModsGrades
Gem_Atelier.onReceiveData = gemAtelierOnReceiveData
