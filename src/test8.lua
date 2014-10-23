-- Copyright (c) 2014 Loïc Fejoz
-- This file is provided under the MIT License.
-- author(s):
--  * Loïc Fejoz <loic@fejoz.net>

constraints = {}

function solve()
   if (0 ~= #constraints) then
      all_constraints_satisfied = false
      while not all_constraints_satisfied do
	 all_constraints_satisfied = true
	 for k, u  in ipairs(constraints) do
	    if (u ~= nil) then
	       if u() then
		  table.remove(constraints, k)
	       else
		  all_constraints_satisfied = false	 
	       end
	    end
	 end
      end
   end
end

CValue = {}
function CValue:new (o)
   o = o or {}   -- create object if user does not provide one
   setmetatable(o, self)
   self.__index = self
   return o
end

function CValue:toString()
   value = self.value or ""
   return "CValue(" .. value .. ")"
end


function CValue:equals(another)
   if (getmetatable(another) == nil) then
      self.value = another
      return true
   else
      if another.value == nill then
	 this = self
	 function update()
	    if another.value == nil then
	       return false
	    else
	       this.value = another.value
	       return true
	    end
	 end
	 table.insert(constraints, update)
	 return false
      else
	 self.value = another.value
	 return true
      end
   end
end

CPoint = {}
function CPoint:new (o)
   o = o or {}   -- create object if user does not provide one
   setmetatable(o, self)
   self.__index = self
   o.x = CValue:new()
   o.y = CValue:new()
   return o
end

CCircle = {}
function CCircle:new (o)
   o = o or {}   -- create object if user does not provide one
   setmetatable(o, self)
   self.__index = self
   o.center = CPoint:new()
   o.radius = CValue:new()
   return o
end

function aCircle()
   return CCircle:new()
end

function CCircle:emit()
   return translate(self.center.x.value, self.center.y.value) * circle(self.radius.value)
end

c1 = aCircle()
c1.radius:equals(30)
c1c = c1.center
c1c.x:equals(150)
c1c.y:equals(100)

solve()

engrave(1, c1:emit())

engrave(0.7,
  union(
     translate(320, 320) * circle(30),
     translate(300, 300) * box(50)
  )
)
