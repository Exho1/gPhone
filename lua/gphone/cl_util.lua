----// Clientside Utility Functions //----

local client = LocalPlayer()

--// Console commands
concommand.Add("gphone", function()
	gPhone.buildPhone()
end)

concommand.Add("gphone_close", function()
	gPhone.hidePhone()
end)

concommand.Add("gphone_remove", function()
	gPhone.destroyPhone()
end)

concommand.Add("gphone_configsave", function()
	gPhone.saveClientConfig()
end)

-- TEMPORARY

concommand.Add("vibrate", function()
	gPhone.vibrate()
end)
-- END TEMPORARY

--// Fonts
surface.CreateFont( "gPhone_18Lite", {
	font = "Roboto Lt",
	size = 18,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_14", {
	font = "Roboto Lt",
	size = 14,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_16", {
	font = "Roboto Lt",
	size = 14,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_12", {
	font = "Roboto Lt",
	size = 12,
	weight = 600,
	antialias = true,
} )

surface.CreateFont( "gPhone_60", {
	font = "Roboto Lt",
	size = 60,
	weight = 300,
	antialias = true,
} )

surface.CreateFont( "gPhone_40", {
	font = "Roboto Lt",
	size = 40,
	weight = 400,
	antialias = true,
} )

surface.CreateFont( "gPhone_18", {
	font = "Roboto Lt",
	size = 18,
	weight = 650,
	antialias = true,
} )

surface.CreateFont( "gPhone_18lite", {
	font = "Roboto Lt",
	size = 18,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_20", {
	font = "Roboto Lt",
	size = 20,
	weight = 650,
	antialias = true,
} )

surface.CreateFont( "gPhone_22", {
	font = "Roboto Lt",
	size = 20,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_36", {
	font = "Roboto Lt",
	size = 36,
	weight = 650,
	antialias = true,
} )

--// Panel-based blur function kindly given by Netheous (STEAM_0:0:19766778)
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

--// Hide or show children of a panel
function gPhone.hideChildren( pnl )
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( pnl:GetChildren() ) do
		if IsValid(v) then
			v:SetVisible(false)
		end
	end
end

function gPhone.showChildren( pnl )
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( pnl:GetChildren() ) do
		if IsValid(v) then
			v:SetVisible(true)
		end
	end
end

function gPhone.hideAppObjects()
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( gApp["_children_"] ) do
		if IsValid(v) then
			v:SetVisible( false )
		end
	end
end

--// Chat messages
function gPhone.chatMsg( text )
	chat.AddText(
		Color(17, 148, 240), "[gPhone]", 
		Color(255,255,255), ": "..text
	)
end
 
net.Receive( "gPhone_ChatMsg", function( len, ply )
	gPhone.chatMsg( net.ReadString() )
end)

--// Wallpaper
function gPhone.setWallpaper( bHome, texStr )
	if bHome then
		gPhone.config.HomeWallpaperMat = Material(texStr)
		gPhone.config.HomeWallpaper = texStr
	else
		gPhone.config.LockWallpaperMat = Material(texStr)
		gPhone.config.LockWallpaper = texStr
	end
end

function gPhone.getWallpaper( bHome, isMat )
	if bHome then
		if isMat then
			return gPhone.config.HomeWallpaperMat or Material( gPhone.config.FallbackWallpaper )
		else
			return gPhone.config.HomeWallpaper or gPhone.config.FallbackWallpaper
		end
	else
		if isMat then
			return gPhone.config.LockWallpaperMat or Material( gPhone.config.FallbackWallpaper )
		else
			return gPhone.config.LockWallpaper or gPhone.config.FallbackWallpaper
		end
	end
end

--// Color the status bar
function gPhone.darkenStatusBar()
	for class, tab in pairs(gPhone.StatusBar) do
		if class == "text" then
			for k, pnl in pairs(tab) do
				if not IsValid(pnl) then return end
				pnl:SetTextColor(Color(0,0,0))
			end
		else
			for k, pnl in pairs(tab) do
				if not IsValid(pnl) then return end
				pnl:SetImageColor(Color(0,0,0))
			end
		end
	end
end

function gPhone.lightenStatusBar() 
	for class, tab in pairs(gPhone.StatusBar) do
		if class == "text" then
			for k, pnl in pairs(tab) do
				if not IsValid(pnl) then return end
				pnl:SetTextColor(Color(255,255,255))
			end
		else
			for k, pnl in pairs(tab) do
				if not IsValid(pnl) then return end
				pnl:SetImageColor(Color(255,255,255))
			end
		end
	end
end

--// Show or hide the entire status bar or portions
function gPhone.showStatusBar()
	for class, tab in pairs(gPhone.StatusBar) do
		for k, pnl in pairs(tab) do
			pnl:SetVisible(true)
		end
	end
