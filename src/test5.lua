-- Copyright (c) 2014 Loïc Fejoz
-- This file is provided under the MIT License.
-- author(s):
--  * Loïc Fejoz <loic@fejoz.net>

engrave(1,
	translate(320, 320) *
	   shell(10,
		 blended_union(1,
			       translate(80,80) * circle(90),
			       circle(80))))
