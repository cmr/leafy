local router = require "router"

local stub = function() return spy.new(function() end) end

local routing_table = {
	[""] = stub(),
	foo = setmetatable({
		[""] = stub(),
	}, {__index = {bar=stub()}}),
	bar = {
		baz = {
			quux = stub()
		}
	}
}

describe("callable", function()
	it("returns true for functions", function()
		assert.is_true(router.callable(function() end))
	end)

	it("returns true for tables with metaevent __call", function()
		assert.is_true(router.callable(setmetatable({}, {__call = function() end})))
	end)

	it("returns true for stubs", function()
		assert.is_true(router.callable(stub()))
	end)

	it("returns false for all other values", function()
		local values = {1, 0, true, false, {}, "foo"}
		for _, v in ipairs(values) do
			assert.is_not_true(router.callable(v))
		end
		assert.is_not_true(router.callable(nil))
	end)
end)

describe("split", function()
	local split = router.split
	it("splits a path into its components", function()
		assert.same(split("/foo/bar"), {"foo", "bar"})
		assert.same(split("/foo/bar/"), {"foo", "bar", ""})
	end)
end)

describe("router", function()
	local route = router.route
	it("resolves the root directory", function()
		route(routing_table, "/")()
		assert.spy(routing_table[""]).called()
	end)
	it("resolves deep path segments", function()
		route(routing_table, "/bar/baz/quux")()
		assert.spy(routing_table.bar.baz.quux).called()
	end)
	it("hands off unmatched paths", function()
		route(routing_table, "/foo/bar/baz")()
		assert.spy(getmetatable(routing_table.foo).__index.baz).called()
	end)
end)
