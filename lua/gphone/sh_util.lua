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

GPHONE_TEXT_MSG = 17
--GPHONE_REQUEST_TEXTS = 18

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

--// Returns if the player is currently in a multiplayer game with other players
function plymeta:inMPGame()
	return self:GetNWBool("gPhone_InMPGame", false)
end


--// Sends a colored message to console
GPHONE_MSGC_WARNING = 1
GPHONE_MSGC_NOTIFY = 2
GPHONE_MSGC_NONE = 3
function gPhone.msgC( enum, ... )
	local side = nil
	local col = nil
	if SERVER then 
		col = Color( 0, 128, 255 )
	else 
		if gPhone.config.showConsoleMessages == false then return end
		col = Color( 255, 255, 100 )
	end

	-- tostring all of the extra arguments
	local args = {...}
	for i=1, #args do
		args[i] = tostring(args[i])
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

--// Changes a Steam ID into a file-compatible string, for naming
function gPhone.steamIDToFormat( id )
	local idFragments = string.Explode( ":", id )
	
	local oneOrZero = idFragments[2]
	local bulk = idFragments[3]
	
	local fmat = oneOrZero..bulk
	
	return fmat
end

--// Reverses a formatted string back to its Steam ID
function gPhone.formatToSteamID( fmat )
	local front = "STEAM_0:"
	
	local formatFrags = string.Explode( "", fmat )
	local middle = formatFrags[1]
	table.remove( formatFrags, 1 )
	local end_ = table.concat( formatFrags, "")
	
	local id = front..middle..":"..end_
	
	return id
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


--// Helper function for 'encryption' of JSON
-- Not really that secure but its better than keeping it in plain text
local byteKey = 5
local function tableScrambler( tbl, num, bReverse )
	local sign = 1
	if bReverse then 
		sign = -1 
	end
	
	local newTable = {}
	for k, v in pairs( tbl ) do
		local newKey = k
		-- 36 -> 126
		if type(k) == "string" and tonumber(k) == nil then
			local letters = string.Explode( "", k ) 
			for key, l in pairs( letters ) do 
				letters[key] = string.char( string.byte(l) + (num * sign) )
			end
			newKey = table.concat(letters)
		end
		
		if type(v) == "string" then
			v = tostring(v)
			
			local letters = string.Explode( "", v ) 
			for key, l in pairs( letters ) do 
				letters[key] = string.char( string.byte(l) + (num * sign) )
			end
			
			local str = table.concat(letters)
			
			newTable[newKey] = str
		elseif type(v) == "table" then
			newTable[newKey] = tableScrambler( v, num, bReverse )
		else
			-- Booleans need to be scrambled too
			newTable[newKey] = v
		end
	end
	return newTable
end

--// Converts a JSON table to a scrambled version so it won't be saved in plain text
function gPhone.scrambleJSON( json, bReturnTable )
	local new = {}
	
	local tbl = util.JSONToTable( json )
	for k, v in pairs( tbl ) do
		new[k] = tableScrambler( v, byteKey )
	end
	
	if bReturnTable then
		return new
	else
		new = util.TableToJSON( new )
		return new
	end
end

--// Reverses the scrambling and returns a plain text JSON table
function gPhone.unscrambleJSON( json, bReturnTable )
	local new = {}
	
	local tbl = util.JSONToTable( json )
	for k, v in pairs( tbl ) do
		new[k] = tableScrambler( v, byteKey, true )
	end
	
	if bReturnTable then
		return new
	else
		new = util.TableToJSON( new )
		return new
	end
end
