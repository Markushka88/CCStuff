-- tv_client.lua
rednet.open("top")
local monitor = peripheral.wrap("right")
monitor.setTextScale(0.5)

local colorMap = {
  white = colors.white, orange = colors.orange, magenta = colors.magenta,
  lightBlue = colors.lightBlue, yellow = colors.yellow, lime = colors.lime,
  pink = colors.pink, gray = colors.gray, lightGray = colors.lightGray,
  cyan = colors.cyan, purple = colors.purple, blue = colors.blue,
  brown = colors.brown, green = colors.green, red = colors.red, black = colors.black
}

local lines = {}
local lastUpdate = os.clock()

while true do
  local _, msg = rednet.receive(0.1)
  if type(msg) == "string" and msg:sub(1, 3) == "TV_" then
    local id, fgName, bgName, text = msg:match("^TV_(%d+)|(%a+)|(%a+)|(.+)")
    if id and fgName and bgName and text then
      local fg = colorMap[fgName] or colors.white
      local bg = colorMap[bgName] or colors.black
      lines[tonumber(id)] = {fg = fg, bg = bg, text = text}
      lastUpdate = os.clock()
    end
  end

  if os.clock() - lastUpdate > 0.2 and next(lines) then
    monitor.clear()
    for i = 1, #lines do
      local line = lines[i]
      if line then
        monitor.setCursorPos(1, i)
        monitor.setTextColor(line.fg)
        monitor.setBackgroundColor(line.bg)
        monitor.write(line.text)
      end
    end
    lines = {}
  end
end
