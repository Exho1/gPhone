----// Clientside Animations //----

local client = LocalPlayer()
local trans = gPhone.getTranslation

-- Animations need to be smooth and so they should probably take RealFrameTime into account, I won't use tickers

--// Leave the current app and go to the home screen
function gPhone.toHomeScreen()
	if gPhone.onHomescreen() == true then return end
	
	if not gPhone.isPortrait() then
		gPhone.setOrientation( "portrait" )
	end
	
	gApp["_close_"]( gPhone.getActiveApp() )
	gPhone.setPhoneState( "home" )
	
	gPhone.buildHomescreen( gPhone.apps )
end

--// Rotate the phone to a landscape position
local oldPWide, oldPHeight, oldSWide, oldSHeight = nil
function gPhone.rotateToLandscape()
	gPhone.setIsAnimating( true )
	
	-- Save old values
	oldPWide, oldPHeight = gPhone.phoneBase:GetSize()
	oldSWide, oldSHeight = gPhone.phoneScreen:GetSize()
	
	-- Expand so the phone can rotate without cutting off anything
	gPhone.phoneBase:SetSize( oldPWide*2, oldPHeight*2 )
	gPhone.phoneScreen:SetSize( oldSWide*2, oldSHeight*2 )
	
	gPhone.phoneBase.Think = function()
		-- Rotate
		local rot = Lerp( 1, gPhone.rotation, 90 )
		gPhone.rotation = rot
		
		if rot == 90 then
			gPhone.phoneBase.Think = oldThink 
		end
	end
	
	-- Adjust sizes and positions for landscape, switch the values
	-- X, Y -> Y, X and W, H -> H, W
	gPhone.phoneBase:SetSize( oldPHeight, oldPWide )
	gPhone.phoneBase:SetPos( ScrW() - oldPHeight, ScrH() - oldPWide )
	gPhone.phoneScreen:SetSize( oldSHeight, oldSWide )
	gPhone.phoneScreen:SetPos( 87, 35 )
	gPhone.homeButton:SetPos( oldPHeight - gPhone.homeButton:GetWide() - 35, oldPWide/2 - gPhone.homeButton:GetTall()/2 + 3 )
	
	gPhone.setIsAnimating( false )
end

--// Rotate the phone back to portrait
function gPhone.rotateToPortrait()

	local oldThink = gPhone.phoneBase.Think
	gPhone.setIsAnimating( true )
	-- Expand so the phone can rotate without cutting off anything
	gPhone.phoneBase:SetSize( oldPWide*2, oldPHeight*2 )
	gPhone.phoneScreen:SetSize( oldSWide*2, oldSHeight*2 )
	
	gPhone.phoneBase.Think = function()
		-- Rotate
		local rot = Lerp( 1, gPhone.rotation, 0 )
		gPhone.rotation = rot
		
		if rot == 0 then
			gPhone.phoneBase.Think = oldThink 
		end
	end
	
	-- Switch the values back for Portrait
	gPhone.phoneBase:SetSize( oldPWide, oldPHeight )
	gPhone.phoneBase:SetPos( ScrW() - oldPWide, ScrH() - oldPHeight )
	gPhone.phoneScreen:SetSize( oldSWide, oldSHeight )
	gPhone.phoneScreen:SetPos( 31, 87 )
	gPhone.homeButton:SetPos( oldPWide/2 - gPhone.homeButton:GetWide()/2 - 3, oldPHeight - gPhone.homeButton:GetTall() - 35 )
	
	gPhone.setIsAnimating( false )
end

