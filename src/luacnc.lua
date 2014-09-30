-- Copyright (c) 2014 Loïc Fejoz
-- This file is provided under the MIT License.
-- author(s):
--  * Loïc Fejoz <loic@fejoz.net>
default_depth = 0.0
fs_src = ""

shape_var_index = 0
function nextShapeVar()
   shape_var_index = shape_var_index + 1
   return "shape" .. shape_var_index
end

point_var_index = 0
function nextPointVar()
   point_var_index = point_var_index + 1
   return "p" .. point_var_index
end

function v(x, y)
   return {x=x,y=y}
end

function circle(radius)
   local v = nextShapeVar()
   local r = {}
   r.glsl = function (p)
      np = nextPointVar()
      fs_src = fs_src .. " vec2 " .. np .. " = " .. p .. " * " .. p .. ";\n"
      fs_src = fs_src .. " bool " .. v .. " = " .. np .. ".x + " .. np .. ".y < " .. radius .. " * " .. radius .. ";\n"
   end
   r.dist = function (p)
      fs_src = fs_src .. " float " .. v .. "_dist = length(" .. p .. ") - ".. radius .. ";\n"
   end
   r.name = v
   return r
end

function box(width)
   local v = nextShapeVar()
   local r = {}
   r.glsl = function (p)
      fs_src = fs_src .. " bool " .. v .. " = " .. p .. ".x < " .. width .. " && " .. p .. ".y < " .. width .. " && " .. p .. ".x > 0 && " .. p .. ".y > 0;\n"
   end
   r.name = v
   return r
end


Translation = {}

function Translate(v, shape)
   local np = nextPointVar()
   local r = {}
   r.glsl = function(p)
      fs_src = fs_src .. " vec2 " .. np .. " = " .. p .. " - vec2(" .. v.x .. ", " .. v.y .. ");\n"
      shape.glsl(np)
   end
   r.dist = function(p)
      fs_src = fs_src .. " vec2 " .. np .. " = " .. p .. " - vec2(" .. v.x .. ", " .. v.y .. ");\n"
      shape.dist(np)
   end
   r.name = shape.name
   return r
end

Translation.mt = {}
Translation.mt.__mul = Translate

function translate(x, y)
   local tr = {x=x,y=y}
   setmetatable(tr, Translation.mt)
   return tr
end

function union(shape1, shape2)
   local v = nextShapeVar()
   local r = {}
   r.glsl = function (p)
      shape1.glsl(p)
      shape2.glsl(p)
      fs_src = fs_src .. " bool " .. v .. " = " .. shape1.name .. " || " .. shape2.name .. ";\n"
   end
   r.name = v
   return r
end

function blended_union(d, shape1, shape2)
   local v = nextShapeVar()
   local r = {}
   r.dist = function (p)
      shape1.dist(p)
      shape2.dist(p)
      -- See Matt Keeter's thesis: http://cba.mit.edu/docs/theses/13.05.Keeter.pdf
      -- min(min(A,B, sqrt(abs(A) + sqrt(abs(b)) - r)
      fs_src = fs_src .. " float " .. v .. "_dist = min(min(" .. shape1.name .. "_dist, " .. shape2.name .. "_dist), sqrt(abs(" .. shape1.name .. "_dist)) + sqrt(abs(" .. shape2.name .. "_dist)) - " .. d .. ");\n"
   end
   r.glsl = function (p)
      r.dist(p)
      fs_src = fs_src .. " bool " .. v .. " = " .. v .. "_dist <= 0;\n"
   end
   r.name = v
   return r
end

function morph(d, shape1, shape2)
   local v = nextShapeVar()
   local r = {}
   r.dist = function (p)
      shape1.dist(p)
      shape2.dist(p)
      -- See Matt Keeter's thesis: http://cba.mit.edu/docs/theses/13.05.Keeter.pdf
      -- d * A + (1-d) * B
      fs_src = fs_src .. " float " .. v .. "_dist = " .. d .. " * " .. shape1.name .. "_dist + (1 - " .. d .. ") * " .. shape2.name .. "_dist;\n"
   end
   r.glsl = function (p)
      r.dist(p)
      fs_src = fs_src .. " bool " .. v .. " = " .. v .. "_dist <= 0;\n"
   end
   r.name = v
   return r
end

function shell(t, shape)
   local v = nextShapeVar()
   local r = {}
   r.dist = function (p)
      shape.dist(p)
      -- See Matt Keeter's thesis: http://cba.mit.edu/docs/theses/13.05.Keeter.pdf
      -- max(A - t/2, -t/2-A)
      fs_src = fs_src .. " float " .. v .. "_dist = max(" .. shape.name .. "_dist - (" .. t .. "/2.0), -(" .. t .. "/2.0) -" .. shape.name .. "_dist);\n"
   end
   r.glsl = function (p)
      r.dist(p)
      fs_src = fs_src .. " bool " .. v .. " = " .. v .. "_dist <= 0;\n"
   end
   r.name = v
   return r
end

function engrave(depth, shape)
   shape.glsl("coord")
   fs_src = fs_src .. " if (" .. shape.name .. ") {\n"
   fs_src = fs_src .. "  gl_FragColor[0] = " .. depth .. ";\n"
   fs_src = fs_src .. "  gl_FragColor[1] = " .. depth .. ";\n"
   fs_src = fs_src .. "  gl_FragColor[2] = " .. depth .. ";\n"
   fs_src = fs_src .. " }\n"
end
