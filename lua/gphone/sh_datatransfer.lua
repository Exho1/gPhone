----// Shared Net Messages //----

local trans = gPhone.getTranslation

--[[
	Before:
		Server:
			Start up - 241
			Open app - 280
			Close app - 160
			Texting "HOW BOUT DEM BYTES" - 808
			Close phone - 217
		Client:
			Phone call - 752
			Texting "HOW BOUT DEM BYTES" - 985
	After:
		Server:
			Start up - 17
			Open app - 88
			Close app - 24
			Texting "HOW BOUT DEM BYTES" - 344 
			Close phone - 17
		Client:
			Phone call - 372
			Texting "HOW BOUT DEM BYTES" - 385
]]

if SERVER then

	--// Sets a networked variable based on the phone's state
	net.Receive( "gPhone_StateChange", function( len, ply )
		local open = net.ReadBool()
		
		if open == true then
			ply:SetNWBool("gPhone_Open", open)
			hook.Run( "gPhone_built", ply )
		else
			ply:SetNWBool("gPhone_Open", open)
		end
	end)
	
	--// Generates a number from the player's steam ID, used in case they somehow didn't receive one
	net.Receive( "gPhone_GenerateNumber", function( len, ply )
		ply:generatePhoneNumber()
	end)
	
	--// Handles requests
	net.Receive( "gPhone_Request", function( len, ply )
		local data = gPhone.readTable()
		
		gPhone.receiveRequest( data )
	end)
	
	--// Handles responses
	net.Receive( "gPhone_Response", function( len, ply )
		local data = gPhone.readTable()

		gPhone.receiveResponse( data )
	end)
	
	--// Sets a networked variable for the player's phone's currently opened app
	net.Receive( "gPhone_App", function( len, ply )
		local app = net.ReadString()
		
		ply:SetNWString("gPhone_CurApp", app or "")
	end)
	
	--// Transfers money to a player
	net.Receive( "gPhone_Transfer", function( len, ply )
		local amount = net.ReadString()
		local target = net.ReadString()
		
		target = util.getPlayerByNick( target ) 
		
		-- Make sure we are in DarkRP
		if not ply.getDarkRPVar then
			gPhone.chatMsg( ply, trans("transfer_fail_gm") )
		end
		
		amount = tonumber(amount)
		local plyWallet = tonumber(ply:getDarkRPVar("money"))
		
		-- Cooldowns to prevent spam
		if ply:getTransferCooldown() > 0 then
			gPhone.chatMsg( ply, string.format( trans("transfer_fail_cool"), math.Round(ply:getTransferCooldown()) ) )
			return
		end
		
		-- If the player disconnected or they are sending money to themselves, stop the transaction
		if not IsValid(target) or target == ply then
			gPhone.chatMsg( ply, trans("transfer_fail_ply") )
			return
		end
		
		-- If a negative or string amount got through, stop it
		if amount < 0 or amount == nil or amount != math.abs(amount)  then 
			gPhone.chatMsg( ply, trans("transfer_fail_amount") )
			gPhone.kick( ply, 23 ) 
			return
		end
		
		-- Make sure the player has this money and didn't cheat it on the client
		if plyWallet > amount then 	
			-- Last measure before allowing the deal, call the hook
			local shouldTransfer, denyReason = hook.Run( "gPhone_shouldAllowTransaction", ply, target, amount )
			if shouldTransfer == false then
				if denyReason != nil then
					gPhone.chatMsg( ply, denyReason )
				else
					gPhone.chatMsg( ply, trans("transfer_fail_generic") )
				end
				return
			end
			
			-- Complete the transaction
			target:addMoney(amount)
			ply:addMoney(-amount)
			
			gPhone.chatMsg( target, string.format( trans("received_money"), amount, ply:Nick() ) )
			gPhone.chatMsg( ply, string.format( trans("sent_money"), amount, target:Nick() ) )
			
			ply:setTransferCooldown( 5 )
		else
			gPhone.chatMsg( ply, trans("transfer_fail_funds") )
			return
		end
	end)
	
	--// Receives a text message and sends it to the target player
	local antiSpamWindow, lastText = 0, 0
	net.Receive( "gPhone_Text", function( len, ply )
		local date = net.ReadString()
		local time = net.ReadString()
		local message = net.ReadString()
		local target = net.ReadString()
		local sender = net.ReadString()
		local self = net.ReadBool()
		
		if target == "" or sender == "" then
			self = nil
		end
		
		local msgTable = {date,time,message,target,sender,self}
		
		local canText = ply:GetNWBool("gPhone_CanText", true)
		local nick = msgTable[4]
		local target = util.getPlayerByNick( nick )
		
		msgTable[5] = ply:Nick()
		msgTable[6] = false
		
		-- Flagged for spam
		if not canText then
			gPhone.chatMsg( ply, string.format( trans("text_cooldown"), math.Round(ply.TextCooldown) ) )
			return 
		end
		
		-- Anti text spam
		ply.MessageCount = (ply.MessageCount or 0) + 1
		hook.Add("Think", "gPhone_AntiSpam_"..ply:SteamID(), function()
			-- Span of time in which texts are counted to check against spam
			if CurTime() > antiSpamWindow then
				antiSpamWindow = CurTime() + gPhone.config.antiSpamTimeframe
				ply.MessageCount = 0
			end
			
			-- If they haven't texted in 10 seconds, this hook is no longer needed
			if CurTime() - lastText > 10 then
				hook.Remove("Think", "gPhone_AntiSpam_"..ply:SteamID())
				ply.MessageCount = 0
			end

			-- Caught em
			if ply.MessageCount > gPhone.config.textPerTimeframeLimit and CurTime() < antiSpamWindow then
				ply:SetNWBool("gPhone_CanText", false)
				ply.TextCooldown = gPhone.config.textSpamCooldown
				
				gPhone.msgC( GPHONE_MSGC_WARNING, ply:Nick().." has been flagged for spamming the texting system" )
				gPhone.chatMsg( ply, string.format( trans("text_flagged"), ply.TextCooldown ) )
				ply.MessageCount = 0 
				
				-- Countdown until the cooldown ends
				local endTime = CurTime() + ply.TextCooldown
				hook.Add("Think", "gPhone_TextCooldown_"..ply:SteamID(), function()
					ply.TextCooldown = endTime - CurTime()
					
					if ply.TextCooldown <= 0 then
						ply.TextCooldown = nil
						canText = true
						ply:SetNWBool("gPhone_CanText", true)
						hook.Remove("Think", "gPhone_TextCooldown_"..ply:SteamID())
					end
				end)
			end
		end)
		
		-- Send the message the the target
		net.Start("gPhone_Text")
			net.WriteString( msgTable[1] )
			net.WriteString( msgTable[2] )
			net.WriteString( msgTable[3] )
			net.WriteString( msgTable[4] )
			net.WriteString( msgTable[5] )
			net.WriteBool( msgTable[4] )
		net.Send( target )
		
		lastText = CurTime()
	end)
	
	--// Starts or ends a phone call
	net.Receive( "gPhone_Call", function( len, ply )
		local number = net.ReadString()
		
		if number != "end" then -- Start a call
			local callingNum = ply:getPhoneNumber()
			
			local targetPly = gPhone.getPlayerByNumber( number )
			
			if targetPly:hasPhoneOpen() and not targetPly:inCall() then	
				local reqStr = string.format( trans("being_called"), ply:Nick() )
				local id = gPhone.sendRequest( {[2]=ply, [3]="Phone", [4]=reqStr}, targetPly )
				
				gPhone.runFunction( targetPly, "calledSound" )
				
				gPhone.waitForResponse( id, function( bAccepted, tbl ) 
					if bAccepted == true then
						gPhone.runFunction( targetPly, "stopSound" )
						gPhone.createCall( ply, targetPly )
					end
				end)
			else
				gPhone.notifyPlayer( "alert", ply, 
				{
					msg=string.format(trans("cannot_call"), targetPly:Nick()), 
					title=trans("phone"), 
					options = {
						trans("okay"),
						"",
					}
				},
				true)
			end
		else -- End a call
			local id = gPhone.getCallID( ply )
			gPhone.endCall( id )
		end
	end)
