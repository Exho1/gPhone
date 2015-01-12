----// Clientside Utility Functions //----

local client = LocalPlayer()

--// Console commands
concommand.Add("gphone", function()
	gPhone.BuildPhone()
end)

concommand.Add("gphone_close", function()
	gPhone.HidePhone()
end)

concommand.Add("gphone_remove", function()
	gPhone.DestroyPhone()
end)

concommand.Add("gphone_configsave", function()
	gPhone.SaveClientConfig()
end)

-- TEMPORARY
concommand.Add("text", function()
	gPhone.SendTextMessage( "Exho", 1 )
end)

concommand.Add("textload", function()
	gPhone.LoadTextMessages()
end)

concommand.Add("vibrate", function()
	gPhone.Vibrate()
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

surface.CreateFont( "gPhone_20", {
	font = "Roboto Lt",
	size = 20,
	weight = 650,
	antialias = true,
} )

surface.CreateFont( "gPhone_36", {
	font = "Roboto Lt",
	size = 36,
	weight = 650,
	antialias = true,
} )

--// Hide or show children of a panel
function gPhone.HideChildren( pnl )
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( pnl:GetChildren() ) do
		if IsValid(v) then
			v:SetVisible(false)
		end
	end
end

function gPhone.ShowChildren( pnl )
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( pnl:GetChildren() ) do
		if IsValid(v) then
			v:SetVisible(true)
		end
	end
end

function gPhone.HideAppObjects()
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( gApp["_children_"] ) do
		if IsValid(v) then
			v:SetVisible( false )
		end
	end
end

--// Chat messages
function gPhone.ChatMsg( text )
	chat.AddText(
		Color(17, 148, 240), "[gPhone]", 
		Color(255,255,255), ": "..text
	)
end
 
net.Receive( "gPhone_ChatMsg", function( len, ply )
	gPhone.ChatMsg( net.ReadString() )
end)

--// Wallpaper
function gPhone.SetWallpaper( bHome, texStr )
	if bHome then
		gPhone.Config.HomeWallpaperMat = Material(texStr)
		gPhone.Config.HomeWallpaper = texStr
	else
		gPhone.Config.LockWallpaperMat = Material(texStr)
		gPhone.Config.LockWallpaper = texStr
	end
end

function gPhone.GetWallpaper( bHome, isMat )
	if bHome then
		if isMat then
			return gPhone.Config.HomeWallpaperMat or Material( gPhone.Config.FallbackWallpaper )
		else
			return gPhone.Config.HomeWallpaper or gPhone.Config.FallbackWallpaper
		end
	else
		if isMat then
			return gPhone.Config.LockWallpaperMat or Material( gPhone.Config.FallbackWallpaper )
		else
			return gPhone.Config.LockWallpaper or gPhone.Config.FallbackWallpaper
		end
	end
end

--// Color the status bar
function gPhone.DarkenStatusBar()
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

function gPhone.LightenStatusBar() 
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
function gPhone.ShowStatusBar()
	for class, tab in pairs(gPhone.StatusBar) do
		for k, pnl in pairs(tab) do
			pnl:SetVisible(true)
		end
	end
end

function gPhone.ShowStatusBarElement( name )
	for class, tab in pairs(gPhone.StatusBar) do
		if tab[string.lower(name)] then
			tab[string.lower(name)]:SetVisible(true)
		end
	end
end

function gPhone.HideStatusBar()
	for class, tab in pairs(gPhone.StatusBar) do
		for k, pnl in pairs(tab) do
			pnl:SetVisible(false)
		end
	end
end

function gPhone.HideStatusBarElement( name )
	for class, tab in pairs(gPhone.StatusBar) do
		if tab[string.lower(name)] then
			tab[string.lower(name)]:SetVisible(false)
		end
	end
end

--// Grab text size easily
function gPhone.GetTextSize(text, font)
	surface.SetFont(font)
	return surface.GetTextSize(text)
end

--// Center text in a panel
function gPhone.SetTextAndCenter(label, parent, vertical)
	label:SizeToContents()
	local x, y = label:GetPos()
	if vertical then
		label:SetPos( parent:GetWide()/2 - label:GetWide()/2, parent:GetTall()/2 - label:GetTall()/2 )
	else
		label:SetPos( parent:GetWide()/2 - label:GetWide()/2, y )
	end
end

--// Config
function gPhone.SaveClientConfig()
	gPhone.MsgC( GPHONE_MSGC_NONE, "Saving config file")
	
	cfgJSON = util.TableToJSON( gPhone.Config )
	
	file.CreateDir( "gphone" )
	file.Write( "gphone/client_config.txt", cfgJSON)
end

function gPhone.LoadClientConfig()
	gPhone.MsgC( GPHONE_MSGC_NONE, "Loading config file")
	
	if not file.Exists( "gphone/client_config.txt", "DATA" ) then
		gPhone.MsgC( GPHONE_MSGC_WARNING, "Unable to locate config file!!")
		gPhone.SaveClientConfig()
		gPhone.LoadClientConfig()
		return
	end
	
	local cfgFile = file.Read( "gphone/client_config.txt", "DATA" )
	local cfgTable = util.JSONToTable( cfgFile ) 

	gPhone.Config = cfgTable
end

function gPhone.SetAppPositions( tbl )
	cfgJSON = util.TableToJSON( tbl )
	
	file.CreateDir( "gphone" )
	file.Write( "gphone/homescreen_layout.txt", cfgJSON)
end

function gPhone.GetAppPositions()
	if not file.Exists( "gphone/homescreen_layout.txt", "DATA" ) then
		gPhone.MsgC( GPHONE_MSGC_WARNING, "Unable to locate app position file!")
		gPhone.SetAppPositions( gPhone.Apps )
		return
	end
	
	local posFile = file.Read( "gphone/homescreen_layout.txt", "DATA" )
	local posTable = util.JSONToTable( posFile ) 

	return posTable
end

function gPhone.SendTextMessage( target, msg ) 
	local ply = util.GetPlayerByNick( target )
	local idFormat = gPhone.SteamIDToFormat( ply:SteamID() )
	
	if msg == 1 then
		local possibles = {"Numbers: 123123123123", "What what..",
		"I need more messages to enter into this box to test", "Howaboutalongnonspacedstring?",
		"This is a very, very long spaced string that should use at least 3 lines if I am lucky"}
		
		msg = table.Random(possibles)
	end
	
	print("Sent", msg, "to", target)
	local msgTable = {target=target, time=os.date( "%I:%M%p" ), date = os.date( "%x" ), message=msg }
	
	net.Start("gPhone_DataTransfer")
		net.WriteTable({header=GPHONE_TEXT_MSG, tbl=msgTable})
	net.SendToServer()
	
	-- Store the sent text on the client
	msgTable.self = true
	msgTable.sender = LocalPlayer():Nick()
	gPhone.ReceiveTextMessage( msgTable, true )
end

--[[
	// Issues //
Messages are not saving
id on line 197 is nil after the first message

]]

--// Saves a text message to an existing txt document or a new one
function gPhone.ReceiveTextMessage( tbl, bSelf )
	-- tbl.sender, tbl.self, tbl.time, tbl.date, tbl.message
	local writeTable = {}
	local ply
	if bSelf then
		ply = util.GetPlayerByNick( tbl.sender )
	else
		ply = util.GetPlayerByNick( tbl.target )
	end
	local idFormat = gPhone.SteamIDToFormat( ply:SteamID() )
	
	print("ID format", idFormat)
	if file.Exists( "gphone/messages/"..idFormat..".txt", "DATA" ) then
		local readFile = file.Read( "gphone/messages/"..idFormat..".txt", "DATA" )
		local readTable = util.JSONToTable( readFile ) 
		
		writeTable = readTable
	end

	print("Received", ply )
	table.insert( writeTable, tbl )

	local json = util.TableToJSON( writeTable ) 
		
	file.CreateDir( "gphone/messages" )
	file.Write( "gphone/messages/"..idFormat..".txt", json)
	
	local app = gApp["_active_"]
	if app.Data.PrintName == "Messages" then
		app.Data.UpdateMessages( idFormat )
	end
end

--// Loads all text messages 
function gPhone.LoadTextMessages()
	local msgTable = {}
	files = file.Find( "gphone/messages/*.txt", "DATA" )
	
	for k, v in pairs(files) do
		local msgFile = file.Read( "gphone/messages/"..v, "DATA" )
		local tbl = util.JSONToTable( msgFile )
		
		local id = string.gsub(v, ".txt", "")
		id = gPhone.FormatToSteamID( id )
		
		msgTable[id] = tbl
	end
	
	return msgTable
end

function gPhone.SteamIDToFormat( id )
	local idFragments = string.Explode( ":", id )
	
	local oneOrZero = idFragments[2]
	local bulk = idFragments[3]
	
	local fmat = oneOrZero..bulk
	
	return fmat
end

function gPhone.FormatToSteamID( fmat )
	local front = "STEAM_0:"
	
	local formatFrags = string.Explode( "", fmat )
	local middle = formatFrags[1]
	table.remove( formatFrags, 1 )
	local end_ = table.concat( formatFrags, "")
	
	local id = front..middle..":"..end_
	
	return id
end
