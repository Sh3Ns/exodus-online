g_extendedtooltip = {}
local toolTipLabel, currentHoveredWidget = nil
local BASE_WIDTH = 90
local BASE_HEIGHT = 34
local tooltipWidth = 0
local tooltipWidthBase = BASE_WIDTH
local tooltipHeight = BASE_HEIGHT
local longestString = 0
local Styles = {
	{
		color = "#C8C8C8",
		clips = {
			0,
			34,
			68
		}
	},
	{
		color = "#8888FF",
		clips = {
			102,
			136,
			170
		}
	},
	{
		color = "#FAC234",
		clips = {
			204,
			238,
			272
		}
	},
	{
		color = "#4AE63A",
		clips = {
			306,
			340,
			374
		}
	},
	{
		color = "#B54BFF",
		clips = {
			510,
			544,
			578
		}
	},
	{
		color = "#3BB5F7",
		clips = {
			612,
			646,
			680
		}
	},
	{
		color = "#F7C83B",
		clips = {
			714,
			748,
			782
		}
	},
	{
		color = "#F28518",
		clips = {
			816,
			850,
			884
		}
	}
}

local function moveToolTip(first)
	if not first and (not toolTipLabel:isVisible() or toolTipLabel:getOpacity() < 0.1) then
		return 
	end

	local pos = g_window.getMousePosition()
	local windowSize = g_window.getSize()
	local labelSize = toolTipLabel:getSize()
	pos.x = pos.x + 1
	pos.y = pos.y + 1

	if windowSize.width - (pos.x + labelSize.width) < 10 then
		pos.x = pos.x - labelSize.width - 3
	else
		pos.x = pos.x + 10
	end

	if windowSize.height - (pos.y + labelSize.height) < 10 then
		pos.y = pos.y - labelSize.height - 3
	else
		pos.y = pos.y + 10
	end

	toolTipLabel:setPosition(pos)

	return 
end

local function onWidgetStyleApply(widget, styleName, styleNode)
	if styleNode.extendedTooltip then
		widget.extendedTooltip = styleNode.extendedTooltip
	end

	return 
end

g_extendedtooltip.init = function ()
	connect(UIWidget, {
		onStyleApply = onWidgetStyleApply
	})
	addEvent(function ()
		toolTipLabel = g_ui.createWidget("ExtendedTooltip", rootWidget)

		toolTipLabel:setId("extendedToolTip")
		toolTipLabel:hide()

		return 
	end)

	return 
end
g_extendedtooltip.terminate = function ()
	disconnect(UIWidget, {
		onStyleApply = onWidgetStyleApply
	})

	currentHoveredWidget = nil

	toolTipLabel:destroy()

	toolTipLabel = nil
	g_extendedtooltip = nil

	return 
end

local function addTitle(title, resize)
	if not toolTipLabel then
		return 
	end

	toolTipLabel.title:setText(title)

	if resize then
		toolTipLabel.title:setTextAutoResize(true)

		local textSize = toolTipLabel.title:getTextSize()
		tooltipWidth = tooltipWidthBase + textSize.width
	end

	return 
end

local function addSingleString(text, resize)
	local label = g_ui.createWidget("ExtendedTooltipLabel", toolTipLabel.texts)

	label.setColor(label, "#8888FF")

	if resize then
		toolTipLabel:setWidth(math.max(580, tooltipWidth))
		label.setTextWrap(label, true)
		label.setTextAutoResize(label, true)
		label.setText(label, text)

		local textSize = label.getTextSize(label)

		if longestString == 0 then
			longestString = textSize.width

			if tooltipWidth < tooltipWidthBase + longestString then
				tooltipWidth = tooltipWidthBase + longestString
			end

			label.addAnchor(label, AnchorTop, "parent", AnchorTop)
		end

		tooltipHeight = tooltipHeight + textSize.height
	else
		label.setText(label, text)

		local textSize = label.getTextSize(label)

		if longestString == 0 then
			longestString = textSize.width

			if tooltipWidth < tooltipWidthBase + longestString then
				tooltipWidth = tooltipWidthBase + longestString
			end

			label.addAnchor(label, AnchorTop, "parent", AnchorTop)
		elseif longestString < textSize.width then
			longestString = textSize.width
			tooltipWidth = (tooltipWidthBase + longestString) - 14
		end

		tooltipHeight = tooltipHeight + textSize.height
	end

	return 
end

g_extendedtooltip.display = function (tooltip)
	local title = tooltip.title
	local texts = tooltip.texts

	if title == nil or title.len(title) == 0 then
		return 
	end

	if not toolTipLabel then
		return 
	end

	tooltipWidth = 0
	longestString = 0
	tooltipWidthBase = BASE_WIDTH
	tooltipHeight = BASE_HEIGHT

	toolTipLabel.texts:destroyChildren()

	local headerLeft = toolTipLabel:recursiveGetChildById("header-left")
	local headerMid = toolTipLabel:recursiveGetChildById("header-middle")
	local headerRight = toolTipLabel:recursiveGetChildById("header-right")

	headerLeft.setImageClip(headerLeft, {
		width = 32,
		height = 34,
		x = 0,
		y = Styles[tooltip.style].clips[1]
	})
	headerMid.setImageClip(headerMid, {
		width = 32,
		height = 34,
		x = 0,
		y = Styles[tooltip.style].clips[2]
	})
	headerRight.setImageClip(headerRight, {
		width = 30,
		height = 34,
		x = 0,
		y = Styles[tooltip.style].clips[3]
	})
	toolTipLabel.title:setColor(Styles[tooltip.style].color)
	addTitle(title, true)

	for _, t in ipairs(texts) do
		addSingleString(t, 80 < t.len(t))
	end

	tooltipHeight = math.max(tooltipHeight, 52)

	toolTipLabel:setWidth(tooltipWidth)
	toolTipLabel:setHeight(tooltipHeight)
	toolTipLabel:show()
	toolTipLabel:raise()
	toolTipLabel:enable()
	g_effects.fadeIn(toolTipLabel, 100)
	moveToolTip(true)
	connect(rootWidget, {
		onMouseMove = moveToolTip
	})

	return 
end
g_extendedtooltip.hide = function ()
	g_effects.fadeOut(toolTipLabel, 100)
	disconnect(rootWidget, {
		onMouseMove = moveToolTip
	})

	return 
end
UIWidget.setExtendedTooltip = function (self, title, texts, style)
	self.extendedTooltip = {
		title = title,
		texts = texts,
		style = style
	}

	return 
end
UIWidget.removeExtendedTooltip = function (self)
	self.extendedTooltip = nil

	return 
end
UIWidget.getExtendedTooltip = function (self)
	return self.extendedTooltip
end

g_extendedtooltip.init()
connect(g_app, {
	onTerminate = g_extendedtooltip.terminate
})

return 