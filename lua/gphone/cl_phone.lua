----// Clientside Phone //----

local client = LocalPlayer()
local phone = Material( "vgui/gphone/gphone.png" )
local firstTimeUsed = CreateClientConVar("gphone_firsttime", "1", true, true)	

--// Builds the phone 
function gPhone.BuildPhone()
	gPhone.LoadClientConfig()

	gPhone.Apps = {}
	gPhone.ImportApps()
	gPhone.SettingsTabs = {
		"General",
		"Wallpaper",
		"_SPACE_", -- Moves the next entry down one button height (not an actual tab)
		"Text",
		"Phone",
		"Contacts",
	}
	
	-- Dimensions
	local pWidth, pHeight = 300, 600 -- Phone
	local sWidth, sHeight = 234, 416 -- Screen
	local hWidth, hHeight = 45, 45 -- Home button
	
	gPhone.IsPortrait = true
	gPhone.Rotation = 0
	gPhone.IsInAnimation = false
	gPhone.ShouldUnlock = true
	
	-- Create the phone 
		gPhone.phoneBase = vgui.Create( "DFrame" )
	gPhone.phoneBase:SetSize( pWidth, pHeight )
	gPhone.phoneBase:SetPos( ScrW()-pWidth, ScrH() - 40 )
	gPhone.phoneBase:SetTitle( "" )
	gPhone.phoneBase:SetDraggable( true )  -- TEMPORARY
	gPhone.phoneBase:SetDeleteOnClose( true )
	gPhone.phoneBase:ShowCloseButton( false ) -- TEMPORARY
	gPhone.phoneBase.Paint = function( self, w, h)
		surface.SetDrawColor( gPhone.Config.PhoneColor )
		surface.SetMaterial( phone ) 
		--surface.DrawTexturedRect( 0, 0, pWidth, pHeight )
		surface.DrawTexturedRectRotated( self:GetWide()/2, self:GetTall()/2, pWidth, pHeight, gPhone.Rotation )
	end
	--gPhone.phoneBase.btnClose.DoClick = function ( button ) -- TEMPORARY
	--	gPhone.DestroyPhone()
	--end
	
	local phoneBase = gPhone.phoneBase
	local pX, pY = phoneBase:GetPos()
	gPhone.SetWallpaper( true, gPhone.Config.HomeWallpaper )
	gPhone.SetWallpaper( false, gPhone.Config.LockWallpaper )
	
		gPhone.phoneScreen = vgui.Create("DPanel", gPhone.phoneBase)
	gPhone.phoneScreen:SetPos( 31, 87 )
	gPhone.phoneScreen:SetSize( sWidth, sHeight ) 
	gPhone.phoneScreen.Paint = function( self )
		surface.SetMaterial( gPhone.GetWallpaper( true, true ) )  -- Draw the wallpaper
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
	end
	gPhone.phoneScreen.Think = function()
		if gPhone.Config.DarkenStatusBar == true then
			gPhone.DarkenStatusBar()
		end
	end
	
	local nextTimeUpdate = 0
	local phoneTime = vgui.Create( "DLabel", gPhone.phoneScreen )
	phoneTime:SetText( os.date("%I:%M %p") )
	phoneTime:SizeToContents()
	phoneTime:SetPos( sWidth/2 - phoneTime:GetWide()/2, 0 )
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
	batteryPercent:SetText( "100%" )
	batteryPercent:SizeToContents()
	batteryPercent:SetPos( sWidth - batteryPercent:GetWide() - 23, 0 )
	local nextPass, battPerc = CurTime() + math.random(30, 60), 100
	batteryPercent.Think = function()
		if CurTime() > nextPass then
			local dropPerc = math.random(1, 3)

			battPerc = battPerc - dropPerc
			batteryPercent:SetText( battPerc.."%" )
			batteryPercent:SetPos( sWidth - batteryPercent:GetWide() - 20, 0 )
			
			nextPass = CurTime() + math.random(60, 180)
		end
		
		if battPerc < math.random(1, 4) then -- Simulate a phone dying, its kinda silly and few people will ever see it
			gPhone.ChatMsg( "Your phone has run out of battery and died! Recharging..." )
			gPhone.HidePhone()
			timer.Simple(math.random(2, 5), function()
				gPhone.ChatMsg( "Phone recharged!" )
				gPhone.ShowPhone()
				battPerc = 100
			end)
		end
	end
	
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
		local batterySize = math.Clamp(battPerc * segments, 1, 11)
		
		-- Battery bar color
		if battPerc <= 20 then
			col = Color(200, 30, 30) 
		else
			col = batteryImage:GetImageColor() 
		end
		
		-- Draw the battery bar
		draw.RoundedBox( 0, 2, 2, batterySize, 4, col )
	end
	
	local serviceProvider = vgui.Create( "DLabel", gPhone.phoneScreen )
	serviceProvider:SetText( "Garry" )
	serviceProvider:SizeToContents()
	serviceProvider:SetPos( 5, 0 )
	
	gPhone.homeButton = vgui.Create( "DButton", gPhone.phoneBase )
	gPhone.homeButton:SetSize( hWidth, hHeight )
	gPhone.homeButton:SetPos( pWidth/2 - hWidth/2 - 3, pHeight - hHeight - 35 )
	gPhone.homeButton:SetText( "" )
	gPhone.homeButton.Paint = function() end
	gPhone.homeButton.DoClick = function()
		if gPhone.IsOnHomeScreen != true and gPhone.IsInAnimation != true then
			gPhone.ToHomeScreen()
		end
	end
	
	gPhone.StatusBar = { -- Gotta keep track of all the status bar elements
		["text"] = { battery=batteryPercent, network=serviceProvider, time=phoneTime },
		["image"] = { battery=batteryImage },
	}
	gPhone.StatusBarHeight = 15
	
	-- Homescreen icons
	local homeIcons = {}
	
	gPhone.HomeIconLayout = vgui.Create( "DPanel", gPhone.phoneScreen )
	gPhone.HomeIconLayout:SetSize( sWidth - 20, sHeight - 40 )
	gPhone.HomeIconLayout:SetPos( 10, 25 )
	gPhone.HomeIconLayout.Paint = function() end
	
	local xBuffer, yBuffer, iconCount = 0, 0, 1
	for name, mat in pairs(gPhone.Apps) do
		homeIcons[name] = vgui.Create( "DImageButton", gPhone.HomeIconLayout ) 
		homeIcons[name]:SetSize( 32, 32 )
		homeIcons[name]:SetPos( 10 + xBuffer, 10 + yBuffer )
		homeIcons[name]:SetImage( mat )		
		homeIcons[name].DoClick = function()
			gPhone.RunApp( string.lower(name) )
		end
		
		local x, y = xBuffer + 10, yBuffer + 50
		local iconLabel = vgui.Create( "DLabel", gPhone.HomeIconLayout )
		iconLabel:SetText( name )
		iconLabel:SetFont("gPhone_AppName")
		iconLabel:SizeToContents()
		iconLabel:SetPos( x + homeIcons[name]:GetWide()/2 - iconLabel:GetWide()/2, y )
	
		if iconCount % 4 == 0 then
			xBuffer = 0
			yBuffer = yBuffer + 75
		else
			xBuffer = xBuffer + 55
			yBuffer = yBuffer
		end
		iconCount = iconCount + 1
	end
	
	gPhone.PhoneExists = true
	gPhone.Config.PhoneColor.a = 100
