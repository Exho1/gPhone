----// Shared Multiplayer Handler //----

gPhone.connectedPlayers = gPhone.connectedPlayers or {{"test"}}

local plymeta = FindMetaTable( "Player" )

-- Net message enumerations 
GPHONE_MP_PLAYER_QUIT = 1

if SERVER then

	--// Hook onto when a player responds to another player's request to play gPong
	hook.Add( "gPhone_responseSent", "test", function( sender, target, tbl, id )
		if tbl[3]:lower() == "gpong" then
			local accepted = tbl[5]
			
			if accepted then
				gPhone.waitForGame( sender, target, tbl[3]:lower(), id )
			end
		end
	end)

	--// Create a 'net stream' between 2 players in which tables of information are exchanged
	function gPhone.startNetStream( ply1, ply2, app, key )
		-- Generate a valid key if one is not provided. The key identifies this lobby
		key = key or #gPhone.connectedPlayers
		if key == 0 then key = 1 end
		
		gPhone.connectedPlayers[key] = {ply1=ply1, ply2=ply2, game=app}
		
		gPhone.msgC( GPHONE_MSGC_NONE, "Created net stream between: ", ply1, ply2, "SESSION ID: "..key )
		
		local app = app or ply1:getActiveApp() or ply2:getActiveApp()
		
		-- Tell both players to rotate their phones (if they haven't already) and launch up a multiplayer game
		-- I need to figure out a way to make this compatible with other apps as it only works with Pong
		gPhone.runFunction( ply1, "setOrientation", "landscape" )
		gPhone.runAppFunction( ply1, app, "SetUpGame", 2 )
		gPhone.runFunction( ply2, "setOrientation", "landscape" )
		gPhone.runAppFunction( ply2, app, "SetUpGame", 2 )
		
		local lastUpdate = CurTime()
		local seen = false
		local data = data or {}
		local nextStream = 0
		local failed = 0
		hook.Add("Think", "gPhone_MP_Update_"..key, function()
			-- The sender of the game invite is ALWAYS player 1 and the recipient is player 2
			
			if not IsValid( ply1 ) or not IsValid( ply2 ) then
				gPhone.endNetStream( ply1 )
				gPhone.endNetStream( ply2 )
			end
			
			-- This gives a false positive immediately after creating a match. Look into it
			--[[if ply1::GetNWBool("gPhone_InMPGame", false) or not ply2::GetNWBool("gPhone_InMPGame", false) then
				gPhone.endNetStream( ply1 )
				gPhone.endNetStream( ply2 )
			end]]
			
			if CurTime() > nextStream then
				-- Send the table to the necessary player
				if data.sender == ply2 then
					gPhone.streamData( data, ply1 )
				elseif data.sender == ply1 then
					gPhone.streamData( data, ply2 )
				else -- No client inputs yet
					gPhone.streamData( data, ply1 )
					gPhone.streamData( data, ply2 )
				end
				
				-- Slight delay
				nextStream = CurTime() + 0.1
			end
			
			-- Player has gone to the home screen or closed the phone
			if ply1:getActiveApp():lower() != app:lower() then
				gPhone.endNetStream( ply1 )
			elseif ply2:getActiveApp():lower() != app:lower() then
				gPhone.endNetStream( ply2 )
			end
			
			if CurTime() - lastUpdate > 5 and not seen then
				seen = true
				gPhone.msgC( GPHONE_MSGC_WARNING, "gPhone net stream has not received a message in over 5 seconds! Session: "..key )
				lastUpdate = CurTime()
				seen = false
				
				failed = failed + 1
				
				-- End the lobby after 5 failed attempts
				if failed == 5 then
					gPhone.msgC( GPHONE_MSGC_WARNING, "gPhone net stream has been removed due to no connection! Session: "..key )
					hook.Remove("Think", "gPhone_MP_Update_"..key)
					gPhone.endNetStream( ply1 )
					gPhone.endNetStream( ply2 )
				end
			end
		end)
		
		--// Receives a table of data from the client with positions
		net.Receive( "gPhone_MultiplayerStream", function( len, ply )
			data = net.ReadTable()
			
			if data.sender then
				lastUpdate = CurTime() 
				data.sender = ply -- Track who created this table
				
				ply.lastMPUpdate = ply.lastMPUpdate or {}
				
				-- Check to make sure we are not sending a repeat of the last table
				if ply.lastMPUpdate.ball and data.ball then
					if data.ball.x == ply.lastMPUpdate.ball.x and data.ball.y == ply.lastMPUpdate.ball.y then
						if data.paddle1.y == ply.lastMPUpdate.paddle1.y then
							-- Its a repeat, don't send it
							data = {}
							return
						end
					end
				end
				
				ply.lastMPUpdate = data
				
				if data.header == GPHONE_MP_PLAYER_QUIT then -- Player quit the game but is still in the app
					gPhone.msgC( GPHONE_MSGC_NOTIFY, "Player ("..ply:Nick()..") quit a multiplayer game" )
					gPhone.endNetStream( ply )
				end
			else -- No sender? Destroy the unknown table and send blank ones out
				data = {}
			end
		end)
		
		-- Set NWBools so ply:inMPGame returns true
		ply1:SetNWBool("gPhone_InMPGame", true)
		ply2:SetNWBool("gPhone_InMPGame", true)
	end
	
	--// Destroys the net stream that this player is in
	function gPhone.endNetStream( ply )
		if not IsValid(ply) then return end
		
		for i=1, #gPhone.connectedPlayers do
			local tab = gPhone.connectedPlayers[i]
			
			if ply == tab.ply1 or ply == tab.ply2 then
				gPhone.msgC( GPHONE_MSGC_NONE, "Ended net stream between ", tab.ply1, tab.ply2 )
				hook.Remove("Think", "gPhone_MP_Update_"..i)
				gPhone.connectedPlayers[i] = {}
				
				tab.ply1:SetNWBool("gPhone_InMPGame", false)
				tab.ply2:SetNWBool("gPhone_InMPGame", false)
			end
		end
	end
	
	--// Sends a table through the stream to a player
	function gPhone.streamData( tbl, ply )
		if IsValid(ply) then
			net.Start("gPhone_MultiplayerStream")
				net.WriteTable( tbl )
			net.Send( ply )
		else
			-- How can we remove them from the connected player table?
			gPhone.msgC( GPHONE_MSGC_WARNING, "Attempt to stream data to an invalid player")
		end
	end
	
	--// Waits for both players to be in the proper game before starting the net stream
	function gPhone.waitForGame( ply1, ply2, game, id )
		hook.Add("Think", "gPhone_MP_Wait_"..id, function()
			if ply1:getActiveApp():lower() == game:lower() and ply2:getActiveApp():lower() == game:lower() then
				hook.Remove("Think", "gPhone_MP_Wait_"..id)
				gPhone.startNetStream( ply1, ply2, game )
			end
		end)
	end
end

if CLIENT then
	local client = LocalPlayer()
	
	if not client.inMPGame then
	
	end
	
	--// Send a table to the server to be distributed amongst the connected players
	function gPhone.updateToNetStream( data )
		if client.inMPGame and client:GetNWBool("gPhone_InMPGame", false) then
			data.sender = client
			
			net.Start("gPhone_MultiplayerStream")
				net.WriteTable( data )
			net.SendToServer()
		else
			gPhone.msgC( GPHONE_MSGC_WARNING, "Cannot update to net stream outside of a multiplayer game!" )
		end
	end
	
	--// Receive the server-side data
	local lastUpdate, failCount = CurTime() + 5, 0
	net.Receive( "gPhone_MultiplayerStream", function( len, ply )
		streamTable = net.ReadTable()
		
		if table.Count(streamTable) > 0 then
			lastUpdate = CurTime()
			failCount = 0
		end
		
		--// Returns the stream table
		function gPhone.updateFromNetStream()
			return streamTable
		end
	end)
	
	--// Check if the server is continuing to stream data to us
	local seen = false
	hook.Add("Think", "gPhone_CheckConnected", function()
		if client:GetNWBool("gPhone_InMPGame", false) then
			if CurTime() - lastUpdate > 5 and not seen then
				seen = true
				
				gPhone.msgC( GPHONE_MSGC_WARNING, "gPhone net stream has not received a message in over 5 seconds!")
				failCount = failCount + 1
				lastUpdate = CurTime()
				
				if failCount % 5 == 0 then
					gPhone.chatMsg( "gPhone multiplayer has lost connection!" )
					hook.Remove("Think", "gPhone_CheckConnected")
				end
				
				seen = false
			end
		end
	end)
end




