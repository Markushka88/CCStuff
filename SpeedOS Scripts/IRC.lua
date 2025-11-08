function Start()
	local messages = {};
	local serverHost = false;
	local channelOP = 0;
	local programName = shell.getRunningProgram()
	local getVersionIRC = " IRC v1.0 "
	local x,y = term.getSize()
	local serverOPs = {}
	local banList = {}
	local function cPrint(text)
	   local x,y = term.getSize()
	   x2,y2 = term.getCursorPos()
	   term.setCursorPos(math.ceil((x / 2) - (text:len() / 2)), y2)
	   write(text.. "\n")
	end

	function newIRCREAD( _sReplaceChar, _tHistory )
		term.setCursorBlink( true )

		local sLine = ""
		local nHistoryPos = nil
		local nPos = 0
		if _sReplaceChar then
			_sReplaceChar = string.sub( _sReplaceChar, 1, 1 )
		end

		local w, h = term.getSize()
		local sx, sy = term.getCursorPos()
		local function redraw()
			local nScroll = 0
			if sx + nPos >= w then
				nScroll = (sx + nPos) - w
			end

			term.setCursorPos( sx, sy )
			term.write( string.rep(" ", w - sx + 1) )
			term.setCursorPos( sx, sy )
			if _sReplaceChar then
				term.write( string.rep(_sReplaceChar, string.len(sLine) - nScroll) )
			else
				term.write( string.sub( sLine, nScroll + 1 ) )
			end
			term.setCursorPos( sx + nPos - nScroll, h )
		end

		while true do
			local sEvent, param, message = os.pullEvent()
			if sEvent == "char" then
				sLine = string.sub( sLine, 1, nPos ) .. param .. string.sub( sLine, nPos + 1 )
				nPos = nPos + 1
				redraw()

			elseif sEvent == "key" then
				if param == keys.enter then
					-- Enter
					break

				elseif param == keys.left then
					-- Left
					if nPos > 0 then
						nPos = nPos - 1
						redraw()
					end

				elseif param == keys.right then
					-- Right
					if nPos < string.len(sLine) then
						nPos = nPos + 1
						redraw()
					end

				elseif param == keys.up or param == keys.down then
					-- Up or down
					if _tHistory then
						if param == keys.up then
							-- Up
							if nHistoryPos == nil then
								if #_tHistory > 0 then
									nHistoryPos = #_tHistory
								end
							elseif nHistoryPos > 1 then
								nHistoryPos = nHistoryPos - 1
							end
						else
							-- Down
							if nHistoryPos == #_tHistory then
								nHistoryPos = nil
							elseif nHistoryPos ~= nil then
								nHistoryPos = nHistoryPos + 1
							end
						end

						if nHistoryPos then
							sLine = _tHistory[nHistoryPos]
							nPos = string.len( sLine )
						else
							sLine = ""
							nPos = 0
						end
						redraw()
					end
				elseif param == keys.backspace then
					-- Backspace
					if nPos > 0 then
						sLine = string.sub( sLine, 1, nPos - 1 ) .. string.sub( sLine, nPos + 1 )
						nPos = nPos - 1
						redraw()
					end
				end
			elseif sEvent == "rednet_message" then
				local id = param
				local _messageWords1 = split(message, ":")
				local _messageWords2 = split(message, "<!:>")
				local _messageLength2 = string.len("IRC_MESSAGE<!:>" .._tChannel.. "<!:>");
				local _messageLength3 = string.len("IRC_COMMAND:" .._tChannel.. ":");
				if serverHost and message == ("IRC_OPS:" .._tChannel) then
					rednet.send(id, textutils.serialize(serverOPs))
				elseif serverHost and message == ("IRC_BAN:" .._tChannel) then
					rednet.send(id, textutils.serialize(banList))
				elseif message == ("IRC_OP:" .._tChannel.. ":" .._tUser) then
					addMSG("You are now OP!")
				elseif _messageWords1[1] == ("IRC_JOIN") and _messageWords1[2] == (_tChannel) then
					if isBanned( _messageWords1[3] ) ~= true then
						addMSG(_messageWords1[3].. " has joined the server!")
					end
				elseif _messageWords1[1] == ("IRC_LEFT") and _messageWords1[2] == (_tChannel) then
					if isBanned( _messageWords1[3] ) ~= true then
						addMSG(_messageWords1[3].. " has has left the server!")
					end
				elseif _messageWords2[1] == ("IRC_MESSAGE") and _messageWords2[2] == (_tChannel) then
					if isBanned( _messageWords2[3] ) ~= true then
						if isOP(_messageWords2[3],serverOPs) then
							addMSG("[" .._messageWords2[3].. "] " .._messageWords2[4])
						else
							addMSG("<" .._messageWords2[3].. "> " .._messageWords2[4])
						end
					end
				elseif message == ("ServerPing" .._tChannel) and serverHost then
					rednet.send(id, ("Ping_Received_" .._tChannel.. "_IRC"))
				end

				local x11,y11 = term.getSize()
				local x12,y12 = term.getCursorPos()
				term.clear()
				term.setCursorPos(1,1)
				print(_tUser.. " has joined the server!")
				for i=1,#messages do
					print(messages[i])
				end

				print()
				term.setCursorPos(1,y11)
				write("> " ..sLine)
			end
		end

		term.setCursorBlink( false )

		return sLine
	end

	function isOP( username )
		if serverHost ~= true then
			rednet.send(channelOP, "IRC_OPS:" .._tChannel)
			repeat
				id, message2 = rednet.receive()
			until id == channelOP
			serverOPs = textutils.unserialize(message2)
		end
		for i=1,#serverOPs do
			if serverOPs[i] == username then
				return true
			end
		end
		return false
	end

	function isBanned( username )
		if serverHost ~= true then
			rednet.send(channelOP, "IRC_BAN:" .._tChannel)
			repeat
				id, message2 = rednet.receive()
			until id == channelOP
			banList = textutils.unserialize(message2)
		end
		for i=1,#banList do
			if banList[i] == username then
				return true
			end
		end
		return false
	end

	function split( sLine, sCode )
		local tWords = {}
		for match in string.gmatch(sLine, "[^" ..sCode.. "\t]+") do
			table.insert( tWords, match )
		end
		return tWords
	end

	function startProgram()
		term.clear()
		term.setCursorPos(1,1)
		print("Opening modems...")
		rednet.open("top")
		print("Pinging server: " .._tChannel)
		local timer = os.startTimer(1)
		while true do
			rednet.broadcast("ServerPing" .._tChannel)
			local event, id, message = os.pullEvent()
			if event == "rednet_message" and message == "Ping_Received_" .._tChannel.. "_IRC" then
				channelOP = id;
				serverHost = false;
				print("Server found! Joining...")
				sleep(0.5)
				break
			elseif event == "timer" and id == timer then
				print("Server not detected. Hosting...")
				serverHost = true;
				serverOPs[1] = _tUser
				sleep(0.5)
				break
			end
		end
		term.clear()
		term.setCursorPos(1,1)
		sleep(0)
		function addMSG( messagez )
			messages[#messages + 1] = messagez
		end

		rednet.broadcast("IRC_JOIN:" .._tChannel.. ":" .._tUser)

		function b()
			while true do
				local x1,y1 = term.getCursorPos()
				local x,y = term.getSize()
				term.setCursorPos(1,1)
				print(_tUser.. " has joined the server!")

				term.setCursorPos(1, y)
				write("> ")
				local messageaa = newIRCREAD()
				term.setCursorPos(1,y-1)
				term.clearLine()
				term.setCursorPos(1,y)
				term.clearLine()
				term.setCursorPos(x1,y1)

				if string.sub(messageaa, 1, 1) == "/" then
					if string.sub(messageaa, 1, 3) == "/op" then
						if isOP(_tUser, serverOPs) then
							addMSG("(Console) Op'ing " ..string.sub(messageaa, 5, string.len(messageaa)))
							serverOPs[#serverOPs+1] = string.sub(messageaa, 5, string.len(messageaa))
							rednet.broadcast("IRC_OP:" .._tChannel.. ":" ..string.sub(messageaa, 5, string.len(messageaa)))
						else
							addMSG("No permission")
						end
					elseif string.sub(messageaa, 1, 5) == "/mute" then
						if isOP(_tUser, serverOPs) then
							addMSG(string.sub(messageaa, 7, string.len(messageaa)).. " has been muted.")
							banList[#banList+1] = string.sub(messageaa, 7, string.len(messageaa))
						else
							addMSG("No permission")
						end
					elseif string.sub(messageaa, 1, 5) == "/exit" then
						rednet.broadcast("IRC_LEFT:" .._tChannel.. ":" .._tUser)
						error()
					else
						addMSG("Unknown command.")
					end
				else
					if isBanned( _tUser ) then
						addMSG("You have been muted.")
					else
						if isOP(_tUser, serverOPs) then
							addMSG("[" .._tUser.. "] " ..messageaa)
						else
							addMSG("<" .._tUser.. "> " ..messageaa)
						end
						rednet.broadcast("IRC_MESSAGE<!:>" .._tChannel.. "<!:>" .._tUser.. "<!:>" ..messageaa)
					end
				end

				local x11,y11 = term.getSize()
				local x12,y12 = term.getCursorPos()
				term.clear()
				term.setCursorPos(1,1)
				print(_tUser.. " has joined the server!")
				for i=1,#messages do
					print(messages[i])
				end

				print()
			end
		end

		b()
	end

	function mainMenu( showAdministrator )
		term.clear()
		term.setCursorPos(1,4)
		cPrint("+--------------------+")
		cPrint("|     " ..getVersionIRC.. "     |")
		cPrint("|     ----------     |")
		cPrint("| User:              |")
		cPrint("| Channel: #         |")
		if showAdministrator then
			cPrint("|     ----------     |")
			cPrint("| Admin:             |")
			cPrint("| Enter administrator|")
			cPrint("| code to manage IRC.|")
		end
		cPrint("+--------------------+")

		if showAdministrator then
			term.setCursorPos(23,7)
			write(_tUser)
		else
			repeat
				term.setCursorPos(23,7)
				_tUser = read()
			until _tUser ~= ""
		end

		repeat
			term.setCursorPos(27,8)
			_tChannel = read()
		until _tChannel ~= ""

		if _tChannel == "ShowAdmin" then --OoOoOo! A easter egg :D Too bad you can't use it :/
			mainMenu( true )
		end

		if showAdministrator then
			term.setCursorPos(24,10)
			_tAdminCode = read()
			-- Doesn't do anything yet...
		end
	end

	mainMenu( false )
	startProgram()
end

Start()
