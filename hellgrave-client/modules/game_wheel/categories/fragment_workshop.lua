Fragment_Workshop = Fragment_Workshop or {}
WheelDestiny = WheelDestiny or {}
Gem_Atelier = Gem_Atelier or {}

local MODS_PER_PAGE = 30
local BASIC_FILTER = 2
local SUPREME_FILTER = 3

local GRADE_PRICES = {
    [BASIC_FILTER] = { [0] = 2000000, [1] = 5000000, [2] = 30000000 },
    [SUPREME_FILTER] = { [0] = 5000000, [1] = 12500000, [2] = 75000000 }
}

local GRADE_FRAGMENTS = { [0] = 5, [1] = 15, [2] = 30 }

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

local function number(value, default)
    local result = tonumber(value)
    if result == nil then
        return default or 0
    end
    return result
end

local function formatPrice(value)
    value = math.max(0, number(value))
    if comma_value then
        return comma_value(value)
    end
    local text = tostring(math.floor(value))
    repeat
        local replaced
        text, replaced = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
    until replaced == 0
    return text
end

local function sortedModifierIds(modifiers)
    local ids = {}
    for id, data in pairs(modifiers or {}) do
        id = tonumber(id)
        if id ~= nil and type(data) == "table" then
            table.insert(ids, id)
        end
    end
    table.sort(ids)
    return ids
end

local function descriptionsSearchText(data)
    local values = { tostring(data and data.name or "") }
    for _, description in ipairs(data and data.descriptions or {}) do
        table.insert(values, tostring(description.text or ""))
    end
    return table.concat(values, " "):lower()
end

local function getGrade(filter, clip)
    if filter == SUPREME_FILTER then
        return math.max(0, math.min(3, number(Fragment_Workshop.GreaterFragments and
            Fragment_Workshop.GreaterFragments[clip])))
    end
    return math.max(0, math.min(3, number(Fragment_Workshop.LesserFragments and
        Fragment_Workshop.LesserFragments[clip])))
end

local function getInventoryCount(filter, clip)
    local inventoryIndex = filter == SUPREME_FILTER and 1 or 2
    return number(Fragment_Workshop.Fragments and Fragment_Workshop.Fragments[inventoryIndex] and
        Fragment_Workshop.Fragments[inventoryIndex][clip])
end

local function isActiveModifier(filter, clip)
    for _, gemWidget in pairs(WheelDestiny.ActivedGem or {}) do
        local data = gemWidget and gemWidget.data
        if data and data.object then
            for index = 1, number(data.size) do
                local attribute = Gem_Atelier.getGemAttribute and Gem_Atelier.getGemAttribute(index)
                if attribute and number(data.object[attribute], -1) == clip then
                    local gemFilter = index == 3 and SUPREME_FILTER or BASIC_FILTER
                    if gemFilter == filter then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function setupPageButtons()
    if not Fragment_Workshop.UI then
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
            fragmentWorkshopOnSelectPage(action)
            return true
        end
        buttonWidget.onMouseRelease = function()
            return true
        end
        buttonWidget.onClick = function()
            return true
        end
    end

    bind(Fragment_Workshop.UI.nextButton, 1)
    bind(Fragment_Workshop.UI.prevButton, 2)
end

local function refreshModifierPageWidgets(selectFirst)
    if not Fragment_Workshop.UI or not Fragment_Workshop.UI.mods then
        return nil
    end

    local info = Fragment_Workshop.Info or { actualPage = 1, pages = 1, count = 0 }
    local first = nil
    for _, child in ipairs(Fragment_Workshop.UI.mods:getChildren()) do
        local visible = child.data and child.data.visible and child.data.page == info.actualPage
        child:setVisible(visible and true or false)
        if visible and not first then
            first = child
        end
    end

    if selectFirst then
        fragmentWorkshopOnSelectMod(first)
    end
    return first
end

