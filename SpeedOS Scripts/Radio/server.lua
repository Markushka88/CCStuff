rednet.open("top")
print("Radio server started. Broadcasting all notes...")

local notes = { "C", "Cs", "D", "Ds", "E", "F", "Fs", "G", "Gs", "A", "As", "B" }

local octaves = { 1, 2, 3, 4, 5, 6, 7 }

local dur = 0.25

while true do
  for _, oct in ipairs(octaves) do
    for _, note in ipairs(notes) do
      local msg = "note="..note..";oct="..oct..";dur="..dur
      rednet.broadcast(msg)
      print("Sent from [" .. tostring(os.getComputerID()) .. ": "..msg)
      sleep(dur)
    end
  end
  print("All notes played. Repeating in 2s...")
  sleep(2)
end
