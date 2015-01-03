----// Clientside Animations //----

local client = LocalPlayer()

-- Animations need to be smooth and so they should probably take RealFrameTime into account, I won't use tickers

--// Leave the current app and go to the home screen
function gPhone.ToHomeScreen()
	if gPhone.IsOnHomeScreen == true then return end
	
	if not gPhone.IsPortrait then
		gPhone.RotateToPortrait()
	end
	
	gApp["_close_"]( gApp["_active_"] )
	gPhone.IsOnHomeScreen = false
end

--// Rotate the phone to a landscape position
local oldPWide, oldPHeight, oldSWide, oldSHeight = nil
function gPhone.RotateToLandscape()
	if not gPhone.IsPortrait then return end
	
	gPhone.IsInAnimation = true
	
	-- Save old values
	oldPWide, oldPHeight = gPhone.phoneBase:GetSize()
	oldSWide, oldSHeight = gPhone.phoneScreen:GetSize()
	
	-- Expand so the phone can rotate without cutting off anything
	gPhone.phoneBase:SetSize( oldPWide*2, oldPHeight*2 )
	gPhone.phoneScreen:SetSize( oldSWide*2, oldSHeight*2 )
	
	gPhone.phoneBase.Think = function()
		-- Rotate
		local rot = Lerp( 1, gPhone.Rotation, 90 )
		gPhone.Rotation = rot
		
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
	
	gPhone.IsInAnimation = false
	gPhone.IsPortrait = false
end

--// Rotate the phone back to portrait
function gPhone.RotateToPortrait()
	if gPhone.IsPortrait then return end
	
	local oldThink = gPhone.phoneBase.Think
	gPhone.IsInAnimation = true
	-- Expand so the phone can rotate without cutting off anything
	gPhone.phoneBase:SetSize( oldPWide*2, oldPHeight*2 )
	gPhone.phoneScreen:SetSize( oldSWide*2, oldSHeight*2 )
	
	gPhone.phoneBase.Think = function()
		-- Rotate
		local rot = Lerp( 1, gPhone.Rotation, 0 )
		gPhone.Rotation = rot
		
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
	
	gPhone.IsInAnimation = false
	gPhone.IsPortrait = true
end

--// Vibrate the phone if its in its passive state
function gPhone.Vibrate()
	if not gPhone.PhoneActive and IsValid( gPhone.phoneBase ) then
		if gPhone.IsInAnimation then return end
		gPhone.IsInAnimation = true
		
		-- Holy variables Batman!
		local oldThink = gPhone.phoneBase.Think
		local oldX, oldY = gPhone.phoneBase:GetPos()
		local oldPWide, oldPHeight = gPhone.phoneBase:GetSize()
		
		local degreeDistance = 5 -- How far (in degrees) the phone will turn while vibrating
		
		local final = -degreeDistance
		local y = oldY
		local shouldVibrate = true
		local shouldBeExtended = true
		local moveToPos = oldY - 30
		
		gPhone.Config.PhoneColor.a = 255
		surface.PlaySound( "gphone/vibrate.wav" )
		
		-- Think function to do our animations in
		gPhone.phoneBase.Think = function()
			if not IsValid( gPhone.phoneBase ) then -- Kill the function
				gPhone.phoneBase.Think = oldThink
			end
			
			if shouldVibrate then
				gPhone.phoneScreen:SetVisible(false)
				gPhone.phoneBase:SetSize( oldPWide * 1.5, oldPHeight * 1.5 )
				
				local rot = gPhone.Rotation
				
				if rot == final then
					if final == -degreeDistance then
						final = degreeDistance
					elseif final == degreeDistance then
						final = -degreeDistance
					end
				end
				
				rot = math.Approach( rot, final, 300 * RealFrameTime() )
				rot = math.Clamp( rot, -degreeDistance, degreeDistance )

				gPhone.Rotation = rot
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
			gPhone.Config.PhoneColor.a = 100
			timer.Simple(0.5, function() -- Stop vibrating and reset everything
				shouldVibrate = false
				
				gPhone.phoneScreen:SetVisible(true)
		
				gPhone.phoneBase:SetSize( oldPWide, oldPHeight )
				gPhone.phoneBase:SetPos( oldX, oldY )
				gPhone.phoneBase.Think = oldThink 
				
				gPhone.IsInAnimation = false
			end)
		end)
	end
end

--// 'Booting' animation for when the player first opens their phone
function gPhone.BootUp()
	local screen = gPhone.phoneScreen
	gPhone.IsInAnimation = true
	
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
			gPhone.IsInAnimation = false
			
			gPhone.Unlock()
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
function gPhone.UnlockLockScreen( callback )
	if not IsValid(lockTime) or not IsValid(slideUnlock) then return end
	
	local screen = gPhone.phoneScreen
	local x, y = screen:GetPos()
	gPhone.IsInAnimation = true
	
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
		gPhone.ShowStatusBar()
		
		if IsValid( callback ) then
			callback()
		end
		
		gPhone.IsInAnimation = false
	end)
end

--// Build the actual lock screen with all the info
-- Set 'gPhone.ShouldUnlock' to false to cancel the default timed unlock
function gPhone.BuildLockScreen()
	local screen = gPhone.phoneScreen
	
	-- Hide the default home screen
	oldScreen = gPhone.phoneScreen.Paint
	for k, v in pairs(gPhone.phoneScreen:GetChildren()) do
		v:SetVisible(false)
	end
	gPhone.ShowStatusBar()
	gPhone.HideStatusBarElement( "time" )
	
	gPhone.phoneScreen.Paint = function( self )
		surface.SetMaterial( gPhone.GetWallpaper( false, true ) ) 
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
	
	timer.Simple(gPhone.Config.OpenLockDelay, function()
		if gPhone.ShouldUnlock then 
			print("Unlock") 
			gPhone.UnlockLockScreen()
		end
	end)
end

--[[
	// Plan for passive //
1. Vibrate phone
2. On open, cancel the default timed unlock
3. Create a Derma panel with Accept/Deny buttons
4. On clicked, close the notification and finish the unlocking
5. Jump to app if Accepted

]]

function gPhone.Notification( text, otherStuff )
	gPhone.ShouldUnlock = false
	
	print("Create notification", text)
	
	--PrintTable(arg)
	
	--[[
	if accepted then
		gPhone.UnlockLockScreen( function()
			gPhone.RunApp( otherStuff.game )
		end)
	end
	
	if denied then
		gPhone.UnlockLockScreen()
	end
	
	gPhone.ShouldUnlock = true
	]]
end