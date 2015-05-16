----// Shared Multiplayer Handler //----

<<<<<<< HEAD
gPhone.connectedPlayers = gPhone.connectedPlayers or {{"test"}}

local plymeta = FindMetaTable( "Player" )

--// Returns if the player is currently in a multiplayer game with other players
function plymeta:inMPGame()
	return self:GetNWBool("gPhone_InMPGame", false)
end

-- Net message enumerations 
GPHONE_MP_PLAYER_QUIT = 1
=======
--[[
gPhone.connectedPlayers = gPhone.connectedPlayers or {}
>>>>>>> parent of 804b3cd... Rewrote and re-enabled multiplayer for gPong

if SERVER then

	--// Create a 'net stream' between 2 players in which tables of information are exchanged
	function gPhone.startNetStream( ply1, ply2, app, key )
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
		hook.Add("Think", "gPhone_MP_Update_"..key, function()
			-- The sender of the game invite is ALWAYS player 1 and the recipient is player 2
			
<<<<<<< HEAD
			if not IsValid( ply1 ) or not IsValid( ply2 ) then
				gPhone.endNetStream( ply1 )
				gPhone.endNetStream( ply2 )
			end
			
			-- This gives a false positive immediately after creating a match. Look into it
			--[[if ply1:inMPGame() or not ply2:inMPGame() then
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
=======
			-- Send the table to the necessary player
			if data.sender == ply2 then
				gPhone.streamData( data, ply1 )
			elseif data.sender == ply1 then
				gPhone.streamData( data, ply2 )
			else -- No client inputs yet
				gPhone.streamData( data, ply1 )
				gPhone.streamData( data, ply2 )
>>>>>>> parent of 804b3cd... Rewrote and re-enabled multiplayer for gPong
			end
			
			-- Player has gone to the home screen or closed the phone
			if ply1:getActiveApp() == "" or ply1:getActiveApp() == nil then
				gPhone.endNetStream( ply1 )
			elseif ply2:getActiveApp() == "" or ply2:getActiveApp() == nil then
				gPhone.endNetStream( ply2 )
			end
			
			if CurTime() - lastUpdate > 5 and not seen then
				seen = true
				gPhone.msgC( GPHONE_MSGC_WARNING, "gPhone net stream has not received a message in over 5 seconds! Session: "..key )
				lastUpdate = CurTime()
				seen = false
			end
		end)
		
		
		net.Receive( "gPhone_MultiplayerStream", function( len, ply )
			data = net.ReadTable()
			print("recieve", data.sender, data.header == GPHONE_MP_PLAYER_QUIT)
			if data.sender then
				lastUpdate = CurTime() 
				data.sender = ply -- Track who created this table
				
				if data.header == GPHONE_MP_PLAYER_QUIT then -- Player quit the game but is still in the app
					gPhone.msgC( GPHONE_MSGC_NOTIFY, "Player ("..tostring(ply)..") quit" )
					gPhone.endNetStream( ply )
				end
			else -- No sender? Destroy the unknown table and send blank ones out
				data = {}
			end
		end)
		
		ply1:SetNWBool("gPhone_InMPGame", true)
		ply2:SetNWBool("gPhone_InMPGame", true)
	end
	
	--// Destroys the net stream that this player is in
	function gPhone.endNetStream( ply )
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
	
	function gPhone.waitForGame( ply1, ply2, game, id )
		print("start game wait")
		hook.Add("Think", "gPhone_MP_Wait_"..id, function()
			if ply1:getActiveApp():lower() == game:lower() and ply2:getActiveApp():lower() == game:lower() then
				print("Both players ready")
				hook.Remove("Think", "gPhone_MP_Wait_"..id)
				gPhone.startNetStream( sender, target, game )
			end
		end)
	end
	
	--// Receive multiplayer data
	net.Receive( "gPhone_MultiplayerData", function( len, ply )
		local data = net.ReadTable()
		local header = data.header
		
		print("Received multiplayer data")
		
		if header == GPHONE_MP_REQUEST then
			-- The sender of the invitation is ALWAYS player 1 and the recipient is player 2
			local sender = ply or data.ply1
			local target = data.ply2
			local game = data.game
			
			if sender:hasPhoneOpen() then
				
				-- TEMP: Stop anyone from using it while its broken
				if true then
					gPhone.chatMsg( ply, "Multiplayer is not implemented at the moment, sorry" )
					gPhone.runAppFunction( ply, game, "QuitToMainMenu" )
					gPhone.runFunction( ply1, "setOrientation", "portrait" )
					return
				end
				
				gPhone.chatMsg(ply, "Challenged "..ply:Nick().."!")
			
				-- TEMP: Push to net stream later, after they accept
				--gPhone.startNetStream( sender, target, game )
				-- TEMP: First argument should be ply
				gPhone.invitePlayer( target, sender, game )
			else
				gPhone.msgC( GPHONE_MSGC_WARNING, sender:Nick().." attempted to request a multiplayer game outside of the gPhone!")
			end
		elseif header == GPHONE_MP_REQUEST_RESPONSE then
			local sender = ply
			local target = data.target
			local response = data.accepted
			local game = data.game
			
			print("Request response", sender, target, response, game)
			
			-- Have the phone tell the player of the response
			if response == true then
				local text = sender:Nick().." has accepted your offer to play "..game
				gPhone.sendResponse( target, game, text )
				
				local key = #gPhone.connectedPlayers + 1
				gPhone.connectedPlayers[key] = {ply1=target, ply2=sender, game=game}
				
				gPhone.waitForGame( target, sender, game, key )
			else
				local text = sender:Nick().." has delined your offer to play "..game
				gPhone.sendResponse( target, game, text )
			end
		end
	end)
	
	-- Function name conflicts
	function gPhone.sendResponse( ply, game, msg )
		net.Start("gPhone_MultiplayerData")
			net.WriteTable( {header=GPHONE_MP_REQUEST_RESPONSE, game=game, msg=msg} )
		net.Send( ply )	
	end
	
	function gPhone.invitePlayer( ply, sender, game )
		net.Start("gPhone_MultiplayerData")
			net.WriteTable( {header=GPHONE_MP_REQUEST, sender=sender, game=game} )
		net.Send( ply )
	end
end

if CLIENT then
	local client = LocalPlayer()
	
<<<<<<< HEAD
<<<<<<< HEAD
	if not client.inMPGame then
	
=======
	--// Receive multiplayer data
	net.Receive( "gPhone_MultiplayerData", function( len, ply )
		local data = net.ReadTable()
		local header = data.header
		
		print("Received multiplayer data")
		
		if header == GPHONE_MP_REQUEST then
			local sender = data.sender
			local game = data.game
			
			print("Request", sender, game)
			
			local msg = sender:Nick().." has invited you to play "..game
			
			if gPhone.isInApp() then
				gPhone.notifyBanner( {msg=msg, game=game}, function()
					gPhone.sendRequestResult( sender, game, true )
					gPhone.runApp( game )
				end)
			else
				if not gPhone.isOpen() then
					gPhone.vibrate()
				end
				
				-- Notify the player about the game invite
				gPhone.notifyAlert( {msg=msg, title="Multiplayer", options={"Deny", "Accept"}},
				function( pnl, value )
					gPhone.sendRequestResult( sender, game, false )
				end,
				function( pnl, value )
					gPhone.sendRequestResult( sender, game, true )
					gPhone.runApp( game )
				end,
				false, true)
			end
		elseif header == GPHONE_MP_REQUEST_RESPONSE then
			local text = data.msg
			local game = data.game
			
			-- Banner notify the client of the response
			gPhone.notifyBanner( {msg=text, app=game}, function()
				-- What is this for?
				--gPhone.sendRequestResult( sender, game, true )
				--gPhone.runApp( game )
			end)
		end
	end)

	--// Request a player to join in a game
	function gPhone.requestGame(target, game)
		if client.hasPhoneOpen and client:hasPhoneOpen() then
			if client.inMPGame and not client:inMPGame() then
				net.Start("gPhone_MultiplayerData")
					net.WriteTable( { header=GPHONE_MP_REQUEST, ply2=target, game=game} )
				net.SendToServer()
			else
				gPhone.msgC( GPHONE_MSGC_WARNING, "Cannot request a multiplayer game while already in one!" )
			end
		else
			gPhone.msgC( GPHONE_MSGC_WARNING, "Cannot request a multiplayer game without a phone!" )
		end
	end
	
	function gPhone.sendRequestResult( target, game, bAccepted )
		print("Request result", target, game, bAccepted)
		net.Start("gPhone_MultiplayerData")
			net.WriteTable( { header=GPHONE_MP_REQUEST_RESPONSE, target=target, game=game, accepted=bAccepted} )
		net.SendToServer()	
>>>>>>> parent of 804b3cd... Rewrote and re-enabled multiplayer for gPong
	end
	
	--// Send a table to the server to be distributed amongst the connected players
	function gPhone.updateToNetStream( data )
<<<<<<< HEAD
		if client.inMPGame and client:GetNWBool("gPhone_InMPGame", false) then
=======
	--// Send a table to the server to be distributed amongst the connected players
	function gPhone.updateToNetStream( data )
		if client:inMPGame() then
>>>>>>> parent of ff2889e... Removed ply:inMPGame and fixed some MP bugs
			data.sender = client
			
=======
		if client:inMPGame() then
>>>>>>> parent of 804b3cd... Rewrote and re-enabled multiplayer for gPong
			net.Start("gPhone_MultiplayerStream")
				net.WriteTable( data )
			net.SendToServer()
		else
			gPhone.msgC( GPHONE_MSGC_WARNING, "Cannot update to net stream outside of a multiplayer game!" )
		end
	end
	
	--// Return an updated table from the server
	local streamTable = {}
	local lastUpdate, failCount = CurTime() + 5, 0
	function gPhone.updateFromNetStream()
		return streamTable
	end

	net.Receive( "gPhone_MultiplayerStream", function( len, ply )
		streamTable = net.ReadTable()
		if table.Count(streamTable) > 0 then -- the # operator doesn't seem to work here
			lastUpdate = CurTime()
			failCount = 0
		end
	end)
	
	--// Check if the server is continuing to stream data to us
	local seen = false
	hook.Add("Think", "gPhone_CheckConnected", function()
<<<<<<< HEAD
<<<<<<< HEAD
		if client:GetNWBool("gPhone_InMPGame", false) then
=======
		if client.inMPGame and client:inMPGame() then -- Meta function hasn't loaded yet
>>>>>>> parent of 804b3cd... Rewrote and re-enabled multiplayer for gPong
=======
		if client.inMPGame and client:inMPGame() then
>>>>>>> parent of ff2889e... Removed ply:inMPGame and fixed some MP bugs
			if CurTime() - lastUpdate > 5 and not seen then
				seen = true
				
				gPhone.msgC( GPHONE_MSGC_WARNING, "gPhone net stream has not received a message in over 5 seconds!")
				failCount = failCount + 1
				lastUpdate = CurTime()
				
				if failCount % 5 == 0 then
					gPhone.chatMsg( "gPhone multiplayer is losing connection!" )
				end
				
				seen = false
			end
		end
	end)
end

]]



