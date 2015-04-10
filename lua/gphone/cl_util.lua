----// Clientside Utility Functions //----

local client = LocalPlayer()
local trans = gPhone.getTranslation

--// Builds the phone
concommand.Add("gphone_build", function()
	if gPhone.exists() then
		gPhone.msgC( GPHONE_MSGC_WARNING, "You cannot have multiple instances of the gPhone running!" )
		return
	end
	gPhone.buildPhone()
end)

--// Destroys the phone
concommand.Add("gphone_destroy", function()
	if not gPhone.exists() then
		gPhone.msgC( GPHONE_MSGC_WARNING, "No instances of the gPhone are open" )
		return
	end
	gPhone.destroyPhone()
	gPhone.setPhoneState( "destroyed" )
end)

--// Prints the phone's version
concommand.Add("gphone_version", function()
	gPhone.msgC( GPHONE_MSGC_NOTIFY, "This server is running the gPhone version: "..gPhone.version )
end)

--// Dumps the event log to a text file
concommand.Add("gphone_dump", function()
	gPhone.dumpLog()
end)

--// Wipes the event log table
concommand.Add("gphone_logwipe", function()
	gPhone.wipeLog()
end)

--// Stops the active music channel (gets overriden by the the music app)
concommand.Add("gphone_stopmusic", function()
	gPhone.msgC( GPHONE_MSGC_WARNING, "No active music channel to stop!" )
end)

--// Removes the file that disables the tutorial on booting
concommand.Add("gphone_enabletutorial", function()
	gPhone.setSeenTutorial( false )
end)

--// Simulates searching an 'artist song' pair to get an album url
concommand.Add("gphone_searchsong", function(_, _, args)
	local name = table.concat(args, " ")
	gPhone.loadAlbumArt(name, 1, function( url )
		gPhone.msgC( GPHONE_MSGC_NONE, "Found album cover")
		print(url)
	end)
end)

--// Opens or closes the phone
concommand.Add("gphone_toggle", function()
	gPhone.msgC( GPHONE_MSGC_NONE, "Toggle phone - Open? "..tostring(gPhone.isOpen()))
	if gPhone.isOpen() then
		gPhone.hidePhone()
	else
		gPhone.showPhone()
	end
end)

--// Spotify API album finding code provided by Rejax (STEAM_0:1:45852799)
local api = "http://api.spotify.com/v1/search?type=track&limit=1&q=%s"
function gPhone.loadAlbumArt(track_name, track_id, callback) -- where id is how you're indexing your music or whatever
	http.Fetch(api:format(track_name:gsub("%s", "+")), function(body)
		local data = util.JSONToTable(body)
		if not data or not data.tracks or not data.tracks.items or not data.tracks.items[1] then 
			return 
		end

		local album = data.tracks.items[1].album
		local image = album.images[track_id] -- 640 x 640 px
		
		if callback != nil then
			callback( image.url ) 
		end
	end)
end

local plymeta = FindMetaTable( "Player" )

--// Chat messages
function gPhone.chatMsg( text )
	chat.AddText(
		Color(17, 148, 240), "[gPhone]", 
		Color(255,255,255), ": "..text
	)
	gPhone.log("gPhone.chatMsg: "..text)
end
 
net.Receive( "gPhone_ChatMsg", function( len, ply )
	gPhone.chatMsg( net.ReadString() )
end)

--// Returns true if the player does not have the file showing that they have seen the tutorial
function gPhone.getShowTutorial()
	return !file.Exists( "gphone/tutorial_viewed.txt", "DATA" )
end

--// Creates or deletes the file to determine if the phone tutorial will be shown on boot
function gPhone.setSeenTutorial( b )
	if b == true then
		gPhone.msgC( GPHONE_MSGC_NONE, "Created seen tutorial file")
		file.Write( "gphone/tutorial_viewed.txt", "AYE LADDIE" )
	else
		gPhone.msgC( GPHONE_MSGC_NONE, "Deleted seen tutorial file")
		file.Delete( "gphone/tutorial_viewed.txt" )
	end
end

