----// Serverside Phone //----

local trans = gPhone.getTranslation

--// Resourcing and app adding
resource.AddFile( "materials/vgui/gphone/gphone.png" )
resource.AddFile( "resource/fonts/roboto_light.tff" )
resource.AddFile( "resource/fonts/04b_19.tff" )
local files = file.Find( "materials/vgui/gphone/*.png", "GAME" ) -- Phone images
for k, v in pairs(files) do
	resource.AddFile("materials/vgui/gphone/"..v)
end
files = file.Find( "materials/vgui/gphone/wallpapers/*.png", "GAME" ) -- Wallpapers
for k, v in pairs(files) do
	resource.AddFile("materials/vgui/gphone/wallpapers/"..v)
end
files = file.Find( "materials/vgui/gphone/apps/*.png", "GAME" ) -- App images
for k, v in pairs(files) do
	resource.AddFile("materials/vgui/gphone/apps/"..v)
end
files = file.Find( "sound/gphone/*", "GAME" ) -- Sounds
for k, v in pairs(files) do
	resource.AddFile("sound/gphone/"..v)
end

--// Meta table
local plymeta = FindMetaTable( "Player" )

function plymeta:setCanOpenPhone( b )
	self:SetNWBool( "gPhone_canOpen", b )
end

function plymeta:setTransferCooldown( time )
	self.transferCooldown = CurTime() + time
end

function plymeta:getTransferCooldown()
	local timeLeft = self.transferCooldown or CurTime()
	return timeLeft - CurTime()
end

function plymeta:getCurApp()
	return self:GetNWString("gPhone_CurApp", nil)
end

function plymeta:generatePhoneNumber()
	gPhone.msgC( GPHONE_MSGC_NONE, "Generating number for "..self:Nick() )
	
	local number = self:GetPData( "gPhone_Number", gPhone.invalidNumber )
	if number != gPhone.invalidNumber then
		gPhone.msgC( GPHONE_MSGC_NONE, self:Nick().." has phone number: "..self:GetPData( "gPhone_Number"))
		
		-- Already has a number, just set the networked string
		self:SetNWString( "gPhone_Number", number )
		return
	end
	
	local number = gPhone.steamIDToPhoneNumber( self )
	
	self:SetPData( "gPhone_Number", number )
	self:SetNWString( "gPhone_Number", number )
	
	return number
end 

function plymeta:inCallWith( ply2 )
	if self:GetNWBool("gPhone_InCall") == true and ply2:GetNWBool("gPhone_InCall") == true then
		for id, tbl in pairs( gPhone.callingPlayers ) do
			if tbl[1] == self or tbl[2] == self and tbl[1] == ply or tbl[2] == ply then
				return true
			end
		end
	end
	return false
end

gPhone.callingPlayers = {}

--// Creates a phone call between 2 players
function gPhone.createCall( ply1, ply2 )
	local id = nil
	
	if not ply1:inCall() and not ply2:inCall() then
		if IsValid(ply1) and IsValid(ply2) then
			id = #gPhone.callingPlayers + 1
			
			gPhone.msgC(GPHONE_MSGC_NONE, "Created call between "..tostring(ply1).." and "..tostring(ply2))
			gPhone.callingPlayers[id] = {ply1, ply2}
			ply1:SetNWBool("gPhone_InCall", true)
			ply2:SetNWBool("gPhone_InCall", true)
			
			-- To keep track of who they are currently calling
			ply1:SetNWString("gPhone_CallingNumber", ply2:getPhoneNumber())
			ply2:SetNWString("gPhone_CallingNumber", ply1:getPhoneNumber())
		end	
	end
	
	return id
end

--// End a created call from its id
function gPhone.endCall( id )
	if gPhone.callingPlayers[id] then
		gPhone.msgC(GPHONE_MSGC_NONE, "Ended call id ("..id..")")
		for k, caller in pairs( gPhone.callingPlayers[id] ) do
			caller:SetNWBool("gPhone_InCall", false)
			
			-- Set it to their number to prevent errors
			caller:SetNWString("gPhone_CallingNumber", caller:getPhoneNumber())
		end
		
		gPhone.callingPlayers[id] = {}
	end
end

