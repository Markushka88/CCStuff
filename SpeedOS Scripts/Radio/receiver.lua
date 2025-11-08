term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.white)
print("Rednet Radio (receiver).")
print("")

local modemSide = nil
for _, side in pairs(rs.getSides()) do
  if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
    modemSide = side
    break
  end
end

if not modemSide then
  term.setTextColor(colors.red)
  print("No modem found! Please attach a modem.")
  term.setTextColor(colors.white)
  read()
  if SpeedOS then
    SpeedOS.close()
  end
  return
end

rednet.open(modemSide)

local spkSide = nil
for _, side in pairs(rs.getSides()) do
  if peripheral.isPresent(side) and peripheral.getType(side) == "speaker" then
    spkSide = side
    break
  end
end

if not spkSide then
  term.setTextColor(colors.red)
  print("No speaker found! Please attach an Immibis speaker.")
  term.setTextColor(colors.white)
  read()
  if SpeedOS then
    SpeedOS.close()
  end
  return
end

term.setTextColor(colors.white)
print("Found modem on ["..modemSide.."] and speaker on ["..spkSide.."].")
print("")

local notes = {
  C = 16.35, Cs = 17.32, D = 18.35, Ds = 19.45, E = 20.60, F = 21.83,
  Fs = 23.12, G = 24.50, Gs = 25.96, A = 27.50, As = 29.14, B = 30.87
}

local function getFreq(note, octave)
  local base = notes[note]
  if not base then return 440 end
  return base * (2 ^ (octave or 4))
end

local function playFreq(freq, dur)
  peripheral.call(spkSide, "start", 0, freq)
  sleep(dur or 0.5)
  peripheral.call(spkSide, "stop", 0)
end

peripheral.call(spkSide, "setAttenuation", 5)

while true do
  term.setTextColor(colors.white)
  term.clear()
  term.setCursorPos(1,1)
  print("Rednet Radio (receiver).")
  print("")
  write("Enter station ID (blank to exit): ")
  local input = read()
  if input == "" then
    print("")
    print("Shutting down speaker and exiting...")
    peripheral.call(spkSide, "shutdown")
    rednet.close(modemSide)
    return
  end

  local targetID = tonumber(input)
  if not targetID then
    term.setTextColor(colors.red)
    print("Invalid ID! Try again.")
    sleep(1.5)
  else
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1,1)
    print("Tuned to station "..targetID)
    print("Press [Enter] to stop listening.")
    print("")

    local listening = true
    while listening do
      local event, p1, p2, p3 = os.pullEvent()
      if event == "rednet_message" then
        local id, msg = p1, p2
        if id == targetID and type(msg) == "string" then
          local note = string.match(msg, "note=([A-Gs]+)")
          local oct = tonumber(string.match(msg, "oct=(%d+)")) or 4
          local dur = tonumber(string.match(msg, "dur=([%d%.]+)")) or 0.4
          if note then
            local freq = getFreq(note, oct)
            playFreq(freq, dur)
            print(string.format("[%d] %s%d (%.1f Hz, %.2fs)", id, note, oct, freq, dur))
          end
        end
      elseif event == "key" and p1 == keys.enter then
        listening = false
        print("")
        print("Stopped listening. Returning to menu...")
        sleep(1)
      end
    end
  end
end
