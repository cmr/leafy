local router = require "./leafy"

local stub = function() return spy.new(function() end) end

local called = 0

local barstub = stub()
local stubtwo = stub()
local unimstub = stub()

local routing_table = {
	[""] = stub(),
	foo = setmetatable({
		[""] = stub(),
	}, {
		default = function(path)
			return true, {baz = barstub}
		end
	}),
	bar = {
		baz = setmetatable({
			quux = stub(),
			quux2 = stub(),
		}, {
			default = function(path)
				return false, stubtwo
			end
		})
	},
	baz = "not a function!",
	-- because a stub is a functable
	quux = function() called = called + 1 end,
	unimaginative = setmetatable({}, {default = function() return false, unimstub end}),
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
	it("continues lookup through a default handler", function()
		local c = route(routing_table, "/foo/bar/baz")
		c()
		assert.spy(barstub).called()
	end)
	it("returns function + unresolved path segments for some handlers", function()
		local func, remainder = route(routing_table, "/bar/baz/undef/extra")
		func()
		assert.spy(stubtwo).called()
		assert.same({"undef", "extra"}, remainder)
	end)
	it("calls the default handler when there aren't unresolved segments but no routes defined", function()
		local func = route(routing_table, "/unimaginative")
		func()
		assert.spy(unimstub).called()
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
