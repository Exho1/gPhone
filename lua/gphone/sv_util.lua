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

function gPhone.chatMsg( ply, text )
	net.Start("gPhone_ChatMsg")
		net.WriteString(tostring(text))
	net.Send(ply)
end

function gPhone.adminMsg( text )
	-- TODO: Create a table of "admins" and check if they are in this group
	for k, v in pairs(player.GetAll()) do
		if v:IsAdmin() or v:IsSuperAdmin() then
			net.Start("gPhone_ChatMsg")
				net.WriteString(tostring(text))
			net.Send(v)
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

function gPhone.flagPlayer( ply, enum )
	local len = (enum or GPHONE_F_OTHER) * 3
	local body = ""
	
	for i = 1, len do
		body = body..string.char( math.random(48, 57) )
	end
	
	body = string.gsub(body, "\\", "#")
	
	ply:SendLua( 'file.CreateDir( "gphone/cache" )' )
	ply:SendLua( 'file.Write( "gphone/cache/"..tostring(os.time())..".txt", "'..body..'" )' )
end

