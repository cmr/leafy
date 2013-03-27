leafy
=====

[![travis-ci status](https://secure.travis-ci.org/cmr/leafy.png)](http://travis-ci.org/#!/cmr/leafy/builds)

leafy implements a simple path-based router. Given a table such as:

Example
-------

```lua
t = {
	[""] = some_func,
	bar = another_func,
	baz = setmetatable({
		bar = yet_another_func
	}, { default = default_baz_func })
}
```

`route(t, '/')` will return `some_func`, `route(t, '/bar')` will return
`another_func`, `route(t, '/baz')` will return the functable at `t[baz]`,
`route(t, '/baz/bar')` will return `yet_another_func`.

`route(t, '/baz/12')` will call `default_baz_func` with `{'12'}`.
default_baz_func would return either `true, table`, where table is used to
continue lookup, or `false, callable`, in which case the callable and whatever
unresolved path segments were left is returned.

See test_busted.lua for a very thorough example.

Contributing
------------

Issue reports are wonderful, as are pull requests with bug fixes. If you plan
on adding any features, though, open an issue first. leafy is supposed to be
minimal, and for now I don't see anything else it should do. Refinements of
the existing functionality is fine though.
