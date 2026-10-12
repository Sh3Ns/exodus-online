buttonsWindow = nil
contentsPanel = nil

function init()
  buttonsWindow = g_ui.loadUI('buttons', modules.game_interface.getRightPanel())
  buttonsWindow:disableResize()
  buttonsWindow:setup()
  contentsPanel = buttonsWindow.contentsPanel
  if not buttonsWindow.forceOpen or not contentsPanel.buttons then
    buttonsWindow:close()
  end
end

function terminate()
  buttonsWindow:destroy()
end

function takeButtons(buttons)
  if not buttonsWindow.forceOpen or not contentsPanel.buttons then return end
  for i, button in ipairs(buttons) do
    takeButton(button, true)
  end
  updateOrder()
end

function takeButton(button, dontUpdateOrder)
  if not buttonsWindow.forceOpen or not contentsPanel.buttons then return end
  button:setParent(contentsPanel.buttons)
  if not dontUpdateOrder then
    updateOrder()
  end
end

function updateOrder()
   local children = contentsPanel.buttons:getChildren()
   table.sort(children, function(a, b)
    local aIndex = a.index or 1000
    local bIndex = b.index or 1000
    if aIndex == bIndex then
      return a:getId() < b:getId()
    end
    return aIndex < bIndex
   end)
   contentsPanel.buttons:reorderChildren(children)
   local visibleCount = 0
   for _, child in ipairs(children) do
    if child:isVisible() then
      visibleCount = visibleCount + 1
    end
   end
   if visibleCount > 6 and buttonsWindow:getHeight() < 30 then
    buttonsWindow:setHeight(buttonsWindow:getHeight() + 22)
   end
end