--// vibrate the phone if its in its passive state
function gPhone.vibrate()
	if not gPhone.isOpen() and IsValid( gPhone.phoneBase ) then
		if gPhone.isAnimating() then return end
		gPhone.setIsAnimating( true )
		
		-- Holy variables Batman!
		local oldThink = gPhone.phoneBase.Think
		local oldX, oldY = gPhone.phoneBase:GetPos()
		local oldPWide, oldPHeight = gPhone.phoneBase:GetSize()
		
		local degreeDistance = 5 -- How far (in degrees) the phone will turn while vibrating
		
		local final = -degreeDistance
		local y = oldY
		local shouldvibrate = true
		local shouldBeExtended = true
		local moveToPos = oldY - 30
		
		gPhone.config.phoneColor.a = 255
		surface.PlaySound( "gphone/vibrate.wav" )
		
		-- Think function to do our animations in
		gPhone.phoneBase.Think = function()
			if not IsValid( gPhone.phoneBase ) then -- Kill the function
				gPhone.phoneBase.Think = oldThink
			end
			
			if shouldvibrate then
				gPhone.phoneScreen:SetVisible(false)
				gPhone.phoneBase:SetSize( oldPWide * 1.5, oldPHeight * 1.5 )
				
				local rot = gPhone.rotation
				
				if rot == final then
					if final == -degreeDistance then
						final = degreeDistance
					elseif final == degreeDistance then
						final = -degreeDistance
					end
				end
				
				rot = math.Approach( rot, final, 300 * RealFrameTime() )
				rot = math.Clamp( rot, -degreeDistance, degreeDistance )

				gPhone.rotation = rot
			end
			
			if shouldBeExtended then
				y = math.Approach( y, moveToPos, 2 )
				--y = math.Clamp( y, oldY, oldY + 20 )
			else
				y = math.Approach( y, ScrH() - 40, 2 )
				--y = math.Clamp( y, oldY, oldY + 20 )
			end
			gPhone.phoneBase:SetPos( oldX - 75, y - 150 )
		end
		
		timer.Simple(1, function() -- Fix the phone's angles and retract
			final = 0 
			shouldBeExtended = false
			gPhone.config.phoneColor.a = 100
			timer.Simple(0.5, function() -- Stop vibrating and reset everything
				shouldvibrate = false
				
				gPhone.phoneScreen:SetVisible(true)
		
				gPhone.phoneBase:SetSize( oldPWide, oldPHeight )
				gPhone.phoneBase:SetPos( oldX, oldY )
				gPhone.phoneBase.Think = oldThink 
				
				gPhone.setIsAnimating( false )
			end)
		end)
	end
end

--// 'Booting' animation for when the player first opens their phone
function gPhone.bootUp()
	local screen = gPhone.phoneScreen
	gPhone.setIsAnimating( true )
	gPhone.setPhoneState( "boot" )

	-- Hide the default home screen
	local oldScreen = gPhone.phoneScreen.Paint
	for k, v in pairs(gPhone.phoneScreen:GetChildren()) do
		v:SetVisible(false)
	end
	
	local logo = vgui.Create("DImage", screen)
	logo:SetSize( 64, 64 )
	logo:SetPos( screen:GetWide()/2 - logo:GetWide()/2, screen:GetTall()/2 - logo:GetTall())
	logo:SetImage( "vgui/gphone/boot_logo.png" )
	
	local progressBar = vgui.Create( "DPanel", screen )
	progressBar:SetSize( 75, 10 )
	progressBar:SetPos( screen:GetWide()/2 - progressBar:GetWide()/2, screen:GetTall()/2 + 15 )
	local bootProgress = 0
	local nextPass = 0
	
	-- TEMP
	if true then
		bootProgress = 75
	end
	
	progressBar.Think = function()
		if bootProgress >= 75 then -- Finished fake booting
			logo:Remove()
			progressBar:Remove()
			
			gPhone.setIsAnimating( false )
			
			-- Open the tutorial
			gPhone.beginnerTutorial( oldScreen )
		end
		
		if CurTime() > nextPass then
			local amount = math.random(3, 10)
			bootProgress = math.Clamp(bootProgress + amount, 0, progressBar:GetWide())
			
			nextPass = CurTime() + math.Rand(0.5, 1)
		end
	end
	progressBar.Paint = function()
		draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), Color(50, 50, 50))
		draw.RoundedBox(2, 0, 0, bootProgress, screen:GetTall(), Color(100, 250, 100))
	end
	
	gPhone.phoneScreen.Paint = function( self )
		draw.RoundedBox(2, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.whiteBG)
	end
	
