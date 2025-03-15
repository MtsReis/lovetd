-- Module responsible for saving and loading files
local Persistence = class("Persistence")

function Persistence.saveINI(data, dir, tweakableOnly)
	data = data or amora.settings
	dir = dir or "settings.cfg"
	tweakableOnly = (tweakableOnly ~= false) or false -- True as default value

	local success, message = lip.save(dir, data, tweakableOnly)

	if not success then
		log.warn(message)
	end
end

function Persistence.loadSettings(dir)
	dir = dir or "settings.cfg"

	-- Check whether the specified file exists
	if love.filesystem.getInfo(dir) ~= nil then
		local userSettings = lip.load(dir) -- Load user settings

		-- Iterate over INI sections
		for section, sectionValue in pairs(userSettings) do
			if type(sectionValue) == "table" and amora.settings[section] ~= nil then
				-- Load fields in the section if it has tweakable values
				if amora.settings[section]["__tweakable"] ~= nil then
					for settingKey, settingValue in pairs(sectionValue) do
						-- Only load the key if it's tweakable
						if pl.tablex.find(amora.settings[section]["__tweakable"], settingKey) ~= nil then
							amora.settings[section][settingKey] = settingValue
						end
					end
				end
			end
		end
	end
end


--[[
Load and return .tds files

name:<name>
bgm:<musicfilename>
width:<number>
tileW:<number>
tileY:<number>
;
0 0 0 0 0 0 9 8 90 78 9 78
0 2 8 0 3 0 9 8 90 78 9 78
0 0 0 0 0 0 9 8 90 78 9 78
3 5 4 0 0 0 9 8 90 78 9 78
;
0 0 0 0 0 0 9 8 90 78 9 78
0 2 8 0 3 0 9 8 90 78 9 78
0 0 0 0 0 0 9 8 90 78 9 78
3 5 4 0 0 0 9 8 90 78 9 78
]]
function Persistence.loadScenario(fileName)
	local dir = "scenarios/"
	local fileExt = ".tds"
	local path = dir .. fileName .. fileExt

	log.info("Attempting to load scenario '%(name)s'" % { name = fileName })

	if (type(fileName) ~= "string") or (love.filesystem.getInfo(path) == nil) then
		log.error("Unable to load scenario '%(name)s'" % { name = fileName })

		return false
	end

	local data = { layers = {} }
	local validKeys = { name = true, bgm = true, width = true }
	local section = 0

	for line in love.filesystem.lines(path) do
		if line == ";" then
			section = section + 1
		else
			log.debug("Reading section %(sec)d" % { sec = section })

			if section == 0 then
				k, v = line:match("(%w+):(%w+)")

				if k and validKeys[k] then
					data[k] = v
				end
			else
				data.layers[section] = data.layers[section] or {}
				for code in line:gmatch("%d+") do
					table.insert(data.layers[section], tonumber(code))
				end
			end
		end
	end

	log.info("Scenario %(fileName)s loaded successfully" % { fileName = fileName })

	return data
end

return Persistence
