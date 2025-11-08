local MAX_COORD = 50
local EPSILON = 0.5

rednet.open("top")

local function parse_report(msg)
  local t = {}
  for key, value in string.gmatch(msg, "(%w+)=([%d%.%-]+)") do
    t[key] = tonumber(value)
  end
  return t
end

local reports = {}

print("Waiting for 3 position reports...")
while #reports < 3 do
  local id, msg = rednet.receive()
  local data = parse_report(msg)
  if data.x and data.y and data.z and data.d then
    table.insert(reports, data)
    print("Received report "..#reports..": x="..data.x.." y="..data.y.." z="..data.z.." d="..data.d)
  end
end

print("Starting triangulation...")

for x = 0, MAX_COORD do
  for y = 0, MAX_COORD do
    for z = 0, MAX_COORD do
      local function dist(p)
        local dx = p.x - x
        local dy = p.y - y
        local dz = p.z - z
        return math.sqrt(dx*dx + dy*dy + dz*dz)
      end

      local ok = true
      for i = 1, 3 do
        local d_actual = dist(reports[i])
        if math.abs(d_actual - reports[i].d) > EPSILON then
          ok = false
          break
        end
      end

      if ok then
        print("Possible sender position: x="..x.." y="..y.." z="..z)
      end
    end
  end
end

print("Search complete.")