end


if CLIENT then
	--// Runs a function on the phone or in an application
	net.Receive( "gPhone_RunFunction", function( len, ply )	
		local type = net.ReadString()
		local app = net.ReadString()
		local func = net.ReadString()
		local args = net.ReadTable()
		
		type = type:lower()
		
		gPhone.log(string.format( "Running function from server (%s). App? %s", func, tostring(type == app) ) )
		
		if type == "app" then
			if gApp[app:lower()] then
				app = app:lower()
				for k, v in pairs( gApp[app].Data ) do
					if k:lower() == func:lower() then
						gApp[app].Data[k]( unpack(args) )
						return
					end
				end
			end
			gPhone.msgC( GPHONE_MSGC_WARNING, "Unknown application ("..app..") function "..func.."!" )
		elseif type == "phone" then
			for k, v in pairs(gPhone) do
				if k:lower() == func:lower() then
					gPhone[k]( unpack(args) )
					return
				end
			end
			
			gPhone.msgC( GPHONE_MSGC_WARNING, "Unknown phone function "..func.."!")
		end
	end)
	
	--// Handles requests
	net.Receive( "gPhone_Request", function( len, ply )
		gPhone.log("Received p2p request from server")
		
		local data = gPhone.readTable()
		
		gPhone.receiveRequest( data )
	end)
	
	--// Handles responses
	net.Receive( "gPhone_Response", function( len, ply )
		gPhone.log("Received p2p response from server")
		
		local data = gPhone.readTable()
		
		gPhone.receiveResponse( data )
	end)
	
	--// Tells the server what app we have open
	net.Receive( "gPhone_App", function( len, ply )
		local name, active = nil, gPhone.getActiveApp() 
		active = active or {}
		active.Data = active.Data or {}
		
		if active.Data.PrintName then
			name = active.Data.PrintName or nil
		end

		net.Start("gPhone_App")
			net.WriteString(name)
		net.SendToServer()
	end)
	
	--// Sends a text message to the server
	net.Receive( "gPhone_Text", function( len, ply )
		gPhone.log("Received text message")
		local date = net.ReadString()
		local time = net.ReadString()
		local message = net.ReadString()
		local target = net.ReadString()
		local sender = net.ReadString()
		local self = net.ReadBool()
		
		local data = {date,time,message,target,sender,self}
		
		data[6] = false

		gPhone.receiveTextMessage( data )
	end)
	
	net.Receive( "gPhone_Notify", function( len, ply )
		gPhone.log("Received notification from server")
		local type = net.ReadBit()

		if type == 1 then -- Banner
			local msg = net.ReadString()
			local app = net.ReadString()
			local title = net.ReadString()
			
			-- Create a banner (no function for clicking though
			gPhone.notifyBanner( {msg=msg, app=app, title=title} )
		else -- Alert
			local msg = net.ReadString()
			local title = net.ReadString()
			local option1 = net.ReadString()
			local option2 = net.ReadString()
			local oneOption = net.ReadBool()
			
			gPhone.notifyAlert( {msg=msg, title=title, options={ option1, option2} }, 
			nil, nil, oneOption, true )
		end
	end)
end

--[[ TEMP
function net.Incoming( len, client )

	local i = net.ReadHeader()
	local strName = util.NetworkIDToString( i )
	
	if ( !strName ) then return end
	
	print("Incoming net message ("..strName..")! Size: "..len)
	
	local func = net.Receivers[ strName:lower() ]
	if ( !func ) then return end

	--
	-- len includes the 16 bit int which told us the message name
	--
	len = len - 16
	
	func( len, client )

end
-- TEMP]]

--// Writes a table with integer keys to a net message
function gPhone.writeTable( tbl )
	net.WriteUInt( table.Count(tbl), 4 )
	
	for k, v in pairs( tbl ) do
		net.WriteType( v )
	end
	
	-- End of table
	--net.WriteUInt( 0, 8 )
end

--// Reads a table with integer keys from a net message
function gPhone.readTable()
	local len = net.ReadUInt( 4 )
	local returnTbl = {}
	
	for i = 1, len do
		local t = net.ReadUInt( 8 )
		--if ( t == 0 ) then return returnTbl end
		local v = net.ReadType( t )
		
		returnTbl[i] = v
	end
	
	return returnTbl
end	
