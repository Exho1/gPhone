local APP = {}
local trans = gPhone.getTranslation

APP.PrintName = "App Store"
APP.Icon = "vgui/gphone/store.png"
APP.Author = "Exho"
APP.Tags = {"Apps", "Downloads", "General"}

function APP.Run( objects, screen )
	gPhone.darkenStatusBar()
	
	objects.Title = vgui.Create( "DLabel", screen )
	objects.Title:SetText( trans("app_store") )
	objects.Title:SetTextColor( color_black )
	objects.Title:SetFont("gPhone_18Lite")
	objects.Title:SizeToContents()
	objects.Title:SetPos( screen:GetWide()/2 - objects.Title:GetWide()/2, 25 )
		
	local offset = 20 -- A little trick to push the scrollbar off the screen
	objects.LayoutScroll = vgui.Create( "DScrollPanel", screen )
	objects.LayoutScroll:SetSize( screen:GetWide() + offset, screen:GetTall() - 50 )
	objects.LayoutScroll:SetPos( 0, 50 )
	objects.LayoutScroll.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, self:GetWide(), self:GetTall(), 0, Color(0, 235, 0))
	end
	
	objects.Layout = vgui.Create( "DIconLayout", objects.LayoutScroll )
	objects.Layout:SetSize( screen:GetWide(), screen:GetTall() - 1 )
	objects.Layout:SetPos( 0, 1 )
	objects.Layout:SetSpaceY( 0 )
	
	APP.PopulateList()
end

function APP.PopulateList()
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	local availableApps = gPhone.getHiddenApps()
	
	-- Handle not having an applications available to download
	if #availableApps == 0 then
		local bgPanel = objects.Layout:Add("DPanel")
		bgPanel:SetSize(screen:GetWide(), 50)
		bgPanel.Paint = function( self, w, h )
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
			
			draw.RoundedBox(0, 0, h-1, w, 1, gPhone.colors.greyAccent)
		end
		
		local title = vgui.Create( "DLabel", bgPanel )
		title:SetText( trans("no_apps") )
		title:SetTextColor( color_black )
		title:SetFont("gPhone_16")
		title:SizeToContents()
		gPhone.setTextAndCenter( title, trans("no_apps_phrase"), bgPanel, true )
		return
	end
	
	-- Loop through all the apps that we can download
	for key, data in pairs( availableApps ) do
		gPhone.incrementBadge( "App Store", data.name:lower() )
		
		local bgPanel = objects.Layout:Add("DPanel")
		bgPanel:SetSize(screen:GetWide(), 50)
		bgPanel.Paint = function( self, w, h )
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
			
			draw.RoundedBox(0, 30, h-1, w-30, 1, gPhone.colors.greyAccent)
		end
		
		local icon = vgui.Create( "DImage", bgPanel )
		icon:SetImage( data.icon or "ERROR" )
		icon:SetImageColor( color_white )
		icon:SetSize( 32, 32 )
		icon:SetPos( 10, 5 )
		
		local dName = data.name
		local dNameL = dName:lower()
		
		local title = vgui.Create( "DLabel", bgPanel )
		title:SetText( dName )
		title:SetTextColor( color_black )
		title:SetFont("gPhone_16")
		title:SizeToContents()
		title:SetPos( icon:GetWide() + 20, 10 )
		
		local author = vgui.Create( "DLabel", bgPanel )
		author:SetTextColor( Color(100,100,100) )
		author:SetFont("gPhone_12")
		
		-- Get the author name
		for name, tbl in pairs( gApp ) do
			if name == dNameL then
				if tbl.Data and tbl.Data.Author then
					author:SetText( tbl.Data.Author )
					break
				end
			end
			author:SetText( "" )
		end
		
		author:SizeToContents()
		author:SetPos( icon:GetWide() + 20, 25 )
		
		local download = vgui.Create( "DButton", bgPanel )
		download:SetSize( 40, 20 )
		download:SetPos( bgPanel:GetWide() - download:GetWide() - 10, bgPanel:GetTall()/2 - download:GetWide()/4 )
		download:SetText(trans("get"))
		download.chosen = false
		download.bgColor = gPhone.colors.blue
		download.Paint = function( self, w, h )
			draw.RoundedBox(4, 0, 0, w, h, self.bgColor)
			if self:IsDown() then
				download:SetTextColor( color_white )
			else
				draw.RoundedBox(4, 1, 1, w - 2, h - 2, color_white)
				download:SetTextColor( self.bgColor )
			end
		end
		
		-- Handle downloads
		local canDownload = true
		if #gPhone.appPanels >= 20 then
			canDownload = false
			download.bgColor = gPhone.colors.red
		end
		download.DoClick = function()
			download.chosen = !download.chosen
			
			for name, tbl in pairs( gApp ) do
				if name == dNameL then
					if tbl.Data and tbl.Data.AllowedUsergroups then
						groups = tbl.Data.AllowedUsergroups
						break
					end
				end
			end
			
			if groups and !table.HasValue(groups, LocalPlayer():GetUserGroup()) then	
				gPhone.msgC( GPHONE_MSGC_NOTIFY, "You are not the right rank to get this app!" )
				return			
			end
			
			if download.chosen then -- Download app
				if canDownload then
					gPhone.msgC( GPHONE_MSGC_NOTIFY, "Downloaded app ("..dName..") from app store" )
					
					gPhone.setAppVisible( dName, true )
					download:SetText(trans("have"))
				else
					gPhone.msgC( GPHONE_MSGC_WARNING, "Not enough space on the homescreen to install app!" )
					
					local notifyTbl = {title=trans("error"), 
					msg=trans("no_homescreen_space"),
					options={trans("okay")}}
					gPhone.notifyAlert( notifyTbl, nil, nil, true )
				end
			else -- Uninstall recently downloaded app
				gPhone.msgC( GPHONE_MSGC_NOTIFY, "Uninstalled app ("..dName..") from app store" )
				
				gPhone.setAppVisible( dName, false )
				download:SetText(trans("get"))
				
				-- Remove from the app panels table so it will fail when we look for removed apps
				for k, tbl in pairs( gPhone.appPanels ) do
					if tbl.name:lower() == dNameL then
						table.remove( gPhone.apps, k )
					end
				end
			end
			gPhone.saveAppPositions( gPhone.apps )
		end
	end
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), gPhone.colors.darkerWhite)
		
	draw.RoundedBox(2, 0, 0, screen:GetWide(), 50, gPhone.colors.whiteBG)
	draw.RoundedBox(0, 0, 50, screen:GetWide(), 1, Color(20, 40, 40))
end

gPhone.addApp(APP)
