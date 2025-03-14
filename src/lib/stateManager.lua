_slotState = _slotState or {states = {}}
local StateManager = {}

--[[ Metamethods ]]
local latestIndex
local states = {}
local indices = {}

local pairsIter = function(table)
  local function iter(t, iSet)
    local trueIndex = iSet._trueIndex - 1
    local invIndex = #indices - trueIndex + 1

    if indices[trueIndex] ~= nil then
      return {
        _trueIndex = trueIndex,
        k = indices[trueIndex],
        i = invIndex
      }, t[indices[trueIndex]]
    end
  end

  return iter, table, {_trueIndex = #indices + 1}
end

setmetatable(_slotState.states, {
  __newindex = function(t, k, v)
    if t[k] ~= nil and v ~= nil then
      log.warn(string.format("Key '%s' is already taken", k))
      k = "auto"
    end

    if type(k) == "number" and k == math.floor(k) then
      states[k] = v

      if v ~= nil then
        table.insert(indices, k)
        table.sort(indices, function(a, b) return a > b end)
        latestIndex = k
      else
        for i = 1, #indices do
          if indices[i] == k then
            table.remove(indices, i)
            latestIndex = nil
            break
          end
        end
      end
    else
      assert(
        k == "auto",
        string.format("States can't have a non-integer index ([%s] => %s)", type(k), k)
      )

      for i = 1, #states + 1 do
        local invIndex = #indices - i + 1 -- +1 since arrays start at 1
        if i ~= indices[invIndex] then
          table.insert(indices, invIndex + 1, i)
          states[i] = v
          latestIndex = i
          break
        end
      end
    end

  end,

  __index = function (_, k)
    return states[k]
  end,

  __ipairs = pairsIter,
  __pairs = pairsIter,

  __len = function()
    if indices[1] then
      return indices[1]
    end

    return 0
  end
})

setmetatable(states, {
  __len = function()
    if indices[1] then
      return indices[1]
    end

    return 0
  end
})

function StateManager.add(class, id, index)
  index = index == nil and "auto" or index

  _slotState.states[index] = class

  class._enabled = false
  class._id = id

  log.trace(string.format("Loading state '%s'", id))
  local _ = class.load and class:load() -- Run if exists

   return latestIndex
end

function StateManager.isEnabled(id)
  for _, state in pairs(_slotState.states) do
    if state._id == id then
      return state._enabled
    end
  end
end

function StateManager.get(id)
  for _, state in pairs(_slotState.states) do
    if state._id == id then
      return state
    end
  end
end

function StateManager.enable(id)
  for _, state in pairs(_slotState.states) do
    if state._id == id and not state._enabled then
      log.trace(string.format("Starting state '%s'", id))
      local _ = state.enable and state:enable() -- Run if exists
      state._enabled = true
      return state._enabled
    end
  end

  log.warn(string.format("State '%s' was not found", id))
  return false
end

function StateManager.disable(id)
  for _, state in pairs(_slotState.states) do
    if state._id == id then
      if state._enabled then
        local disabled = true

        if state.disable and state:disable() == false then
          log.info(string.format("State '%s' isn't ready to be disabled", id))
          disabled = false
        end

        if disabled then
          log.trace(string.format("Disabling state '%s'", id))
          state._enabled = false
        end
      end

      return not state._enabled
    end
  end

  log.warn(string.format("State '%s' was not found", id))
  return false
end

function StateManager.toggle(id)
  for _, state in pairs(_slotState.states) do
    if state._id == id then
      if state._enabled then
        return StateManager.disable(id)
      else
        return StateManager.enable(id)
      end
    end
  end
end

function StateManager.destroy(id)
  for iSet, state in pairs(_slotState.states) do
    if state._id == id then
      if StateManager.disable(id) then -- Try to disable the state first
        log.trace(string.format("Destroying state '%s'", id))
        local _ = state.close and state:close() -- Run if exists
        _slotState.states[iSet.k] = nil
      end

      return _slotState.states[iSet.k] == nil
    end
  end

  log.warn(string.format("State '%s' was not found", id))
  return false
end

return StateManager
