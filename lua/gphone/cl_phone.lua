----// Clientside Phone //----

local client = LocalPlayer()
local trans = gPhone.getTranslation
local phone = Material( "vgui/gphone/gphone.png" )

--// Builds the phone 
function gPhone.buildPhone()
	gPhone.wipeLog()
	
	gPhone.log("Building phone")
	
	if game.SinglePlayer() then
		gPhone.msgC( GPHONE_MSGC_WARNING, "The phone is being run in single player!! Expect errors")
	end
	
	if not client:GetNWBool( "gPhone_canOpen", true ) then
		gPhone.chatMsg( trans("unable_to_open") )
		return
	end
	
	file.CreateDir( "gphone" )
	
	gPhone.loadClientConfig()
	gPhone.saveClientConfig()

	gPhone.removedApps = {}
	gPhone.apps = {}
	gPhone.importApps()
	
	gPhone.archiveCleanup()
	
	-- Dimensions
	local pWidth, pHeight = 300, 600 -- Phone
	local sWidth, sHeight = 234, 416 -- Screen
	local hWidth, hHeight = 45, 45 -- Home button
	
	gPhone.rotation = 0
	
	gPhone.orientation = "portrait"
	gPhone.setIsAnimating( false )
	gPhone.setPhoneState( "lock" )
	gPhone.shouldUnlock = true
	
	-- Create the phone 
		gPhone.phoneBase = vgui.Create( "DFrame" )
	gPhone.phoneBase:SetSize( pWidth, pHeight )
	gPhone.phoneBase:SetPos( ScrW()-pWidth, ScrH() - 40 )
	gPhone.phoneBase:SetTitle( "" )
	gPhone.phoneBase:SetDraggable( false )
	gPhone.phoneBase:SetDeleteOnClose( true )
	gPhone.phoneBase:ShowCloseButton( false )
	gPhone.phoneBase.Paint = function( self, w, h)
		surface.SetDrawColor( gPhone.config.phoneColor )
		surface.SetMaterial( phone ) 
		--surface.DrawTexturedRect( 0, 0, pWidth, pHeight )
		surface.DrawTexturedRectRotated( self:GetWide()/2, self:GetTall()/2, pWidth, pHeight, gPhone.rotation )
	end
	gPhone.phoneBase.btnClose.DoClick = function ( button ) -- TEMP
		gPhone.destroyPhone()
	end
	
	local phoneBase = gPhone.phoneBase
	local pX, pY = phoneBase:GetPos()
	gPhone.setWallpaper( true, gPhone.config.homeWallpaper )
	gPhone.setWallpaper( false, gPhone.config.lockWallpaper )
	
		gPhone.phoneScreen = vgui.Create("DPanel", gPhone.phoneBase)
	gPhone.phoneScreen:SetPos( 31, 87 )
	gPhone.phoneScreen:SetSize( sWidth, sHeight ) 
	gPhone.phoneScreen.Paint = function( self )
		surface.SetMaterial( gPhone.getWallpaper( true, true ) )  -- Draw the wallpaper
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
	end
	gPhone.phoneScreen.Think = function()
		if gPhone.config.darkStatusBar == true then
			gPhone.darkenStatusBar()
		end
	end
	
	local nextTimeUpdate = 0
	local phoneTime = vgui.Create( "DLabel", gPhone.phoneScreen )
	phoneTime:SetText( os.date("%I:%M %p") )
	phoneTime:SizeToContents()
	phoneTime:SetPos( sWidth/2 - phoneTime:GetWide()/2, 0 )
	phoneTime.Paint = gPhone.dLabelPaintOverride
	phoneTime.Think = function()
		if CurTime() > nextTimeUpdate then
			phoneTime:SetText(os.date("%I:%M %p"))
			phoneTime:SizeToContents()
			phoneTime:SetPos( sWidth/2 - phoneTime:GetWide()/2, 0 )
			nextTimeUpdate = CurTime() + 5
		end
	end
	
	--// Status bar
	local batteryPercent = vgui.Create( "DLabel", gPhone.phoneScreen )
	local nextPass, batteryPerc = CurTime() + math.random(30, 60), 100
	batteryPercent:SetText( batteryPerc.."%" )
	batteryPercent:SizeToContents()
	batteryPercent:SetPos( sWidth - batteryPercent:GetWide() - 23, 0 )
	batteryPercent.Think = function()
		if CurTime() > nextPass then
			batteryPercent:SetPos( sWidth - batteryPercent:GetWide() - 21, 0)
			local dropPerc = math.random(1, 3)

			batteryPerc = batteryPerc - dropPerc
			batteryPercent:SetText( batteryPerc.."%" )
			batteryPercent:SetPos( sWidth - batteryPercent:GetWide() - 20, 0 )
			
			nextPass = CurTime() + math.random(60, 180)
		end
		
		if batteryPerc < math.random(1, 4) then -- Simulate a phone dying, its kinda silly and few people will ever see it
			batteryPerc = 100
			batteryPercent:SetText( batteryPerc.."%" )
			--[[gPhone.chatMsg( trans("battery_dead") )
			gPhone.hidePhone()
			timer.Simple(math.random(2, 5), function()
				gPhone.chatMsg( trans("battery_okay") )
				gPhone.showPhone()
			end)]]
		end
	end
	batteryPercent.Paint = gPhone.dLabelPaintOverride
	
	local batteryImage = vgui.Create("DImage", gPhone.phoneScreen)
	batteryImage:SetSize( 16, 8 )
	batteryImage:SetPos( sWidth - 20, 3)
	batteryImage:SetImageColor(Color(255,255,255))
	local batteryMat = Material( "vgui/gphone/battery.png" )
	batteryImage.Paint = function( self )
		-- Draw the battery icon
		surface.SetMaterial( batteryMat ) 
		surface.SetDrawColor( batteryImage:GetImageColor() )
		surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
		
		-- Math to determine the size of the battery bar
		local segments = 11 / 100
		local batterySize = math.Clamp(batteryPerc * segments, 1, 11)
		
		-- Battery bar color
		if batteryPerc <= 20 then
			col = Color(200, 30, 30) 
		else
			col = batteryImage:GetImageColor() 
		end
		
		-- Draw the battery bar
		draw.RoundedBox( 0, 2, 2, batterySize, 4, col )
	end
	
	gPhone.signalStrength = 5
	
	local signalDots = {}
	local xBuffer = 3
	for i = 1, 5 do
		signalDots[i] = vgui.Create("DImage", gPhone.phoneScreen)
		signalDots[i]:SetSize( 6, 6 )
		signalDots[i]:SetPos( xBuffer, 4)
		signalDots[i]:SetImageColor(Color(255,255,255))
		local off = Material( "vgui/gphone/dot_empty.png", "smooth noclamp" )
		local on = Material( "vgui/gphone/dot_full.png", "smooth noclamp" )
		signalDots[i].Paint = function( self )
			if i <= gPhone.signalStrength then
				surface.SetMaterial( on ) 
				surface.SetDrawColor( self:GetImageColor() )
				surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
			else
				surface.SetMaterial( off ) 
				surface.SetDrawColor( self:GetImageColor() )
				surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
			end
		end
		xBuffer = xBuffer + signalDots[i]:GetWide() + 1
	end
	
	local serviceProvider = vgui.Create( "DLabel", gPhone.phoneScreen )
	serviceProvider:SetText( trans("service_provider") )
	serviceProvider:SizeToContents()
	local lastDot = signalDots[#signalDots]
	serviceProvider:SetPos( lastDot:GetPos() + lastDot:GetWide() + 5, 0 )
	serviceProvider.Paint = gPhone.dLabelPaintOverride
	
	gPhone.homeButton = vgui.Create( "DButton", gPhone.phoneBase )
	gPhone.homeButton:SetSize( hWidth, hHeight )
	gPhone.homeButton:SetPos( pWidth/2 - hWidth/2 - 3, pHeight - hHeight - 35 )
	gPhone.homeButton:SetText( "" )
	gPhone.homeButton.Paint = function() end
	gPhone.homeButton.DoClick = function()
		gPhone.appDeleteMode = false
		if gPhone.isInApp() and not gPhone.isAnimating() then
			gPhone.toHomeScreen()
		end
	end
	
	gPhone.statusBar = { -- Gotta keep track of all the status bar elements
		["text"] = { battery=batteryPercent, network=serviceProvider, time=phoneTime },
		["image"] = { battery=batteryImage, unpack(signalDots) },
	}
	gPhone.statusBarHeight = 15
	
	--// Build the homescreen
	
	-- Loads up icon positions from the position file
	local txtPositions = gPhone.loadAppPositions()
	local newApps = {}
	local denies = 0
	
	if txtPositions and #txtPositions > 1 then
		for a = 1, #gPhone.apps do
			local app = gPhone.apps[a] -- name and icon
			local name = app.name
			denies = 0
			
			-- Checks if an app exists in the config file and at which key
			for i = 1, #txtPositions do	
				if not txtPositions[i] then 
					gPhone.log("Error referencing app in position file! Key: "..i)
					continue 
				end
				
				if name == txtPositions[i].name then
					-- Insert app normally at config-specified position
					table.insert(newApps, i, txtPositions[i])
				elseif txtPositions[i].apps then
					-- Check folder
					local folder = txtPositions[i].apps
					for k = 1, #folder do
						if folder[k].name == name then
							-- This app exists in a folder, create the folder
							table.insert(newApps, i, txtPositions[i])
						end	
					end
				else
					denies = denies + 1
				end
			end
			
			-- This app does not exist in the config, put it at the end
			if denies == #txtPositions then
				table.insert(newApps, app)
			end
		end 
		
		gPhone.apps = newApps
	end
	
	-- Build the layout
	gPhone.homeIconLayout = vgui.Create( "DPanel", gPhone.phoneScreen )
	gPhone.homeIconLayout:SetSize( sWidth - 10, sHeight - 40 )
	gPhone.homeIconLayout:SetPos( 5, 25 )
	gPhone.homeIconLayout.Paint = function( self, w, h ) 
		--draw.RoundedBox(2, 0, 0, w, h, Color(0, 255, 0, 100) )
	end
	
	-- Helper function to jiggle apps
	local function appJiggle( tbl )
		for k, data in pairs( tbl ) do
			if IsValid(data.pnl) then
				local pnl = data.pnl
				local x, y = pnl:GetPos()
				
				if not pnl.oldX and not pnl.oldY then
					pnl.oldX = x
					pnl.oldY = y
				end
				
				local newX = pnl.oldX + math.random(-1, 1)
				local newY = pnl.oldY + math.random(-1,1)
				
				pnl:SetPos( newX, newY )
			end
			
			if data.pnl and not data.pnl.tiedButton then
				gPhone.appDeleteMode = false
				gPhone.homeIconLayout:deleteApps()
			end	
		end
	end
	
	-- Enable/disable app delete mode
	gPhone.appDeleteMode = false
	local mouseStartTime = 0
	gPhone.homeIconLayout.Think = function( self )
		if input.IsMouseDown( MOUSE_RIGHT ) then
			if mouseStartTime == 0 then
				mouseStartTime = CurTime()
			end
			
			if CurTime() - mouseStartTime >= 0.75 then
				self:deleteApps()
				
				mouseStartTime = 0
			end
		else
			mouseStartTime = 0
		end
		
		-- App jiggle
		if gPhone.appDeleteMode then
			if not gPhone.inFolder() then
				appJiggle( gPhone.appPanels )
			else
				local folder = gPhone.getActiveFolder()
				if folder.apps == nil then return end
				
				appJiggle( folder.apps )
			end
		elseif not gPhone.inFolder() then
			for k, data in pairs( gPhone.appPanels ) do
				if IsValid( data.pnl ) then
					local pnl = data.pnl
					local x, y = pnl:GetPos()
					
					if not pnl.oldX and not pnl.oldY then
						pnl.oldX = x
						pnl.oldY = y
					end
					
					if x != pnl.oldX or y != pnl.oldY then
						pnl:SetPos( pnl.oldX, pnl.oldY )
					end
					
				end
			end
		end
	end
	
	-- Helper function to create app badges
	local function createBadges( tbl, bInFolder )
		for k, data in pairs( tbl ) do
			if gPhone.appBadges[data.name] then
				local badges = #gPhone.appBadges[data.name]
				if badges > 0 then
					local pnl = data.pnl
					
					if not IsValid(pnl) then return end
					
					local text, font = tostring(badges), "gPhone_12"
					local width, height = gPhone.getTextSize(text, font) -- X, 12
					width = width + height/2
					
					local x, y = pnl:GetPos()
					
					if bInFolder == true then
						-- Offset with the parent position
						local pX, pY = pnl:GetParent():GetPos()
						x, y = x + pX, y + pY
					end
					
					local tX, tY = x + pnl:GetWide() - width + 1, y - 6
					
					draw.RoundedBox(6, x + pnl:GetWide() - width - 3, y - 6, width, height, Color(240, 5, 5) )
					draw.DrawText( text, font, tX, tY, color_white )
				end
			end
		end
	end
	
	-- App badges
	gPhone.appBadges = {}
	
	gPhone.homeIconLayout.PaintOver = function()
		if not gPhone.inFolder() then
			createBadges( gPhone.appPanels )
		else
			createBadges( gPhone.getActiveFolder().apps, true )
		end
	end
	
	-- Handles the delete button and function for applications
	gPhone.homeIconLayout.deleteApps = function( self )
		gPhone.log("Toggle app deletion mode - "..tostring(gPhone.appDeleteMode))
		
		local dontDelete = {
			"settings",
			"app store",
			"messages",
			"phone",
			"contacts",
		}
		
		if not gPhone.inFolder() then
			for k, data in pairs( gPhone.appPanels ) do
				local pnl = data.pnl
				if not IsValid(pnl) then return end
			
				local x, y = pnl:GetPos()
				local xOffset, yOffset = 6, -7
				
				local deleteButton = vgui.Create( "DButton", self )
				deleteButton:SetPos( x + xOffset, y + yOffset )
				deleteButton:SetSize( 15, 15 )
				deleteButton:SetText("")
				deleteButton.Paint = function( self, w, h )
					draw.RoundedBox(6, 2, 2, 13, 13, Color(200, 200, 200, 240) )
					draw.DrawText( "x", "gPhone_14", 5, 2, Color(100, 100, 100, 240) )
				end
				data.pnl.tiedButton = deleteButton
				deleteButton.DoClick = function() 
					local name = data.name

					gPhone.setAppVisible( name, false )
					gPhone.buildHomescreen( gPhone.apps ) -- Rebuild homescreen
				end
				deleteButton.Think = function( self )
					if not gPhone.appDeleteMode then
						self:Remove()
					end
					
					local pnl = gPhone.appPanels[k].pnl
					
					if IsValid(pnl) then
						local x, y = pnl:GetPos()
						
						self:SetPos( x + xOffset, y + yOffset )
					else
						gPhone.msgC( GPHONE_MSGC_WARNING, "Invalid panel to position delete button on. Key: "..k )
					end
				end
				
				-- Make sure we don't delete any apps that should not be deleted (including folders)
				for _, name in pairs( dontDelete ) do
					if data.name:lower() == name:lower() or data.apps then
						deleteButton:Remove()
					end
				end
			end
		else
			-- Deleting apps in folders
		end
		gPhone.appDeleteMode = !gPhone.appDeleteMode
	end
	
	gPhone.appPanels = {} -- {name, pnl, icon, inFolder, apps}
	gPhone.canMoveApps = true
	gPhone.setActiveFolder( {} )
	gPhone.setActiveFolderPanel( nil )
	
	-- Handles the dropping of icons on the home screen
	gPhone.homeIconLayout:Receiver( "gPhoneIcon", function( pnl, item, drop, i, x, y ) 
		if drop then
			gPhone.log("Dropped a homescreen icon")
			if not gPhone.canMoveApps then 
				gPhone.msgC( GPHONE_MSGC_WARNING, "Unable to move apps at this moment" )
				return
			end
			
			local removedAppKeys = {}
			for k, v in pairs( gPhone.appPanels ) do
				local iX, iY = v.pnl:GetPos()
				local iW, iH = v.pnl:GetSize()
				
				if gPhone.apps[k] and gPhone.apps[k].name then
					local name = gPhone.apps[k].name or ""
					
					if not gPhone.getAppVisible( name ) then
						removedAppKeys[k] = k
						continue
					end
				end
				
				-- Moving an icon out of a folder
				if gPhone.inFolder() then
					local w, h = gPhone.homeIconLayout:GetWide(), gPhone.homeIconLayout:GetTall()/1.7
					local fW, fH = w - 10, h
					local fX, fY = 5, gPhone.homeIconLayout:GetTall()/2 - h/2
					
					local heldPanel = dragndrop.GetDroppable()[1]
					local curFolder = gPhone.getActiveFolder()
					if x <= fX or x >= fX + fW or y <= fY or y >= fY + fH then
						local droppedData = {name="N/A", icon="N/A"}
						local droppedKey = 0
						local folderKey = 0
						
						-- Grab the icon we are moving
						for k, v in pairs( gPhone.getActiveFolder().apps ) do
							if heldPanel == v.pnl:GetChildren()[1] then
								local icon = v.pnl:GetChildren()[1]
								droppedData = {name=v.name, icon=v.icon}
								droppedKey = k
							end
						end	
						
						-- Find the folder in the gPhone.apps table
						for k, v in pairs( gPhone.apps ) do
							if curFolder == v then
								folderKey = k
							end
						end
						
						-- Remove the icon from the folder and throw it on the end of the home screen
						table.remove(gPhone.apps[folderKey].apps, droppedKey)
						table.insert(gPhone.apps, droppedData)
						
						-- Table is going to have 1 icon left, destroy it
						if #gPhone.getActiveFolder().apps <= 1 then
							local leftApp = gPhone.apps[folderKey].apps[1]
							table.remove(gPhone.apps, folderKey)
							table.insert(gPhone.apps, folderKey, {name=leftApp.name, icon=leftApp.icon})
						end

						-- Close the folder which rebuilds the homescreen
						gPhone.closeFolder()
					else
						print("Should move apps in folder")
						if gPhone.firstTimeCalled() then
							gPhone.chatMsg( trans("feature_deny") ) 
						end
						--table.insert(gPhone.appPanels, {name=v.name, icon=v.icon, pnl=bgPanel, inFolder=true} )
						--gPhone.getActiveFolder().apps[k] = {pnl=bgPanel, name=v.name, icon=v.icon}
					end
				
				-- Creating a folder and adding apps to it
				elseif x >= iX + iW/3 and x <= iX + iW - iW/3 then
					if y >= iY and y <= iY + iH and not gPhone.inFolder() then	
						local targetKey = k 
						local droppedData = {name=trans("folder_fallback"), apps={}} 
						local droppedKey = 0
						
						-- Get the name and image of the icon we are moving
						for i = 1,#gPhone.appPanels do
							if item[1] == gPhone.appPanels[i].pnl:GetChildren()[1] then
								local droppedName = gPhone.appPanels[i].name

								for p = 1, #gPhone.apps do
									if gPhone.apps[p].name == droppedName then
										droppedKey = p
									end
								end
							end
						end
						
						-- Compensate for removed apps
						for _, key in pairs( removedAppKeys ) do
							if key < targetKey then
								targetKey = targetKey + 1
							end
						end
						
						local droppedApp = gPhone.apps[droppedKey]
						local targetActiveApp = gPhone.apps[targetKey]

						-- Preventing bad stuff
						if not droppedApp then
							gPhone.msgC( GPHONE_MSGC_WARNING, "Dropped app is not valid. Key: "..droppedKey )
							return
						elseif targetActiveApp.apps and #targetActiveApp.apps >= 9 then
							gPhone.msgC( GPHONE_MSGC_WARNING, "Folder is full and cannot hold any more apps" )
							return
						elseif gPhone.apps[k] == droppedApp then
							gPhone.msgC( GPHONE_MSGC_WARNING, "Cannot drop an app on itself" )
							return
						elseif droppedApp.apps or droppedApp.IsFolder then 
							gPhone.msgC( GPHONE_MSGC_WARNING, "Cannot drop folders on icons or other folders" )
							return
						end
						
						-- Give the folder a name based on app tags
						local droppedAppTable = gApp[droppedApp.name:lower()]
						local targetAppTable = gApp[targetActiveApp.name:lower()]
						if droppedAppTable and targetAppTable then
							local tags = {}
							if droppedAppTable.Data.Tags then
								for k, v in pairs( droppedAppTable.Data.Tags ) do
									tags[#tags+1] = v
								end
							end
							if targetAppTable.Data.Tags then
								for k, v in pairs( targetAppTable.Data.Tags ) do
									tags[#tags+1] = v
								end
							end
							
							local tag = table.Random(tags)
							for k, v in pairs(gPhone.apps) do
								if v.name == tag then
									tag = table.Random(tags)
								end
							end

							droppedData.name = tag or trans("folder_fallback")
						end
						
						-- Table stuff
						if gPhone.apps[targetKey].apps != nil then -- Append in folder
							table.insert(gPhone.apps[targetKey].apps, {name=droppedApp.name, icon=droppedApp.icon})
							table.remove(gPhone.apps, droppedKey)
						else -- Create folder
							table.insert(droppedData.apps, {name=targetActiveApp.name, icon=targetActiveApp.icon})
							table.insert(droppedData.apps, {name=droppedApp.name, icon=droppedApp.icon})
							
							-- Remove the moved icon and the dropped-on icon, create a folder
							table.remove(gPhone.apps, droppedKey)
							table.remove(gPhone.apps, targetKey)
							table.insert(gPhone.apps, targetKey, droppedData)
						end
						
						-- Build a shiny new homescreen
						gPhone.buildHomescreen( gPhone.apps )
					end
					
				-- Moving apps around
				elseif dragndrop.GetDroppable() != nil and not gPhone.inFolder() then
					-- We are not dropping in the folder area, move the apps instead
					local prevX, prevY 

					local x, y = v.pnl:GetPos()
					local w, h = v.pnl:GetSize()
					local heldPanel = dragndrop.GetDroppable()[1]
					local shouldMove = false
					-- GetDroppable doesnt return a true pos, this works just as well
					local mX, mY = gPhone.homeIconLayout:ScreenToLocal( gui.MouseX(), gui.MouseY() )
					if x != 0 and gPhone.appPanels[k-1] != nil then
						prevX, prevY = gPhone.appPanels[k-1].pnl:GetPos()
						prevH, prevW = gPhone.appPanels[k-1].pnl:GetSize()		
					
						-- Check if the mouse is in the droppable area (between panels)
						if mX <= x + w/3 and mX >= prevX + (prevH/3 *2) then -- Increase the drop area by 33% on each side
							if mY >= y and mY <= y + h then
								shouldMove = true
							end
						end
					else
						if mX <= x + w/3 then 
							if mY >= y and mY <= y + h then
								shouldMove = true
							end
						end
					end
					
					if shouldMove then
						local droppedData = {name="N/A", icon="N/A"}
						local droppedKey = 0
						
						-- Get the name and image of the icon we are moving
						for i = 1, #gPhone.appPanels do
							if heldPanel == gPhone.appPanels[i].pnl:GetChildren()[1] then
								local droppedName = gPhone.appPanels[i].name
								
								for p = 1, #gPhone.apps do
									if gPhone.apps[p] and gPhone.apps[p].name == droppedName then
										droppedData = gPhone.apps[p]
										droppedKey = p
									end
								end
							end
						end
						
						-- Compensate for removed apps
						for _, key in pairs( removedAppKeys ) do
							if key < k then
								k = k + 1
							end
						end
						
						-- Remove the icon from its old key and move it to its new key
						table.remove(gPhone.apps, droppedKey)
						table.insert(gPhone.apps, k, droppedData )
						
						-- Build a shiny new homescreen
						gPhone.buildHomescreen( gPhone.apps )
					end
				end
			end
		end
	end, {})

	-- Populate the homescreen with apps
	function gPhone.buildHomescreen( tbl )
		if gPhone.isInApp() or not gPhone.isOpen() then return end
		
		-- Destroy the old homescreen 
		for k, v in pairs( gPhone.homeIconLayout:GetChildren() ) do
			v:Remove()
		end
		gPhone.appPanels = {}
		
		-- Run a pass through the table to fix issues
		gPhone.fixHomescreen( tbl )

		-- Start building apps and folders
		local xBuffer, yBuffer, iconCount = 0, 0, 1
		for key, data in pairs( tbl ) do
			local bgPanel, appinFolder
			
			-- Prevent icon overflow
			if iconCount > 20 then
				gPhone.msgC( GPHONE_MSGC_WARNING, "Homescreen is full and unable to hold any more applications!" )
				local remaining = #tbl - 20
				gPhone.msgC( GPHONE_MSGC_NOTIFY, remaining.." app(s) were not able to be added" )
				return
			end
			
			-- Prevent flagged apps from being added to the homescreen, they will go to the app store
			local removedApp = gPhone.removedApps[data.name:lower()]
			if removedApp or data.hidden then
				if data.hidden == false and gPhone.config.showUnusableApps == true then
					gPhone.setAppVisible( data.name, true )
				else
					continue -- Special garry keyword
				end
			end
			
			if data.icon then
				-- Create a normal app icon
				bgPanel = vgui.Create( "DPanel", gPhone.homeIconLayout )
				bgPanel:SetSize( 50, 45 )
				bgPanel:SetPos( 0 + xBuffer, 10 + yBuffer )
				bgPanel.Paint = function( self, w, h )
					--draw.RoundedBox(0, 0, 0, w, h, Color(255,0,0) )
				end
				
				local imagePanel = vgui.Create( "DImageButton", bgPanel ) 
				imagePanel:SetSize( 32, 32 )
				imagePanel:SetPos( 10, 0 )
				imagePanel:SetImage( data.icon )
				imagePanel:Droppable( "gPhoneIcon" )
				imagePanel.DoClick = function()
					gPhone.runApp( string.lower(data.name) )
				end
				
				local iconLabel = vgui.Create( "DLabel", bgPanel )
				iconLabel:SetText( data.name )
				iconLabel:SetFont("gPhone_12")
				iconLabel:SizeToContents()
				local y = imagePanel:GetTall() + 2
				if iconLabel:GetWide() > bgPanel:GetWide() then
					local w, h = iconLabel:GetSize()
					iconLabel:SetPos( 0, y )
					iconLabel:SetSize( bgPanel:GetWide(), h * 1.5 )
				else
					iconLabel:SetPos( bgPanel:GetWide()/2 - iconLabel:GetWide()/2, y)
				end
			elseif data.apps and #data.apps > 1 then
				-- The fun part, create a folder
				local folderLabel, nameEditor 
				bgPanel = vgui.Create( "DPanel", gPhone.homeIconLayout )
				bgPanel:SetSize( 50, 45 )
				bgPanel:SetPos( 0 + xBuffer, 10 + yBuffer )
				bgPanel.IsFolder = true
				bgPanel.Paint = function( self, w, h )
					if IsValid(nameEditor) and nameEditor:IsEditing() then
						local w, h = self:GetSize()
						local x, y = self:GetPos()
						draw.RoundedBox(4, 0, y + 10, bgPanel:GetWide(), 50, Color(50, 50, 50, 150) )
					end
					--draw.RoundedBox(4, 0, 0, w, h, Color(255, 0, 0, 150) )
				end
				
				local previewPanel = vgui.Create( "DImageButton", bgPanel ) 
				previewPanel:SetSize( 32, 32 )
				previewPanel:SetPos( 10, 0 )
				previewPanel:Droppable( "gPhoneIcon" )
				previewPanel.IsFolder = true
				
				-- Set up the preview icons, updates everytime the homescreen is built
				local drawnIcons = {}
				local xBuffer, yBuffer, previewIconCount = 2, 2, 0
				for k, v in pairs( data.apps ) do
					local icon = v.icon or "error"
					
					table.insert(drawnIcons, {x=xBuffer, y=yBuffer, icon=Material(icon)})
					previewIconCount = previewIconCount + 1
					
					if previewIconCount % 3 == 0 then
						xBuffer = 2
						yBuffer = yBuffer + 10
					else
						xBuffer = xBuffer + 10
						yBuffer = yBuffer
					end
				end
				previewPanel.Paint = function( self, w, h )
					-- Background blur
					if not dragndrop.GetDroppable() or not dragndrop.GetDroppable()[1] == self or gPhone.isinFolder then
						-- Vanishes when the panel is picked up or the entire screen becomes blurred
						gPhone.drawPanelBlur( self, 10, 20, 255 )
					end
					
					-- Draw the app icons for the folders contents
					if not gPhone.inFolder() then
						for k, v in pairs( drawnIcons ) do
							surface.SetDrawColor( color_white )
							surface.SetMaterial( v.icon )
							surface.DrawTexturedRect( v.x, v.y, 8, 8 )
						end
					end
				end
				
				local iconLabel = vgui.Create( "DLabel", bgPanel )
				iconLabel:SetText( data.name )
				iconLabel:SetFont("gPhone_12")
				iconLabel:SizeToContents()
				if iconLabel:GetWide() <= bgPanel:GetWide() then
					iconLabel:SetPos( bgPanel:GetWide()/2 - iconLabel:GetWide()/2, previewPanel:GetTall() + 2)
				else
					iconLabel:SetPos( 0, previewPanel:GetTall() + 2)
				end
				
				local x, y = previewPanel:GetPos()
				local w, h = previewPanel:GetSize()
				local oldBGPos = {bgPanel:GetPos()}
				local oldBGSize = {bgPanel:GetSize()}
				
				previewPanel.closeFolder = function()
					gPhone.log("Closing folder")
					if nameEditor then		
						nameEditor:OnEnter()		
						nameEditor:SetVisible(false)		
					end		
					
					gPhone.homeIconLayout.OnMousePressed = function() end
				
					gPhone.setPhoneState("homescreen")
					previewPanel:SetCursor( "hand" )		
					bgPanel:SetPos( unpack(oldBGPos) )		
					
					previewPanel:SizeTo( w, h, 0.5)		
					timer.Simple(0.5, function()		
						if IsValid(bgPanel) then		
							--bgPanel:Remove()		
						end		
					end)		
							
					gPhone.currentFolder = nil		
					gPhone.currentFolderApps = {}		
					gPhone.isInFolder = false		
					gPhone.buildHomescreen( gPhone.apps )
				end

				-- Handle the building of folders
				previewPanel.DoClick = function( self )
					gPhone.log("Opening folder")
					
					data.pnl = bgPanel
					gPhone.setActiveFolder( data )
					gPhone.setActiveFolderPanel( self )
					gPhone.setPhoneState( "folder" )
					previewPanel:SetCursor( "arrow" )
						
					-- Hide the other apps
					for k, v in pairs( gPhone.homeIconLayout:GetChildren() ) do
						if v != bgPanel then
							v:SetVisible(false)
						end
					end
					
					bgPanel.OnMousePressed = function( mousecode )
						if IsValid(previewPanel) then
							gPhone.closeFolder( nameEditor, previewPanel, bgPanel, oldBGPos ) 
						else
							gPhone.log("Cannot close folder, panel is nil")
						end
					end
					
					gPhone.homeIconLayout.OnMousePressed = function( mousecode )
						if IsValid(previewPanel) then
							gPhone.closeFolder( nameEditor, previewPanel, bgPanel, oldBGPos ) 
						else
							gPhone.log("Cannot close folder, panel is nil")
						end
					end
					
					iconLabel:SetVisible(false)
					bgPanel:SetPos( 0, 0 )
					bgPanel:SetSize( gPhone.homeIconLayout:GetWide(),  gPhone.homeIconLayout:GetTall())
					
					local w, h = gPhone.homeIconLayout:GetWide(), gPhone.homeIconLayout:GetTall()/1.7
					self:SizeTo( w - 10, h, 0.5)
					self:MoveTo( 5, gPhone.homeIconLayout:GetTall()/2 - h/2, 0.5)
					
					-- Inivisible label to get the size of the DTextEntry
					local sizeLabel = vgui.Create( "DLabel", bgPanel )
					sizeLabel:SetText( data.name )
					sizeLabel:SetFont("gPhone_36")
					sizeLabel:SizeToContents()
					sizeLabel:SetVisible( false )
					sizeLabel:SetPos( bgPanel:GetWide()/2 - sizeLabel:GetWide()/2, 15 )
					
					nameEditor = vgui.Create( "DTextEntry", bgPanel )
					nameEditor:SetText( data.name )
					nameEditor:SetFont( "gPhone_36" )
					nameEditor:SetSize( bgPanel:GetWide(), sizeLabel:GetTall() )
					nameEditor:SetPos( sizeLabel:GetPos() ) 
					nameEditor:SetTextColor( color_white )
					nameEditor:SetDrawBorder( false )
					nameEditor:SetDrawBackground( false )
					nameEditor:SetCursorColor( color_white )
					nameEditor:SetHighlightColor( Color(27,161,226) )
					nameEditor.Think = function( self )
						draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), Color(255, 255, 255) )
						
						if self.Opened == false then
							self:Remove()
						end
					end
					nameEditor.OnChange = function( self )
						local text = self:GetText()
						sizeLabel:SetText(text)
						sizeLabel:SizeToContents()
						sizeLabel:SetPos( bgPanel:GetWide()/2 - sizeLabel:GetWide()/2, 15 )
						
						self:SetPos( sizeLabel:GetPos() )
					end
					nameEditor.OnEnter = function( self )
						gPhone.log("Changed homescreen folder name from "..data.name.." to "..self:GetText())
						
						local text = string.Trim( self:GetText() )
						if text != "" then
							data.name = self:GetText()
						else
							self:SetText( trans("invalid_folder_name") )
						end
					end
					-- Why doesn't the text entry have a variable or function for that?
					nameEditor.HasFocus = false
					nameEditor.OnGetFocus = function( self )
						self.HasFocus = true
					end
					nameEditor.OnLoseFocus = function( self )
						self.HasFocus = false
						nameEditor:OnEnter()
					end
					
					-- Create the folder's app icons
					local xBuffer, yBuffer = 0,0
					local folderIconCount = 1
					for k, v in pairs( tbl[key].apps ) do
						-- Create a normal app icon
						local bgPanel = vgui.Create( "DPanel", previewPanel )
						bgPanel:SetSize( 50, 45 )
						bgPanel:SetPos( 15 + xBuffer, 15 + yBuffer )
						bgPanel.Paint = function( self, w, h )
						end
						
						v.icon = v.icon or ""
						
						local imagePanel = vgui.Create( "DImageButton", bgPanel ) 
						imagePanel:SetSize( 32, 32 )
						imagePanel:SetPos( 10, 0 )
						imagePanel:SetImage( v.icon )
						imagePanel:Droppable( "gPhoneIcon" )
						imagePanel.DoClick = function()
							gPhone.runApp( string.lower(v.name) )
						end
						
						local iconLabel = vgui.Create( "DLabel", bgPanel )
						iconLabel:SetText( v.name )
						iconLabel:SetFont("gPhone_12")
						iconLabel:SizeToContents()
						iconLabel:SetPos( bgPanel:GetWide()/2 - iconLabel:GetWide()/2, imagePanel:GetTall() + 2)
						
						local folderLabel = vgui.Create( "DLabel", bgPanel )
						folderLabel:SetText( v.name )
						folderLabel:SetFont("gPhone_12")
						folderLabel:SizeToContents()
						folderLabel:SetPos( bgPanel:GetWide()/2 - folderLabel:GetWide()/2, 34)
						
						if folderIconCount % 3 == 0 then
							xBuffer = 0
							yBuffer = yBuffer + bgPanel:GetTall() + 30
						else
							xBuffer = xBuffer + bgPanel:GetWide() + 10
							yBuffer = yBuffer
						end
						folderIconCount = folderIconCount+ 1
						
						table.insert(gPhone.appPanels, {name=v.name, icon=v.icon, pnl=bgPanel, inFolder=true} )
						gPhone.getActiveFolder().apps[k] = {pnl=bgPanel, name=v.name, icon=v.icon}
					end
				end
			end
		
			-- Properly align the icons
			if iconCount % 4 == 0 then
				xBuffer = 0
				yBuffer = yBuffer + 75
			else
				xBuffer = xBuffer + 55
				yBuffer = yBuffer
			end
			
			iconCount = iconCount + 1

			table.insert(gPhone.appPanels, {name=data.name, icon=data.icon, pnl=bgPanel, apps=data.apps} )
		end
		
		-- Save the app positions
		gPhone.saveAppPositions( gPhone.apps )
	end
	gPhone.buildHomescreen( gPhone.apps )
	
	-- Update the store's badges
	for _, data in pairs( gPhone.getHiddenApps() ) do
		gPhone.incrementBadge( "App Store", data.name:lower() )
	end
	
	-- Assorted stuff
	gPhone.setPhoneState( "hidden" )
	gPhone.config.phoneColor.a = 100
	
	gPhone.loadBadges()
	-- Check for updates from my website ONCE 
	gPhone.checkUpdate()
	
	gPhone.log("Phone built successfullly")
end

--// Moves the phone up into visiblity
function gPhone.showPhone( callback )
	if gPhone and gPhone.phoneBase then
		gPhone.log("Show phone")
		
		local pWidth, pHeight = gPhone.phoneBase:GetSize()
		gPhone.phoneBase:MoveTo( ScrW()-pWidth, ScrH()-pHeight, 0.7, 0, 2, function()
			gPhone.phoneBase:MakePopup()
			
			-- Needed to fix occasional bug where these are not clickable
			gPhone.homeIconLayout:SetMouseInputEnabled(true)
			gPhone.phoneScreen:SetMouseInputEnabled(true)
			
			if callback != nil then
				callback()
			end
		end)
		
		gPhone.config.phoneColor.a = 255
		
		if gPhone.getShowTutorial() then
			gPhone.bootUp()
			gPhone.setSeenTutorial( true )
		else 
			gPhone.buildLockScreen()
		end
		
		-- Tell the server we are done and the phone is ready to be used
		net.Start("gPhone_StateChange")
			net.WriteBool(true)
		net.SendToServer()
	end
end

--// Moves the phone down and disables it
function gPhone.hidePhone( callback )
	if gPhone and gPhone.phoneBase and gPhone.getPhoneState() != "hidden" then
		gPhone.log("Hide phone")
		
		gPhone.phoneBase:SetMouseInputEnabled( false )
		gPhone.phoneBase:SetKeyboardInputEnabled( false )
		gPhone.phoneScreen:SetMouseInputEnabled( false )
		
		gPhone.appDeleteMode = false
		gPhone.toHomeScreen()
		gPhone.setPhoneState( "hidden" )

		local x, y = gPhone.phoneBase:GetPos()
		
		gPhone.phoneBase:MoveTo( x, ScrH()-40, 0.7, 0, 2, function()
			gPhone.config.phoneColor.a = 100 -- Fade the alpha
			
			if callback then
				callback()
			end
		end)
		
		gApp.removeTickers()
		
		net.Start("gPhone_StateChange")
			net.WriteBool(false)
		net.SendToServer()
		
		net.Start("gPhone_App")
			net.WriteString("")
		net.SendToServer()
	end
end

--// Completely removes the phone from the game
function gPhone.destroyPhone( callback )
	if gPhone and gPhone.phoneBase then
		gPhone.log("Destroy phone")
		
		gPhone.phoneBase:Close()
		gPhone.phoneBase = nil
		
		gApp.removeTickers()
		
		gPhone.appDeleteMode = false
		gPhone.setPhoneState( "destroyed" )
		
		LocalPlayer():ConCommand("-voicerecord")
		LocalPlayer():ConCommand("gphone_stopmusic")
		
		net.Start("gPhone_StateChange")
			net.WriteBool(false)
		net.SendToServer()
		
		net.Start("gPhone_App")
			net.WriteString("")
		net.SendToServer()
		
		if callback != nil then
			callback()
		end
	end
end

--// Rebuilds the phone as fast as possible or with a time delay
function gPhone.rebootPhone( timeDelay )
	gPhone.log("Reboot phone")
	gPhone.hidePhone( function()
		gPhone.destroyPhone( function() 
			timer.Simple(timeDelay or 0.5, function()
				gPhone.log("Reboot finished")
				gPhone.buildPhone()
				gPhone.showPhone()
			end)
		end)
	end)
end

--// Fake signal strength for the phone based on distance from the map's origin
local mapOrigin = Vector(0,0,0)
function gPhone.updateSignalStrength()
	-- If I ever scrap Distance() and make my own, make the Z axis have more weight 
	local distFromOrigin = mapOrigin:Distance( LocalPlayer():GetPos() ) 

	-- rp_Downtown_v2 is 7000 units at its longest point
	if distFromOrigin <= 1000 then
		gPhone.signalStrength = 5
	elseif distFromOrigin <= 2000 then
		gPhone.signalStrength = 4
	elseif distFromOrigin <= 4000 then
		gPhone.signalStrength = 3
	elseif distFromOrigin <= 8000 then
		gPhone.signalStrength = 2
	else
		gPhone.signalStrength = 1
	end
end

--// Updates the signal strength
local nextUpdate = 0
hook.Add( "Think", "gPhone_signalStrength", function()
	if CurTime() > nextUpdate then
		-- Its purely for looks and players don't normally move 1-2k units in 5 seconds
		gPhone.updateSignalStrength()
		nextUpdate = CurTime() + 5 
	end
end)

--// Logic for opening the phone by holding down a key
local keyStartTime, nextOpen = 0, 0
local canOpenPhone = true
hook.Add( "Think", "gPhone_openAndCloseKey", function()
	-- Prevents the phone from being opened while chatting, in console, or in the main menu
	if not canOpenPhone or gui.IsConsoleVisible() or gui.IsGameUIVisible() then return end
	
	if input.IsKeyDown( gPhone.config.openKey ) then
		if keyStartTime == 0 then
			keyStartTime = CurTime()
		end
		
		if CurTime() < nextOpen then return end
		
		-- Key has been held down long enough and the phone is not animating
		if CurTime() - keyStartTime >= gPhone.config.keyHoldTime and not gPhone.isAnimating() then
			if gPhone.isOpen() != true then
				gPhone.showPhone()
			else
				gPhone.hidePhone()
			end
			
			nextOpen = CurTime() + 1
			keyStartTime = 0
		end
	else
		keyStartTime = 0
	end
end)

hook.Add("StartChat", "gPhone_liveAndLetChat", function()
	canOpenPhone = false
end)

hook.Add("FinishChat", "gPhone_weDoneChatting", function()
	canOpenPhone = true
end)
