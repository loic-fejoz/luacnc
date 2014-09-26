shape_var_index = 1;
function nextShapeVar()
   return "shape" .. shape_var_index
end

point_var_index = 1;
function nextPointVar()
   return "p" .. point_var_index
end

function v(x, y)
   return {x=x,y=y}
end

function circle(radius)
   v = nextShapeVar()
   r = {}
   function glsl(p)
      print("bool " .. v .. " = " .. p .. ".x + " .. p .. ".y < " .. radius .. " * " .. radius)
   end
   r.name = v
   r.glsl = glsl
   return r
end


Translation = {}

function Translate(v, shape)
   np = nextPointVar()
   r = {}
   function glsl(p)
      print("vec2 " .. np .. " = " .. p .. " - vec2(" .. v.x .. ", " .. v.y .. ");")
      shape.glsl(np)
   end
   r.glsl = glsl
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

function emit(shape)
   shape.glsl("gl_FragCoord")
   print("if (" .. shape.name .. ") {")
   print(" gl_FragColor[0] = 1.0;")
   print(" gl_FragColor[1] = 0.0; ")
   print(" gl_FragColor[2] = 0.0; ")
   print("} else {")
   print(" gl_FragColor[0] = 0.0; ")
   print(" gl_FragColor[1] = 0.0; ")
   print(" gl_FragColor[2] = 0.0; ")
   print("}")
end

emit(Translate(v(320,320), circle(80)))
