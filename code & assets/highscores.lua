--[[

This file is part of GSS 6473

 GSS 6473 is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 GSS 6473 is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with GSS 6473.  If not, see <http://www.gnu.org/licenses/>.

 ]]

-- SICK: Simple Indicative of Competitive sKill
-- aka libhighscore

local h = {}
h.scores = {}

function h.set(filename, places, name, score)
	h.filename = filename
	h.places = places
	if not h.load() then
		h.scores = {}
		for i = 1, places do
			h.scores[i] = {score, name}
		end
	end
end

function h.load()
	local file = love.filesystem.newFile(h.filename)
	if not love.filesystem.exists(h.filename) or not file:open("r") then return end
	h.scores = {}
	for line in file:lines() do
		local i = line:find('\t', 1, true)
		h.scores[#h.scores+1] = {tonumber(line:sub(1, i-1)), line:sub(i+1)}
	end
	return file:close()
end

local function sortScore(a, b)
	return a[1] > b[1]
end
function h.add(name, score)
print(#h.scores)
	h.scores[#h.scores+1] = {score, name}
	table.sort(h.scores, sortScore)
end

function h.save()
	local file = love.filesystem.newFile(h.filename)
	if not file:open("w") then return end
	for i = 1, #h.scores do
		item = h.scores[i]
		file:write(item[1] .. "\t" .. item[2] .. "\n")
	end
	return file:close()
end

setmetatable(h, {__call = function(self)
	local i = 0
	return function()
		i = i + 1
		if i <= h.places and h.scores[i] then
			return i, unpack(h.scores[i])
		end
	end
end})

highscore = h

return h