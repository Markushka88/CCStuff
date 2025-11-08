-- tv_server.lua
rednet.open("top")

local lines = {
  "white|gray|Color TV!                            ",
  "yellow|blue|It works great!",
  "white|green|Broadcasting right now",
  "cyan|black|Using Rednet!"
}

i = 1

while true do
  for i, line in ipairs(lines) do
    rednet.broadcast("TV_" .. i .. "|" .. line)
    sleep(0.05)
  end
  sleep(1)

  i = i + 1
  if i % 2 == 0 then
    lines[1] = "yellow|green|Hello world!                         "
  else
    lines[1] = "white|gray|Color TV!                            "
  end

  lines[5] = "white|black|" .. tostring(i)
end
