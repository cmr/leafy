package = "leafy"
version = "0.3.0-0"
source = {
   url = "git://github.com/cmr/leafy.git",
   tag = "v0.3.0",
}
description = {
   summary = 'Simple path-based ("URL") router',
   homepage = "http://github.com/cmr/leafy",
   license = "MIT/X11"
}
dependencies = {
   "lua ~> 5.1",
   "lpeg"
}
build = {
	type = "builtin",
	modules = {
		leafy = "leafy.lua"
	}
}
