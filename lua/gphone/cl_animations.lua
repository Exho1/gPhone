----// Clientside Animations //----

--// Leave the current app and go to the home screen
function gPhone.ToHomeScreen()
	if not gPhone.IsPortrait then
		gPhone.RotateToPortrait()
	end
	
	gPhone.AppBase["_close_"]()
	gPhone.IsOnHomeScreen = false
end

--// Rotate the phone to a landscape position
local oldPWide, oldPHeight, oldSWide, oldSHeight = nil
function gPhone.RotateToLandscape()
	gPhone.IsInAnimation = true
	
	-- Save old values
	oldPWide, oldPHeight = gPhone.phoneBase:GetSize()
	oldSWide, oldSHeight = gPhone.phoneScreen:GetSize()
	
	-- Expand so the phone can rotate without cutting off anything
	gPhone.phoneBase:SetSize( oldPWide*2, oldPHeight*2 )
	gPhone.phoneScreen:SetSize( oldSWide*2, oldSHeight*2 )
	
	-- Rotate
	local rot = Lerp( 1, gPhone.Rotation, 90 )
	gPhone.Rotation = rot
	
	-- Adjust sizes and positions for landscape, switch the values from what they originally were
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
	gPhone.IsInAnimation = true
	-- Expand so the phone can rotate without cutting off anything
	gPhone.phoneBase:SetSize( oldPWide*2, oldPHeight*2 )
	gPhone.phoneScreen:SetSize( oldSWide*2, oldSHeight*2 )
	
	-- Rotate
	local rot = Lerp( 1, gPhone.Rotation, 0 )
	gPhone.Rotation = rot
	
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
		-- Holy variables Batman!
		local oldThink = gPhone.phoneBase.Think
		local oldX, oldY = gPhone.phoneBase:GetPos()
		local final = -15
		local y = oldY
		local shouldVibrate = true
		local shouldBeExtended = true
		local moveToPos = oldY - 30
		
		-- Think function to do our animations in
		gPhone.phoneBase.Think = function()
			if not IsValid( gPhone.phoneBase ) then -- Kill the function
				gPhone.phoneBase.Think = function() end 
			end
			
			if shouldVibrate then
				local rot = gPhone.Rotation
				
				if rot == final then
					if final == -15 then
						final = 15
					elseif final == 15 then
						final = -15
					end
				end
				
				rot = math.Approach( rot, final, 2 )
				rot = math.Clamp( rot, -15, 15 )

				gPhone.Rotation = rot
			end
			
			if shouldBeExtended then
				y = math.Approach( y, moveToPos, 2 )
				--y = math.Clamp( y, oldY, oldY + 20 )
			else
				y = math.Approach( y, ScrH() - 40, 2 )
				--y = math.Clamp( y, oldY, oldY + 20 )
			end
			gPhone.phoneBase:SetPos( oldX, y )
		end
		
		timer.Simple(1, function() -- Fix the phone's angles and retract
			final = 0 
			shouldBeExtended = false
			timer.Simple(0.5, function() -- Stop vibrating and kill the function
				shouldVibrate = false
				gPhone.phoneBase.Think = oldThink 
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

function gPhone.Unlock()
	local screen = gPhone.phoneScreen
	if gPhone.IsInAnimation then return end
	gPhone.IsInAnimation = true
	
	-- Hide the default home screen
	local oldScreen = gPhone.phoneScreen.Paint
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
	
	local lockTime = vgui.Create( "DLabel", screen )
	lockTime:SetText( os.date("%I:%M") )
	lockTime:SetFont("gPhone_LockTime")
	lockTime:SizeToContents()
	lockTime:SetPos( screen:GetWide()/2 - lockTime:GetWide()/2, 15 )
	lockTime.Think = function()
		lockTime:SetText(os.date("%I:%M"))
		lockTime:SetFont("gPhone_LockTime")
		lockTime:SizeToContents()
	end
	
	local dateLabel = vgui.Create( "DLabel", screen )
	dateLabel:SetText( os.date("%A, %B %d") )
	dateLabel:SetFont("gPhone_TitleLite")
	dateLabel:SizeToContents()
	dateLabel:SetPos( screen:GetWide()/2 - dateLabel:GetWide()/2, 70 )
	
	local slideUnlock = vgui.Create( "DLabel", screen )
	slideUnlock:SetText( "slide to unlock" )
	slideUnlock:SetFont("gPhone_TitleLite")
	slideUnlock:SizeToContents()
	slideUnlock:SetPos( screen:GetWide()/2 - slideUnlock:GetWide()/2, screen:GetTall() - slideUnlock:GetTall() - 50 )
	
	local x, y = screen:GetPos()
	local lX, lY = lockTime:GetPos()
	local dX, dY = dateLabel:GetPos()
	local sX, sY = slideUnlock:GetPos()
	
	local arrow = vgui.Create( "DImage", screen )
	arrow:SetSize( 8, 16 )
	arrow:SetImage( "vgui/gphone/right_arrow.png" )
	arrow.Think = function()
		sX, sY = slideUnlock:GetPos()
		arrow:SetPos( sX - 16, sY + 2)
	end
	
	lockTime:MoveTo( x + screen:GetWide() + 50, lY, 0.5, gPhone.Config.OpenLockDelay, 3)
	dateLabel:MoveTo( x + screen:GetWide() + 50, dY, 0.5, gPhone.Config.OpenLockDelay, 3)
	slideUnlock:MoveTo( x + screen:GetWide() + 50, sY, 0.5, gPhone.Config.OpenLockDelay, 3, function()
		gPhone.phoneScreen.Paint = oldScreen
		
		arrow:Remove()
		lockTime:Remove()
		dateLabel:Remove()
		slideUnlock:Remove()
		
		for k, v in pairs(gPhone.phoneScreen:GetChildren()) do
			v:SetVisible(true)
		end
		gPhone.ShowStatusBar()
		
		gPhone.IsInAnimation = false
	end)
end