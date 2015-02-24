local APP = {}
local trans = gPhone.getTranslation

APP.PrintName = "Settings"
APP.Icon = "vgui/gphone/settings.png"
APP.Author = "Exho"
APP.Tags = {"Manage", "Config"}

local topLevelTabs = {
	trans("general"),
	trans("wallpaper"),
	trans("homescreen"),
	"_SPACE_", 
}

local generalLevelTabs = {
	trans("about"),
	trans("update"),
	"_SPACE_",
	trans("color"),
	trans("archive")
}

local homescreenLevelTabs = {
	{text=trans("show_unusable_apps"), button=false},
	{text="_SPACE_", button=false},
	{text=trans("reset_app_pos"), button=true},
}

local archivePanels = {
	{text=trans("archive_cleanup"), toggle=true, val="deleteArchivedFiles"},
	{text=trans("file_life"), val="daysToCleanupArchive"},
	{text="_SPACE_"},
	{text=trans("wipe_archive"), button=true},
}

function APP.Run( objects, screen )
	gPhone.darkenStatusBar()
	
	print(trans("settings"))
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
	
	objects.Layout = vgui.Create( "DIconLayout", screen)
	objects.Layout:SetSize( screen:GetWide(), screen:GetTall() - 50 )
	objects.Layout:SetPos( 0, 80 )
	objects.Layout:SetSpaceY( 0 )
	
	for key, name in pairs( topLevelTabs ) do
		if name == "_SPACE_" then
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
				APP.OpenTab( name )
			end
			
			local title = vgui.Create( "DLabel", layoutButton )
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
	
	if name == trans("wallpaper"):lower() then
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
	elseif name == trans("general"):lower() then
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
	elseif name == trans("homescreen"):lower() then
		APP.PrepareNewTab( trans("Homescreen") )
		
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
						title=trans("confirm"), options={trans("no"), trans("yes")}}, nil, 
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
	end
end

function APP.OpenLowerTab( name, upperTabName )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	name = name:lower()
	
	if name == trans("about"):lower() then
		APP.PrepareNewTab( trans("about") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.OpenTab( upperTabName )
		end
		
		local background = objects.Layout:Add("DPanel")
		background:SetSize(screen:GetWide(), screen:GetTall()/1.5)
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
		
		-- Center the Garry Phone
		local aboutText = [[
Contact:
exho.steam@gmail.com
STEAM_0:0:53332328

Source: 
https://github.com/Exho1/gPhone

Credits:
Derma blur - 
https://github.com/Chessnut/NutScript
Phone image - 
https://creativemarket.com/buatoom
Icon images - http://www.flaticon.com/
]]

		local aboutLabel = vgui.Create( "DLabel", background )
		aboutLabel:SetText( aboutText )
		aboutLabel:SetTextColor(Color(0,0,0))
		aboutLabel:SetFont("gPhone_14")
		local x, y = titleLabel:GetPos()
		aboutLabel:SetPos( 10, y + titleLabel:GetTall() + 10 )
		
		gPhone.WordWrap( aboutLabel, background:GetWide(), 10 )
		
	elseif name == trans("update"):lower() then
		APP.PrepareNewTab( trans("update") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.OpenTab( upperTabName )
		end
		
		--{update=Bool, version=String, description=String}
		local uData = gPhone.updateTable
		
		if uData.update then
			local background = objects.Layout:Add("DPanel")
			background:SetSize(screen:GetWide(), screen:GetTall()/2.4)
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
			
			gPhone.WordWrap( descriptionLabel, background:GetWide(), 10 )
			
			-- Shrink the DPanel to match the content of the text
			local _, dY = descriptionLabel:GetPos()
			dY = dY + descriptionLabel:GetTall()
			
			local w, h = background:GetSize()
			background:SetSize( w, dY + 10 )
			
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
				-- TEMP: Replace later with a link to the workshop page
				gui.OpenURL( "http://steamcommunity.com/id/Exho1/myworkshopfiles/?appid=4000" )
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
	elseif name == trans("color"):lower() then	
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
		title:SetText( "Set Color" )
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
			gPhone.config.phoneColor = color_white
		end
		
		local title = vgui.Create( "DLabel", layoutButton )
		title:SetText( "Default" )
		title:SetTextColor( color_black )
		title:SetFont("gPhone_18")
		title:SizeToContents()
		title:SetPos( 15, 5 )
	elseif name == trans("archive"):lower() then
		APP.PrepareNewTab( trans("archive") )
		
		objects.Back:SetVisible( true )
		objects.Back.DoClick = function()
			APP.OpenTab( upperTabName )
		end
		
		--[[
		local archivePanels = {
	{text="Archive cleanup", button=false, toggle=true},
	{text="Archive delete time:", button=false, toggle=true},
	{text="_SPACE_"},
	{text="Wipe archive", button=true},
}
		]]
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
						title=trans("confirm"), options={trans("no"), trans("yes")}}, nil, 
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
	end
	
end

function APP.Paint(screen)
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), gPhone.colors.darkerWhite)
		
	draw.RoundedBox(2, 0, 0, screen:GetWide(), 50, gPhone.colors.whiteBG)
	draw.RoundedBox(0, 0, 50, screen:GetWide(), 1, Color(20, 40, 40))
end

gPhone.addApp(APP)