local function updateEnhanceControls(widget)
    if not Fragment_Workshop.UI or not Fragment_Workshop.UI.grade then
        return false
    end

    local view = Fragment_Workshop.UI.grade
    local data = widget and widget.data
    if not data then
        view.selectedEmpty:setVisible(true)
        view.selected:setVisible(false)
        Fragment_Workshop.SelectedMod = nil
        return false
    end

    local grade = getGrade(data.filter, data.clip)
    data.grade = grade
    local fragmentType = data.filter == SUPREME_FILTER and 2 or 1

    view.selectedEmpty:setVisible(false)
    view.selected:setVisible(true)
    view.selected.name:setText(data.object.name or "Unknown modifier")

    for tierIndex = 1, 4 do
        local descriptions = view.selected["descriptions" .. tierIndex]
        local tier = view.selected["tier" .. tierIndex]
        local supreme = data.filter == SUPREME_FILTER

        tier.mod:setImageSource(supreme and
            "/modules/game_wheel/images/icons-skillwheel-suprememods" or
            "/modules/game_wheel/images/icons-skillwheel-basicmods")
        local clipSize = supreme and 35 or 30
        tier.mod:setImageClip(torect(string.format("%d %d %d %d", data.clip * clipSize, 0, clipSize, clipSize)))
        tier.mod:setSize({ width = clipSize, height = clipSize })
        tier.mod:setMarginBottom(supreme and 2 or 0)
        tier.mod:setMarginLeft(supreme and 3 or 0)

        local unlocked = (grade + 1) >= tierIndex
        tier:setEnabled(unlocked)
        view.selected["backdrop" .. tierIndex]:setChecked(unlocked)
        local line = view.selected["line" .. (tierIndex - 1)]
        if line then
            line:setChecked(unlocked)
        end

        descriptions:destroyChildren()
        for _, object in ipairs(data.object.descriptions or {}) do
            local label = g_ui.createWidget("ModGemDescription", descriptions)
            local value = object.values and object.values[tierIndex - 1]
            label:setText(string.format("%s %s", tostring(value or ""), tostring(object.text or "")))
            label:setTextAutoResize(true)
            label:setEnabled(tierIndex == (grade + 1))
        end
    end

    view.fragment.icon:setImageSource(fragmentType == 2 and
        "/modules/game_wheel/images/icon-fragments-greater" or
        "/modules/game_wheel/images/icon-fragments-lesser")
    setWidgetTooltip(view.gold, "Gold\nCost to enhance the selected modifier.")
    if fragmentType == 2 then
        setWidgetTooltip(view.fragment, "Greater Exalted Fragments\nUsed to enhance Supreme Mods.")
    else
        setWidgetTooltip(view.fragment, "Lesser Exalted Fragments\nUsed to enhance Basic Mods.")
    end

    local maximumGrade = grade >= 3
    view.enchance:setVisible(not maximumGrade)
    view.gold:setVisible(not maximumGrade)
    view.fragment:setVisible(not maximumGrade)

    if not maximumGrade then
        local price = GRADE_PRICES[data.filter] and GRADE_PRICES[data.filter][grade] or 0
        local requiredFragments = GRADE_FRAGMENTS[grade] or 0
        local fragmentResource = fragmentType == 2 and 85 or 84
        local gold = number(WheelDestiny.Resources and WheelDestiny.Resources[0])
        local availableFragments = number(WheelDestiny.Resources and WheelDestiny.Resources[fragmentResource])
        local hasGold = gold >= price
        local hasFragments = availableFragments >= requiredFragments
        local canAct = WheelDestiny.state == 1 and not WheelDestiny.preview and
            not WheelDestiny.PendingRequest

        view.gold.value:setText(formatPrice(price))
        view.gold.value:setEnabled(hasGold)
        view.fragment.value:setText(tostring(requiredFragments))
        view.fragment.value:setEnabled(hasFragments)
        view.enchance:setEnabled(canAct and hasGold and hasFragments)
    end

    Fragment_Workshop.SelectedMod = {
        widget = widget,
        clip = data.clip,
        grade = grade,
        filter = data.filter
    }
    return true
