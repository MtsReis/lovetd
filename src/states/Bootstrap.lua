local Bootstrap = class('Bootstrap')

function Bootstrap.load()
  -----------------------------------------------
  --                  settings
  -----------------------------------------------
  -- Load the user .cfg files
  Persistence.loadSettings()

  -- Update video with the user settings
  amora:updateVideo()

  -----------------------------------------------
  --                    i18n
  -----------------------------------------------
  i18n.load(require('system.i18n.en')) -- Default locale
  -- Load user defined locale
  if amora.settings.preferences.locale ~= nil then
    amora:setLocale(amora.settings.preferences.locale)
  end


  -----------------------------------------------
  --                   states
  -----------------------------------------------
  if amora.debugMode then
    state.add(require 'states.Debug', "Debug", 10)
  end

  state.add(require 'states.Root', "Root", 1)

  -----------------------------------------------
  --                  wrappers
  -----------------------------------------------
  --
  pd = pl.pretty.dump
  pw = pl.pretty.write

  -----------------------------------------------
  --                    utils
  -----------------------------------------------
  --[[ Expand the string std table to perform a string interpolation
  by using the mod operator (%).
  e.g.: "%(val)7.2f% float assigned to %(var)s" % {val = 33.1337, var = "progress"}
  ]]
  local function interp(s, tab)
    return (s:gsub('%%%((%a%w*)%)([-0-9%.]*[cdeEfgGiouxXsq])',
              function(k, fmt) return tab[k] and ("%"..fmt):format(tab[k]) or
                  '%('..k..')'..fmt end))
  end
  getmetatable("").__mod = interp
end

function Bootstrap.enable()
  if amora.debugMode then
    state.enable("Debug")
  end

  state.enable("Root")
end

function Bootstrap.update()
  -- End of boot
  state.disable("Bootstrap")
  state.destroy("Bootstrap")
end

return Bootstrap