--// Returns true if this function has not been called in the last second. Pretty bad implementation
local called = nil
local lastTraceback = ""
function gPhone.firstTimeCalled()
	if called then
		return false
	else
		called = true
		
		local disable = CurTime() + 1
		hook.Add("Think", "gPhone_firstTimeCool", function()
			if CurTime() > disable then
				called = false
			end
		end)
		
		return true
	end	
end

--// Appends a string to the end of the gPhone log table with the time as the key
function gPhone.log( string )
	table.insert( gPhone.debugLog, {time=os.date("%X"), msg=string})
	
	if #gPhone.debugLog >= 200 then -- Keep the debug table within a reasonable size
		table.remove(gPhone.debugLog, 1)
		table.remove(gPhone.debugLog, 2)
		table.remove(gPhone.debugLog, 3)
	end
end

--// Dumps the current debug log to a text file
function gPhone.dumpLog()
	local date = os.date("%c")
	date = string.gsub(date, "/", "-")
	date = string.gsub(date, ":", "-")
	date = string.gsub(date, " ", "_")
	
	gPhone.msgC( GPHONE_MSGC_NONE, "Dumping phone log to file (gphone/dumps/"..date..".txt)")
	file.CreateDir( "gphone/dumps" )
	file.Write( "gphone/dumps/"..date..".txt", "--START CONSOLE DUMP AT "..os.date("%X").."--\r\n\r\n")
	
	for _, tbl in pairs( gPhone.debugLog ) do
		file.Append( "gphone/dumps/"..date..".txt", "["..tbl.time.."]: "..tbl.msg.."\r\n" )
	end
	gPhone.msgC( GPHONE_MSGC_NONE, "Log successfully dumped")
	
	--gPhone.debugLog = {}
end

--// Clears the debug log
function gPhone.wipeLog()
	gPhone.debugLog = {}
	gPhone.msgC( GPHONE_MSGC_NONE, "Wiped debug log")
end

--// Iterates through a table to remove panels
function gPhone.removeAllPanels( tbl )
	for k, v in pairs(tbl) do
		if type(v) != "table" then
			if v.Remove then
				v:Remove()
			end
		else
			gPhone.removeAllPanels( v )
		end
	end
end

--// Returns a color with a newly set alpha
function gPhone.colorNewAlpha( col, a )
	local r, g, b = col.r, col.g, col.b
	return Color( r, g, b, a )
end

--// Checks if the local player can use an application based on usergroups or gamemode (unsafe)
function gPhone.canUseApp( appData )
	local canUse = true
	
	if appData.Gamemode and appData.Gamemode != "" then
		if string.lower(appData.Gamemode) != string.lower(engine.ActiveGamemode()) then
			canUse = false
		end
	end
	
	if appData.AllowedUsergroups and #appData.AllowedUsergroups > 0 then
		for _, group in pairs( appData.AllowedUsergroups ) do
			if client:GetUserGroup() == group then
				break
			end
			canUse = false
		end
	end
	
	return canUse
end

--// Panel-based blur function by Chessnut (https://github.com/Chessnut/NutScript)
local blur = Material( "pp/blurscreen" )
function gPhone.drawPanelBlur( panel, layers, density, alpha )
	local x, y = panel:LocalToScreen(0, 0)

	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 3 do
		blur:SetFloat( "$blur", ( i / layers ) * density )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	end
end

--// Time formatting function by Bad King Ugrain used in Trouble in Terrorist Town
function gPhone.simpleTime(seconds, fmt)
	if not seconds then seconds = 0 end

    local ms = (seconds - math.floor(seconds)) * 100
    seconds = math.floor(seconds)
    local s = seconds % 60
    seconds = (seconds - s) / 60
    local m = seconds % 60

    return string.format(fmt, m, s, ms)
end

--// Hide children of a panel
function gPhone.hideChildren( pnl )
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( pnl:GetChildren() ) do
		if IsValid(v) then
			v:SetVisible(false)
		end
	end
end

--// Show children of a panel
function gPhone.showChildren( pnl )
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( pnl:GetChildren() ) do
		if IsValid(v) then
			v:SetVisible(true)
		end
	end
end

--// Remove children of a panel
function gPhone.removeChildren( pnl )
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( pnl:GetChildren() ) do
		if IsValid(v) then
			v:Remove()
		end
	end
end

