local router = require "leafy"

local stub = function() return spy.new(function() end) end

local called = 0

local routing_table = setmetatable({
	[""] = stub(),
	foo = setmetatable({
		[""] = stub(),
	}, {
		__index = {
			bar = stub(),
		}
	}),
	bar = {
		baz = {
			quux = stub(),
			quux2 = stub(),
		}
	},
	baz = "not a function!",
	-- because a stub is a functable
	quux = function() called = called + 1 end,
}, {
	__index = function() end,
})

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
		route(routing_table, "/quux")()
		assert.equals(called, 1)
	end)
	it("also accepts a sequence as a path", function()
		route(routing_table, {"bar", "baz", "quux"})()
		assert.spy(routing_table.bar.baz.quux).called(2)
		route(routing_table, {})()
		assert.spy(routing_table[""]).called(2)
		route(routing_table, {""})()
		assert.spy(routing_table[""]).called(3)
	end)
	it("hands off unmatched paths", function()
		local c = {route(routing_table, "/foo/bar/baz")}
		c[1]()
		assert.same({"baz"}, c[2])
		assert.spy(getmetatable(routing_table.foo).__index.bar).called()
	end)
	it("returns nil for non-function leafs", function()
		assert.is_nil(route(routing_table, "/baz"))
	end)
	it("returns nil for nonexistent paths", function()
		assert.is_nil(route(routing_table, "/nonexistent"))
		assert.is_nil(route(routing_table, "/a/b/c/d/e/f"))
	end)
	it("errors on non-string/table arguments", function()
		assert.has_error(function() route(routing_table, 123) end)
	end)
end)
