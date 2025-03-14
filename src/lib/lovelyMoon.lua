local lovelyMoon = {}

function lovelyMoon.update(dt)
  for _, state in pairs(_slotState.states) do
    if state and state._enabled and state.update then
      state:update(dt)
    end
  end
end

function lovelyMoon.draw()
  for _, state in pairs(_slotState.states) do
    if state and state._enabled and state.draw then
      state:draw()
    end
  end
end

function lovelyMoon.keypressed(key, scancode, isrepeat)
  for _, state in pairs(_slotState.states) do
    if state and state._enabled and state.keypressed then
      state:keypressed(key, scancode, isrepeat)
    end
  end
end

function lovelyMoon.keyreleased(key, scancode)
  for _, state in pairs(_slotState.states) do
    if state and state._enabled and state.keyreleased then
      state:keyreleased(key, scancode)
    end
  end
end

function lovelyMoon.textinput(text)
  for _, state in pairs(_slotState.states) do
    if state and state._enabled and state.textinput then
      state:textinput(text)
    end
  end
end

function lovelyMoon.mousemoved(x, y, dx, dy, istouch)
  for _, state in pairs(_slotState.states) do
    if state and state._enabled and state.mousemoved then
      state:mousemoved(x, y, dx, dy, istouch)
    end
  end
end

function lovelyMoon.mousepressed(x, y, button, istouch, presses)
  for _, state in pairs(_slotState.states) do
    if state and state._enabled and state.mousepressed then
      state:mousepressed(x, y, button, istouch, presses)
    end
  end
end

function lovelyMoon.mousereleased(x, y, button, istouch, presses)
  for _, state in pairs(_slotState.states) do
    if state and state._enabled and state.mousereleased then
      state:mousereleased(x, y, button, istouch, presses)
    end
  end
end

function lovelyMoon.wheelmoved(x, y)
  for _, state in pairs(_slotState.states) do
    if state and state._enabled and state.wheelmoved then
      state:wheelmoved(x, y)
    end
  end
end

return lovelyMoon