end

--// Creates the tutorial for first time users
function gPhone.beginnerTutorial( oldScreen )
	local screen = gPhone.phoneScreen
	
	-- Prevents this from being called more than once
	if gPhone.isAnimating() == true then
		return false
	end
	gPhone.setIsAnimating( true )
	
	local base = vgui.Create("DPanel", screen)
	base:SetSize( screen:GetSize() )
	base:SetPos( 0, 0 )
	base.Paint = function( self, w, h ) end
	
	local title = vgui.Create( "DLabel", base )
	title:SetText( "Welcome" )
	title:SetFont("gPhone_24")
	title:SetColor( color_black )
	title:SizeToContents()
	title:SetPos( screen:GetWide()/2 - title:GetWide()/2, screen:GetTall()/3 - title:GetTall()/2 )
	
	local lowerText = vgui.Create( "DLabel", base )
	lowerText:SetText( "Choose your language" )
	lowerText:SetFont("gPhone_16")
	lowerText:SetColor( gPhone.colors.grey )
	lowerText:SizeToContents()
	local _, y = title:GetPos()
	lowerText:SetPos( screen:GetWide()/2 - lowerText:GetWide()/2, screen:GetTall()/3 + title:GetTall() - 5 )
	
	local languagePicker = vgui.Create( "DComboBox", base )
	languagePicker:SetSize( screen:GetWide()/2, 30 )
	languagePicker:SetPos( screen:GetWide()/2 - languagePicker:GetWide()/2, screen:GetTall()/2 - languagePicker:GetTall() )
	languagePicker:SetValue( trans("language") )
	languagePicker:SetTextColor( color_black )
	languagePicker:SetFont( "gPhone_18" )
	for k, _ in pairs( gPhone.languages ) do
		if k != "default" then -- Default is a variable not a language
			languagePicker:AddChoice( k:gsub("^%l", string.upper) )
		end
	end
	languagePicker.OnSelect = function( self, key, val )
		
		-- Set language
		if val:lower() != "language" and val != gPhone.getActiveLanguage() then
			gPhone.setActiveLanguage( val )
		end
		
		if val != "english" then
			-- Reimport all the apps so the translation takes effect
			gPhone.removedApps = {}
			gPhone.apps = {}
			gPhone.importApps()
		end
		
		-- Change the title's text and move it to the center-top
		local x = title:GetPos()
		title:MoveTo( x, -title:GetTall(), 0.5, 0, 2, function()
			gPhone.beginnerSlideshow( base, oldScreen )
		end)
		
		-- Slide the language picker off the screen and remove it
		local _, y = languagePicker:GetPos()
		languagePicker:MoveTo( -languagePicker:GetWide() - 10, y, 0.5, 0, 2, function()
			languagePicker:Remove()
		end)
		
		local _, y = lowerText:GetPos()
		lowerText:MoveTo( -lowerText:GetWide() - 10, y, 0.5, 0, 2, function()
			lowerText:Remove()
		end)
	end
end

