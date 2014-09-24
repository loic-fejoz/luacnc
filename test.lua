function FontFace(v)
   return v
end

function Text(v)
   len = #v
   if len ==1 then
      v.text = v[1]
      table.remove(v, 1)
   end
   if v.size then
   end
   return v
end

function mm(value)
   return value
end

function cm(value)
   return 10*value
end

function show(t)
   for key,value in pairs(t) do print(key,value) end
end

function Rectangle(o)
   -- d = debug.getinfo(2, "Sl")
   -- show(d)
   -- print(d.currentline)
   -- print(d.source)
   len = #o
   if len == 1 then
      o.width = o[1]
      o.height = o[1]
      table.remove(o, 1)
   elseif len == 2 then
      o.width = o[1]
      o.height = o[2]
      table.remove(o, 2)
      table.remove(o, 1)
   end
   return o
end

Square = Rectangle

defaultUnits = mm
local function setDefaultUnits(aUnit)
   defaultUnits = aUnit
end


---------------------------------------------------
setDefaultUnits(mm)

ld = FontFace{
   family="Little Days",
   src="http://img.dafont.com/dl/?f=little_days"
}

t = Text{
   "ABC",
   font={
      family=ld,
      size=20
   },
   weight=normal
}
show(t)
show(t.font)
print('------------')
show(Square{10})
print('------------')
show(Rectangle{10, 20})

