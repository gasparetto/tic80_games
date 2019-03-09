math.randomseed(os.time())
print("  STARS_XY={")
-- for i=1,30 do
--   s=""
--   for j=1,5 do
--     if j==1 then s=s.."    " end
--     x=math.random(1,240); y=math.random(1,400)
--     s=s.."{x="..x..",y="..y.."}"
--     if j~=5 then s=s..", " end
--     if i~=30 and j==5 then s=s.."," end
--   end
--   print(s)
-- end
for i=1,15 do
  s=""
  for j=1,10 do
    if j==1 then s=s.."    " end
    x=math.random(1,240); y=math.random(1,400)
    s=s..x..","..y
    if not (i==15 and j==10) then s=s.."," end
  end
  print(s)
end
print("  }")