--// Hides app objects
function gPhone.hideAppObjects()
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( gApp["_children_"] ) do
		if IsValid(v) then
			v:SetVisible( false )
		end
	end
end

--// Overrides the Paint function for DLabels to fix the SetTextColor function
function gPhone.dLabelPaintOverride( pnl, w, h )
	pnl:SetFGColor( pnl:GetTextColor() or color_white ) 
end

--// Color the status bar
function gPhone.darkenStatusBar()
	for class, tab in pairs(gPhone.statusBar) do
		if class == "text" then
			for k, pnl in pairs(tab) do
				if not IsValid(pnl) then return end
				pnl:SetTextColor( color_black )
			end
		else
			for k, pnl in pairs(tab) do
				if not IsValid(pnl) then return end
				pnl:SetImageColor( color_black)
			end
		end
	end
end

--// Color the status bar
function gPhone.lightenStatusBar() 
	for class, tab in pairs(gPhone.statusBar) do
		if class == "text" then
			for k, pnl in pairs(tab) do
				if not IsValid(pnl) then return end
				pnl:SetTextColor( color_white )
			end
		else
			for k, pnl in pairs(tab) do
				if not IsValid(pnl) then return end
				pnl:SetImageColor( color_white )
			end
		end
	end
end

--// Returns a value, subject to change, to compensate for status bar height
function gPhone.getStatusBarHeight()
	return gPhone.statusBarHeight
end

--// Show or hide the entire status bar or portions
function gPhone.showStatusBar()
	for class, tab in pairs(gPhone.statusBar) do
		for k, pnl in pairs(tab) do
			pnl:SetVisible(true)
		end
	end
end

function gPhone.showStatusBarElement( name )
	for class, tab in pairs(gPhone.statusBar) do
		if tab[string.lower(name)] then
			tab[string.lower(name)]:SetVisible(true)
		end
	end
end

function gPhone.hideStatusBar()
	for class, tab in pairs(gPhone.statusBar) do
		for k, pnl in pairs(tab) do
			pnl:SetVisible(false)
		end
	end
end

function gPhone.hideStatusBarElement( name )
	for class, tab in pairs(gPhone.statusBar) do
		if tab[string.lower(name)] then
			tab[string.lower(name)]:SetVisible(false)
		end
	end
end

--// Grab text size easily
function gPhone.getTextSize(text, font)
	surface.SetFont(font)
	return surface.GetTextSize(text)
end

--// Center text in a panel
function gPhone.setTextAndCenter(label, text, parent, vertical)
	label:SetText( text or label:GetText() )
	label:SetFont( label:GetFont() )
	label:SizeToContents()
	local x, y = label:GetPos()
	if vertical then
		label:SetPos( parent:GetWide()/2 - label:GetWide()/2, parent:GetTall()/2 - label:GetTall()/2 )
	else
		label:SetPos( parent:GetWide()/2 - label:GetWide()/2, y )
	end
end

--// Returns an app table from its name
function gPhone.getAppFromName( name )
	for _, data in pairs( gPhone.apps ) do
		if data.name:lower() == name:lower() then
			return data
		end
	end
end

--// Music App
function gPhone.saveMusic( tbl )
	gPhone.msgC( GPHONE_MSGC_NONE, "Saving music file")
	
	json = util.TableToJSON( tbl )
	
	file.CreateDir( "gphone" )
	file.Write( "gphone/music_stations.txt", json)
end

--// Music App
function gPhone.loadMusic()
	gPhone.msgC( GPHONE_MSGC_NONE, "Loading music file")
	
	if not file.Exists( "gphone/music_stations.txt", "DATA" ) then
		gPhone.msgC( GPHONE_MSGC_WARNING, "Unable to locate music file!!")
		gPhone.saveMusic( {} )
		gPhone.loadMusic()
	end
	
	local contents = file.Read( "gphone/music_stations.txt", "DATA" )
	local tbl = util.JSONToTable( contents ) 
	
	return tbl
end

