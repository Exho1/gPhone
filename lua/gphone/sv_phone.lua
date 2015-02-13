----// Serverside Phone //----

--// Resourcing and app adding
resource.AddFile( "materials/vgui/gphone/gPhone.png" )
resource.AddFile( "resource/fonts/roboto_light.tff" )
resource.AddFile( "sound/gphone/vibrate.wav" )
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
files = file.Find( "gphone/apps/*.lua", "LUA" ) -- Apps
for k, v in pairs(files) do
	AddCSLuaFile("apps/"..v)
end

--// Meta table
local plymeta = FindMetaTable( "Player" )

function plymeta:setTransferCooldown( time )
	self.transferCooldown = CurTime() + time
end

function plymeta:getTransferCooldown()
	local timeLeft = self.transferCooldown or 0
	return timeLeft - CurTime()
end

function plymeta:generatePhoneNumber()
	if self:GetPData( "gPhone_Number", gPhone.invalidNumber ) != gPhone.invalidNumber then
		-- Already has a number, just set the networked string
		self:SetNWString( "gPhone_Number", self:GetPData( "gPhone_Number" ) )
		return
	end
	
	local number = gPhone.steamIDToPhoneNumber( self )
	
	self:SetPData( "gPhone_Number", number )
	self:SetNWString( "gPhone_Number", number )
end 

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

--// Confirms a transaction
function gPhone.confirmTransaction( ply, tbl )
	net.Start("gPhone_DataTransfer")
		net.WriteTable( {header=GPHONE_MONEY_CONFIRMED, tbl} ) 
	net.Send( ply )
end

--// Sends a notification to the player using one of the GPHONE_NOTIFY enumeratiosn
function gPhone.notifyPlayer( ply, sender, text, enum )
	net.Start("gPhone_DataTransfer")
		net.WriteTable( {header=enum, sender=sender, text=text} )
	net.Send( ply )
end

--// Runs a function in the gPhone app table
function gPhone.runAppFunction( ply, app, name, ... )
	net.Start("gPhone_DataTransfer")
		net.WriteTable( {header=GPHONE_RUN_APPFUNC, app=app, func=name, args={...}} ) 
	net.Send( ply )
end

--// Runs a function in the gPhone table
function gPhone.runFunction( ply, name, ... )
	net.Start("gPhone_DataTransfer")
		net.WriteTable( {header=GPHONE_RUN_FUNC, func=name, args={...}} ) 
	net.Send( ply )
end

--// Various gameplay hooks and what not
hook.Add("PlayerInitialSpawn", "gPhone_GenerateNumber", function( ply )
	ply:generatePhoneNumber()

	net.Start("gPhone_DataTransfer")
		net.WriteTable( {header=GPHONE_BUILD} )
	net.Send( ply )
end)

hook.Add("PlayerDeath", "gPhone_HideOnDeath", function( ply )
	gPhone.runFunction( ply, "hidePhone" )
end)

hook.Add("PlayerCanHearPlayersVoice", "gPhone_CallHandler", function( listener, talker )
	if listener:isInCall() and talker:isInCall() then
		return true
	elseif talker:isInCall() and not listener:isInCall() then
		return false
	elseif listener:isInCall() and not talker:isInCall() then
		return false
	end
end)




