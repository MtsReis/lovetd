-- Core libs
pl = require 'lib.pl.import_into'() -- On-demand lib loading into pl
class = require 'lib.middleclass'.class
lip = require 'lib.LIP'
log = require 'lib.log'
i18n = require 'lib.i18n'
state = require 'lib.stateManager'

pl.stringx.import() -- Bring the stringx methods into the standard string table

-- Init specific config
log.level = "warn"

function love.conf(t)
  t.identity = "rtslovejam"
  t.version = "11.5"

  t.window.title = "RTS Love"
  t.window.resizable = true

  t.externalstorage = true
end