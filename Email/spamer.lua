--[[
    Скрипт спамит сообщением
    по электронной почте. Написать,
    как и кастомизировать программу очень
    просто.
]]

-----------------------------------------------------------------------------------------------------------------------------------
-- Подгружаем нужные программе АПИ

SpeedOS.LoadAPI("SpeedAPI/SpeedText")
SpeedOS.LoadAPI("SpeedAPI/windows")
SpeedOS.LoadAPI("SpeedAPI/peripheral")

-----------------------------------------------------------------------------------------------------------------------------------
-- Блок констант

local i = 0

-----------------------------------------------------------------------------------------------------------------------------------
-- Блок ввода параметров

windows.clearScreen(colors.black)
term.setCursorPos(1, 1)

term.setTextColor(colors.white)
io.write("Enter your message: ")
term.setTextColor(colors.magenta)
term.setCursorPos(term.getCursorPos())
msg = read()

term.setTextColor(colors.white)
io.write("Enter your fake label: ")
term.setTextColor(colors.magenta)
term.setCursorPos(term.getCursorPos())
label = read()

term.setTextColor(colors.white)
io.write("Enter victim's ID: ")
term.setTextColor(colors.magenta)
term.setCursorPos(term.getCursorPos())
id = read()

-----------------------------------------------------------------------------------------------------------------------------------
-- Блок визуальной инициализации

windows.clearScreen(colors.black)
term.setTextColor(colors.white)
term.setCursorPos(1, 1)

-----------------------------------------------------------------------------------------------------------------------------------
-- Основной цикл отправки сообщений

while true do
    local newemail = '$EMAIL'..id
                     ..'!SP!'..label
                     ..'!SP!'..os.time()
                     ..'!SP!'..msg
                     
    rednet.send(434, newemail)
    return_id, return_msg = rednet.receive(5)

    if return_id ~= nil then
      i = i + 1
      print("Message #"..tostring(i).." sent.")
    else
      print("Can't reach server!")
    end
end

-----------------------------------------------------------------------------------------------------------------------------------
