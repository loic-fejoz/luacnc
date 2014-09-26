shape_var_index = 0;
function nextShapeVar()
   shape_var_index = shape_var_index + 1
   return "shape" .. shape_var_index
end

point_var_index = 0;
function nextPointVar()
   point_var_index = point_var_index + 1
   return "p" .. point_var_index
end

function v(x, y)
   return {x=x,y=y}
end

function circle(radius)
   v = nextShapeVar()
   r = {}
   r.glsl = function (p)
      print(" bool " .. v .. " = " .. p .. ".x + " .. p .. ".y < " .. radius .. " * " .. radius .. ";")
   end
   r.name = v
   return r
end

function box(width)
   v = nextShapeVar()
   r = {}
   r.glsl = function (p)
      print(" bool " .. v .. " = " .. p .. ".x < " .. width .. " && " .. p .. ".y < " .. width .. ";")
   end
   r.name = v
   return r
end


Translation = {}

function Translate(v, shape)
   np = nextPointVar()
   r = {}
   r.glsl = function(p)
      print(" vec2 " .. np .. " = " .. p .. " - vec2(" .. v.x .. ", " .. v.y .. ");")
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
   v = nextShapeVar()
   r = {}
   function glsl(p)
      shape1.glsl(p)
      shape2.glsl(p)
      print(" bool " .. v .. " = " .. shape1.name .. " && " .. shape2.name .. ";")
   end
   r.name = v
   r.glsl = glsl
   return r
end

function emit(shape)
   print("#version 120")
   print("void main(void) {")
   shape.glsl("gl_FragCoord")
   print(" if (" .. shape.name .. ") {")
   print("  gl_FragColor[0] = 1.0;")
   print("  gl_FragColor[1] = 0.0; ")
   print("  gl_FragColor[2] = 0.0; ")
   print(" } else {")
   print("  gl_FragColor[0] = 0.0; ")
   print("  gl_FragColor[1] = 0.0; ")
   print("  gl_FragColor[2] = 0.0; ")
   print(" }")
   print("}")
end

emit(
   union(
      translate(320,320) * box(80),
      translate(300, 300) * circle(50)
   )
)