end

local function createModifierWidget(mods, filter, clip, data)
    local widget = g_ui.createWidget("FragmentWindow", mods)
    local supreme = filter == SUPREME_FILTER
    local clipSize = supreme and 35 or 30
    local grade = getGrade(filter, clip)

    widget:setId(string.format("%d_%d", filter, clip))
    widget.base.mod:setImageSource(supreme and
        "/modules/game_wheel/images/icons-skillwheel-suprememods" or
        "/modules/game_wheel/images/icons-skillwheel-basicmods")
    widget.base.mod:setImageClip(torect(string.format("%d %d %d %d", clipSize * clip, 0, clipSize, clipSize)))
    widget.base.mod:setSize({ width = clipSize, height = clipSize })
    widget.base.mod:setMarginBottom(supreme and 2 or 0)
    widget.base.mod:setMarginLeft(supreme and 3 or 0)
    widget.base:setImageClip(torect(string.format("%d %d %d %d", 50 * grade, 0, 50, 50)))

    widget.data = {
        clip = clip,
        filter = filter,
        object = data,
        page = 1,
        visible = true,
        grade = grade,
        search = descriptionsSearchText(data)
    }
    return widget
end

function fragmentWorkshopReset(clearInventory)
    Fragment_Workshop.LesserFragments = {}
    Fragment_Workshop.GreaterFragments = {}
    Fragment_Workshop.SelectedMod = nil
    if clearInventory ~= false then
        Fragment_Workshop.Fragments = { [1] = {}, [2] = {} }
    end
end

function fragmentWorkshopResetInventory()
    Fragment_Workshop.Fragments = { [1] = {}, [2] = {} }
end

function fragmentWorkshopOnReceiveData(lesserFragments, greaterFragments)
    if not Fragment_Workshop.UI or not Fragment_Workshop.UI.mods then
        return false
    end

    fragmentWorkshopReset(false)
    for _, data in pairs(type(lesserFragments) == "table" and lesserFragments or {}) do
        if type(data) == "table" and tonumber(data.bonusId) ~= nil then
            Fragment_Workshop.LesserFragments[tonumber(data.bonusId)] =
                math.max(0, math.min(3, number(data.grade)))
        end
    end
    for _, data in pairs(type(greaterFragments) == "table" and greaterFragments or {}) do
        if type(data) == "table" and tonumber(data.bonusId) ~= nil then
            Fragment_Workshop.GreaterFragments[tonumber(data.bonusId)] =
                math.max(0, math.min(3, number(data.grade)))
        end
    end

    local mods = Fragment_Workshop.UI.mods
    mods:destroyChildren()
    local vocation = number(WheelDestiny.vocation, 1)

    for _, id in ipairs(sortedModifierIds(Fragment_Workshop.Supreme_Modifiers)) do
        local data = Fragment_Workshop.Supreme_Modifiers[id]
        if not data.disabled and (not data.vocations or data.vocations[vocation]) then
            createModifierWidget(mods, SUPREME_FILTER, id, data)
        end
    end
    for _, id in ipairs(sortedModifierIds(Fragment_Workshop.Basic_Modifiers)) do
        local data = Fragment_Workshop.Basic_Modifiers[id]
        if not data.disabled then
            createModifierWidget(mods, BASIC_FILTER, id, data)
        end
    end

    Fragment_Workshop.activeFilter = number(Fragment_Workshop.activeFilter, 1)
    Fragment_Workshop.searchText = Fragment_Workshop.searchText or ""
    fragmentWorkshopRefreshInventoryCounts()
    fragmentWorkshopOnFilter(Fragment_Workshop.activeFilter)
    fragmentWorkshopUpdateActivedMods()
    if Gem_Atelier.updateModsGrades then
        Gem_Atelier.updateModsGrades()
    end
    return true
end