--// Creates the 'slideshow' for the tutorial
function gPhone.beginnerSlideshow( base, oldScreen )
	local screen = gPhone.phoneScreen
	local title = base:GetChildren()[1]
	
	local currentPanel 
	local nextImage = 1
	local images = {
		"vgui/gphone/boot_logo.png",
		"vgui/gphone/camera.png",
		"vgui/gphone/music.png",
		"vgui/gphone/phone.png",
	}
	
	local messages = {
		"Welcome to the Garry Phone! This is a short tutorial that will teach you the basics of the phone",
		"TEST2",
		"AYYYYYYYYYYYYYYYYYYYYYYYYYYYYY",
		"AYYYYYYYYYYYYYYYYYYYYYOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
	}
	
	local slideImage = vgui.Create( "DImage", base )
	slideImage:SetSize( screen:GetWide() - 50, screen:GetTall()/2 )
	slideImage:SetPos( 25, 50 )
	slideImage:SetImage( images[nextImage] )
	currentPanel = slideImage
	
	local messageLabel = vgui.Create( "DLabel", base )
	messageLabel:SetText( messages[nextImage] )
	messageLabel:SetFont("gPhone_18")
	messageLabel:SetColor( color_black )
	messageLabel:SizeToContents()
	gPhone.wordWrap( messageLabel, base:GetWide(), 35 )
	local _, y = slideImage:GetPos()
	messageLabel:SetPos( screen:GetWide()/2 - messageLabel:GetWide()/2, y + slideImage:GetTall() + 20 )
	
	print(messageLabel:GetPos())
	
	nextImage = nextImage + 1
	
	local slideImage2 = vgui.Create( "DImage", base )
	slideImage2:SetSize( screen:GetWide() - 50, screen:GetTall()/2 )
	slideImage2:SetPos( screen:GetWide() + slideImage:GetWide() + 25, 50 )
	slideImage2:SetImage( images[nextImage] )
	
	local messageLabel2 = vgui.Create( "DLabel", base )
	messageLabel2:SetText( messages[nextImage] )
	messageLabel2:SetFont("gPhone_18")
	messageLabel2:SetColor( color_black )
	messageLabel2:SizeToContents()
	local _, y = slideImage:GetPos()
	messageLabel2:SetPos( screen:GetWide() + messageLabel2:GetWide(), y + slideImage:GetTall() + 20 )
	gPhone.wordWrap( messageLabel2, base:GetWide(), 35 )
	
	local nextButton = vgui.Create( "DButton", base )
	nextButton:SetText( trans("okay") )
	nextButton:SetFont("gPhone_16")
	nextButton:SetColor( color_black )
	local w, h = gPhone.getTextSize(nextButton:GetText(), nextButton:GetFont())
	nextButton:SetSize( w * 3, h * 2 )
	local x, y = screen:GetWide()/2 - nextButton:GetWide()/2, screen:GetTall() - nextButton:GetTall() * 2
	nextButton:SetPos( x, screen:GetTall() + nextButton:GetTall() )
	nextButton:MoveTo( x, y, 0.5, 0, 2) -- Move
	nextButton.Paint = function( self, w, h )
		if not self:IsDown() then
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
		else
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.darkerWhite)
		end
		
		surface.SetDrawColor( gPhone.colors.grey )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	local count = 1
	local animating = false
	nextButton.DoClick = function( self )
		
		if animating then return end
		animating = true
		
		local slide1
		local slide2
		local message1
		local message2
		
		-- Figure out which slide is currently on the screen
		if currentPanel == slideImage then
			slide1 = slideImage
			slide2 = slideImage2
			message1 = messageLabel
			message2 = messageLabel2
		else
			slide1 = slideImage2
			slide2 = slideImage
			message1 = messageLabel2
			message2 = messageLabel
		end
		
		if count == #images then
			-- Slide out and remove the active panels
			local _, y = slide1:GetPos()
			slide1:MoveTo( -slide1:GetWide(), y, 0.5, 0, 2, function()
				slide1:Remove()
			end)
			local _, y = message1:GetPos()
			message1:MoveTo( -message1:GetWide(), y, 0.5, 0, 2, function()
				message1:Remove()
			end)
			
			-- Remove all tutorial panels
			base:Remove()
			
			-- Restore original phone stuff
			gPhone.phoneScreen.Paint = oldScreen
			for k, v in pairs(gPhone.phoneScreen:GetChildren()) do
				v:SetVisible(true)
			end
			
			-- Go to lock screen
			gPhone.buildLockScreen()
			animating = false
			return
		end
		
		local x, y = slide1:GetPos()
		-- Slide out of view
		slide1:MoveTo( -slide1:GetWide(), y, 0.5, 0, 2, function()
			-- Put back on the right
			if not images[nextImage + 1] then return end
			
			slide1:SetPos( screen:GetWide() + slide1:GetWide() + 25, 50 )
			slide1:SetImage( images[nextImage + 1] )
			
			nextImage = nextImage + 1
		end)
		
		local mX, mY = message1:GetPos()
		message1:MoveTo( -message1:GetWide(), mY, 0.5, 0, 2, function()
			message1:SetPos( screen:GetWide() + message2:GetWide(), mY )
			message1:SetText( messages[nextImage] )
			gPhone.wordWrap( message1, base:GetWide(), 35 )
		end)
		
		-- Slide into frame
		slide2:MoveTo( x, y, 0.5, 0, 2, function()
			currentPanel = slide2
			animating = false
		end)
		
		message2:MoveTo( base:GetWide()/2 - message2:GetWide()/2, mY, 0.5, 0, 2)
		
		count = count + 1
	end
