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

local plymeta = FindMetaTable( "Player" )
function plymeta:IsInGame()
	
end

if SERVER then
	
	net.Receive( "gPhone_MultiplayerData", function( len, ply )
		local data = net.ReadTable()
		local dataHeader = data.header
		
		if dataHeader == GPHONE_MP_REQUEST then -- Requesting a game between 2 players
			local sender = ply 
			local target = data.ply2
			local game = data.game
			
			print(sender, target, game)
			
			gPhone.InviteToGame( target, sender, game )
		else
		
		end
	end)
	
	function gPhone.InviteToGame( ply, sender, game )
		gPhone.NotifyPlayer( ply, sender, msg )
	end
	
end

if CLIENT then
	local client = LocalPlayer()

	--// Request a player to join in a game
	function gPhone.RequestGame(target, game)
		net.Start("gPhone_MultiplayerData")
			net.WriteTable( { header=GPHONE_MP_REQUEST, ply2=target, game=game} )
		net.SendToServer()
		
		net.Receive( "gPhone_MultiplayerData", function( len, ply )
			local data = net.ReadTable()
			local dataHeader = data.header
			
			if dataHeader == GPHONE_MP_REQUEST_RESPONSE then
				
			end
		end)
	end
	
	
	
end

