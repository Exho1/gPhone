----// Shared Multiplayer Handler //----

--[[
	// Plan //
- Multiplayer Request:
1. Client sends request to server with Game and Target
2. Server notifies Target with Game and Client
3. Target chooses to accept or deny then sends to server
4. Server notifies Client
5. Create a multiplayer game if needed



]]

gPhone.ConnectedPlayers = gPhone.ConnectedPlayers or {}


local plymeta = FindMetaTable( "Player" )

--// Returns if the player is currently in a multiplayer game with other players
function plymeta:IsInMPGame()
	return self:GetNWBool("gPhone_InMPGame", false)
end

if SERVER then

	--// Create a 'data stream' between 2 players in which tables of information are exchanged
	function gPhone.StartDataStream( ply1, ply2, app )
		local key = #gPhone.ConnectedPlayers + 1
		gPhone.MsgC( GPHONE_MSGC_NONE, "Created Data Stream between: ", ply1, ply2, "SESSION ID: "..key )
		
		local app = app or ply1:GetApp() or ply2:GetApp()
		
		-- Tell both players to rotate their phones (if they haven't already) and launch up a multiplayer game
		-- I need to figure out a way to make this compatible with other apps as it only works with Pong
		gPhone.RunFunction( ply1, app, "RotateToLandscape" )
		gPhone.RunAppFunction( ply1, app, "SetUpGame", 2 )
		gPhone.RunFunction( ply2, app, "RotateToLandscape" )
		gPhone.RunAppFunction( ply2, app, "SetUpGame", 2 )
		
		local lastUpdate = CurTime()
		local seen = false
		local data = data or {}
		hook.Add("Think", "gPhone_MP_Update_"..key, function()
			-- The sender of the game invite is ALWAYS player 1 and the recipient is player 2
			
			-- Send the table to the necessary player
			--if data.sender == ply2 then
			--	gPhone.StreamData( data, ply1 )
			--elseif data.sender == ply1 then
			--	gPhone.StreamData( data, ply2 )
			--else -- No client inputs yet
				gPhone.StreamData( data, ply1 )
				gPhone.StreamData( data, ply2 )
			--end
			
			-- Player has gone to the home screen or closed the phone
			if ply1:GetApp() == "" or ply1:GetApp() == nil then
				gPhone.EndDataStream( ply1 )
			end
			--elseif ply2:GetApp() == "" or ply2:GetApp() == nil then
			--	gPhone.EndDataStream( ply2 )
			--end
			
			if CurTime() - lastUpdate > 5 and not seen then
				seen = true
				gPhone.MsgC( GPHONE_MSGC_WARNING, "gPhone Data Stream has not received a message in over 5 seconds! Session: "..key )
				lastUpdate = CurTime()
				seen = false
			end
		end)
		
		
		net.Receive( "gPhone_MultiplayerStream", function( len, ply )
			data = net.ReadTable()
			if data.sender then
				lastUpdate = CurTime() 
				data.sender = ply -- Track who created this table
				
				if data.header == GPHONE_MP_PLAYER_QUIT then -- Player quit the game but is still in the app
					gPhone.EndDataStream( ply )
				end
			else -- No sender? Destroy the unknown table and send blank ones out
				data = {}
			end
		end)
		
		ply1:SetNWBool("gPhone_InMPGame", true)
		ply2:SetNWBool("gPhone_InMPGame", true)
		gPhone.ConnectedPlayers[key] = {ply1=ply1, ply2=ply2, game=app}
	end
	
	--// Destroys the data stream that this player is in
	function gPhone.EndDataStream( ply )
		for i=1, #gPhone.ConnectedPlayers do
			local tab = gPhone.ConnectedPlayers[i]
			
			if ply == tab.ply1 or ply == tab.ply2 then
				gPhone.MsgC( GPHONE_MSGC_NONE, "Ended data stream between ", tab.ply1, tab.ply2 )
				hook.Remove("Think", "gPhone_MP_Update_"..i)
				gPhone.ConnectedPlayers[i] = {}
				
				tab.ply1:SetNWBool("gPhone_InMPGame", false)
				tab.ply2:SetNWBool("gPhone_InMPGame", false)
			end
		end
	end
	
	--// Sends a table through the stream to a player
	function gPhone.StreamData( tbl, ply )
		if IsValid(ply) then
			net.Start("gPhone_MultiplayerStream")
				net.WriteTable( tbl )
			net.Send( ply )
		else
			-- How can we remove them from the connected player table?
			gPhone.MsgC( GPHONE_MSGC_WARNING, "Attempt to stream data to an invalid player")
		end
	end
	
	--// Receive multiplayer data
	net.Receive( "gPhone_MultiplayerData", function( len, ply )
		local data = net.ReadTable()
		local header = data.header
		
		if header == GPHONE_MP_REQUEST then -- Requesting a game between 2 players
			-- The sender of the invitation is ALWAYS player 1 and the recipient is player 2
			local sender = ply or data.ply1
			local target = data.ply2
			local game = data.game
			
			if sender:HasPhoneOpen() then
				if target:HasPhoneOpen() then
					-- Pop up notification
				else
					-- Vibrate
				end
			
				-- TEMP: Push to data stream later, after they accept
				gPhone.StartDataStream( sender, target, game )
				
				-- TEMP: I invite myself to test
				local response = gPhone.NotifyPlayer( sender, sender, game, GPHONE_NOTIFY_GAME ) -- TEMP: First arg should be target
			else
				gPhone.MsgC( GPHONE_MSGC_WARNING, sender:Nick().." attempted to request a multiplayer game outside of the gPhone!")
			end
		else
		
		end
	end)
end

if CLIENT then
	local client = LocalPlayer()
	
	--// Receive multiplayer data
	net.Receive( "gPhone_MultiplayerData", function( len, ply )
		local data = net.ReadTable()
		local header = data.header
		
		if header == GPHONE_MP_REQUEST_RESPONSE then
			
		end
	end)

	--// Request a player to join in a game
	function gPhone.RequestGame(target, game)
		if not client:IsInMPGame() and client:HasPhoneOpen() then
			net.Start("gPhone_MultiplayerData")
				net.WriteTable( { header=GPHONE_MP_REQUEST, ply2=target, game=game} )
			net.SendToServer()
			
			-- Return the answer
			
		elseif client:HasPhoneOpen() then
			gPhone.MsgC( GPHONE_MSGC_WARNING, "Cannot request a multiplayer game while already in one!" )
		else
			gPhone.MsgC( GPHONE_MSGC_WARNING, "Cannot request a multiplayer game without a phone!" )
		end
	end
	
	--// Send a table to the server to be distributed amongst the connected players
	function gPhone.UpdateToDataStream( data )
		if client:IsInMPGame() then
			net.Start("gPhone_MultiplayerStream")
				net.WriteTable( data )
			net.SendToServer()
		else
			gPhone.MsgC( GPHONE_MSGC_WARNING, "Cannot update to Data Stream outside of a multiplayer game!" )
		end
	end
	
	--// Return an updated table from the server
	local streamTable = {}
	local lastUpdate, failCount = CurTime() + 5, 0
	function gPhone.UpdateFromDataStream()
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
		if client.IsInMPGame and client:IsInMPGame() then -- Meta function hasn't loaded yet
			if CurTime() - lastUpdate > 5 and not seen then
				seen = true
				
				gPhone.MsgC( GPHONE_MSGC_WARNING, "gPhone Data Stream has not received a message in over 5 seconds!")
				failCount = failCount + 1
				lastUpdate = CurTime()
				
				if failCount % 5 == 0 then
					gPhone.ChatMsg( "gPhone multiplayer is losing connection!" )
				end
				
				seen = false
			end
		end
	end)
end

