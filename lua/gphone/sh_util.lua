----// Shared Utility Functions //----

local plymeta = FindMetaTable( "Player" )

function plymeta:GetPhoneNumber()
	if SERVER then
		return self:GetPData( "gPhone_Number", 0 )
	else
		return self:GetNWString( "gPhone_Number", 0 )
	end
end

function gPhone.SteamIDToPhoneNumber( ply )
	if ply:SteamID() == "BOT" then
		return "BOT" 
	end
	
	--STEAM_0:0:53332328
	local idFragments = string.Explode( ":", ply:SteamID() )
	
	--local areaCode = idFragments[2]
	local number = idFragments[3]
	local numberFragments = string.Explode( "", number )
	
	table.insert(numberFragments, 5, "-")
	number = table.concat( numberFragments )
	
	return number
end

--// Net Message Header Enumerations
GPHONE_MP_REQUEST = 1
GPHONE_MP_REQUEST_RESPONSE = 2

GPHONE_MONEY_TRANSFER = 1
GPHONE_STATE_CHANGED = 2
GPHONE_BUILD = 3

GPHONE_NOTIFY = 1