end

--// Run an animation to unlock the phone's lock screen
local lockTime, dateLabel, slideUnlock, arrow, oldScreen
function gPhone.unlockLockScreen( callback )
	if not IsValid(lockTime) or not IsValid(slideUnlock) then return end
	
	local screen = gPhone.phoneScreen
	local x, y = screen:GetPos()
	gPhone.setIsAnimating( true )
	
	local lX, lY = lockTime:GetPos()
	local dX, dY = dateLabel:GetPos()
	local sX, sY = slideUnlock:GetPos()
	
	lockTime:MoveTo( x + screen:GetWide() + 50, lY, 0.5, 0, 2)
	dateLabel:MoveTo( x + screen:GetWide() + 50, dY, 0.5, 0, 2)
	slideUnlock:MoveTo( x + screen:GetWide() + 50, sY, 0.5, 0, 2, function()
		gPhone.phoneScreen.Paint = oldScreen
		
		arrow:Remove()
		lockTime:Remove()
		dateLabel:Remove()
		slideUnlock:Remove()
		
		for k, v in pairs(gPhone.phoneScreen:GetChildren()) do
			v:SetVisible(true)
		end
		gPhone.buildHomescreen( gPhone.apps )
		
		gPhone.showStatusBar()
		
		if IsValid( callback ) then
			callback()
		end
		
		gPhone.setIsAnimating( false )
		gPhone.setPhoneState( "home" )
	end)
end

--// Build the actual lock screen with all the info
-- Set 'gPhone.shouldUnlock' to false to cancel the default timed unlock
function gPhone.buildLockScreen()
	gPhone.setPhoneState( "lock" )

	local screen = gPhone.phoneScreen
	
	-- Hide the default home screen
	oldScreen = gPhone.phoneScreen.Paint
	for k, v in pairs(gPhone.phoneScreen:GetChildren()) do
		v:SetVisible(false)
	end
	gPhone.showStatusBar()
	gPhone.hideStatusBarElement( "time" )
	
	gPhone.phoneScreen.Paint = function( self )
		surface.SetMaterial( gPhone.getWallpaper( false, true ) ) 
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
	end
	
	lockTime = vgui.Create( "DLabel", screen )
	lockTime:SetText( os.date("%I:%M") )
	lockTime:SetFont("gPhone_60")
	lockTime:SizeToContents()
	lockTime:SetPos( screen:GetWide()/2 - lockTime:GetWide()/2, 15 )
	lockTime.Think = function()
		if IsValid(lockTime) then
			lockTime:SetText(os.date("%I:%M"))
			lockTime:SetFont("gPhone_60")
			lockTime:SizeToContents()
		end
	end
	
	dateLabel = vgui.Create( "DLabel", screen )
	dateLabel:SetText( os.date("%A, %B %d") )
	dateLabel:SetFont("gPhone_18Lite")
	dateLabel:SizeToContents()
	dateLabel:SetPos( screen:GetWide()/2 - dateLabel:GetWide()/2, 70 )
	
	slideUnlock = vgui.Create( "DLabel", screen )
	slideUnlock:SetText( trans("slide_unlock") )
	slideUnlock:SetFont("gPhone_18Lite")
	slideUnlock:SizeToContents()
	slideUnlock:SetPos( screen:GetWide()/2 - slideUnlock:GetWide()/2, screen:GetTall() - slideUnlock:GetTall() - 50 )
	
	local sX, sY = slideUnlock:GetPos()
	
	arrow = vgui.Create( "DImage", screen )
	arrow:SetSize( 8, 16 )
	arrow:SetImage( "vgui/gphone/right_arrow.png" )
	arrow.Think = function()
		if IsValid(slideUnlock) then
			sX, sY = slideUnlock:GetPos()
			arrow:SetPos( sX - 16, sY + 2)
		end
	end
	
	timer.Simple(gPhone.config.openLockDelay, function()
		if gPhone.shouldUnlock then 
			gPhone.unlockLockScreen()
		else	
			gPhone.msgC( GPHONE_MSGC_NOTIFY, "Unlock halted at this time, waiting for unlock." )
			hook.Add("Think", "gPhone_waitForUnlock", function()
				-- In case the lock screen is not allowed to be opened, we wait for the boolean to be true
				if gPhone.shouldUnlock then
					gPhone.unlockLockScreen()
					hook.Remove("Think", "gPhone_waitForUnlock")
				end
			end)
		end
	end)
