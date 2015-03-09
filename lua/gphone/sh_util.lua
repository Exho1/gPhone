----// Shared Utility Functions //----

local trans = gPhone.getTranslation

-- Gotta make sure the languages are included at this point
local files = file.Find( "gphone/lang/*.lua", "LUA" )
for k, v in pairs(files) do
	include("gphone/lang/"..v)
end

--// Net Message Header Enumerations
GPHONE_MP_REQUEST = 1
GPHONE_MP_REQUEST_RESPONSE = 2
GPHONE_MP_PLAYER_QUIT = 3
GPHONE_MONEY_TRANSFER = 4
GPHONE_STATE_CHANGED = 5
GPHONE_BUILD = 6
GPHONE_NOTIFY_ALERT = 7
GPHONE_NOTIFY_BANNER = 8
GPHONE_RETURNAPP = 9
GPHONE_CUR_APP = 10
GPHONE_RUN_APPFUNC = 11
GPHONE_RUN_FUNC = 12
GPHONE_MONEY_CONFIRMED = 13
GPHONE_TEXT_MSG = 17
GPHONE_START_CALL = 18
GPHONE_NET_REQUEST = 19
GPHONE_NET_RESPONSE = 20
GPHONE_END_CALL = 21

--// Language strings for requests. [appname] = string.format("%s...", playerNick)
gPhone.deniedStrings = {
	["phone"] = trans("phone_deny"),
	["gpong"] = trans("gpong_deny"),
}

gPhone.acceptedStrings = {
	["phone"] = trans("phone_accept"),
	["gpong"] = trans("gpong_accept"),
}

local plymeta = FindMetaTable( "Player" )

function plymeta:hasPhoneOpen()
	return self:GetNWBool("gPhone_Open", false)
end

function plymeta:getActiveApp()
	return string.Trim( self:GetNWString("gPhone_CurApp", "") )
end

function plymeta:getPhoneNumber()
	local number 
	if SERVER then
		number = self:GetPData( "gPhone_Number", self:GetNWString( "gPhone_Number", gPhone.invalidNumber ) )
	else
		number = self:GetNWString( "gPhone_Number", gPhone.invalidNumber )
	end
	
	if number == gPhone.invalidNumber then
		gPhone.msgC( GPHONE_MSGC_WARNING, self:Nick().." has an invalid phone number! A new one will be generated" )
		if SERVER then
			number = self:generatePhoneNumber()
		else
			net.Start("gPhone_DataTransfer")
				net.WriteTable( {header=GPHONE_NEW_NUMBER} )
			net.SendToServer()
			return gPhone.invalidNumber
		end
	end
	
	return number
end

--// Returns if the player is currently in a multiplayer game with other players
function plymeta:inMPGame()
	return self:GetNWBool("gPhone_InMPGame", false)
end

function plymeta:inCall()
	return self:GetNWBool("gPhone_InCall", false)
end

-- Returns a table of the phone numbers for all connected players
function gPhone.getPhoneNumbers()
	local numberTable = {}
	
	for _, ply in pairs( player.GetAll() ) do
		numberTable[ply:getPhoneNumber()] = ply
	end
	
	return numberTable
end

function gPhone.getPlayerByNumber( number )
	local tbl = gPhone.getPhoneNumbers()
	
	if tbl[number] then
		return tbl[number]
	end
end

--// Helper function for inverting the sender and target of a table
function gPhone.flipSenderTarget( tbl )
	local target = tbl.target
	local sender = tbl.sender
	tbl.sender = target
	tbl.target = sender
	
	return tbl
end

gPhone.requestIDs = {}

--// Ping-pong request and response functions using the net library
--[[
	Send table format: 
		{target = player, sender = player, app = string, msg = string}
	Server:
		gPhone.sendRequest( {sender=ply, app="Name", msg="Hello"}, ply2 )
	Client:
		gPhone.sendRequest( {app="Name", msg="Hello"}, ply )
	
	1. Request: Client1 -> Server (if started on server, this step is skipped)
	2. Request: Server -> Client2
	3. Response: Client2 -> Server
	4. Response: Server -> Client1
]]
function gPhone.sendRequest( tbl, ply )
	tbl.header = GPHONE_NET_REQUEST
	
	if SERVER then
		-- Log the request and send to target
		local id = #gPhone.requestIDs+1
		gPhone.requestIDs[id] = {responded=false, accepted=false, 
		target=tbl.target, sender=tbl.sender, app=tbl.app}
		
		tbl.id = id
		
		-- Sender should be manually declared when sending from the server
		tbl.target = ply
		
		net.Start("gPhone_DataTransfer")
			net.WriteTable( tbl )
		net.Send( ply )
		
		return id
	else
		tbl.sender = LocalPlayer()
		tbl.target = ply
		
		net.Start("gPhone_DataTransfer")
			net.WriteTable( tbl )
		net.SendToServer()
	end