function fragmentWorkshopOnSelectMod(widget)
    if not Fragment_Workshop.UI or not Fragment_Workshop.UI.grade then
        return false
    end

    local mods = Fragment_Workshop.UI.mods
    for _, child in pairs(mods:getChildren()) do
        child:setChecked(child == widget)
    end
    return updateEnhanceControls(widget)
end

function fragmentWorkshopUpdatePage()
    if not Fragment_Workshop.UI then
        return
    end
    setupPageButtons()
    Fragment_Workshop.Info = Fragment_Workshop.Info or { actualPage = 1, pages = 1, count = 0 }
    local info = Fragment_Workshop.Info
    info.pages = math.max(1, number(info.pages, 1))
    info.actualPage = math.max(1, math.min(info.pages, number(info.actualPage, 1)))

    refreshModifierPageWidgets(false)
    Fragment_Workshop.UI.prevButton:setEnabled(info.pages > 1)
    Fragment_Workshop.UI.nextButton:setEnabled(info.pages > 1)
    Fragment_Workshop.UI.pageCount:setText(string.format("Page %d / %d (%d Mods)",
        info.actualPage, info.pages, number(info.count)))
end

function fragmentWorkshopOnSelectPage(action)
    if not Fragment_Workshop.UI or not Fragment_Workshop.Info then
        return false
    end
    local info = Fragment_Workshop.Info
    local previousPage = number(info.actualPage, 1)
    if number(action) == 1 then
        info.actualPage = math.min(info.pages, info.actualPage + 1)
    else
        info.actualPage = math.max(1, info.actualPage - 1)
    end

    refreshModifierPageWidgets(info.actualPage ~= previousPage)
    fragmentWorkshopUpdatePage()
    return true
end

function fragmentWorkshopGetGradePrice(type, grade)
    local filter = number(type) == 2 and SUPREME_FILTER or BASIC_FILTER
    return GRADE_PRICES[filter][number(grade)]
end

function fragmentWorkshopGetGradeFragments(type, grade)
    return GRADE_FRAGMENTS[number(grade)]
end

function fragmentWorkshopOnSearch(text)
    Fragment_Workshop.searchText = tostring(text or "")
    fragmentWorkshopOnFilter(Fragment_Workshop.activeFilter or 1)
end

function fragmentWorkshopClearSearch()
    if not Fragment_Workshop.UI or not Fragment_Workshop.UI.search then
        return false
    end
    Fragment_Workshop.UI.search:clearText()
    Fragment_Workshop.searchText = ""
    fragmentWorkshopOnFilter(Fragment_Workshop.activeFilter or 1)
    return true
end

function fragmentWorkshopOnFilter(option)
    if not Fragment_Workshop.UI or not Fragment_Workshop.UI.mods then
        return false
    end

    option = number(option, 1)
    Fragment_Workshop.activeFilter = option
    local query = tostring(Fragment_Workshop.searchText or ""):lower()
    local first = nil
    local count = 0

    for _, widget in pairs(Fragment_Workshop.UI.mods:getChildren()) do
        local data = widget.data
        local passes = data ~= nil
        if passes and option == 2 then
            passes = data.filter == BASIC_FILTER
        elseif passes and option == 3 then
            passes = data.filter == SUPREME_FILTER
        elseif passes and option == 4 then
            passes = isActiveModifier(data.filter, data.clip)
        elseif passes and option >= 5 and option <= 8 then
            passes = getGrade(data.filter, data.clip) == (option - 5)
        end
        if passes and query ~= "" then
            passes = data.search:find(query, 1, true) ~= nil
        end

        data.visible = passes
        if passes then
            count = count + 1
            data.page = math.ceil(count / MODS_PER_PAGE)
            widget:setVisible(data.page == 1)
            if not first then
                first = widget
            end
        else
            widget:setVisible(false)
        end
    end

    Fragment_Workshop.Info = {
        actualPage = 1,
        pages = math.max(1, math.ceil(count / MODS_PER_PAGE)),
        count = count
    }
    fragmentWorkshopOnSelectMod(first)
    fragmentWorkshopUpdatePage()
    return true
