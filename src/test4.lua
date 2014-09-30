-- Copyright (c) 2014 Loïc Fejoz
-- This file is provided under the MIT License.
-- author(s):
--  * Loïc Fejoz <loic@fejoz.net>
for v = 0, 1, 0.1 do
   engrave(v,
	   translate(320, 320) *
	      morph(v,
		    translate(80,80) * circle(90),
		    circle(80)))
end
