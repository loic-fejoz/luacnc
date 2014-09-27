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
   r = {}
   r.glsl = function (p)
      np = nextPointVar()
      fs_src = fs_src .. " vec2 " .. np .. " = " .. p .. " * " .. p .. ";\n"
      fs_src = fs_src .. " bool " .. v .. " = " .. np .. ".x + " .. np .. ".y < " .. radius .. " * " .. radius .. ";\n"
   end
   r.name = v
   return r
end

function box(width)
   local v = nextShapeVar()
   r = {}
   r.glsl = function (p)
      fs_src = fs_src .. " bool " .. v .. " = " .. p .. ".x < " .. width .. " && " .. p .. ".y < " .. width .. " && " .. p .. ".x > 0 && " .. p .. ".y > 0;\n"
   end
   r.name = v
   return r
end


Translation = {}

function Translate(v, shape)
   local np = nextPointVar()
   r = {}
   r.glsl = function(p)
      fs_src = fs_src .. " vec2 " .. np .. " = " .. p .. " - vec2(" .. v.x .. ", " .. v.y .. ");\n"
      shape.glsl(np)
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
   r = {}
   r.glsl = function (p)
      shape1.glsl(p)
      shape2.glsl(p)
      fs_src = fs_src .. " bool " .. v .. " = " .. shape1.name .. " || " .. shape2.name .. ";\n"
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