end

function gPhone.receiveRequest( tbl )
	if SERVER then
		-- If it started on the client, log it
		if not tbl.id then
			local id = #gPhone.requestIDs+1
			gPhone.requestIDs[id] = {target=tbl.target, sender=tbl.sender, sendTime=CurTime()}
			tbl.id = id
		end
		
		hook.Run( "gPhone_requestSent", tbl.sender, tbl.target, tbl, id )
		gPhone.sendRequest( tbl, tbl.target )
	else
		-- Recieve the request and alert the client
		gPhone.notifyAlert( {msg=tbl.msg, title=trans("request"), options={trans("deny"), trans("accept")}},
		function( pnl, value )
			 gPhone.sendResponse( {target=tbl.sender, bAccepted=false, id=tbl.id, app=tbl.app}, tbl.sender )
		end,
		function( pnl, value )
			-- On accept, send response and run app
			local msg 
			local sendTable = {target=tbl.sender, bAccepted=true, id=tbl.id, app=tbl.app, msg=msg}
			
			gPhone.sendResponse( sendTable, tbl.sender )
			gPhone.runApp( tbl.app )
		end,
		false, true)
	end
end

function gPhone.sendResponse( tbl, ply )
	local sendTable = {header=GPHONE_NET_RESPONSE, sender=ply}
	table.Merge( sendTable, tbl )
	
	if SERVER then
		-- Foward response to target
		net.Start("gPhone_DataTransfer")
			net.WriteTable( sendTable )
		net.Send( ply )
	else
		-- This is a response so flip the roles around
		sendTable = gPhone.flipSenderTarget( sendTable )
		
		net.Start("gPhone_DataTransfer")
			net.WriteTable( sendTable )
		net.SendToServer()
	end
end

function gPhone.receiveResponse( tbl )
	if SERVER then	
		-- Update response table
		gPhone.requestIDs[tbl.id].responded = true
		gPhone.requestIDs[tbl.id].accepted = tbl.bAccepted
		gPhone.requestIDs[tbl.id].receiveTime = CurTime()
	
		hook.Run( "gPhone_responseSent", tbl.sender, tbl.target, tbl, id )
		-- Forward the response
		gPhone.sendResponse( tbl, tbl.target )
		
		timer.Simple(5, function()
			if tbl.id and gPhone.requestIDs[tbl.id] then
				gPhone.requestIDs[tbl.id] = {}
			end
		end)
	else
		-- Generate a response text based off the string table
		local message 
		if tbl.bAccepted == true then
			if gPhone.acceptedStrings[tbl.app:lower()] then
				message = string.format(gPhone.acceptedStrings[tbl.app:lower()], tbl.sender:Nick())
			else
				message = string.format( trans("accept_fallback"), tbl.sender:Nick(), tbl.app )
			end
		else
			if gPhone.deniedStrings[tbl.app:lower()] then
				message = string.format(gPhone.deniedStrings[tbl.app:lower()], tbl.sender:Nick())
			else
				message = string.format( trans("deny_fallback"), tbl.sender:Nick(), tbl.app )
			end
		end
		
		-- Receive the response and notify with a banner
		gPhone.notifyBanner( {msg=message, app=tbl.app or "ERROR"} )
	end
end	

--// Waits until a reponse is given for the id and then calls a function (bAccepted, tbl)
function gPhone.waitForResponse( id, callback )
	local startTime = CurTime()
	
	if gPhone.requestIDs[id] then
		hook.Add("Think", "gPhone_waitFor"..id, function()
			if gPhone.requestIDs[id].responded == true then
				callback( gPhone.requestIDs[id].accepted, gPhone.requestIDs[id] )
				hook.Remove("Think", "gPhone_waitFor"..id)
			end
		end)
	end
end

--// Returns if a request has been accepted
function gPhone.getRequestAccepted( id )
	if gPhone.requestIDs[id] then
		-- Was the request with this id accepted?
		return gPhone.requestIDs[id].accepted 
	end
end

--// Returns if a request has been responded
function gPhone.getRequestResponded( id )
	if gPhone.requestIDs[id] then
		-- Was there a response to this request?
		return gPhone.requestIDs[id].responded
	end
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
		col = Color( 255, 255, 100 )
	end

	-- tostring all of the extra arguments
	local args = {...}
	for i=1, #args do
		args[i] = tostring(args[i])
	end
	
	-- Log everything that runs through
	if CLIENT then
		gPhone.log( table.concat( args, "   " ) )
	end	
	
	-- If console printing is off, don't show the message but it will be logged
	if gPhone.config.showConsoleMessages == false then return end
	
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
	
	local idFragments = string.Explode( ":", bPlayer and plyOrID:SteamID() or plyOrID );

	--local areaCode = idFragments[2] -- Very low chance not including the 1 or 0 will conflict
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
