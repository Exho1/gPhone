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
			net.Start("gPhone_GenerateNumber")
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
	local target = tbl[1]
	local sender = tbl[2]
	tbl[2] = target
	tbl[1] = sender
	
	return tbl
end

gPhone.requestIDs = {}

--// Ping-pong request and response functions using the net library
--[[
	Request table format: 
		[1] = Target
		[2] = Sender
		[3] = App
		[4] = Message
		[5] = Id
		[6] = Accepted
	Response table format:
		[1] = Target
		[2] = Sender
		[3] = App
		[4] = Id
		[5] = Accepted
	1. Request: Client1 -> Server (if started on server, this step is skipped)
	2. Request: Server -> Client2
	3. Response: Client2 -> Server
	4. Response: Server -> Client1
]]
function gPhone.sendRequest( tbl, ply )
	if SERVER then
		-- Log the request and send to target
		local id = #gPhone.requestIDs+1
		gPhone.requestIDs[id] = {responded=false, accepted=false, 
		target=ply, sender=tbl[2], app=tbl[3]}
		
		tbl[5] = id
		
		-- Sender should be manually declared when sending from the server
		tbl[1] = ply
		
		net.Start("gPhone_Request")
			--net.WriteTable( tbl )
			gPhone.writeTable( tbl )
		net.Send( ply )
		
		return id
	else
		tbl[2] = LocalPlayer()
		tbl[1] = ply
		
		net.Start("gPhone_Request")
			--net.WriteTable( tbl )
			gPhone.writeTable( tbl )
		net.SendToServer()
	end
end

function gPhone.receiveRequest( tbl )
	local id = tbl[5]
	
	if SERVER then
		-- If it started on the client, log it
		if not id then
			id = #gPhone.requestIDs+1
			gPhone.requestIDs[id] = {target=tbl[1], sender=tbl[2], sendTime=CurTime()}
			tbl[5] = id
		end
		
		hook.Run( "gPhone_requestSent", tbl[2], tbl[1], tbl, id )
		gPhone.sendRequest( tbl, tbl.target )
	else
		-- Recieve the request and alert the client
		gPhone.notifyAlert( {msg=tbl[4], title=trans("request"), options={trans("deny"), trans("accept")}},
		function( pnl, value )
			gPhone.sendResponse( {[1] = tbl[2], [6]=false, [5]=id, [3]=tbl[3]},
			tbl[2] )
		end,
		function( pnl, value )
			-- On accept, send response and run app
			local msg -- Um... Why doesn't this get assigned to anything?
			local sendTable = {[1]=tbl[2], [6]=true, [5]=id, [3]=tbl[3]}
			
			gPhone.sendResponse( sendTable, tbl[2] )
			gPhone.runApp( tbl[3] )
		end,
		false, true)
	end
end

function gPhone.sendResponse( tbl, ply )
	if SERVER then
		-- Foward response to target
		net.Start("gPhone_Response")
			gPhone.writeTable( tbl )
		net.Send( ply )
	else
		-- This is a response so flip the roles around
		local sendTable = tbl
		sendTable[1] = ply
		sendTable[2] = tbl[1]
		-- The third entry doesn't change
		sendTable[4] = tbl[5]
		sendTable[5] = tbl[6]
		sendTable[6] = nil -- Shrink the table
		
		net.Start("gPhone_Response")
			gPhone.writeTable( sendTable )
		net.SendToServer()
	end
end

function gPhone.receiveResponse( tbl )
	if SERVER then	
		local id = tbl[4]
		
		-- Update response table
		if gPhone.requestIDs[id] then
			gPhone.requestIDs[id].responded = true
			gPhone.requestIDs[id].accepted = tbl[5]
			gPhone.requestIDs[id].receiveTime = CurTime()
		else
			gPhone.msgC( GPHONE_MSGC_WARNING, "Attempted to receive response for invalid request id: "..id )
			
		end
	
		hook.Run( "gPhone_responseSent", tbl[2], tbl[1], tbl, id )
		-- Forward the response
		gPhone.sendResponse( tbl, tbl[1] )
		
		timer.Simple(5, function()
			if id and gPhone.requestIDs[id] then
				gPhone.requestIDs[id] = {}
			end
		end)
	else
		-- Generate a response text based off the string table
		local message 
		local app = tbl[3]
		local sender = tbl[2]
		if tbl[5] == true then
			if gPhone.acceptedStrings[app:lower()] then
				message = string.format(gPhone.acceptedStrings[app:lower()], sender:Nick())
			else
				message = string.format( trans("accept_fallback"), sender:Nick(), app )
			end
		else
			if gPhone.deniedStrings[app:lower()] then
				message = string.format(gPhone.deniedStrings[app:lower()], sender:Nick())
			else
				message = string.format( trans("deny_fallback"), sender:Nick(), app)
			end
		end
		
		-- Receive the response and notify with a banner
		gPhone.notifyBanner( {msg=message, app=app or "ERROR"} )
	end
end	

--// Waits until a reponse is given for the id and then calls a function (bAccepted, tbl)
function gPhone.waitForResponse( id, callback )
	local startTime = CurTime()
	
	if gPhone.requestIDs[id] then
		local startTime = CurTime()
		hook.Add("Think", "gPhone_waitFor"..id, function()
			if gPhone.requestIDs[id] then
				if gPhone.requestIDs[id].responded == true then
					callback( gPhone.requestIDs[id].accepted, gPhone.requestIDs[id] )
					hook.Remove("Think", "gPhone_waitFor"..id)
				elseif CurTime() - startTime > 15 then
					local ply = gPhone.requestIDs[id].target
					
					gPhone.notifyBanner( {msg=string.format(trans("response_timeout"), ply:Nick()),
					app="gPhone", title=trans("confirmation")}, nil)
					gPhone.requestIDs[id] = {}
					
					hook.Remove("Think", "gPhone_waitFor"..id)
				end
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
	if name != nil then
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
	else
		gPhone.msgC( GPHONE_MSGC_WARNING, "Attempt to get player for nil nick!\n", debug.traceback())
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
