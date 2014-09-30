-- fs_src = [[
--  vec2 p1 = coord - vec2(320, 320);
--  vec2 p3 = p1 * p1;
--  bool shape1 = p3.x + p3.y < 30 * 30;
--  float shape1_dist = length(p1) - 30;
--  if (shape1_dist <= 0) {
--   gl_FragColor[0] = 0.7;
--   gl_FragColor[1] = 0.7;
--   gl_FragColor[2] = 0.7;
--  }
-- ]]

engrave(0.7,
	translate(320, 320) *
	   blended_union(1,
			 translate(80,80) * circle(90),
			 circle(80)))
