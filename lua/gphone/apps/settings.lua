local APP = {}
local trans = gPhone.getTranslation

APP.PrintName = "Settings"
APP.Icon = "vgui/gphone/settings.png"
APP.Author = "Exho"
APP.Tags = {"Manage", "Config", "Settings"}

local topLevelTabs = {
	trans("airplane_mode"),
	trans("vibrate"),
	"_SPACE_",
	trans("general"),
	trans("wallpaper"),
	trans("homescreen"),
	"_SPACE_", 
	trans("music")
}

local generalLevelTabs = {
	trans("about"),
	trans("update"),
	"_SPACE_",
	trans("language"),
	trans("color"),
	trans("binds"),
	trans("archive"),
	"_SPACE_",
	trans("developer"),
}

local homescreenLevelTabs = {
	{text=trans("show_unusable_apps"), button=false},
	{text="_SPACE_", button=false},
	{text=trans("reset_app_pos"), button=true},
}

local musicLevelTabs = {
	[trans("stop_on_tab")] = "stopMusicOnTabOut",
	[trans("find_album_covers")] = "autoFindAlbumCovers",
}

local bindLevelTabs = {
	trans("open_key"),
	trans("confirm"),
	"_SPACE_",
	trans("key_hold"),
	trans("confirm"),
}

local archivePanels = {
	{text=trans("archive_cleanup"), toggle=true, val="deleteArchivedFiles"},
	{text=trans("file_life"), val="daysToCleanupArchive"},
	{text="_SPACE_"},
	{text=trans("wipe_archive"), button=true},
}

function APP.Run( objects, screen )
	gPhone.darkenStatusBar()
	
	objects.Title = vgui.Create( "DLabel", screen )
	objects.Title:SetText( trans("settings") )
	objects.Title:SetTextColor( color_black )
	objects.Title:SetFont("gPhone_18Lite")
	objects.Title:SizeToContents()
	objects.Title:SetPos( screen:GetWide()/2 - objects.Title:GetWide()/2, 25 )
	
	objects.Back = vgui.Create("gPhoneBackButton", screen)
	objects.Back:SetTextColor( gPhone.colors.blue )
	objects.Back:SetPos( 10, 25 )
	objects.Back:SetVisible( false )
	
	local offset = 20 -- A little trick to push the scrollbar off the screen
	objects.LayoutScroll = vgui.Create( "DScrollPanel", screen )
	objects.LayoutScroll:SetSize( screen:GetWide() + offset, screen:GetTall() - 50 )
	objects.LayoutScroll:SetPos( 0, 80 )
	objects.LayoutScroll.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, self:GetWide(), self:GetTall(), 0, Color(0, 235, 0))
	end
	
	objects.Layout = vgui.Create( "DIconLayout", objects.LayoutScroll )
	objects.Layout:SetSize( screen:GetWide(), screen:GetTall() - 1 )
	objects.Layout:SetPos( 0, 1 )
	objects.Layout:SetSpaceY( 0 )
	
	for key, name in pairs( topLevelTabs ) do
		local lName = name:lower()
		if name == "_SPACE_" then
			local fake = objects.Layout:Add("DPanel")
			fake:SetSize(screen:GetWide(), 30)
			fake.Paint = function() end
		elseif lName != trans("airplane_mode"):lower() and lName != trans("vibrate"):lower() then
			local layoutButton = objects.Layout:Add("DButton")
			layoutButton:SetSize(screen:GetWide(), 30)
			layoutButton:SetText("")
			layoutButton.Paint = function()
				if not layoutButton:IsDown() then
					draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.whiteBG)
				else
					draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.darkWhiteBG)
				end
				
				draw.RoundedBox(0, 30, layoutButton:GetTall()-1, layoutButton:GetWide()-30, 1, gPhone.colors.greyAccent)
			end
			layoutButton.DoClick = function()
				APP.OpenTab( name )
			end
			
			local title = vgui.Create( "DLabel", layoutButton )
			title:SetText( name )
			title:SetTextColor(Color(0,0,0))
			title:SetFont("gPhone_18")
			title:SizeToContents()
			title:SetPos( 35, 5 )
		else
			local bgPanel = objects.Layout:Add("DPanel")
			bgPanel:SetSize(screen:GetWide(), 30)
			bgPanel.Paint = function( self, w, h) 
				draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
				
				draw.RoundedBox(0, 30, h-1, w-30, 1, gPhone.colors.greyAccent)
			end
			
			local cfg
			if gPhone.phraseToEnglish(name):lower() == "airplane mode" then
				cfg = "airplaneMode"
			else
				cfg = "vibrate"
			end
			
			local toggleButton = vgui.Create("gPhoneToggleButton", bgPanel)
			toggleButton:SetPos( bgPanel:GetWide() - toggleButton:GetWide() - 10, 2 )
			toggleButton:SetBool( gPhone.config[cfg] )
			toggleButton.OnValueChanged = function( self, bVal )
				gPhone.setConfigValue( cfg, bVal )
			end
			
			local title = vgui.Create( "DLabel", bgPanel )
			title:SetText( name )
			title:SetTextColor(Color(0,0,0))
			title:SetFont("gPhone_18")
			title:SizeToContents()
			title:SetPos( 35, 5 )
		end
	end
