----// Shared Net Messages for "gPhone_DataTransfer" //----

local trans = gPhone.getTranslation

if SERVER then
	--// Receives data from applications and runs it on the server
	local antiSpamWindow, lastText = 0, 0
	net.Receive( "gPhone_DataTransfer", function( len, ply )
		local data = net.ReadTable()
		local header = data.header
		
		ply.netCount = ply.netCount + 1
		
		hook.Run( "gPhone_receivedClientData", ply, header, data )
		
		if header == GPHONE_MONEY_TRANSFER then -- Money transaction
			-- Make sure we are in DarkRP
			if not ply.getDarkRPVar then
				gPhone.chatMsg( ply, trans("transfer_fail_gm") )
			end
			
			local amount = tonumber(data.amount)
			local target = data.target
			local plyWallet = tonumber(ply:getDarkRParV("money"))
			
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
				
				gPhone.confirmTransaction( ply, {target=target:Nick(), amount=amount, time=os.date( "%x - %I:%M%p")} )
				ply:setTransferCooldown( 5 )
			else
				gPhone.chatMsg( ply, trans("transfer_fail_funds") )
				return
			end
		elseif header == GPHONE_TEXT_MSG then
			local canText = ply:GetNWBool("gPhone_CanText", true)
			local msgTable = {}
			local nick = data.tbl.target
			local target = util.getPlayerByNick( nick )
			
			msgTable = data.tbl
			msgTable.sender = ply:Nick()
			msgTable.self = false
			
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
			net.Start("gPhone_DataTransfer")
				net.WriteTable( {header=GPHONE_TEXT_MSG, data=msgTable} )
			net.Send( target )
			
			lastText = CurTime()
		elseif header == GPHONE_STATE_CHANGED then -- The phone has been opened or closed
			local phoneOpen = data[1]
			if phoneOpen == true then
				ply:SetNWBool("gPhone_Open", true)
				hook.Run( "gPhone_built", ply )
			else
				ply:SetNWBool("gPhone_Open", false)
			end
		elseif header == GPHONE_CUR_APP then
			ply:SetNWString("gPhone_CurApp", data.app or "")
		elseif header == GPHONE_NET_REQUEST then
			gPhone.receiveRequest( data )
		elseif header == GPHONE_NET_RESPONSE then
			gPhone.receiveResponse( data )
		elseif header == GPHONE_START_CALL then
			local targetNum = data.number
			local callingNum = ply:getPhoneNumber()
			
			local targetPly = gPhone.getPlayerByNumber( targetNum )
			
			print("Calling", targetNum, callingNum)
			local reqStr = string.format( trans("being_called"), ply:Nick() )
			local id = gPhone.sendRequest( {sender=ply, app="phone", msg=reqStr}, targetPly )
			
			gPhone.waitForResponse( id, function( bAccepted, tbl ) 
				print("Got response!")
				if bAccepted == true then
					gPhone.createCall( ply, targetPly )
				else
					-- Timeout after a certain amount of time
				end
			end)
		elseif header == GPHONE_NEW_NUMBER then
			ply:generatePhoneNumber()
		elseif header == GPHONE_END_CALL then
			local id = gPhone.getCallID( ply )
			gPhone.endCall( id )
		end
	end)
	
	-- An 'eh' method of making sure the net messages are not spammed. 
	local nextCheck = 0
	hook.Add("Think", "gPhone_netAntiSpam", function()
		if CurTime() > nextCheck then
			for k, v in pairs(player.GetAll()) do
				if v.netCount and v.netCount > 100 then
					-- Kick the player for attempting to overflow net messages and lag the server, "code" 64
					gPhone.kick( v, 64 )
				end
				
				v.netCount = 0
			end
			
			nextCheck = CurTime() + 2
		end
	end)
end


if CLIENT then

	--// Receives a Server-side net message
	net.Receive( "gPhone_DataTransfer", function( len, ply )
		local data = net.ReadTable()
		local header = data.header
		
		
		if header == GPHONE_BUILD then
			gPhone.buildPhone()
		elseif header == GPHONE_RETURNAPP then
			local name, active = nil, gPhone.getActiveApp() 
			active = active or {}
			active.Data = active.Data or {}
			
			if active.Data.PrintName then
				name = active.Data.PrintName or nil
			end

			net.Start("gPhone_DataTransfer")
				net.WriteTable( {header=GPHONE_RETURNAPP, app=name} )
			net.SendToServer()
		elseif header == GPHONE_RUN_APPFUNC then
			local app = data.app
			local func = data.func
			local args = data.args
			
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
		elseif header == GPHONE_RUN_FUNC then
			local func = data.func
			local args = data.args
			
			for k, v in pairs(gPhone) do
				if k:lower() == func:lower() then
					gPhone[k]( unpack(args) )
					return
				end
			end
			
			gPhone.msgC( GPHONE_MSGC_WARNING, "Unable phone function "..func.."!")
		elseif header == GPHONE_MONEY_CONFIRMED then
			--[[local writeTable = {}
			data.header = nil
			data = data[1]
			
			
				Problemo:
			On Client - ALL transactions for any server will show up
			On Server - Server gets flooded with tons of .txt documents that might only contain 1 transaction
			
			No limit on logs
			
			
			if file.Exists( "gphone/appdata/t_log.txt", "DATA" ) then
				local readFile = file.Read( "gphone/appdata/t_log.txt", "DATA" )
				print("File exists", readFile)
				local readTable = util.JSONToTable( gPhone.unscrambleJSON( readFile ) ) 
				
				--table.Add( tbl, readTable )
				writeTable = readTable
				
				--local key = #writeTable+1
				table.insert( writeTable, 1, {amount=data.amount, target=data.target, time=data.time} )
				--writeTable[key] = {amount=data.amount, target=data.target, time=data.time}
				gPhone.msgC( GPHONE_MSGC_NONE, "Appending new transaction log into table")
			else
				gPhone.msgC( GPHONE_MSGC_WARNING, "No transaction file, creating one...")
				writeTable[1] = {amount=data.amount, target=data.target, time=data.time}
				
				PrintTable(writeTable)
			end
			
			local json = util.TableToJSON( writeTable )
			json = gPhone.scrambleJSON( json )
		
			file.CreateDir( "gphone" )
			file.Write( "gphone/appdata/t_log.txt", json)
			]]
		elseif header == GPHONE_TEXT_MSG then
			local tbl = data.data
			tbl.self = false
			
			gPhone.receiveTextMessage( tbl )
		elseif header == GPHONE_NET_REQUEST then
			gPhone.receiveRequest( data )
		elseif header == GPHONE_NET_RESPONSE then
			gPhone.receiveResponse( data )
		end
	end)

end