--// Discards text files into another folder instead of deleting them from the user's computer
function gPhone.discardFile( filePath )
	if file.Exists( filePath, "DATA" ) then
		local contents = file.Read( filePath, "DATA" )
		
		-- Fallback name
		local name = "nil_"..os.date( "%x" ).."_"..os.date( "%I:%M%p" )
		
		-- Get the file name
		local frags = string.Explode("/", filePath)
		for k, v in pairs( frags ) do
			if string.find( v, ".txt" ) then
				name = v
			end
		end
		
		-- Handle multiples
		if file.Exists( "gphone/archive/"..name, "DATA") then
			name = name.."_"..os.date( "%x" ).."_"..os.date( "%I:%M%p" )
		end
		
		-- Write new and delete the old
		file.Write( "gphone/archive/"..name, contents )
		file.Delete( filePath )
	end
end

--// Deletes text files older than the set time from the gPhone/archive folder automatically
function gPhone.archiveCleanup()
	if gPhone.config.deleteArchivedFiles == true then
		local files = file.Find( "gphone/archive/*.txt", "DATA" )
		
		for k, v in pairs( files ) do
			local movedTime = file.Time( "gphone/archive/"..v, "DATA" )
			local days = math.abs( movedTime - os.time() )/ 60 / 60 / 24
			
			if days > gPhone.config.daysToCleanupArchive then
				gPhone.msgC( GPHONE_MSGC_WARNING, "Archived file ("..v..") has exceeded clean up time and now will be permanently deleted")
				file.Delete( "gphone/archive/"..v )
			end
		end
	end
end

--// Modifies the config table with the key and value provided
function gPhone.setConfigValue( key, val )
	for k, v in pairs( gPhone.config ) do
		if k:lower() == key:lower() then
			if type(v) == type(val) then
				gPhone.msgC( GPHONE_MSGC_NOTIFY, "Changed config key: "..key.." to "..tostring(val).." from "..tostring(v))
				gPhone.config[k] = val
			else
				gPhone.msgC( GPHONE_MSGC_WARNING, "Attempted to modify config values for "..key.." with different types: "..type(v).." and "..type(val))
				return
			end
		end
	end
	
	gPhone.saveClientConfig()
end

--// Sets if an app should be shown on the homescreen, if not it will be in the app store
function gPhone.setAppVisible( name, bVisible )
	local nameL = name:lower()
	
	local gAppsKey 
	for k, v in pairs(gPhone.apps) do
		if v.name:lower() == nameL then
			gAppsKey = k
		end
	end
	
	if bVisible then
		gPhone.apps[gAppsKey].hidden = nil
		gPhone.removedApps[nameL] = nil
		
		gPhone.decrementBadge( "App Store", nameL )
	else
		gPhone.apps[gAppsKey].hidden = true
		gPhone.removedApps[nameL] = 0
		
		gPhone.incrementBadge( "App Store", nameL )
	end
	
	gPhone.saveAppPositions( gPhone.apps )
end

function gPhone.getAppVisible( name )
	local nameL = name:lower()
	
	local gAppsKey 
	for k, v in pairs(gPhone.apps) do
		if v.name:lower() == nameL then
			gAppsKey = k
		end
	end
	
	if gPhone.apps[gAppsKey].hidden == nil then
		return true
	else
		return false
	end
end

--// Push a string into another at the specified key
function gPhone.charSub( str, k, strReplace )
	
	local len = string.len( strReplace )
	local start = str:sub( 0, k - 1 )
	local send = str:sub( k + len )
	
	return start .. strReplace .. send	
end

--// Save config
function gPhone.saveClientConfig()
	gPhone.msgC( GPHONE_MSGC_NONE, "Saving config file")
	
	cfgJSON = util.TableToJSON( gPhone.config )
	
	file.CreateDir( "gphone" )
	file.Write( "gphone/config.txt", cfgJSON)
end

--// Load config
function gPhone.loadClientConfig()
	gPhone.msgC( GPHONE_MSGC_NONE, "Loading config file")
	
	if not file.Exists( "gphone/config.txt", "DATA" ) then
		gPhone.msgC( GPHONE_MSGC_WARNING, "Unable to locate config file!!")
		gPhone.saveClientConfig()
		return gPhone.config
	end
	
	local cfgFile = file.Read( "gphone/config.txt", "DATA" )
	local cfgTable = util.JSONToTable( cfgFile ) 
	
	-- Search for values that exist in the config table but not the file
	local shouldSave = false
	for k, v in pairs( gPhone.config ) do
		if not cfgTable[k] and type(v) != "IMaterial" then
			gPhone.msgC( GPHONE_MSGC_NOTIFY, "Saved missing config key/value: "..tostring(k).." "..tostring(v))
			cfgTable[k] = v
			shouldSave = true
		end
	end
	
	gPhone.config = cfgTable
	
	if shouldSave then
		gPhone.saveClientConfig()
	end
