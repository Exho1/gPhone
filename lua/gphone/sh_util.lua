----// Shared Utility Functions //----

--// Net Message Header Enumerations
GPHONE_MP_REQUEST = 1
GPHONE_MP_REQUEST_RESPONSE = 2
GPHONE_MP_PLAYER_QUIT = 3

GPHONE_MONEY_TRANSFER = 4
GPHONE_STATE_CHANGED = 5
GPHONE_BUILD = 6
GPHONE_NOTIFY_GAME = 7
GPHONE_NOTIFY_NORMAL = 8

GPHONE_RETURNAPP = 9
GPHONE_CUR_APP = 10
GPHONE_RUN_APPFUNC = 11
GPHONE_RUN_FUNC = 12
GPHONE_MONEY_CONFIRMED = 13

GPHONE_F_OTHER = 14
GPHONE_F_FINANCES = 15
GPHONE_F_EXISTS = 16


local plymeta = FindMetaTable( "Player" )

function plymeta:HasPhoneOpen()
	return self:GetNWBool("gPhone_Open", false)
end

function plymeta:GetApp()
	return string.Trim( self:GetNWString("gPhone_CurApp", nil) )
end

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
	
	local idFragments = string.Explode( ":", ply:SteamID() )
	
	--local areaCode = idFragments[2]
	local number = idFragments[3]
	local numberFragments = string.Explode( "", number )
	
	table.insert(numberFragments, 5, "-")
	number = table.concat( numberFragments )
	
	return number
end

--// Sends a colored message to console
GPHONE_MSGC_WARNING = 1
GPHONE_MSGC_NONE = 2
function gPhone.MsgC( enum, ... )
	local side = nil
	local col = nil
	if SERVER then 
		side = "SV" 
		col = Color( 0, 128, 255 )
	else 
		side = "CL" 
		col = Color( 255, 255, 100 )
	end

	-- tostring all of the extra arguments
	local args = {...}
	for i=1, #args do
		args[i] = tostring(args[i])
	end
	
	if enum == GPHONE_MSGC_WARNING then
		MsgC( col, "[gPhone - "..side.."]: ", Color(220,80,80), table.concat( args, "   " ), "\n" )
	else
		MsgC( col, "[gPhone - "..side.."]: ", Color(80,220,80), table.concat( args, "   " ), "\n" )
	end
end

--// Utility function to grab a player object from a string
function util.GetPlayerByNick( nick, bExact )
	for k, v in pairs(player.GetAll()) do
		if bExact then 
			if v:Nick() == nick then
				return v
			end
		else
			if v:Nick():lower() == nick:lower() then
				return v
			end
		end
	end
end

