----// Clientside Animations //----

local client = LocalPlayer()

-- Animations need to be smooth and so they should probably take RealFrameTime into account, I won't use tickers

--// Leave the current app and go to the home screen
function gPhone.toHomeScreen()
	if gPhone.isOnHomeScreen == true then return end
	
	if not gPhone.isPortrait then
		gPhone.setOrientation( "portrait" )
	end
	
	gApp["_close_"]( gPhone.getActiveApp() )
	gPhone.setPhoneState( "home" )
	
	gPhone.buildHomescreen( gPhone.apps )
end

--// Rotate the phone to a landscape position
local oldPWide, oldPHeight, oldSWide, oldSHeight = nil
function gPhone.rotateToLandscape()
	if not gPhone.isPortrait() then return end
	
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
	if gPhone.isPortrait() then return end
	
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
		
		gPhone.config.PhoneColor.a = 255
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
			gPhone.config.PhoneColor.a = 100
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
	progressBar.Think = function()
		if bootProgress >= 75 then -- Finished fake booting
			logo:Remove()
			progressBar:Remove()
			
			gPhone.phoneScreen.Paint = oldScreen
			for k, v in pairs(gPhone.phoneScreen:GetChildren()) do
				v:SetVisible(true)
			end
			gPhone.setIsAnimating( false )
			
			gPhone.unlockLockScreen()
		end
		
		if CurTime() > nextPass then
			local amount = math.random(2, 10)
			bootProgress = math.Clamp(bootProgress + amount, 0, progressBar:GetWide())
			
			nextPass = CurTime() + math.Rand(0.5, 2)
		end
	end
	progressBar.Paint = function()
		draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), Color(50, 50, 50))
		draw.RoundedBox(2, 0, 0, bootProgress, screen:GetTall(), Color(100, 250, 100))
	end
	
	gPhone.phoneScreen.Paint = function( self )
		draw.RoundedBox(2, 0, 0, self:GetWide(), self:GetTall(), Color(250, 250, 250))
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
	slideUnlock:SetText( "slide to unlock" )
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
			gPhone.msgC( GPHONE_MSGC_NOTIFY, "Unlock prohibited, waiting for override." )
			hook.Add("Think", "gPhone_waitForUnlock", function()
				if gPhone.shouldUnlock then
					gPhone.unlockLockScreen()
					hook.Remove("Think", "gPhone_waitForUnlock")
				end
			end)
		end
	end)
end

--// Opens a notification which the player has to select 1 of 2 options to close
function gPhone.notifyInteract( tbl )
	-- tbl = {appName, msgText, options={yes,no}}
	gPhone.shouldUnlock = false
	
	if gPhone.isPortrait then
	
	else
	
	end
	
	--gPhone.switchApps( newApp )
	
	--[[
	if accepted then
		gPhone.unlockLockScreen( function()
			gPhone.runApp( otherStuff.game )
		end)
	end
	
	if denied then
		gPhone.unlockLockScreen()
	end
	
	gPhone.shouldUnlock = true
	]]
end

--// Opens a notification which requires no user input (but can be clicked) and goes away automatically
function gPhone.notifyPassive( tbl )
	-- tbl = {appName, msgText}

end