end

--// Retrieves app positions
function gPhone.saveAppPositions( tbl )
	for k, v in pairs( tbl ) do
		for name, _ in pairs( gPhone.removedApps ) do
			if v.name:lower() == name then
				-- Put removed apps at the end of the table
				v.hidden = true
				table.insert( tbl, v )
				table.remove( tbl, k )
			end
		end
	end
	
	cfgJSON = util.TableToJSON( tbl )
	
	file.CreateDir( "gphone" )
	file.Write( "gphone/homescreen_layout.txt", cfgJSON)
end

--// Saves moved app positions
function gPhone.loadAppPositions()
	if not file.Exists( "gphone/homescreen_layout.txt", "DATA" ) then
		gPhone.msgC( GPHONE_MSGC_WARNING, "Unable to locate app position file!")
		gPhone.saveAppPositions( gPhone.apps )
		return
	end
	
	local posFile = file.Read( "gphone/homescreen_layout.txt", "DATA" )
	local posTable = util.JSONToTable( posFile ) 

	return posTable
end

--// Sends a text message 
function gPhone.sendTextMessage( target, msg ) 
	local ply = util.getPlayerByNick( target )
	if IsValid(ply) then
		local idFormat = gPhone.steamIDToFormat( ply:SteamID() )
		
		--[[
			Format:
			[1] = Date
			[2] = Time
			[3] = Message
			[4] = Target
			[5] = Sender
			[6] = Self
		]]
		
		local msgTable = {
			[1] = os.date( "%x" ),
			[2] = os.date( "%I:%M%p" ),
			[3] = msg,
			[4] = target,
		}
		
		gPhone.log("Sending text to ", target)
		
		-- Off to the server!
		net.Start("gPhone_Text")
			net.WriteString( os.date( "%x" ) )
			net.WriteString( os.date( "%I:%M%p" ) )
			net.WriteString( msg )
			net.WriteString( target )
		net.SendToServer()
		
		-- If the server has flagged us as a spammer our message should not appear in the app
		-- The message does get sent to the server, though, so that we can receive a "X seconds left" message
		if LocalPlayer():GetNWBool("gPhone_CanText", true) == false then return end
		
		-- Store the sent text on the client
		msgTable[6] = true
		msgTable[5] = LocalPlayer():Nick()
		gPhone.receiveTextMessage( msgTable, true )
	end
end

--// Saves a text message to an existing txt document or a new one
function gPhone.receiveTextMessage( tbl, bSelf )
	-- Restructure the table to use string keys since it wont be networked from now on
	tbl = {
		["date"] = tbl[1],
		["time"] = tbl[2],
		["message"] = tbl[3],
		["target"] = tbl[4],
		["sender"] = tbl[5],
		["self"] = tbl[6],
	}
	
	local writeTable = {}
	local ply
	if tbl.target == LocalPlayer():Nick() then
		ply = util.getPlayerByNick( tbl.sender )
	else
		ply = util.getPlayerByNick( tbl.target )
	end
	local idFormat = gPhone.steamIDToFormat( ply:SteamID() )
	
	gPhone.log("Received text from "..tbl.sender)
	
	if file.Exists( "gphone/messages/"..idFormat..".txt", "DATA" ) then
		local readFile = file.Read( "gphone/messages/"..idFormat..".txt", "DATA" )
		local readTable = util.JSONToTable( gPhone.unscrambleJSON( readFile ) ) 
		
		writeTable = readTable
	end

	table.insert( writeTable, tbl )

	local json = util.TableToJSON( writeTable ) 
	json = gPhone.scrambleJSON( json )
		
	file.CreateDir( "gphone/messages" )
	file.Write( "gphone/messages/"..idFormat..".txt", json)
	
	local app = gPhone.getActiveApp()
	if app and app.Data and app.Data.UpdateMessages and gPhone.isOpen() then -- In app (viewing convo?)
		if app.Data.CurrentConvo == ply:SteamID() then
			gPhone.log("Received message - In app")
			app.Data.UpdateMessages( idFormat ) 
		end
		return
	elseif gPhone.isOpen() or gPhone.exists() then -- Phone exists
		gPhone.textSound()
		gPhone.incrementBadge( "Messages", idFormat.."_message" )
	else -- Phone removed
		return
	end
	
	if not bSelf then
		local bannerTable = {app="Messages", title=tbl.sender, msg=tbl.message}
			
		gPhone.notifyBanner( bannerTable, function( app )
			gPhone.runApp( app )
		end)
	end