end

function gPhone.showStatusBarElement( name )
	for class, tab in pairs(gPhone.StatusBar) do
		if tab[string.lower(name)] then
			tab[string.lower(name)]:SetVisible(true)
		end
	end
end

function gPhone.hideStatusBar()
	for class, tab in pairs(gPhone.StatusBar) do
		for k, pnl in pairs(tab) do
			pnl:SetVisible(false)
		end
	end
end

function gPhone.hideStatusBarElement( name )
	for class, tab in pairs(gPhone.StatusBar) do
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
function gPhone.setTextAndCenter(label, parent, vertical)
	label:SizeToContents()
	local x, y = label:GetPos()
	if vertical then
		label:SetPos( parent:GetWide()/2 - label:GetWide()/2, parent:GetTall()/2 - label:GetTall()/2 )
	else
		label:SetPos( parent:GetWide()/2 - label:GetWide()/2, y )
	end
end

--// Save config
function gPhone.saveClientConfig()
	gPhone.msgC( GPHONE_MSGC_NONE, "Saving config file")
	
	cfgJSON = util.TableToJSON( gPhone.config )
	
	file.CreateDir( "gphone" )
	file.Write( "gphone/client_config.txt", cfgJSON)
end

--// Load config
function gPhone.loadClientConfig()
	gPhone.msgC( GPHONE_MSGC_NONE, "Loading config file")
	
	if not file.Exists( "gphone/client_config.txt", "DATA" ) then
		gPhone.msgC( GPHONE_MSGC_WARNING, "Unable to locate config file!!")
		gPhone.saveClientConfig()
		gPhone.loadClientConfig()
		return
	end
	
	local cfgFile = file.Read( "gphone/client_config.txt", "DATA" )
	local cfgTable = util.JSONToTable( cfgFile ) 

	gPhone.config = cfgTable
end

--// Retrieves app positions
function gPhone.saveAppPositions( tbl )
	cfgJSON = util.TableToJSON( tbl )
	
	file.CreateDir( "gphone" )
	file.Write( "gphone/homescreen_layout.txt", cfgJSON)
end

--// Saves moved app positions
function gPhone.getActiveAppPositions()
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
	local idFormat = gPhone.steamIDToFormat( ply:SteamID() )
	
	local msgTable = {target=target, time=os.date( "%I:%M%p" ), date = os.date( "%x" ), message=msg }
	
	-- Off to the server!
	net.Start("gPhone_DataTransfer")
		net.WriteTable({header=GPHONE_TEXT_MSG, tbl=msgTable})
	net.SendToServer()
	
	-- If the server has flagged us as a spammer our message should not appear in the app
	-- The message does get sent to the server, though, so that we can receive a "X seconds left" message
	if LocalPlayer():GetNWBool("gPhone_CanText", true) == false then return end
	
	-- Store the sent text on the client
	msgTable.self = true
	msgTable.sender = LocalPlayer():Nick()
	gPhone.receiveTextMessage( msgTable, true )
end

--// Saves a text message to an existing txt document or a new one
function gPhone.receiveTextMessage( tbl, bSelf )
	-- tbl.sender, tbl.self, tbl.time, tbl.date, tbl.message
	local writeTable = {}
	local ply
	if bSelf then
		ply = util.getPlayerByNick( tbl.sender )
	else
		ply = util.getPlayerByNick( tbl.target )
	end
	local idFormat = gPhone.steamIDToFormat( ply:SteamID() )
	
	print("Received", bSelf, tbl.sender, tbl.target)
	
	if file.Exists( "gphone/messages/"..idFormat..".txt", "DATA" ) then
		local readFile = file.Read( "gphone/messages/"..idFormat..".txt", "DATA" )
		local readTable = util.JSONToTable( readFile ) 
		
		writeTable = readTable
	end

	table.insert( writeTable, tbl )

	local json = util.TableToJSON( writeTable ) 
		
	file.CreateDir( "gphone/messages" )
	file.Write( "gphone/messages/"..idFormat..".txt", json)
	
	local app = gApp["_active_"]
	app.Data.UpdateMessages( idFormat )
end

--// Loads all text messages 
function gPhone.loadTextMessages()
	local msgTable = {}
	files = file.Find( "gphone/messages/*.txt", "DATA" )
	
	for k, v in pairs(files) do
		local msgJSON = file.Read( "gphone/messages/"..v, "DATA" )
		local tbl = util.JSONToTable( msgJSON )
		
		local id = string.gsub(v, ".txt", "")
		id = gPhone.formatToSteamID( id )
		
		msgTable[id] = tbl
	end

	return msgTable
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