end

--// Moves the phone up into visiblity
function gPhone.ShowPhone()
	if gPhone and gPhone.phoneBase then
		local pWidth, pHeight = gPhone.phoneBase:GetSize()
		gPhone.phoneBase:MoveTo( ScrW()-pWidth, ScrH()-pHeight, 0.7, 0, 2, function()
			gPhone.phoneBase:MakePopup()
		end)
		
		gPhone.Config.PhoneColor.a = 255
		
		if firstTimeUsed:GetBool() then
			gPhone.BootUp()
			LocalPlayer():ConCommand("gphone_firsttime 0")
		end
		
		gPhone.BuildLockScreen()
		
		gPhone.IsOnHomeScreen = true
		gPhone.PhoneActive = true
		
		-- Tell the server we are done and the phone is ready to be used
		net.Start("gPhone_DataTransfer")
			net.WriteTable({header=GPHONE_STATE_CHANGED, open=true})
		net.SendToServer()
	end
end

--// Moves the phone down and disables it
function gPhone.HidePhone()
	if gPhone and gPhone.phoneBase then
		local x, y = gPhone.phoneBase:GetPos()
		
		gPhone.phoneBase:SetMouseInputEnabled( false )
		gPhone.phoneBase:SetKeyboardInputEnabled( false )
		
		gPhone.phoneBase:MoveTo( x, ScrH()-40, 0.7, 0, 2, function()
			gPhone.Config.PhoneColor.a = 100 -- Fade the alpha
		end)
		
		gPhone.PhoneActive = false
		
		gApp.RemoveTickers()
		
		net.Start("gPhone_DataTransfer")
			net.WriteTable({header=GPHONE_STATE_CHANGED, open=false})
		net.SendToServer()
		
		net.Start("gPhone_DataTransfer")
			net.WriteTable({header=GPHONE_CUR_APP, app=nil})
		net.SendToServer()
	end
