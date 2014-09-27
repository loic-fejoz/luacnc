engrave(0.7,
  union(
     translate(320,320) * circle(30),
     translate(300, 300) * box(50)
  )
)

engrave(0.4, translate(50,50) * box(70))

for v = 0, 600, 20 do
   engrave(0.6, translate(v,50) * box(10))
end
