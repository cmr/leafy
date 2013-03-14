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
	}, {
		__index = default_baz_func},
		__call = bar_func }
	)
}
```

`route(t, '/')` will return `some_func`, `route(t, '/bar')` will return
`another_func`, `route(t, '/baz')` will return the functable at `t[baz]`,
`route(t, '/baz/bar')` will return `yet_another_func`.

`route(t, '/baz/12')` will return two values, `default_baz_func` and `'/12'`.
This is to allow a web framework to easily handle things such as '/baz/:id' or
the such without dealing with the boring stuff.

Contributing
------------

Issue reports are wonderful, as are pull requests with bug fixes. If you plan
on adding any features, though, open an issue first. leafy is supposed to be
minimal, and for now I don't see anything else it should do. Refinements of
the existing functionality is fine though.
