----// Serverside Utility Functions //----

local plymeta = FindMetaTable( "Player" )

function plymeta:SetTransferCooldown( time )
	self.FinishedCooldown = CurTime() + time
end

function plymeta:GetTransferCooldown()
	local timeLeft = self.FinishedCooldown or 0
	return timeLeft - CurTime()
end

function plymeta:GeneratePhoneNumber()
	if self:GetPData( "gPhone_Number", 0 ) != 0 then
		-- Already has a number, just set the networked string
		self:SetNWString( "gPhone_Number", self:GetPData( "gPhone_Number" ) )
		return
	end
	
	local number = gPhone.SteamIDToPhoneNumber( self )
	
	self:SetPData( "gPhone_Number", number )
	self:SetNWString( "gPhone_Number", number )
end 

function gPhone.ChatMsg( ply, text )
	net.Start("gPhone_ChatMsg")
		net.WriteString(tostring(text))
	net.Send(ply)
end

function gPhone.NotifyPlayer( ply, sender, msg )
	local data = {}
	data.header = GPHONE_NOTIFY
	data.sender = sender
	data.text = msg
	
	net.Start("gPhone_DataTransfer")
		net.WriteTable(data)
	net.Send( ply )
end