end

--// Completely removes the phone from the game
function gPhone.DestroyPhone()
	if gPhone and gPhone.phoneBase then
		gPhone.phoneBase:Close()
		gPhone.phoneBase = nil
		
		gPhone.PhoneActive = false
		gPhone.PhoneExists = false
		
		gApp.RemoveTickers()
		
		net.Start("gPhone_DataTransfer")
			net.WriteTable({header=GPHONE_STATE_CHANGED, open=false})
		net.SendToServer()
		
		net.Start("gPhone_DataTransfer")
			net.WriteTable({header=GPHONE_CUR_APP, app=nil})
		net.SendToServer()
	end
end

--// Receives a Server-side net message
net.Receive( "gPhone_DataTransfer", function( len, ply )
	local data = net.ReadTable()
	local header = data.header
	
	if header == GPHONE_BUILD then
		gPhone.BuildPhone()
	elseif header == GPHONE_NOTIFY_GAME then
		local sender = data.sender
		local game = data.text
		
		local msg = sender:Nick().." has invited you to play "..game
		
		if not gPhone.PhoneActive then
			gPhone.Vibrate()
			gPhone.Notification( msg, {game=game} )
		else
			gPhone.Notification( msg, {game=game} )
		end
	elseif header == GPHONE_RETURNAPP then
		local name, active = nil, gApp["_active_"]
		active = active or {}
		active.Data = active.Data or {}
		
		if active.Data.PrintName then
			name = active.Data.PrintName or nil
		end

		net.Start("gPhone_DataTransfer")
			net.WriteTable( {header=GPHONE_RETURNAPP, app=name} )
		net.SendToServer()
	elseif header == GPHONE_RUN_APPFUNC then
		local app = data.app
		local func = data.func
		local args = data.args
		
		if gApp[app:lower()] then
			app = app:lower()
			for k, v in pairs( gApp[app].Data ) do
				if k:lower() == func:lower() then
					gApp[app].Data[k]( unpack(args) )
					return
				end
			end
		end
		gPhone.MsgC( GPHONE_MSGC_WARNING, "Unable to run application function "..func.."!" )
	elseif header == GPHONE_RUN_FUNC then
		local func = data.func
		local args = data.args
		
		for k, v in pairs(gPhone) do
			if k:lower() == func:lower() and type(k) == "function" then
				gPhone[k]( unpack(args) )
				return
			end
		end
		
		gPhone.MsgC( GPHONE_MSGC_WARNING, "Unable to run phone function "..func.."!")
	else
	
	end
end)

--// Logic for opening the phone by holding down a key
local keyStartTime = 0
hook.Add( "Think", "gPhone_OpenAndCloseKey", function()
	if input.IsKeyDown( gPhone.Config.OpenKey ) then
		if keyStartTime == 0 then
			keyStartTime = CurTime()
		end
		
		if CurTime() - keyStartTime >= gPhone.Config.KeyHoldTime and not gPhone.IsInAnimation then
			if gPhone.PhoneActive != true then
				gPhone.ShowPhone()
			else
				gPhone.HidePhone()
			end
			
			keyStartTime = 0
		end
	else
		keyStartTime = 0
	end
end)