end

--// Loads all text messages 
function gPhone.loadTextMessages()
	local msgTable = {}
	local files = file.Find( "gphone/messages/*.txt", "DATA" )
	
	for k, v in pairs(files) do
		local msgJSON = file.Read( "gphone/messages/"..v, "DATA" )
		local tbl = util.JSONToTable( gPhone.unscrambleJSON( msgJSON ) )
		
		local id = string.gsub(v, ".txt", "")
		id = gPhone.formatToSteamID( id )
		
		msgTable[id] = tbl
	end

	return msgTable
end

--// Checks the local gPhone version with the newest version
function gPhone.checkUpdate()
	for k, v in pairs( gPhone.getBadgesForApp( "settings" ) ) do
		if v == "update" then
			return -- Dont need to check update if a badge exists for an update
		end
	end
	
	local isUpdate = false
	http.Fetch( "http://exho1.github.io/gphone/index.html", 
	function ( body, len, headers, code )
		-- Gotta find the json 
		local startPos = string.find( body, "{")
		local endPos = string.find( body, "}")
		
		-- Somehow the JSON isn't working properly
		if startPos == nil or endPos == nil then
			gPhone.incrementBadge( "Settings", "update" )
			gPhone.msgC( GPHONE_MSGC_WARNING, "Invalid JSON format to check version from" )
			gPhone.updateTable = {update=true, version="N/A", description=trans(update_check_fail).." #2", date="N/A"}
			return
		end
		
		-- Json -> Table
		local json = string.sub( body, startPos, endPos )
		local tbl = util.JSONToTable( json )
		
		if tbl == nil then
			gPhone.msgC( GPHONE_MSGC_WARNING, "Update data returned an invalid table" )
			return
		end
		
		-- Get json data
		local webVersion = tbl[1]
		local description = tbl[2]
		local date = string.sub( tbl[3], 1, 10 ) -- Trim off anything that is not part of the date
		
		gPhone.msgC( GPHONE_MSGC_NONE, "Successfully retrieved update data from server" )
		
		local numWebVersion = string.gsub( webVersion, "[.]", "" ) -- The period is the gsub symbol for all characters... Brackets negates that
		local curVersion = string.gsub( gPhone.version , "[.]", "" )
		
		if numWebVersion > curVersion then
			isUpdate = true
			gPhone.incrementBadge( "Settings", "update" )
		else
			gPhone.decrementBadge( "Settings", "update", true )
		end
		gPhone.updateTable = {update=isUpdate, version=webVersion, description=description, date=date}
	end,
	function (error)
		-- Not actually an update but an error
		gPhone.incrementBadge( "Settings", "update" )
		gPhone.msgC( GPHONE_MSGC_WARNING, "Unable to connect to the gPhone webpage to verify versions!" )
		gPhone.updateTable = {update=true, version="N/A", description=trans(update_check_fail).." #1", date="N/A"}
	end)
end

