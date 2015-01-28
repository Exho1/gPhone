----// Serverside Utility Functions //----

local plymeta = FindMetaTable( "Player" )

function plymeta:setTransferCooldown( time )
	self.FinishedCooldown = CurTime() + time
end

function plymeta:getTransferCooldown()
	local timeLeft = self.FinishedCooldown or 0
	return timeLeft - CurTime()
end

function plymeta:generatePhoneNumber()
	if self:GetPData( "gPhone_Number", 0 ) != 0 then
		-- Already has a number, just set the networked string
		self:SetNWString( "gPhone_Number", self:GetPData( "gPhone_Number" ) )
		return
	end
	
	local number = gPhone.steamIDToPhoneNumber( self )
	
	self:SetPData( "gPhone_Number", number )
	self:SetNWString( "gPhone_Number", number )
end 

--// AddCSLuaFiles all the files with the correct prefix
function gPhone.addCSLuaFile( dir )
	local filesSH = file.Find( dir.."/sh_*.lua", "LUA" )
	
	local files = file.Find( dir.."/cl_*.lua", "LUA" )
	for k, v in pairs(files) do
		AddCSLuaFile( dir.."/"..v )
	end
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

function gPhone.confirmTransaction( ply, tbl )
	net.Start("gPhone_DataTransfer")
		net.WriteTable( {header=GPHONE_MONEY_CONFIRMED, tbl} ) 
	net.Send( ply )
end

function gPhone.notifyPlayer( ply, sender, text, notifyEnum )
	net.Start("gPhone_DataTransfer")
		net.WriteTable( {header=notifyEnum, sender=sender, text=text} )
	net.Send( ply )
end

--// Runs a function in the app table
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