end

--// Puts all incoming alerts and banners into a list so they appear after each other in order of arrival
-- The code looks intimidating but its really quite simple
gPhone.notifyQueue = { alert={}, banner={} }
hook.Add("Think", "gPhone_notificationQueue", function()
	if #gPhone.notifyQueue.alert > 0 or #gPhone.notifyQueue.banner > 0 then
		for type, queue in pairs( gPhone.notifyQueue ) do
			if type == "alert" then
				for k, d in pairs( queue ) do
					if not IsValid( gPhone.alertPanel ) then
						gPhone.msgC( GPHONE_MSGC_NOTIFY, "Creating new alert from queue, key: "..k )
						
						-- Remove the next notification if it is a repeat of the current one
						if gPhone.notifyQueue[type][k+1] then
							local nextNotify = gPhone.notifyQueue[type][k+1]
							if nextNotify.tbl.msg == d.tbl.msg and nextNotify.tbl.title == d.tbl.title then
								gPhone.msgC( GPHONE_MSGC_NOTIFY, "Removing repeated "..type.." notification to prevent spam" )
								table.remove( gPhone.notifyQueue.alert, k + 1)
							end
						end
						
						-- Run the notification and remove from the queue
						gPhone.notifyAlert( d.tbl, d.func1, d.func2, d.b1, d.b2 )
						table.remove( gPhone.notifyQueue.alert, k )
					end
				end
			elseif type == "banner" then
				for k, d in pairs( queue ) do
					if not IsValid( gPhone.bannerPanel ) then
						gPhone.msgC( GPHONE_MSGC_NOTIFY, "Creating new banner from queue, key: "..k )
						
						if gPhone.notifyQueue[type][k+1] then
							local nextNotify = gPhone.notifyQueue[type][k+1]
							if nextNotify.tbl.msg == d.tbl.msg and nextNotify.tbl.title == d.tbl.title then
								gPhone.msgC( GPHONE_MSGC_NOTIFY, "Removing repeated "..type.." notification to prevent spam" )
								table.remove( gPhone.notifyQueue.alert, k + 1)
							end
						end
						
						gPhone.notifyBanner( d.tbl, d.func )
						table.remove( gPhone.notifyQueue.banner, k )
					end
				end
			end
		end
	end
end)