end

function fragmentWorkshopUpdateActivedMods()
    if not Fragment_Workshop.UI or not Fragment_Workshop.UI.mods then
        return
    end
    for _, widget in pairs(Fragment_Workshop.UI.mods:getChildren()) do
        if widget.actived and widget.data then
            widget.actived:setVisible(isActiveModifier(widget.data.filter, widget.data.clip))
        end
    end

    if Fragment_Workshop.activeFilter == 4 then
        fragmentWorkshopOnFilter(4)
    end
end

function fragmentWorkshopRefreshInventoryCounts()
    if not Fragment_Workshop.UI or not Fragment_Workshop.UI.mods then
        return
    end
    for _, widget in pairs(Fragment_Workshop.UI.mods:getChildren()) do
        if widget.data and widget.count then
            local count = getInventoryCount(widget.data.filter, widget.data.clip)
            widget.count:setText(string.format("x %d", count))
            widget.count:setVisible(count > 0)
        end
    end
end

function fragmentWorkshopEnchanceMod()
    local data = Fragment_Workshop.SelectedMod
    if not data or not data.widget or WheelDestiny.PendingRequest or
        WheelDestiny.state ~= 1 or WheelDestiny.preview or data.grade >= 3 then
        return false
    end

    local price = GRADE_PRICES[data.filter] and GRADE_PRICES[data.filter][data.grade]
    local fragments = GRADE_FRAGMENTS[data.grade]
    local resource = data.filter == SUPREME_FILTER and 85 or 84
    if not price or not fragments or number(WheelDestiny.Resources[0]) < price or
        number(WheelDestiny.Resources[resource]) < fragments then
        return false
    end

    return WheelDestiny.requestGemAction(4, data.grade, {
        clip = data.clip,
        filter = data.filter
    })
end

function fragmentWorkshopUpdateBalance()
    if not WheelDestiny.UI or not WheelDestiny.UI.main then
        return
    end
    local lesser = number(WheelDestiny.Resources and WheelDestiny.Resources[84])
    local greater = number(WheelDestiny.Resources and WheelDestiny.Resources[85])
    WheelDestiny.UI.main.lesserFragmentsBalance.value:setText(formatPrice(lesser))
    WheelDestiny.UI.main.greaterFragmentsBalance.value:setText(formatPrice(greater))

    local selected = Fragment_Workshop.SelectedMod
    if selected and selected.widget then
        updateEnhanceControls(selected.widget)
    end
end

function fragmentWorkshopSetPending(pending)
    fragmentWorkshopUpdateBalance()
end

Fragment_Workshop.onReceiveData = fragmentWorkshopOnReceiveData
Fragment_Workshop.onSelectMod = fragmentWorkshopOnSelectMod
Fragment_Workshop.updatePage = fragmentWorkshopUpdatePage
Fragment_Workshop.onSelectPage = fragmentWorkshopOnSelectPage
Fragment_Workshop.getGradePrice = fragmentWorkshopGetGradePrice
Fragment_Workshop.getGradeFragments = fragmentWorkshopGetGradeFragments
Fragment_Workshop.onSearch = fragmentWorkshopOnSearch
Fragment_Workshop.clearSearch = fragmentWorkshopClearSearch
Fragment_Workshop.onFilter = fragmentWorkshopOnFilter
Fragment_Workshop.updateActivedMods = fragmentWorkshopUpdateActivedMods
Fragment_Workshop.refreshInventoryCounts = fragmentWorkshopRefreshInventoryCounts
Fragment_Workshop.enchanceMod = fragmentWorkshopEnchanceMod
Fragment_Workshop.reset = fragmentWorkshopReset
Fragment_Workshop.resetInventory = fragmentWorkshopResetInventory
Fragment_Workshop.updateBalance = fragmentWorkshopUpdateBalance
Fragment_Workshop.setPending = fragmentWorkshopSetPending