end

--// Sets the title and hides old panels, called by nearly all tabs
function APP.PrepareNewTab( name )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	gPhone.setTextAndCenter(objects.Title, name, screen)
	
	-- Hide the app's home screen
	for k, v in pairs(objects.Layout:GetChildren()) do
		v:SetVisible(false)
	end
end

--// Returns to the main screen, called by top level tabs
function APP.ToMainScreen()
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	objects.Back:SetVisible( false )
	gPhone.setTextAndCenter(objects.Title, trans("settings"), screen)
	
	for k, pnl in pairs( objects ) do
		pnl:Remove()
	end
	
	APP.Run( objects, screen )
end

--// Custom function to handle the opening of setting tabs
function APP.OpenTab( name )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	name = string.lower( name )
	local nameEn = gPhone.phraseToEnglish( name ):lower()
	
	if nameEn == "wallpaper" then
		APP.PrepareNewTab( trans("wallpaper") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.ToMainScreen()
		end
		
		local newBG = objects.Layout:Add("DButton")
		newBG:SetSize(objects.Layout:GetWide(), 30)
		newBG:SetText("")
		newBG.Paint = function()
			if not newBG:IsDown() then
				draw.RoundedBox(0, 0, 0, newBG:GetWide(), newBG:GetTall(), gPhone.colors.whiteBG)
			else
				draw.RoundedBox(0, 0, 0, newBG:GetWide(), newBG:GetTall(), gPhone.colors.darkWhiteBG)
			end
			draw.RoundedBox(0, 15, newBG:GetTall()-1, newBG:GetWide()-30, 1, gPhone.colors.greyAccent)
		end
		
		local text = vgui.Create( "DLabel", newBG )
		text:SetText( trans("choose_new_wp") )
		text:SetTextColor(Color(0,0,0))
		text:SetFont("gPhone_18")
		text:SizeToContents()
		text:SetPos( 15, 5 )
		
		local background = objects.Layout:Add("DPanel")
		background:SetSize(screen:GetWide(), screen:GetTall()/2.4)
		background:SetText("")
		background.Paint = function()
			draw.RoundedBox(0, 0, 0, background:GetWide(), background:GetTall(), gPhone.colors.whiteBG)
		end
		
		-- Images that show what the client's current wallpapers are set to
		local previewLock = vgui.Create("DImage", background)
		previewLock:SetSize( screen:GetWide()/2.5, screen:GetTall()/3 )
		previewLock:SetPos( 20, 10)
		previewLock:SetImage( gPhone.getWallpaper( false ) )
		local previewHome = vgui.Create("DImage", background)
		previewHome:SetSize( screen:GetWide()/2.5, screen:GetTall()/3 )
		previewHome:SetPos( 20 + previewLock:GetWide() + 10, 10)
		previewHome:SetImage( gPhone.getWallpaper( true ) )
		
		--// Switch modes to the Material Selector, its down here so I can reference a couple things
		newBG.DoClick = function()
			newBG:SetDisabled(true)
			local selectedImage = nil
			
			-- Hide what we don't need anymore
			previewLock:SetVisible(false)
			previewHome:SetVisible(false)
			background:SetSize(screen:GetWide(), screen:GetTall()/2)
			text:SetText( trans("wp_selector") )
			text:SizeToContents()
			
			-- Create a tree
			local tree = vgui.Create("DTree", background)
				local dir = tree:AddNode( trans("wallpapers") )
				dir:MakeFolder( "materials/vgui/gphone/wallpapers", "GAME", true ) -- Set it to the wallpaper directory
			tree:SetSize( screen:GetWide()/1.5, 170 )
			tree:SetPos( screen:GetWide()/2 - tree:GetWide()/2, 10)
			tree.OnNodeSelected = function( node )
				local item = tree:GetSelectedItem()
				local filepath = item:GetText()
				
				if string.find(filepath, ".png") then
					selectedImage = "vgui/gphone/wallpapers/"..filepath
				end
			end
			
			-- Space it out a bit with a fake panel
			local fake = objects.Layout:Add("DPanel")
			fake:SetSize(screen:GetWide(), 30)
			fake.Paint = function() end
			
			-- Create a place for the buttons to go
			local buttonBG = objects.Layout:Add("DPanel")
			buttonBG:SetSize(screen:GetWide(), 30)
			buttonBG:SetText("")
			buttonBG.Paint = function( self ) end
			
			local x, y = tree:GetPos()
			-- If your wallpaper is white, the status bar will be hard to see
			local darkenStatusBar = vgui.Create( "DCheckBoxLabel", background )
			darkenStatusBar:SetPos( 50, y + tree:GetTall() + 5)
			darkenStatusBar:SetText( trans("dark_status") )	
			darkenStatusBar:SizeToContents()
			darkenStatusBar:SetTextColor( Color(0,0,0) )
			darkenStatusBar:SetValue( gPhone.config.darkStatusBar )
			darkenStatusBar.OnChange = function()
				local bool = darkenStatusBar:GetChecked()
				if bool == true then
					gPhone.setConfigValue( "darkStatusBar", true )
				else
					gPhone.setConfigValue( "darkStatusBar", false )
				end
				gPhone.saveClientConfig()
			end
			
			-- Should the image be a lock screen?
			local useAsLock = vgui.Create("DButton", buttonBG)
			useAsLock:SetSize(screen:GetWide()/2, 30)
			useAsLock:SetPos( 0, 0 )
			useAsLock:SetText( trans("set_lock") )
			useAsLock.Paint = function(self)
				if not self:IsDown() then
					draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.whiteBG)
				else
					draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.darkWhiteBG)
				end
			end
			useAsLock.DoClick = function(self)
				gPhone.setWallpaper( false, selectedImage )
				gPhone.saveClientConfig()
			end
			
			-- Or should the image be the home screen
			local useAsHome = vgui.Create("DButton", buttonBG)
			useAsHome:SetSize(screen:GetWide()/2, 30)
			useAsHome:SetPos( buttonBG:GetWide() - useAsHome:GetWide(), 0 )
			useAsHome:SetText( trans("set_home") )
			useAsHome.Paint = function(self)
				if not self:IsDown() then
					draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.whiteBG)
				else
					draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.darkWhiteBG)
				end
			end
			useAsHome.DoClick = function(self)
				gPhone.setWallpaper( true, selectedImage )
				gPhone.saveClientConfig()
			end
		end
	elseif nameEn == "general" then
		APP.PrepareNewTab( trans("general"))
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.ToMainScreen()
		end
		
		for key, tabName in pairs( generalLevelTabs ) do
			if tabName == "_SPACE_" then
				local fake = objects.Layout:Add("DPanel")
				fake:SetSize(screen:GetWide(), 30)
				fake.Paint = function() end
			else
				local layoutButton = objects.Layout:Add("DButton")
				layoutButton:SetSize(screen:GetWide(), 30)
				layoutButton:SetText("")
				layoutButton.Paint = function()
					if not layoutButton:IsDown() then
						draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.whiteBG)
					else
						draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.darkWhiteBG)
					end
					
					draw.RoundedBox(0, 30, layoutButton:GetTall()-1, layoutButton:GetWide()-30, 1, gPhone.colors.greyAccent)
				end
				layoutButton.DoClick = function()
					APP.OpenLowerTab( tabName, name )
				end
				
				local title = vgui.Create( "DLabel", layoutButton )
				title:SetText( tabName )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 35, 5 )
			end
		end
	elseif nameEn == "homescreen" then
		APP.PrepareNewTab( trans("homescreen") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.ToMainScreen()
		end
		
		for _, data in pairs( homescreenLevelTabs ) do
			local name = data.text
			local bIsButton = data.button
			
			if name == "_SPACE_" then
				local fake = objects.Layout:Add("DPanel")
				fake:SetSize(screen:GetWide(), 30)
				fake.Paint = function() end
			elseif bIsButton then
				local layoutButton = objects.Layout:Add("DButton")
				layoutButton:SetSize(screen:GetWide(), 30)
				layoutButton:SetText("")
				layoutButton.Paint = function()
					if not layoutButton:IsDown() then
						draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.whiteBG)
					else
						draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.darkWhiteBG)
					end
					
					draw.RoundedBox(0, 30, layoutButton:GetTall()-1, layoutButton:GetWide()-30, 1, gPhone.colors.greyAccent)
				end
				layoutButton.DoClick = function( self )
					if name == homescreenLevelTabs[3].text then -- Reset
						gPhone.notifyAlert( {msg=trans("reset_homescreen"),
						title=trans("confirmation"), options={trans("no"), trans("yes")}}, nil, 
						function( pnl, value )
							-- On yes, move the file to the garbage directory
							gPhone.discardFile( "gphone/homescreen_layout.txt" )
						end, false, true )
					else
					
					end
				end
				
				local title = vgui.Create( "DLabel", layoutButton )
				title:SetText( name )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 35, 5 )
			else
				local bgPanel = objects.Layout:Add("DPanel")
				bgPanel:SetSize(screen:GetWide(), 30)
				bgPanel.Paint = function( self, w, h) 
					draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
					
					draw.RoundedBox(0, 30, h-1, w-30, 1, gPhone.colors.greyAccent)
				end
				
				local toggleButton = vgui.Create("gPhoneToggleButton", bgPanel)
				toggleButton:SetPos( bgPanel:GetWide() - toggleButton:GetWide() - 10, 2 )
				toggleButton:SetBool( gPhone.config.showUnusableApps )
				toggleButton.OnValueChanged = function( self, bVal )
					gPhone.setConfigValue( "showUnusableApps", bVal )
				end
				
				local title = vgui.Create( "DLabel", bgPanel )
				title:SetText( name )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 35, 5 )
			end
		end
	elseif nameEn == "music" then
		APP.PrepareNewTab( trans("music") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.ToMainScreen()
		end
		
		for name, key in pairs( musicLevelTabs ) do
		
			local bgPanel = objects.Layout:Add("DPanel")
			bgPanel:SetSize(screen:GetWide(), 30)
			bgPanel.Paint = function( self, w, h) 
				draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
				
				draw.RoundedBox(0, 30, h-1, w-30, 1, gPhone.colors.greyAccent)
			end
			
			local toggleButton = vgui.Create("gPhoneToggleButton", bgPanel)
			toggleButton:SetPos( bgPanel:GetWide() - toggleButton:GetWide() - 10, 2 )
			toggleButton:SetBool( gPhone.config[key] )
			toggleButton.OnValueChanged = function( self, bVal )
				gPhone.setConfigValue( key, bVal )
			end
			
			local title = vgui.Create( "DLabel", bgPanel )
			title:SetText( name )
			title:SetTextColor(Color(0,0,0))
			title:SetFont("gPhone_18")
			title:SizeToContents()
			title:SetPos( 35, 5 )
		end
	end
end

function APP.OpenLowerTab( name, upperTabName )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	name = name:lower()
	local nameEn = gPhone.phraseToEnglish( name ):lower()
	
	if nameEn == "about" then
		APP.PrepareNewTab( trans("about") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.OpenTab( upperTabName )
		end
		
		local bg = objects.Layout:Add("DPanel")
		bg:SetSize(screen:GetWide(), screen:GetTall()/1.5)
		bg:SetText("")
		bg.Paint = function( self )
			draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.whiteBG)
		end
		
		local background = vgui.Create("DScrollPanel", bg)
		local w, h = bg:GetSize()
		background:SetSize( w + 20, h )
		background:SetText("")
		background.Paint = function( self )
			draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.whiteBG)
		end
		
		local titleLabel = vgui.Create( "DLabel", background )
		titleLabel:SetTextColor(Color(0,0,0))
		titleLabel:SetFont("gPhone_20")
		titleLabel:SizeToContents()
		titleLabel:SetPos( 0, 5 )
		gPhone.setTextAndCenter( titleLabel, trans("title"), background )
		
		-- Credits and another phone info
		local aboutText = [[
// Contact:
Exho - STEAM_0:0:53332328

// Source: 
https://github.com/Exho1/gPhone

// Credits:
Derma blur:
https://github.com/Chessnut/NutScript

Translations:
Tomelyr - DE - STEAM_0:0:9136467
Donkie - SV - https://github.com/Donkie
Azmok - FR - STEAM_0:0:75743178
Le Otaku - IT - STEAM_0:1:59430965
Mr Matthews - PT -STEAM_0:1:52334051

Album Art:
Spotify's API
Rejax - STEAM_0:1:45852799

Phone image: 
https://creativemarket.com/buatoom

Icon images: 
http://www.flaticon.com/

// fin
The Garry Phone by Exho is licensed 
under a Creative Commons Attribution-
NonCommercial 4.0 International License.
]]

		local aboutLabel = vgui.Create( "DLabel", background )
		aboutLabel:SetText( aboutText )
		aboutLabel:SetTextColor(Color(0,0,0))
		aboutLabel:SetFont("gPhone_14")
		local x, y = titleLabel:GetPos()
		aboutLabel:SetPos( 10, y + titleLabel:GetTall() + 10 )
		--aboutLabel:SetSize( background:GetSize() )
		aboutLabel:SizeToContents()
		aboutLabel:SetWrap(true)
		
		--gPhone.wordWrap( aboutLabel, background:GetWide(), 10 )
		
	elseif name == trans("update"):lower() then
		APP.PrepareNewTab( trans("update") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.OpenTab( upperTabName )
		end
		
		--{update=Bool, version=String, description=String}
		local uData = gPhone.updateTable
		
		if uData.update then
			local background = objects.Layout:Add("DScrollPanel")
			background:SetSize(screen:GetWide() + 20, screen:GetTall()/2.4)
			background:SetText("")
			background.Paint = function( self )
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.whiteBG)
			end
			
			local appIcon = vgui.Create("DImage", background)
			appIcon:SetSize( 64, 64 )
			appIcon:SetPos( 10, 10)
			appIcon:SetImage( APP.Icon )
			appIcon:SetImageColor( color_white )
			
			local versionLabel = vgui.Create( "DLabel", background )
			versionLabel:SetText( "gOS "..(uData.version or "N/A") )
			versionLabel:SetTextColor(Color(0,0,0))
			versionLabel:SetFont("gPhone_20")
			versionLabel:SizeToContents()
			local x, y = appIcon:GetPos()
			versionLabel:SetPos( x + appIcon:GetWide() + 15, y )
			
			local providerLabel = vgui.Create( "DLabel", background )
			providerLabel:SetText( "Exho" )
			providerLabel:SetTextColor(Color(0,0,0))
			providerLabel:SetFont("gPhone_16")
			providerLabel:SizeToContents()
			providerLabel:SetPos( x + appIcon:GetWide() + 15, y + versionLabel:GetTall() + 3 )
			
			local dateLabel = vgui.Create( "DLabel", background )
			dateLabel:SetText( uData.date or "N/A" )
			dateLabel:SetTextColor(Color(0,0,0))
			dateLabel:SetFont("gPhone_16")
			dateLabel:SizeToContents()
			local _, y = providerLabel:GetPos()
			dateLabel:SetPos( x + appIcon:GetWide() + 15, y + providerLabel:GetTall() + 3 )
			
			local descriptionLabel = vgui.Create( "DLabel", background )
			descriptionLabel:SetText( uData.description or trans("no_description") )
			descriptionLabel:SetTextColor(Color(0,0,0))
			descriptionLabel:SetFont("gPhone_14")
			local x, y = appIcon:GetPos()
			descriptionLabel:SetPos( x, y + appIcon:GetTall() + 5)
			
			gPhone.wordWrap( descriptionLabel, background:GetWide(), 10 )
			
			-- Shrink the DPanel to match the content of the text
			local _, dY = descriptionLabel:GetPos()
			dY = dY + descriptionLabel:GetTall()
			
			--local w, h = background:GetSize()
			--background:SetSize( w, dY + 10 )
			
			local fake = objects.Layout:Add("DPanel")
			fake:SetSize(screen:GetWide(), 30)
			fake.Paint = function() end
				
			local layoutButton = objects.Layout:Add("DButton")
			layoutButton:SetSize(screen:GetWide(), 30)
			layoutButton:SetText("")
			layoutButton.Paint = function()
				if not layoutButton:IsDown() then
					draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.whiteBG)
				else
					draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.darkWhiteBG)
				end
				
			end
			layoutButton.DoClick = function()
				gui.OpenURL( "http://steamcommunity.com/sharedfiles/filedetails/?id=407945478" )
			end
			
			local title = vgui.Create( "DLabel", layoutButton )
			title:SetText( trans("install_u") )
			title:SetTextColor( gPhone.colors.blue )
			title:SetFont("gPhone_18")
			title:SizeToContents()
			title:SetPos( 15, 5 )
		else
			-- Your software is up to date
		end
	elseif nameEn == "color" then	
		APP.PrepareNewTab( trans("color") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.OpenTab( upperTabName )
		end
		
		local background = objects.Layout:Add("DPanel")
		background:SetSize(screen:GetWide(), screen:GetTall()/2.4)
		background:SetText("")
		background.Paint = function( self )
			draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.whiteBG)
		end
			
		local colorMixer = vgui.Create( "DColorMixer", background )
		colorMixer:SetSize( background:GetWide() - 30, background:GetTall() - 30 )
		colorMixer:SetPos( 15, 15 )
		colorMixer:SetPalette( true )
		colorMixer:SetAlphaBar( false ) 
		colorMixer:SetWangs( true )
		colorMixer:SetColor( gPhone.config.phoneColor )
		
		local fake = objects.Layout:Add("DPanel")
		fake:SetSize(screen:GetWide(), 30)
		fake.Paint = function() end
			
		local layoutButton = objects.Layout:Add("DButton")
		layoutButton:SetSize(screen:GetWide(), 30)
		layoutButton:SetText("")
		layoutButton.Paint = function( self, w, h)
			if not layoutButton:IsDown() then
				draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
			else
				draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.darkWhiteBG)
			end
			draw.RoundedBox(0, 15, self:GetTall()-1, self:GetWide(), 1, gPhone.colors.greyAccent)
		end
		layoutButton.DoClick = function()
			gPhone.setConfigValue( "phoneColor", colorMixer:GetColor() )
		end
		
		local title = vgui.Create( "DLabel", layoutButton )
		title:SetText( trans("set_color") )
		title:SetTextColor( gPhone.colors.blue )
		title:SetFont("gPhone_18")
		title:SizeToContents()
		title:SetPos( 15, 5 )
		
		local layoutButton = objects.Layout:Add("DButton")
		layoutButton:SetSize(screen:GetWide(), 30)
		layoutButton:SetText("")
		layoutButton.Paint = function( self, w, h)
			if not layoutButton:IsDown() then
				draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
			else
				draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.darkWhiteBG)
			end
		end
		layoutButton.DoClick = function()
			gPhone.setConfigValue( "phoneColor", color_white )
		end
		
		local title = vgui.Create( "DLabel", layoutButton )
		title:SetText( trans("default") )
		title:SetTextColor( color_black )
		title:SetFont("gPhone_18")
		title:SizeToContents()
		title:SetPos( 15, 5 )
	elseif nameEn == "archive" then
		APP.PrepareNewTab( trans("archive") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.OpenTab( upperTabName )
		end
		
		for _, data in pairs( archivePanels ) do
			local name = data.text
			local bIsButton = data.button
			local bIsToggle = data.toggle
			
			if name == "_SPACE_" then
				local fake = objects.Layout:Add("DPanel")
				fake:SetSize(screen:GetWide(), 30)
				fake.Paint = function() end
			elseif bIsButton == true then
				local layoutButton = objects.Layout:Add("DButton")
				layoutButton:SetSize(screen:GetWide(), 30)
				layoutButton:SetText("")
				layoutButton.Paint = function()
					if not layoutButton:IsDown() then
						draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.whiteBG)
					else
						draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.darkWhiteBG)
					end
					
					draw.RoundedBox(0, 30, layoutButton:GetTall()-1, layoutButton:GetWide()-30, 1, gPhone.colors.greyAccent)
				end
				layoutButton.DoClick = function( self )
					if name == archivePanels[4].text then -- Reset
						gPhone.notifyAlert( {msg=trans("wipe_archive_confirm"),
						title=trans("confirmation"), options={trans("no"), trans("yes")}}, nil, 
						function( pnl, value )
							-- On yes, delete everything
							for k, v in pairs( file.Find("gphone/archive/*.txt", "DATA") ) do
								file.Delete("gphone/archive/"..v)
							end
						end, false, true )
					else
					
					end
				end
				
				local title = vgui.Create( "DLabel", layoutButton )
				title:SetText( name )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 35, 5 )
			elseif bIsToggle == true then
				local bgPanel = objects.Layout:Add("DPanel")
				bgPanel:SetSize(screen:GetWide(), 30)
				bgPanel.Paint = function( self, w, h) 
					draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
					
					draw.RoundedBox(0, 30, h-1, w-30, 1, gPhone.colors.greyAccent)
				end
				
				local toggleButton = vgui.Create("gPhoneToggleButton", bgPanel)
				toggleButton:SetPos( bgPanel:GetWide() - toggleButton:GetWide() - 10, 2 )
				toggleButton:SetBool( gPhone.config[data.val] )
				toggleButton.OnValueChanged = function( self, bVal )
					gPhone.setConfigValue( data.val, bVal )
				end
				
				local title = vgui.Create( "DLabel", bgPanel )
				title:SetText( name )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 35, 5 )
			else
				local bgPanel = objects.Layout:Add("DPanel")
				bgPanel:SetSize(screen:GetWide(), 30)
				bgPanel.Paint = function( self, w, h) 
					draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
					
					draw.RoundedBox(0, 30, h-1, w-30, 1, gPhone.colors.greyAccent)
				end
				
				nameEditor = vgui.Create( "DTextEntry", bgPanel )
				nameEditor:SetText( gPhone.config[data.val] )
				nameEditor:SetFont( "gPhone_20" )
				local w, h = gPhone.getTextSize( nameEditor:GetText(), nameEditor:GetFont() )
				nameEditor:SetSize( w * 1.5, h )
				nameEditor:SetPos( bgPanel:GetWide() - nameEditor:GetWide() - 15, 5 ) 
				nameEditor:SetTextColor( gPhone.colors.greyAccent )
				nameEditor:SetDrawBorder( false )
				nameEditor:SetDrawBackground( false )
				nameEditor:SetCursorColor( color_black )
				nameEditor:SetHighlightColor( Color(27,161,226) )
				nameEditor.Think = function( self )
					draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), Color(255, 255, 255) )
					
					if self.Opened == false then
						self:Remove()
					end
				end
				nameEditor.OnChange = function( self )
					local numDays = tonumber(self:GetText())
					local strLength = string.len(self:GetText())
					
					local x, y = self:GetPos()
					local w, h = gPhone.getTextSize( self:GetText(), self:GetFont() )
					
					if w < 15 then
						w = 15
					end
					
					self:SetSize( w * 1.5, h )
					self:SetPos( bgPanel:GetWide() - w - 15, y)
					
					if numDays != nil then
						if strLength < 3 then
							gPhone.setConfigValue( "daysToCleanupArchive", numDays )
						end
					end
				end
				
				local title = vgui.Create( "DLabel", bgPanel )
				title:SetText( name )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 35, 5 )
			end
		end
	elseif nameEn == "language" then
		APP.PrepareNewTab( trans("language") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.OpenTab( upperTabName )
		end
		
		-- Warning
		local bgPanel = objects.Layout:Add("DPanel")
		bgPanel:SetSize(screen:GetWide(), 60)
		bgPanel.Paint = function( self, w, h) 
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
		end
		
		local title = vgui.Create( "DLabel", bgPanel )
		title:SetText( trans("lang_reboot_warn") )
		title:SetTextColor(Color(0,0,0))
		title:SetFont("gPhone_18")
		title:SizeToContents()
		title:SetPos( 5, 5 )
		gPhone.wordWrap( title, bgPanel:GetWide(), 5 )
		
		local fake = objects.Layout:Add("DPanel")
		fake:SetSize(screen:GetWide(), 30)
		fake.Paint = function() end
		
		-- Language combo box
		local bgPanel = objects.Layout:Add("DPanel")
		bgPanel:SetSize(screen:GetWide(), 30)
		bgPanel.Paint = function( self, w, h) 
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
			
			draw.RoundedBox(0, 30, h-1, w-30, 1, gPhone.colors.greyAccent)
		end
		
		local languagePicker = vgui.Create( "DComboBox", bgPanel )
		languagePicker:SetSize( bgPanel:GetWide() - 35, bgPanel:GetTall() )
		languagePicker:SetPos( bgPanel:GetWide() - languagePicker:GetWide() , 0 )
		languagePicker:SetValue( trans("language") )
		languagePicker:SetTextColor( color_black )
		languagePicker:SetFont( "gPhone_18" )
		languagePicker.Paint = function( self, w, h ) end
		for k, _ in pairs( gPhone.languages ) do
			if k != "default" then -- Default is a variable not a language
				languagePicker:AddChoice( k:gsub("^%l", string.upper) )
			end
		end
		
		local fake = objects.Layout:Add("DPanel")
		fake:SetSize(screen:GetWide(), 30)
		fake.Paint = function() end
		
		-- Confirm button
		local layoutButton = objects.Layout:Add("DButton")
		layoutButton:SetSize(screen:GetWide(), 30)
		layoutButton:SetText("")
		layoutButton.Paint = function()
			if not layoutButton:IsDown() then
				draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.whiteBG)
			else
				draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.darkWhiteBG)
			end
			
			draw.RoundedBox(0, 30, layoutButton:GetTall()-1, layoutButton:GetWide()-30, 1, gPhone.colors.greyAccent)
		end
		layoutButton.DoClick = function( self )
			local lang = languagePicker:GetValue() 
			if lang:lower() != "language" and lang != gPhone.getActiveLanguage() then
				gPhone.setActiveLanguage( lang )
				gPhone.rebootPhone()
			end
		end
		
		local title = vgui.Create( "DLabel", layoutButton )
		title:SetText( trans("confirm") )
		title:SetTextColor(Color(0,0,0))
		title:SetFont("gPhone_18")
		title:SizeToContents()
		title:SetPos( 35, 5 )
		
		local fake = objects.Layout:Add("DPanel")
		fake:SetSize(screen:GetWide(), 30)
		fake.Paint = function() end
		
		-- Missing phrases toggle
		local bgPanel = objects.Layout:Add("DPanel")
		bgPanel:SetSize(screen:GetWide(), 30)
		bgPanel.Paint = function( self, w, h) 
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
			
			draw.RoundedBox(0, 30, h-1, w-30, 1, gPhone.colors.greyAccent)
		end
		
		local toggleButton = vgui.Create("gPhoneToggleButton", bgPanel)
		toggleButton:SetPos( bgPanel:GetWide() - toggleButton:GetWide() - 10, 2 )
		toggleButton:SetBool( gPhone.config.replaceMissingTranslations )
		toggleButton.OnValueChanged = function( self, bVal )
			gPhone.setConfigValue( replaceMissingTranslations, bVal )
		end
		
		local title = vgui.Create( "DLabel", bgPanel )
		title:SetText( "Replace missing" )
		title:SetTextColor(Color(0,0,0))
		title:SetFont("gPhone_18")
		title:SizeToContents()
		title:SetPos( 35, 5 )
	elseif nameEn == "developer" then
		-- Add new lower level
		APP.PrepareNewTab( trans("developer") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.OpenTab( upperTabName )
		end
		
		local bgPanel = objects.Layout:Add("DPanel")
		bgPanel:SetSize(screen:GetWide(), screen:GetTall()/2 - 30)
		bgPanel.Paint = function( self, w, h) 
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
		end
		
		-- Rich text is what is used in the console, its exactly what I needed
		local richtext = vgui.Create( "RichText", bgPanel )
		richtext:Dock( FILL )
		
		-- Add the entirety of the debug log to it
		for _, tbl in pairs( gPhone.debugLog ) do
			richtext:InsertColorChange( 40,40,40,255 )
			richtext:AppendText("["..tbl.time.."]: "..tbl.msg.."\n")
		end
		
		local fake = objects.Layout:Add("DPanel")
		fake:SetSize(screen:GetWide(), 30)
		fake.Paint = function() end
		
		local options = {
			trans("wipe_log"),
			trans("dump_log"),
			trans("c_print")
		}
		
		for k, v in pairs( options ) do
			if k == 3 then
				-- Special, this is a toggle
				local bgPanel = objects.Layout:Add("DPanel")
				bgPanel:SetSize(screen:GetWide(), 30)
				bgPanel.Paint = function( self, w, h) 
					draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
					
					draw.RoundedBox(0, 30, h-1, w-30, 1, gPhone.colors.greyAccent)
				end
				
				local toggleButton = vgui.Create("gPhoneToggleButton", bgPanel)
				toggleButton:SetPos( bgPanel:GetWide() - toggleButton:GetWide() - 10, 2 )
				toggleButton:SetBool( gPhone.config.showConsoleMessages )
				toggleButton.OnValueChanged = function( self, bVal )
					gPhone.setConfigValue( "showConsoleMessages", bVal )
				end
				
				local title = vgui.Create( "DLabel", bgPanel )
				title:SetText( v )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 35, 5 )
			else
				local layoutButton = objects.Layout:Add("DButton")
				layoutButton:SetSize(screen:GetWide(), 30)
				layoutButton:SetText("")
				layoutButton.Paint = function()
					if not layoutButton:IsDown() then
						draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.whiteBG)
					else
						draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.darkWhiteBG)
					end
					
					draw.RoundedBox(0, 30, layoutButton:GetTall()-1, layoutButton:GetWide()-30, 1, gPhone.colors.greyAccent)
				end
				layoutButton.DoClick = function( self )
					if k == 1 then
						-- Make sure we dont accidentally wipe the debug log
						gPhone.notifyAlert( {msg=trans("wipe_log_confirm"),
						title=trans("confirmation"), options={trans("deny"), trans("accept")}}, 
						nil, 
						function( pnl, value )
							gPhone.wipeLog()
							APP.OpenLowerTab( trans("developer"):lower(), upperTabName )
						end, 
						false, 
						true )
					else
						gPhone.dumpLog()
					end
				end
				
				local title = vgui.Create( "DLabel", layoutButton )
				title:SetText( v )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 35, 5 )
			end
		end
	elseif nameEn == "binds" then
		APP.PrepareNewTab( trans("binds") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.OpenTab( upperTabName )
		end
		
		local textEntries = {}
		for k, name in pairs( bindLevelTabs ) do
			if name == "_SPACE_" then
				local fake = objects.Layout:Add("DPanel")
				fake:SetSize(screen:GetWide(), 30)
				fake.Paint = function() end
			elseif name == trans("confirm") then
				local layoutButton = objects.Layout:Add("DButton")
				layoutButton:SetSize(screen:GetWide(), 30)
				layoutButton:SetText("")
				layoutButton.Paint = function()
					if not layoutButton:IsDown() then
						draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.whiteBG)
					else
						draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), gPhone.colors.darkWhiteBG)
					end
					
					draw.RoundedBox(0, 30, layoutButton:GetTall()-1, layoutButton:GetWide()-30, 1, gPhone.colors.greyAccent)
				end
				layoutButton.DoClick = function( self )
					if k == 2 then -- Confirm key
						local key = textEntries[1]:GetText()
						
						if gPhone.keys[key:upper()] then
							gPhone.setConfigValue( "openKey", gPhone.keys[key:upper()] )
							textEntries[1]:SetTextColor( Color(0,255,0) )
						else
							textEntries[1]:SetTextColor( Color(255,0,0) )
						end
					else -- Confirm time
						local time = textEntries[2]:GetText()
						
						if tonumber(time) != nil then
							gPhone.setConfigValue( "keyHoldTime", tonumber(time) )
							textEntries[2]:SetTextColor( Color(0,255,0) )
						else
							textEntries[2]:SetTextColor( Color(255,0,0) )
						end
					end
				end
				
				local title = vgui.Create( "DLabel", layoutButton )
				title:SetText( name )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 35, 5 )
			else
				local bgPanel = objects.Layout:Add("DPanel")
				bgPanel:SetSize(screen:GetWide(), 30)
				bgPanel.Paint = function( self, w, h) 
					draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
					
					draw.RoundedBox(0, 30, h-1, w-30, 1, gPhone.colors.greyAccent)
				end
				
				local title = vgui.Create( "DLabel", bgPanel )
				title:SetText( name )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 35, 5 )
				
				if name == bindLevelTabs[1] then
					textEntries[1] = vgui.Create( "DTextEntry", bgPanel )
					textEntries[1]:SetSize( bgPanel:GetWide() - 55 - title:GetWide(), bgPanel:GetTall() )
					textEntries[1]:SetPos( bgPanel:GetWide() - textEntries[1]:GetWide() , 0 )
					textEntries[1]:SetText( input.GetKeyName( gPhone.config.openKey ):upper() )
					textEntries[1]:SetTextColor( color_black )
					textEntries[1]:SetDrawBorder( false )
					textEntries[1]:SetDrawBackground( false )
					textEntries[1]:SetCursorColor( color_black )
					textEntries[1]:SetHighlightColor( Color(27,161,226) )
					textEntries[1]:SetFont( "gPhone_18" )
					textEntries[1].OnTextChanged = function( self )
						if gPhone.keys[self:GetText():upper()] then
							textEntries[1]:SetTextColor( color_black )
						else
							textEntries[1]:SetTextColor( Color(255,0,0) )
						end
					end
				else
					textEntries[2] = vgui.Create( "DTextEntry", bgPanel )
					textEntries[2]:SetSize( bgPanel:GetWide() - 55 - title:GetWide(), bgPanel:GetTall() )
					textEntries[2]:SetPos( bgPanel:GetWide() - textEntries[2]:GetWide() , 0 )
					textEntries[2]:SetText( gPhone.config.keyHoldTime )
					textEntries[2]:SetTextColor( color_black )
					textEntries[2]:SetDrawBorder( false )
					textEntries[2]:SetDrawBackground( false )
					textEntries[2]:SetCursorColor( color_black )
					textEntries[2]:SetHighlightColor( Color(27,161,226) )
					textEntries[2]:SetFont( "gPhone_18" )
					textEntries[2].OnTextChanged = function( self )
						if tonumber(self:GetText()) != nil then
							textEntries[1]:SetTextColor( color_black )
						else
							textEntries[1]:SetTextColor( Color(255,0,0) )
						end
					end
				end
			end
		end
	end
	
end

function APP.Paint(screen)
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), gPhone.colors.darkerWhite)
		
	draw.RoundedBox(2, 0, 0, screen:GetWide(), 50, gPhone.colors.whiteBG)
	draw.RoundedBox(0, 0, 50, screen:GetWide(), 1, Color(20, 40, 40))
end

gPhone.addApp(APP)