--// Opens a notification which the player has to select an option 
-- tbl = {msg = String, title = String, options = Table}
-- options = {"False", "True"}
gPhone.alertPanel = nil
function gPhone.notifyAlert( tbl, optionFunction1, optionFunction2, bOneOption, bCloseOnSelect )
	local screen = gPhone.phoneScreen
	
	if gPhone.config.airplaneMode then
		gPhone.msgC( GPHONE_MSGC_NOTIFY, "Hid alert due to airplane mode")
		return
	end
	
	gPhone.setIsAnimating( true )
	
	if IsValid(gPhone.alertPanel) then
		table.insert(gPhone.notifyQueue.alert, 
		{tbl=tbl, func1=optionFunction1, func2=optionFunction2, b1=bOneOption, b2=bCloseOnSelect} )
		return
	end
	
	local w, h = screen:GetWide() - 30, 80
	gPhone.alertPanel = vgui.Create( "DPanel", screen )
	gPhone.alertPanel:SetSize( w, h )
	gPhone.alertPanel:SetPos( 15, screen:GetTall()/2 - gPhone.alertPanel:GetTall()/2 )
	gPhone.alertPanel.Paint = function( self, w, h )
		draw.RoundedBox(6, 0, 0, w, h, Color(240, 240, 240, 240))
	end
	
	local bgPanel = gPhone.alertPanel
	
	tbl.msg = tbl.msg or "N/A"
	
	local message = vgui.Create( "DLabel", bgPanel )
	message:SetTextColor( color_black )
	message:SetFont("gPhone_16")
	message:SetText( tbl.msg ) 
	if string.len( tbl.msg ) > 95 then
		local newMsg = string.Left( tbl.msg, 95 )
		newMsg = gPhone.charSub( newMsg, 93, "..." )
		message:SetText( newMsg )
	end
	
	gPhone.wordWrap( message, bgPanel:GetWide(), 10 )
	bgPanel:SetSize( w, h + message:GetTall() )
	message:SetPos( bgPanel:GetWide()/2 - message:GetWide()/2,  bgPanel:GetTall() - 50 - message:GetTall() )

	local title = vgui.Create( "DLabel", bgPanel )
	title:SetTextColor( color_black )
	title:SetFont("gPhone_18")
	local x, y = message:GetPos()
	title:SetPos( 0, 10 )
	gPhone.setTextAndCenter(title, tbl.title or "N/A", bgPanel)
	
	local optionPanels = {}
	local x = 0
	-- Create the option buttons
	for k, value in pairs( tbl.options ) do
		optionPanels[k] = vgui.Create("DButton", bgPanel )
		if not bOneOption then
			optionPanels[k]:SetSize( bgPanel:GetWide()/2 - 0.5, 40 )
		else
			optionPanels[k]:SetSize( bgPanel:GetWide(), 40 )
		end
		optionPanels[k]:SetPos( x, bgPanel:GetTall() - optionPanels[k]:GetTall() )
		x = optionPanels[k]:GetWide() + 0.5
		optionPanels[k]:SetText("")
		optionPanels[k].Paint = function( self, w, h )
			draw.RoundedBox(0, 0, 1, self:GetWide(), 1, Color(150, 150, 150))
			
			if not bOneOption then
				if k == 1 then
					draw.RoundedBox(0, self:GetWide()-1, 1, 1, self:GetTall() - 1, Color(150, 150, 150))
				end
			end
		end
		optionPanels[k].DoClick = function( self )
			gPhone.setIsAnimating( false )
			
			if k == 1 then -- The first option should ALWAYS be a close or deny
				-- Run developer-set negative function
				if optionFunction1 then
					optionFunction1( bgPanel, value )
				end
			else
				-- Run developer-set positive function 
				if optionFunction2 then
					optionFunction2( bgPanel, value )
				end
			end
			
			gPhone.alertPanel = nil
			
			if bCloseOnSelect != false then
				-- Close the panel
				bgPanel:Remove()
			end
		end
		
		local buttonText = vgui.Create( "DLabel", optionPanels[k] )
		buttonText:SetTextColor( gPhone.colors.blue )
		buttonText:SetFont("gPhone_18")
		gPhone.setTextAndCenter(buttonText, value, optionPanels[k], true)
	end
end

