-- Module responsible for saving and loading files
local Persistence = class('Persistence')

function Persistence.saveINI(data, dir, tweakableOnly)
	data = data or amora.settings
	dir = dir or 'settings.cfg'
	tweakableOnly = (tweakableOnly ~= false) or false -- True as default value

		local success, message = lip.save(dir, data, tweakableOnly)

		if not success then
			log.warn(message)
		end
end

function Persistence.loadSettings(dir)
	dir = dir or 'settings.cfg'

	-- Check whether the specified file exists
	if love.filesystem.getInfo(dir) ~= nil then
		local userSettings = lip.load(dir) -- Load user settings

		-- Iterate over INI sections
		for section, sectionValue in pairs(userSettings) do
			if type(sectionValue) == "table" and amora.settings[section] ~= nil then
				-- Load fields in the section if it has tweakable values
				if amora.settings[section]['__tweakable'] ~= nil then
					for settingKey, settingValue in pairs(sectionValue) do
						-- Only load the key if it's tweakable
						if pl.tablex.find(amora.settings[section]['__tweakable'], settingKey) ~= nil then
							amora.settings[section][settingKey] = settingValue
						end
					end
				end
			end
		end
	end
end

return Persistence
