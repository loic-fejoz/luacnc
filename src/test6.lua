-- Copyright (c) 2014 Loïc Fejoz
-- This file is provided under the MIT License.
-- author(s):
--  * Loïc Fejoz <loic@fejoz.net>

for v = 1, 0.2, -0.2 do
   engrave(v,
	   translate(320, 320) * (scale(1, 2/v) * circle(300)))
end
