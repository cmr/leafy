-- microbenchmark to test speed of callable()

local callable = require "leafy".callable

local f = function() end
local ft = setmetatable({}, {__call = function() end})

for i=1,1000000 do
	callable(f)
	callable(ft)
end
