package = "leafy"
version = "0.1-2"
source = {
   url = "git://github.com/cmr/leafy.git",
   tag = "0.1"
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