--// Custom word wrapping function originally made for the texting app
function gPhone.wordWrap( label, wrapWidth, buffer )
	buffer = buffer or 10
	wrapWidth = wrapWidth - buffer
	
	label:SizeToContents()
	local w, h = label:GetSize()
	
	if w - buffer >= wrapWidth - buffer then -- Gmod's word wrapping is meh, I'll make my own
		local text = label:GetText()
		surface.SetFont(label:GetFont())
		
		-- Split the text by letter into a table
		local frags = string.Explode( "", text )
		local width, lineBreaks = 0, 1
		for k, v in pairs( frags ) do
			width = width + surface.GetTextSize(v)
			
			-- The string is longer than the message's width (minus a buffer)
			if width >= wrapWidth - buffer then 
				local letter = frags[k]
				
				if letter == " " then -- Perfect, we create new line on a space
					table.insert(frags, k, "\r\n")
				else
					local foundSpace = false
					-- Or we have to go back and find one...
					for i = k, k - 30, -1 do
						if frags[i] == " " then
							table.insert(frags, i, "\r\n")
							table.remove(frags, i + 1)
							foundSpace = true
							break
						end
					end
					
					-- Last resort, split the word
					if foundSpace == false then
						table.insert(frags, k, "-\r\n-")
					end
				end
				lineBreaks = lineBreaks + 1
				width = 0 
			end
		end
		
		-- Reassemble the text 
		text = table.concat( frags, "" )
		label:SetText( text )
		
		-- Size the message box's background according to the number of line breaks
		--label:SetSize( wrapWidth - buffer, h * (lineBreaks)) 
		label:SizeToContents()
		
		return lineBreaks or 1
	end
end

--// Writes a badge table {app=string, id=string} to a text file to be loaded when the phone opens
function gPhone.cacheBadge( tbl )
	if not file.Exists("gphone/offlines_badges.txt", "DATA") then
		local json = util.TableToJSON( {tbl} ) 
		file.Write( "gphone/offlines_badges.txt", json)
		return
	end
	
	local cache = file.Read( "gphone/offlines_badges.txt", "DATA" )
	local cTable = util.JSONToTable( cache ) 
	
	for k, v in pairs( cTable ) do
		if v.id != tbl.id and v.app != tbl.app then
			table.insert(cTable, tbl)
		end
	end
	
	local json = util.TableToJSON( cTable ) 
		
	file.Write( "gphone/offlines_badges.txt", json)
end

--// Loads any badges that were incremented while the phone was offline
function gPhone.loadBadges()
	if not file.Exists("gphone/offlines_badges.txt", "DATA") then return end
	gPhone.msgC( GPHONE_MSGC_NOTIFY, "Loading offlines badges file")
	
	local cache = file.Read( "gphone/offlines_badges.txt", "DATA" )
	local cTable = util.JSONToTable( cache ) 
	
	if cTable == nil then return end
	
	for k, data in pairs(cTable) do
		if data.app != nil and data.id != nil then
			gPhone.incrementBadge( data.app, data.id )
		end
	end
	
	-- Remove the file, its not needed anymore
	file.Delete( "gphone/offlines_badges.txt")
end

