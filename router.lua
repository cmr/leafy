local lpeg = require "lpeg"
local re = require "re"

local utils = require 'pl.utils'

local inspect = require 'inspect'

local M = {}

local function split(path)
	local sep = lpeg.P('/')
	local elem = lpeg.C((1 - sep)^0)
	local p = elem * (sep * elem)^0
	local t = { lpeg.match(p, path) }
	table.remove(t, 1)
	return t
end

local function callable(obj)
	local t = type(obj)
	if t == 'function' then
		return true
	else
		local mt = getmetatable(obj)
		if mt and mt.__call then
			return true
		end
	end
	return false
end

--[[
--	Receives a routing table and a path, and returns the function
--	corresponding to that path
--]]
function M.route(rtab, path)
	local node = rtab
	local spath = split(path)
	for i, v in ipairs(spath) do
		if node == nil then
			return nil
		end

    	print(i, v)
		if callable(node) and i == #spath then
			return node
		elseif type(node) == "table" then
			if rawget(node, v) then
				node = node[v]
			else
				return node[v], table.concat(spath, '/', i)
			end
		end
	end
	-- if we get here, we have exhausted the tree, but have a node
	if callable(node) then
		return node
	else
		-- but that node is invalid :(
		return nil
	end
end

M.callable = callable
M.split = split

return M
