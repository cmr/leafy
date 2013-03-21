local lpeg = require "lpeg"

local M = {}

local function split(path)
	local sep = lpeg.P('/')
	local elem = lpeg.C((1 - sep)^0)
	local p = elem * (sep * elem)^0
	local t = { lpeg.match(p, path) }
	table.remove(t, 1)
	return t
end

--- Test if obj is callable
local function callable(obj)
	--[[
		An alternative implementation could be:

		local mt = getmetatable(obj)
		return type(obj) == 'function' or mt and mt.__call ~= nil

		Which is more concise (but not more readable, I think).
		It doesn't perform as well, either. See bench_callable.lua. On this
		hardware, it's 0.68s versus 0.72s. Not a decision maker, but that
		coupled with readability seals the deal.
	]]

	if type(obj) == 'function' then
		return true
	else
		local mt = getmetatable(obj)
		if mt and mt.__call then
			return true
		end
	end
	return false
end

---
-- Receives a routing table and a path, and returns the function
-- corresponding to that path.
--
-- If there were any leftover path segments, they are returned as well,
-- joined with a / character (including a preceeding one!)

function M.route(rtab, path)
	local node = rtab
	local spath = split(path)
	for i, v in ipairs(spath) do
		if type(node) == "table" then
			if rawget(node, v) then
				node = node[v]
			else
				return node[v], '/' .. table.concat(spath, '/', i + 1)
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