--// Adds a red badge to a homescreen app with a unique id
function gPhone.incrementBadge( app, id )
	id = string.lower( id )
	
	if not gPhone.exists() or not gPhone.phoneBase then
		gPhone.msgC( GPHONE_MSGC_WARNING, "Cannot increment badge for non-existant phone")
		gPhone.cacheBadge( {app=app,id=id} )
		return
	end
	
	gPhone.appBadges = gPhone.appBadges or {}
	gPhone.appBadges[app] = gPhone.appBadges[app] or {}
	
	-- Check for repeats of the same badge id
	for k, v in pairs( gPhone.appBadges[app] ) do
		if v == id then
			gPhone.msgC( GPHONE_MSGC_WARNING, "Attempted to add another app badge of the same id: "..id )
			return
		end
	end
	
	-- Log to console and insert into the badge table
	table.insert( gPhone.appBadges[app], id )
	gPhone.msgC( GPHONE_MSGC_NOTIFY, "Incremented "..app.." badge to "..#gPhone.appBadges[app].." with id: "..id )
	
	-- Rebuild on homescreen
	if gPhone.isOnHomescreen then
		gPhone.buildHomescreen( gPhone.apps )
	end
end

--// Removes a badge id or removes all the ids for a specific app
function gPhone.decrementBadge( app, id, bAll )
	gPhone.appBadges = gPhone.appBadges or {}
	gPhone.appBadges[app] = gPhone.appBadges[app] or {}
	
	for k, v in pairs( gPhone.appBadges[app] ) do
		if v == id then
			if bAll then
				gPhone.appBadges[app] = {}
			else
				gPhone.appBadges[app][k] = nil
			end
		
			gPhone.msgC( GPHONE_MSGC_NOTIFY, "Decremented "..app.." badge to "..#gPhone.appBadges[app].." with id: "..id )
	
			-- Rebuild on homescreen
			if gPhone.isOnHomescreen then
				gPhone.buildHomescreen( gPhone.apps )
			end
			return
		end
	end
	gPhone.msgC( GPHONE_MSGC_WARNING, "Attempted remove badge for nonexistant id: "..id )
end

function gPhone.getHiddenApps()
	local hidden = {}
	
	-- Grab all apps that exist but are not on the homescren
	for key, data in pairs( gPhone.apps ) do
		local failCount = 0 
		for _, tbl in pairs( gPhone.appPanels ) do
			if data.name != tbl.name then
				failCount = failCount + 1
			else
				break
			end
			
			if failCount == #gPhone.appPanels then
				table.insert( hidden, data )
			end
		end
	end
	
	return hidden
end

--// Returns the badge table for the given app name
function gPhone.getBadgesForApp( name )
	name = name:lower()
	gPhone.appBadges = gPhone.appBadges or {}
	
	if gPhone.appBadges[name] then
		return gPhone.appBadges[name]
	end
	return {}
end

--// Saves a table entry for an application
function gPhone.setAppData( app, key, value )
	local data = {}
	
	-- Load any app data
	if gPhone.hasAppData( app ) then
		data = gPhone.getAppData( app )
	end
	
	-- Error on nil value
	if not value then
		error( "nil value to save as app data" )
	end

	-- Insert the value into the table at a specified key or at the end
	if key then
		data[key] = value
	else
		table.insert( data, value )
	end
	
	local json = util.TableToJSON( data )
		
	if not file.Exists( "gphone/data", "DATA" ) then
		file.CreateDir( "gphone/data" )
	end
	
	file.Write( "gphone/data/"..app..".txt", json)
end

--// Returns the value for app data or the entire table if no key is provided
function gPhone.getAppData( app, key )
	local data = {}
	
	if gPhone.hasAppData( app ) then
		local json = file.Read( "gphone/data/"..app..".txt", "DATA" )
		data = util.JSONToTable( json )
		
		if key then
			return data[key]
		end
		return data
	end
	return
end

--// Checks to see if the app has saved data
function gPhone.hasAppData( app )
	if file.Exists( "gphone/data/"..app..".txt", "DATA" ) then
		return true
	end
	return false
end

--// Cleans up errors and repeated apps on the homescreen - You shouldn't call this
function gPhone.fixHomescreen( tbl )
	for k, v in pairs( tbl ) do
		if v.name:lower() == "n/a" then -- Invalid name 
			gPhone.msgC( GPHONE_MSGC_WARNING, "Invalid app at key: "..k.."!" )
			table.remove(tbl, k)
		end 
		
		for k2, v2 in pairs( tbl ) do -- Run through the same table a different time
			if v.apps then 
				local strTable = tostring(v.apps)
				for k3, v3 in pairs( v.apps ) do
					if v2.name == v3.name and v2.icon == v3.icon then -- App exists in both folder and homescreen
						gPhone.msgC( GPHONE_MSGC_WARNING, "Repeated app at key: "..k2.." and in folder: "..strTable.." key: "..k3)
						table.remove(tbl, k2)
					end
					
					for k4, v4 in pairs( v.apps ) do
						if v3.name == v4.name and v3.icon == v4.icon and k3 ~= k4 then -- Repeated app in a folder
							gPhone.msgC( GPHONE_MSGC_WARNING, "Repeated app in folder: "..strTable..". Keys: "..k3.." and "..k4)
							table.remove(tbl[k2].apps, k)
						end
					end
				end
			end
			
			if v.name == v2.name and v.icon == v2.icon and k ~= k2 then -- Repeated app
				if tbl[k] and tbl[k].name == v.name and tbl[k].name == v2.name then
					gPhone.msgC( GPHONE_MSGC_WARNING, "Repeated app at keys: "..k.." and "..k2.."!" )
					table.remove(tbl, k)
				end
			end
		end
	end
end