--// Adds another player into the phone call
-- TODO: Implement this and edit the overhead to help manage
-- Also will need a function to remove a player from a call 
-- Make it so the call is ended when less than 2 people are in it
function gPhone.addToCall( id, ply )
	if gPhone.callingPlayers[id] != nil and gPhone.callingPlayers[id] != {} then
		table.insert( gPhone.callingPlayers[id], ply )
	else
		gPhone.msgC( GPHONE_MSGC_WARNING, "Attempted to add player("..tostring(ply)..") to an invalid call id ("..id..")" )
	end
end

--// Returns the ID of the call the player is currently in
function gPhone.getCallID( ply )
	for id, tbl in pairs(gPhone.callingPlayers) do
		if ply == tbl[1] or ply == tbl[2] then
			return id
		end
	end
end

--// Returns a table of players for that id
function gPhone.getCallParticipants( id )
	return gPhone.callingPlayers[id]
end

--// Manages all of the current calls
hook.Add("Think", "gPhone_phoneOverhead", function()
	for id, tbl in pairs(gPhone.callingPlayers) do
		if IsValid(tbl[1]) and IsValid(tbl[2]) then
			local ply1 = tbl[1]
			local ply2 = tbl[2]
			
			if ply1:getActiveApp() == "" or ply1:getActiveApp() == nil then
				gPhone.endCall( id )
			elseif ply2:getActiveApp() == "" or ply2:getActiveApp() == nil then
				gPhone.endCall( id )
			end
			
		end
	end
end)

--// Sends a message to appears in the player's chat box
function gPhone.chatMsg( ply, text )
	net.Start("gPhone_ChatMsg")
		net.WriteString(tostring(text))
	net.Send(ply)
end

--// Sends a chat message to connected administrators
function gPhone.adminMsg( text )
	for _, ply in pairs( player.GetAll() ) do
		for _, group in pairs( gPhone.config.adminGroups ) do
			if ply:GetUserGroup():lower() == group:lower() then
				gPhone.chatMsg( ply, text )
			end
		end
	end
end

--// Kicks a player and gives them a fancy hex string to make it look legit or something
function gPhone.kick( ply, code ) 
	ply:Kick( string.format( trans("kick"), code ) )
end

--// Sends a notification to the player
function gPhone.notifyPlayer( type, ply, tbl, bOneOption )
	type = type:lower()
	
	if type == "banner" then
		net.Start( "gPhone_Notify" )
			net.WriteBit( true )
			net.WriteString( tbl.msg or tbl.message )
			net.WriteString( tbl.app )
			net.WriteString( tbl.title or tbl.app ) 
		net.Send( ply )
	else
		net.Start( "gPhone_Notify" )
			net.WriteBit( false )
			net.WriteString( tbl.msg or tbl.message )
			net.WriteString( tbl.title )
			net.WriteString( tbl.options[1] )
			net.WriteString( tbl.options[2] )
			net.WriteBool( bOneOption or false )
		net.Send( ply )
	end
end

--// Runs a function in the gPhone app table
function gPhone.runAppFunction( ply, app, name, ... )
	net.Start("gPhone_RunFunction")
		--gPhone.writeTable({"app", app, name, {...}})
		net.WriteString("app")
		net.WriteString(app)
		net.WriteString(name)
		net.WriteTable({...})
	net.Send( ply )
end

--// Runs a function in the gPhone table
function gPhone.runFunction( ply, name, ... )
	net.Start("gPhone_RunFunction")
		--gPhone.writeTable({"phone", "", name, {...}})
		net.WriteString("phone")
		net.WriteString("")
		net.WriteString(name)
		net.WriteTable({...})
	net.Send( ply )
end

--// Various gameplay hooks and what not
hook.Add("PlayerInitialSpawn", "gPhone_generateNumber", function( ply )
	ply:generatePhoneNumber()

	gPhone.runFunction( ply, "buildPhone" )
end)

hook.Add("PlayerDeath", "gPhone_HideOnDeath", function( ply )
	gPhone.runFunction( ply, "hidePhone" )
end)

hook.Add("PlayerCanHearPlayersVoice", "gPhone_CallHandler", function( listener, talker )
	if listener:inCallWith( talker ) and talker:inCallWith( listener ) then
		return true
	end
end)

hook.Add("playerArrested", "gPhone_jailTime", function( ply, time, arrester )
	gPhone.runFunction( ply, "destroyPhone" )
	ply:setCanOpenPhone( false )
	gPhone.chatMsg( ply, trans("phone_confis") )
end)

hook.Add("playerUnArrested", "gPhone_returnPossessions", function( ply, arrester )
	gPhone.runFunction( ply, "buildPhone" )
	ply:setCanOpenPhone( true )
end)




