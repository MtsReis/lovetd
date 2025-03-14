--[[
	Copyright (c) 2012 Carreras Nicolas

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]
--- Lua INI Parser (modified by Luna Engine Team).
-- It has never been that simple to use INI files with Lua.
--@author Dynodzzo

local LIP = {};

--- Returns a table containing all the data from the INI file.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
function LIP.load(fileName)
	if (type(fileName) ~= 'string') then log.debug('Parameter "fileName" must be a string.'); end;
	if (love.filesystem.getInfo(fileName) == nil) then log.error('Error loading file: ' .. fileName); return {}; end;

	local data = {};
	local section;
	for line in love.filesystem.lines(fileName) do
		local tempSection = line:match('^%[([^%[%]]+)%]$');
		if(tempSection)then
			section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
			data[section] = data[section] or {};
		end
		local param, value = line:match("^([%w|_']+)%s-=%s-(.+)$");
		if(param and value ~= nil)then
			if(tonumber(value))then
				value = tonumber(value);
			elseif(value == 'true')then
				value = true;
			elseif(value == 'false')then
				value = false;
			end
			if(tonumber(param))then
				param = tonumber(param);
			end
			data[section][param] = value;
		end
	end
	return data;
end

--- Saves all the data from a table to an INI file.
--@param fileName The name of the INI file to fill. [string]
--@param data The table containing all the data to store. [table]
--@param tweakableOnly Define if only tweakable parameters can be stored. [boolean]
function LIP.save(fileName, data, tweakableOnly)
	if (type(fileName) ~= 'string') then return false, 'Parameter "fileName" must be a string.'; end;
	if (type(data) ~= 'table') then return false, 'Parameter "data" must be a table.'; end;
	if (type(tweakableOnly) ~= 'boolean') then return false, 'Parameter "tweakableOnly" must be boolean.'; end;
	local contents = '';
	for section, param in pairs(data) do
		if (not tweakableOnly or param['__tweakable'] ~= nil) then
			contents = contents .. ('[%s]\n'):format(section);

			if (tweakableOnly) then
				for _, key in pairs(param['__tweakable']) do
					if param[key] ~= nil then
						contents = contents .. ('%s=%s\n'):format(key, tostring(param[key]));
					end
				end
			else
				for key, value in pairs(param) do
					contents = contents .. ('%s=%s\n'):format(key, tostring(value));
				end
			end

			contents = contents .. '\n';
		end
	end

	return love.filesystem.write(fileName, contents)
end

return LIP;
