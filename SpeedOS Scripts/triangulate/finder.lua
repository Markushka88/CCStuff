local TARGET_ID = 1094
local MAIN_ID = 1098
local POS_X, POS_Y, POS_Z = 0, 0, 2

rednet.open("top")

print("Listening for messages from ID "..TARGET_ID)

while true do
  local id, msg, dist = rednet.receive()
  if id == TARGET_ID then
    print("Message from "..id.." with distance "..dist)

    local report = "x="..POS_X..",y="..POS_Y..",z="..POS_Z..",d="..dist
    rednet.send(MAIN_ID, report)
  end
end
