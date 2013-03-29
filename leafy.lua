local lpeg = require 'lpeg'

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

		And, of course, luajit makes it irrelevant. Readability wins.
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

function M.route(rtab, path, extra)
	local node = rtab
	local t = type(path)
	local spath

	if t == 'string' then
		spath = split(path)
	elseif t == 'table' then
		if next(path) == nil then
			path = {''}
		end
		spath = path
	else
		error('String or table must be passed as path (arg 2)')
	end

	for i, v in ipairs(spath) do
		if type(node) == 'table' then
			if rawget(node, v) then
				node = node[v]
			else
				-- No nodes left in the table, call out to the metatable
				local remainder = {}
				for j = i, #spath do
					table.insert(remainder, spath[j])
				end
				local mt = getmetatable(node)
				if mt then
					local cont, result = mt.default(remainder, extra)
					if cont then
						node = result
					else
						return result, remainder
					end
				else
					-- there is no default handler, no result
					return nil
				end
			end
		else
			break
		end
	end
	-- if we get here, we have exhausted the tree, but might have a node
	if callable(node) then
		return node
	else
		-- ok, we don't have a valid node. maybe there's a default?
		local mt = getmetatable(node)
		if mt and mt.default then
			-- don't do lookup, there are no path elements left
			local _, func = mt.default({}, extra)
			return func, {}
		end
		-- nope, no result at all
		return nil
	end
end

M.callable = callable
M.split = split

return M