--// Opens a notification which requires no user input (but can be clicked) and goes away automatically
-- tbl = {msg = String, app = String, (optional) title = String }
gPhone.bannerPanel = nil
function gPhone.notifyBanner( tbl, onClickFunc )
	local screen = gPhone.phoneScreen
	local initialO = gPhone.orientation
	local initialS = gPhone.phoneState
	
	if gPhone.config.airplaneMode then
		gPhone.msgC( GPHONE_MSGC_NOTIFY, "Hid banner due to airplane mode")
		return
	end
	
	if IsValid(gPhone.bannerPanel) then
		table.insert(gPhone.notifyQueue.banner, 
		{tbl=tbl, func=onClickFunc} )
		return
	end
	
	-- Make sure the message doesn't run off the page
	local wordLimit
	if gPhone.isPortrait() then
		wordLimit = 72
	else
		wordLimit = 122
	end
	
	tbl.app = tbl.app or "N/A"
	
	-- Get the app icon
	local icon = "ERROR"
	if tbl.app:lower() != "gphone" then
		for _, data in pairs( gPhone.apps ) do
			if data.name:lower() == tbl.app:lower() then
				icon = data.icon
			end
		end
	else
		icon = "vgui/gphone/boot_logo.png"
	end
	
	gPhone.bannerPanel = vgui.Create( "DPanel", screen )
	gPhone.bannerPanel:SetSize( screen:GetWide(), 0 )
	gPhone.bannerPanel.Paint = function( self, w, h )
		draw.RoundedBox(4, 0, 0, w, h, gPhone.colorNewAlpha( color_black, 250 ))
	end
	
	local bgPanel = gPhone.bannerPanel
	
	local function closePanel( pnl )
		pnl:SizeTo( pnl:GetWide(), 0, 0.3, 0, -1, function( data, pnl )
			if IsValid(pnl) then
				pnl:Remove()
			end
		end)
	end
	
	bgPanel.OnMousePressed = function( self, code )
		-- Left mouse is the only click that will run the function, all others will close the notification
		if code == MOUSE_LEFT then
			if onClickFunc then
				onClickFunc( tbl.app )
			end
		end
		closePanel( self )
	end
	bgPanel.Think = function( self )
		-- If something major happens to the phone, hide the notification
		if gPhone.orientation != initialO or gPhone.phoneState != initialS then
			closePanel( bgPanel )
			bgPanel.Think = function() end
		end
	end
	
	local appImage = vgui.Create( "DImageButton", bgPanel ) 
	appImage:SetSize( 24, 24 )
	appImage:SetPos( 10, 5 )
	appImage:SetImage( icon )
	appImage.DoClick = function()
		-- App icon will launch you into the app
		closePanel( bgPanel )
		if tbl.app:lower() != "gphone" then
			gPhone.runApp( string.lower( tbl.app ) )
		end
	end
	
	tbl.msg = tbl.msg or "N/A"
	
	local message = vgui.Create( "DLabel", bgPanel )
	message:SetTextColor( color_white )
	message:SetFont("gPhone_12")
	message:SetText( tbl.msg ) 
	if string.len( tbl.msg ) > wordLimit then -- 72 character limit
		local newMsg = string.Left( tbl.msg, wordLimit )
		newMsg = gPhone.charSub( newMsg, wordLimit-2, "..." )
		message:SetText( newMsg )
	end
	gPhone.wordWrap( message, bgPanel:GetWide(), 20 )
	message:SetPos( 40, 20 )
	
	local title = vgui.Create( "DLabel", bgPanel )
	title:SetTextColor( color_white )
	title:SetFont("gPhone_16")
	title:SetText( tbl.title or tbl.app or "N/A" )
	title:SizeToContents()
	local x, y = message:GetPos()
	title:SetPos( 40, 5 )
	
	-- Size appropriately
	sizeToHeight = title:GetTall() + message:GetTall() + 10
	bgPanel:SizeTo( bgPanel:GetWide(), sizeToHeight, 0.5 )
	
	timer.Simple(5, function()
		if IsValid(bgPanel) then
			closePanel( bgPanel )
		end
	end)
end

