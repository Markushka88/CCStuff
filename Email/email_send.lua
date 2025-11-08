rednet.open("top")
rednet.send(434, "$EMAIL"..os.getComputerID().."!SP!"
                 ..os.getComputerLabel().."!SP!"
                 ..os.time().."!SP!"
                 .."Message Body")
print("Sending message...")
if rednet.receive(5)~=nil then
  print("Message successfully sent.")
else
  print("Server response timed out.")
end
rednet.close("left")
