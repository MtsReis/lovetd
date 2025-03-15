local amora = class('amora')

-- Default settings
local videoW, videoH = love.window.getDesktopDimensions()
amora.settings = {
  sound = {
    __tweakable = {"sVolume", "mVolume"},
    sVolume = 70,
    mVolume = 80,
  },

  video = {
    __tweakable = {"w", "h", "vsync", "fullscreen"},
    w = videoW * .9, -- Leave 10% of screen unused
    h = videoH * .9,
    vsync = true,
    fullscreen = false
  },

  preferences = {
    __tweakable = {"locale"},
    locale = nil
  }
}

-- Update video settings with the values that user defined
function amora:updateVideo()
  love.window.setMode(self.settings.video.w, self.settings.video.h, {
    fullscreen = self.settings.video.fullscreen,
    vsync = self.settings.video.vsync,
    resizable = true,
    minwidth = 640,
    minheight = 420
  })
end

function amora:setLocale(newLocale, ...)
  if i18n.isLocaleLoaded(newLocale) then
    log.trace(string.format("Locale '%s' already loaded into the system", newLocale))
  else
    log.trace(string.format("Trying to load system locale '%s'", newLocale))

    local data
    if pcall(function ()
      data = assert(require('system.i18n.'..newLocale))
    end) then
      i18n.load(data)
    else
      log.error(string.format("Locale '%s' not found", newLocale))
      return
    end
  end

  log.trace(string.format("Changing system locale from '%s' to '%s'", self.settings.preferences.locale, newLocale))
  self.settings.preferences.locale = newLocale
  i18n.setLocale(newLocale, ...)
end

function amora:ouch()
  log.warn("Trying to forcefully terminate execution. Unsaved modifications might be lost D:")
  os.exit()
end

return amora
