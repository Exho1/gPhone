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
GPHONE_TEXT_MSG = 17


local plymeta = FindMetaTable( "Player" )

function plymeta:hasPhoneOpen()
	return self:GetNWBool("gPhone_Open", false)
end

function plymeta:getActiveApp()
	return string.Trim( self:GetNWString("gPhone_CurApp", nil) )
end

function plymeta:getPhoneNumber()
	if SERVER then
		return self:GetPData( "gPhone_Number", 0 )
	else
		return self:GetNWString( "gPhone_Number", 0 )
	end
end

function gPhone.steamIDToPhoneNumber( plyOrID )
	local bPlayer = type(plyOrID) != "string"
	if bPlayer and plyOrID:SteamID() == "BOT" then
		return "BOT" 
	end
	
	local idFragments
	if bPlayer then
		idFragments = string.Explode( ":", ply:SteamID() )
	else
		idFragments = string.Explode( ":", plyOrID )
	end
	
	--local areaCode = idFragments[2]
	local number = idFragments[3]
	local numberFragments = string.Explode( "", number )
	
	table.insert(numberFragments, 5, "-")
	number = table.concat( numberFragments )
	
	return number
end

--// Sends a colored message to console
GPHONE_MSGC_WARNING = 1
GPHONE_MSGC_NOTIFY = 2
GPHONE_MSGC_NONE = 3
local lastMsg, repeatCount = nil, 0
function gPhone.msgC( enum, ... )
	local side = nil
	local col = nil
	if SERVER then 
		col = Color( 0, 128, 255 )
	else 
		if gPhone.config.ShowRunTimeConsoleMessages == true then return end -- Should we write to console for this?!?!
		col = Color( 255, 255, 100 )
	end

	-- tostring all of the extra arguments
	local args = {...}
	for i=1, #args do
		args[i] = tostring(args[i])
	end
	
	-- Stop spam of repeated messages except when the repeating is divisible by 10
	if table.concat( args, "   " ) != lastMsg then
		lastMsg = table.concat( args, "   " )
		if repeatCount > 5 then 
			MsgC( col, "[gPhone]: ", Color(220,80,80), "To prevent spam, the last "..repeatCount.." messages have been ignored", "\n" )
			repeatCount = 0 
		end
	else
		repeatCount = repeatCount + 1
		if repeatCount % 10 != 0 then
			return
		end
	end
	
	local textColor
	if enum == GPHONE_MSGC_WARNING then
		textColor = Color(220,80,80)
	elseif enum == GPHONE_MSGC_NOTIFY then
		textColor = Color(27,161,226)
	else
		textColor = Color(80,220,80)
	end
	
	MsgC( col, "[gPhone]: ", textColor, table.concat( args, "   " ), "\n" )
end

--// Utility function to grab a player object from a string
function util.getPlayerByNick( name, bExact )
	for k, v in pairs(player.GetAll()) do
		if bExact then 
			if v:Nick() == name then
				return v
			end
		else
			if v:Nick():lower() == name:lower() then
				return v
			end
		end
	end
end

function util.getPlayerByID( id )
	for k, v in pairs(player.GetAll()) do
		if v:SteamID() == id then
			return v
		end
	end
end

