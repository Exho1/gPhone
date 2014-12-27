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

-- Temp
concommand.Add("vibrate", function()
	gPhone.Vibrate()
end)

--// Fonts
surface.CreateFont( "gPhone_TitleLite", {
	font = "Roboto Lt",
	size = 18,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_StatusBar", {
	font = "Roboto Lt",
	size = 14,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_AppName", {
	font = "Roboto Lt",
	size = 12,
	weight = 600,
	antialias = true,
} )

surface.CreateFont( "gPhone_LockTime", {
	font = "Roboto Lt",
	size = 60,
	weight = 300,
	antialias = true,
} )

surface.CreateFont( "gPhone_Title", {
	font = "Roboto Lt",
	size = 18,
	weight = 650,
	antialias = true,
} )

surface.CreateFont( "gPhone_Error", {
	font = "Roboto Lt",
	size = 22,
	weight = 650,
	antialias = true,
} )

--// Hide or show children of a panel
function gPhone.HideChildren( pnl )
	for k, v in pairs( pnl:GetChildren() ) do
		if IsValid(v) then
			v:SetVisible(false)
		end
	end
end

function gPhone.ShowChildren( pnl )
	for k, v in pairs( pnl:GetChildren() ) do
		if IsValid(v) then
			v:SetVisible(true)
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
	print("Saving gPhone Config")
	
	cfgJSON = util.TableToJSON( gPhone.Config )
	
	file.CreateDir( "gphone" )
	file.Write( "gphone/client_config.txt", cfgJSON)
end

function gPhone.LoadClientConfig()
	print("Loading gPhone Config")
	
	if not file.Exists( "gphone/client_config.txt", "DATA" ) then
		print("gPhone cannot load a non-existant config file! Rebuilding...")
		gPhone.SaveClientConfig()
		gPhone.LoadClientConfig()
		return
	end
	
	local cfgFile = file.Read( "gphone/client_config.txt", "DATA" )
	local cfgTable = util.JSONToTable( cfgFile ) 

	gPhone.Config = cfgTable
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
