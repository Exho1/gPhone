local APP = {}

APP.PrintName = "Settings"
APP.Icon = "vgui/gphone/settings.png"

function APP.Run( objects, screen )
	gPhone.DarkenStatusBar()
	
	objects.Title = vgui.Create( "DLabel", screen )
	objects.Title:SetText( "Settings" )
	objects.Title:SetTextColor(Color(0,0,0))
	objects.Title:SetFont("gPhone_18Lite")
	objects.Title:SizeToContents()
	objects.Title:SetPos( screen:GetWide()/2 - objects.Title:GetWide()/2, 25 )
	
	objects.Layout = vgui.Create( "DIconLayout", screen)
	objects.Layout:SetSize( screen:GetWide(), screen:GetTall() - 50 )
	objects.Layout:SetPos( 0, 80 )
	objects.Layout:SetSpaceY( 0 )
	
	for key, name in pairs(gPhone.SettingsTabs) do
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
					draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), Color(250, 250, 250))
				else
					draw.RoundedBox(0, 0, 0, layoutButton:GetWide(), layoutButton:GetTall(), Color(230, 230, 230))
				end
				
				draw.RoundedBox(0, 30, layoutButton:GetTall()-1, layoutButton:GetWide()-30, 1, Color(150, 150, 150))
			end
			layoutButton.DoClick = function()
				APP.OpenTab( name, objects, screen )
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

--// Custom function to handle the opening of setting tabs
function APP.OpenTab( name, objects, screen )
	if name == "Wallpaper" then
		gPhone.SetTextAndCenter(objects.Title, screen)
		
		-- Hide the app's home screen
		for k, v in pairs(objects.Layout:GetChildren()) do
			v:SetVisible(false)
		end
		
		local tX, tY = objects.Title:GetPos()
		
		objects.Back = vgui.Create("DButton", screen)
		objects.Back:SetText("Back")
		objects.Back:SetFont("gPhone_18Lite")
		objects.Back:SetTextColor( gPhone.Config.ColorBlue )
		objects.Back:SetPos( 10, tY )
		objects.Back.Paint = function() end
		objects.Back:SetSize( gPhone.GetTextSize("Back", "gPhone_18Lite") )
		objects.Back.DoClick = function()
			objects.Back:Remove()
			gPhone.SetTextAndCenter(objects.Title, screen)
			
			for k, pnl in pairs(objects.Layout:GetChildren()) do
				if pnl:IsVisible() then
					pnl:Remove()
				else
					pnl:SetVisible(true)
				end
			end
		end
		
		local newBG = objects.Layout:Add("DButton")
		newBG:SetSize(objects.Layout:GetWide(), 30)
		newBG:SetText("")
		newBG.Paint = function()
			if not newBG:IsDown() then
				draw.RoundedBox(0, 0, 0, newBG:GetWide(), newBG:GetTall(), Color(250, 250, 250))
			else
				draw.RoundedBox(0, 0, 0, newBG:GetWide(), newBG:GetTall(), Color(230, 230, 230))
			end
			draw.RoundedBox(0, 15, newBG:GetTall()-1, newBG:GetWide()-30, 1, Color(150, 150, 150))
		end
		
		local text = vgui.Create( "DLabel", newBG )
		text:SetText( "Choose a new wallpaper" )
		text:SetTextColor(Color(0,0,0))
		text:SetFont("gPhone_18")
		text:SizeToContents()
		text:SetPos( 15, 5 )
		
		local background = objects.Layout:Add("DPanel")
		background:SetSize(screen:GetWide(), screen:GetTall()/2.4)
		background:SetText("")
		background.Paint = function()
			draw.RoundedBox(0, 0, 0, background:GetWide(), background:GetTall(), Color(250, 250, 250))
		end
		
		-- Images that show what the client's current wallpapers are set to
		local previewLock = vgui.Create("DImage", background)
		previewLock:SetSize( screen:GetWide()/2.5, screen:GetTall()/3 )
		previewLock:SetPos( 20, 10)
		previewLock:SetImage( gPhone.GetWallpaper( false ) )
		local previewHome = vgui.Create("DImage", background)
		previewHome:SetSize( screen:GetWide()/2.5, screen:GetTall()/3 )
		previewHome:SetPos( 20 + previewLock:GetWide() + 10, 10)
		previewHome:SetImage( gPhone.GetWallpaper( true ) )
		
		--// Switch modes to the Material Selector, its down here so I can reference a couple things
		newBG.DoClick = function()
			newBG:SetDisabled(true)
			local selectedImage = nil
			
			-- Hide what we don't need anymore
			previewLock:SetVisible(false)
			previewHome:SetVisible(false)
			background:SetSize(screen:GetWide(), screen:GetTall()/2)
			text:SetText("Wallpaper Selector")
			text:SizeToContents()
			
			-- Create a tree
			local tree = vgui.Create("DTree", background)
				local dir = tree:AddNode( "Wallpapers" )
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
			darkenStatusBar:SetText( "Darken Status Bar" )	
			darkenStatusBar:SizeToContents()
			darkenStatusBar:SetTextColor( Color(0,0,0) )
			darkenStatusBar:SetValue( gPhone.Config.DarkenStatusBar )
			darkenStatusBar.OnChange = function()
				local bool = darkenStatusBar:GetChecked()
				if bool == true then
					gPhone.Config.DarkenStatusBar = true
				else
					gPhone.Config.DarkenStatusBar = false
				end
				gPhone.SaveClientConfig()
			end
			
			-- Should the image be a lock screen?
			local useAsLock = vgui.Create("DButton", buttonBG)
			useAsLock:SetSize(screen:GetWide()/2, 30)
			useAsLock:SetPos( 0, 0 )
			useAsLock:SetText("Set Lockscreen")
			useAsLock.Paint = function(self)
				if not self:IsDown() then
					draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(250, 250, 250))
				else
					draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(230, 230, 230))
				end
			end
			useAsLock.DoClick = function(self)
				gPhone.SetWallpaper( false, selectedImage )
				gPhone.SaveClientConfig()
			end
			
			-- Or should the image be the home screen
			local useAsHome = vgui.Create("DButton", buttonBG)
			useAsHome:SetSize(screen:GetWide()/2, 30)
			useAsHome:SetPos( buttonBG:GetWide() - useAsHome:GetWide(), 0 )
			useAsHome:SetText("Set Homescreen")
			useAsHome.Paint = function(self)
				if not self:IsDown() then
					draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(250, 250, 250))
				else
					draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(230, 230, 230))
				end
			end
			useAsHome.DoClick = function(self)
				gPhone.SetWallpaper( true, selectedImage )
				gPhone.SaveClientConfig()
			end
		end
	end
end

function APP.Paint(screen)
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), Color(200, 200, 200))
		
	draw.RoundedBox(2, 0, 0, screen:GetWide(), 50, Color(250, 250, 250))
	draw.RoundedBox(0, 0, 50, screen:GetWide(), 1, Color(20, 40, 40))
end

gPhone.AddApp(APP)
