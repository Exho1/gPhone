local APP = {}
local trans = gPhone.getTranslation

APP.PrintName = "Phone"
APP.Icon = "vgui/gphone/phone.png"
APP.Author = "Exho"
APP.Tags = {"Calling", "Contact", "Communication"}

function APP.Run( objects, screen )
	gPhone.darkenStatusBar()
	
	local offset = 20 -- A little trick to push the scrollbar off the screen
	objects.layoutScroll = vgui.Create( "DScrollPanel", screen )
	objects.layoutScroll:SetSize( screen:GetWide() + offset, screen:GetTall() - 15 )
	objects.layoutScroll:SetPos( 0, 15 )
	objects.layoutScroll.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, self:GetWide(), self:GetTall(), 0, Color(0, 235, 0))
	end
	
	objects.layout = vgui.Create( "DIconLayout", objects.layoutScroll )
	objects.layout:SetSize( screen:GetWide(), screen:GetTall() - 1 )
	objects.layout:SetPos( 0, 1 )
	objects.layout:SetSpaceY( 0 )

	APP.CreateKeypad( objects )
	
	-- Throws the player into a call if the server says they are in one
	hook.Add("Think", "gPhone_callWait", function()
		if LocalPlayer():inCall() then
			gPhone.msgC( GPHONE_MSGC_NOTIFY, "Now in call, opening call screen")
			APP.OpenCallScreen( LocalPlayer():GetNWString("gPhone_CallingNumber"), CurTime() )
			hook.Remove("Think", "gPhone_callWait")
		end
	end)
end

function APP.CreateKeypad( objects )
	local screen = gPhone.phoneScreen

	local buttons = {}
	
	for i = 1, 9 do
		table.insert(buttons, i)
	end
	table.insert(buttons, "*")
	table.insert(buttons, 0)
	table.insert(buttons, "##")
	table.insert(buttons, "_SPACE_")
	table.insert(buttons, "_PHONE_")
	table.insert(buttons, "_SPACE_")
	
	local buttonBG = objects.layout:Add("DPanel")
	buttonBG:SetSize( objects.layout:GetWide(), objects.layout:GetTall() )
	buttonBG.Paint = function( self, w, h )
		--draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.red)
	end
	
	local sizeLabel = vgui.Create( "DLabel", buttonBG )
	sizeLabel:SetText( "" )
	sizeLabel:SetFont("gPhone_36")
	sizeLabel:SizeToContents()
	sizeLabel:SetVisible( false )
	sizeLabel:SetPos( buttonBG:GetWide()/2 - sizeLabel:GetWide()/2, 15 )
	
	local numberText = vgui.Create( "DTextEntry", buttonBG )
	numberText:SetText( "" )
	numberText:SetFont( "gPhone_36" )
	numberText:SetSize( buttonBG:GetWide() / 1.5, sizeLabel:GetTall() )
	numberText:SetPos( 0, 15 ) 
	numberText:SetTextColor( color_black )
	numberText:SetDrawBorder( false )
	numberText:SetDrawBackground( false )
	numberText:SetCursorColor( color_black )
	numberText:SetHighlightColor( Color(27,161,226) )
	numberText:SetZPos(-5)
	
	local function editNumber( text, bErase )
		local txt = numberText:GetText()
		local newText = txt..text
		
		if string.len( newText ) > 9 then
			return
		end
		
		if bErase then
			newText = string.sub( newText, 1, string.len(newText) - 1 )
		end
		
		-- Put a dash in the number
		if string.len( newText ) > 4 then
			local frags = string.Explode( "", newText )
			if frags[5] != "-" then
				table.insert(frags, 5, "-")
			end
			newText = table.concat( frags, "" )
		end
		
		gPhone.setTextAndCenter( sizeLabel, newText, buttonBG )
		
		local w, h = gPhone.getTextSize( sizeLabel:GetText(), numberText:GetFont() )
		
		numberText:SetText( newText )
		numberText:SetPos( sizeLabel:GetPos() )
	end

	
	local xBuffer, yBuffer, buttonCount = 10, 40, 0
	for _, num in pairs( buttons ) do
		if num != "_SPACE_" and num != "_PHONE_" then
			
			local numButton = vgui.Create("DButton", buttonBG)
			numButton:SetSize( 50, 50 )
			numButton:SetPos( 15 + xBuffer, 15 + yBuffer )
			numButton:SetText( num )
			numButton:SetFont("gPhone_24")
			numButton:SetColor( color_black )
			local matCircle = Material("vgui/gphone/circle.png")
			numButton.Paint = function( self, w, h )
				surface.SetDrawColor( Color(218,165,32) ) -- TEMP: Need either a netural color or wallpaper
				surface.SetMaterial( matCircle ) 
				surface.DrawTexturedRect( 0, 0, w, h )
			end
			numButton.DoClick = function( self )
				editNumber( num )
			end
		elseif num == "_PHONE_" then
			APP.NextCall = 0
			
			local callButton = vgui.Create("DButton", buttonBG)
			callButton:SetSize( 50, 50 )
			callButton:SetPos( 15 + xBuffer, 15 + yBuffer )
			callButton:SetText( "" )
			callButton:SetColor( color_white )
			local matPhone = Material( "vgui/gphone/phone_icon.png" )
			local matCircle = Material("vgui/gphone/circle_filled.png")
			callButton.Paint = function( self, w, h )
				--draw.RoundedBox(10, 0, 0, w, h, color_black)
				surface.SetDrawColor( gPhone.colors.green )
				surface.SetMaterial( matCircle ) 
				surface.DrawTexturedRect( 0, 0, w, h )
				
				surface.SetDrawColor( color_white )
				surface.SetMaterial( matPhone ) 
				surface.DrawTexturedRect( 5, 5, w-10, h-10 )
			end
			callButton.DoClick = function( self )
				if CurTime() > APP.NextCall then
					-- Start the call
					APP.StartCall( numberText:GetText() )
					APP.NextCall = CurTime() + 1
				end
			end
		end
		
		buttonCount = buttonCount + 1
		if buttonCount % 3 == 0 then
			xBuffer = 10
			yBuffer = yBuffer + 50 + 15
		else
			xBuffer = xBuffer + 50 + 15
			yBuffer = yBuffer
		end
	end
	
	local backButton = vgui.Create("DImageButton", buttonBG)
	backButton:SetSize( 16, 16 )
	backButton:SetPos( buttonBG:GetWide() - backButton:GetTall() - 15, backButton:GetTall() + 10 )
	backButton:SetColor( gPhone.colors.blue )
	backButton:SetImage("vgui/gphone/backspace.png")
	backButton:SetZPos(5)
	backButton.DoClick = function( self )
		editNumber( "", true )
	end
end

function APP.StartCall( number )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	local connectedNumbers = gPhone.getPhoneNumbers()
	local ply = gPhone.getPlayerByNumber( number )

	-- Comment out to enable self calling
	if ply == LocalPlayer() then
		gPhone.msgC( GPHONE_MSGC_WARNING, number.." is tied to local player")
		
		gPhone.notifyAlert( {msg=trans("invalid_player_phone"),
		title=trans("error"), options={trans("okay")}}, 
		nil, nil, true, true )
		return
	end
	
	if connectedNumbers[number] and IsValid(ply) then
		gPhone.msgC( GPHONE_MSGC_NONE, number.." is tied to an online player! Calling..")
		
		-- Send the request to the server
		net.Start("gPhone_Call")
			net.WriteString(number)
		net.SendToServer()
		
		APP.NextCall = CurTime() + 5
	else
		gPhone.msgC( GPHONE_MSGC_WARNING, number.." is not tied to an online player!" )
		
		gPhone.notifyAlert( {msg=trans("invalid_player_phone"),
		title=trans("error"), options={trans("okay")}}, 
		nil, nil, true, true )
		return
	end
	
	APP.OpenWaitScreen()
end

function APP.OpenWaitScreen()
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	gPhone.hideChildren( objects.layout )
	
	objects.connecting = vgui.Create("DLabel", screen)
	objects.connecting:SetFont("gPhone_36")
	objects.connecting:SetTextColor( color_black )
	objects.connecting:SizeToContents()
	objects.connecting:SetPos( screen:GetWide()/2 - objects.connecting:GetWide()/2, screen:GetTall()/2 - objects.connecting:GetTall()/2 )
	local nextDot, dots = 0, ""
	objects.connecting.Think = function( self )
		-- Create a counting dot effect to make it seem like something is going on
		-- Technically there is as the server is checking that the other person accepted and creating the call lobby
		if CurTime() > nextDot then
			dots = dots.."."
			gPhone.setTextAndCenter(self, "Connecting"..dots, screen, true)
			nextDot = CurTime() + 0.3
			
			if string.find( dots, "[.][.][.]") then
				dots = ""
			end
		end
	end
end

function APP.OpenCallScreen( number, timeStarted )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	objects.connecting:Remove()
	gPhone.hideChildren( objects.layout )
	LocalPlayer():ConCommand("+voicerecord")
	
	hook.Add("Think", "gPhone_callScreenHandler", function()
		if not LocalPlayer():inCall() then
			gPhone.log("Phone call ended by other party")
			
			LocalPlayer():ConCommand("-voicerecord")
			gPhone.notifyBanner( {app="Phone", title=trans("phone"), msg=trans("hung_up_on")} )
			
			gPhone.removeAllPanels( objects )
			APP.Run( objects, screen )
			
			hook.Remove("Think", "gPhone_callScreenHandler")
		end
	end)
	
	local buttons = {
		trans("mute"):lower(),
		trans("keypad"):lower(),
		trans("speaker"):lower(),
		"_SPACE_",
		trans("add"):lower(),
	}
		
	local buttonBG = objects.layout:Add("DPanel")
	buttonBG:SetSize( objects.layout:GetWide(), objects.layout:GetTall() )
	buttonBG.Paint = function( self, w, h )
		surface.SetMaterial( gPhone.getWallpaper( true, true ) )  -- Draw the wallpaper
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
		
		-- Holy blur, these values are insane
		gPhone.drawPanelBlur( self, 50, 50, 255 )
	end
	
	local callingName = vgui.Create( "DLabel", buttonBG )
	callingName:SetText( gPhone.getPlayerByNumber( number ):Nick() )
	callingName:SetFont("gPhone_36")
	callingName:SizeToContents()
	callingName:SetTextColor(color_white)
	callingName:SetPos( buttonBG:GetWide()/2 - callingName:GetWide()/2, 25 )
	
	-- Handle this clientside: Set a time when the phone opens this screen and count
	local timeCalled = vgui.Create( "DLabel", buttonBG )
	timeCalled:SetText( gPhone.simpleTime(CurTime() - timeStarted, "%02i:%02i") )
	timeCalled:SetFont("gPhone_20")
	timeCalled:SizeToContents()
	timeCalled:SetTextColor(color_white)
	local _, y = callingName:GetPos()
	timeCalled:SetPos( buttonBG:GetWide()/2 - timeCalled:GetWide()/2, y + 35 )
	timeCalled.Think = function( self )
		timeCalled:SetText( gPhone.simpleTime(CurTime() - timeStarted, "%02i:%02i") )
	end
		
	local xBuffer, yBuffer, buttonCount = 10, screen:GetTall()/4, 0
	for _, name in pairs( buttons ) do
		if name != "_SPACE_" then
			local numButton = vgui.Create("DButton", buttonBG)
			numButton:SetSize( 50, 70 )
			numButton:SetPos( 15 + xBuffer, 15 + yBuffer )
			numButton:SetText( "" )
			numButton.text = name
			numButton.color = Color(230, 230, 230)
			numButton.bool = false
			local matCircle = Material("vgui/gphone/circle.png")
			local matIcon = Material("vgui/gphone/i_"..gPhone.getTranslationEN( name )..".png")
			local matSecondIcon = nil
			
			if name == buttons[1] then
				matSecondIcon = Material("vgui/gphone/i_speaker.png")
			end
			
			numButton.Paint = function( self, w, h )
				surface.SetDrawColor( numButton.color ) 
				surface.SetMaterial( matCircle ) 
				surface.DrawTexturedRect( 0, 0, w, h - 20 )
				
				draw.DrawText( self.text, "gPhone_16", w/2, h - 16, numButton.color, TEXT_ALIGN_CENTER )
				
				if matSecondIcon != nil and self.bool == true then
					surface.SetDrawColor( numButton.color )
					surface.SetMaterial( matSecondIcon ) 
					surface.DrawTexturedRect( 12, 12, w/1.8, h/1.8 - 12 )
				else
					surface.SetDrawColor( numButton.color )
					surface.SetMaterial( matIcon ) 
					surface.DrawTexturedRect( 12, 12, w/1.8, h/1.8 - 12 )
				end
				
				if not self:IsDown() then
					self.color = color_white
				else
					self.color = Color(150, 150, 150)
				end
				
				if self.bool == true and name == "speaker" then
					self.color = gPhone.colors.green
				end
			end
			numButton.DoClick = function( self )
				-- First click makes it true
				self.bool = !self.bool
				
				if name == buttons[1] then -- Mute
					if self.bool == false then
						LocalPlayer():ConCommand("+voicerecord")
						numButton.text = trans("mute"):lower()
					else
						LocalPlayer():ConCommand("-voicerecord")
						numButton.text = trans("unmute"):lower()
					end
				elseif name == buttons[2] then -- Keypad
					gPhone.chatMsg( trans("feature_deny") )
				elseif name == buttons[3] then -- Speaker
					gPhone.chatMsg( trans("feature_deny") )
				elseif name == buttons[5] then -- Add
					gPhone.chatMsg( trans("feature_deny") )
				end
			end
		end
		
		buttonCount = buttonCount + 1
		if buttonCount % 3 == 0 then
			xBuffer = 10
			yBuffer = yBuffer + 50 + 30
		else
			xBuffer = xBuffer + 50 + 15
			yBuffer = yBuffer
		end
	end
	
	local endCall = vgui.Create("DButton", buttonBG)
	endCall:SetSize( screen:GetWide() - 40, 50 )
	endCall:SetPos( 20, screen:GetTall() - endCall:GetTall() - 40 )
	endCall:SetText( trans("end_call") )
	endCall:SetTextColor( color_white )
	endCall:SetFont("gPhone_24")
	endCall.Paint = function( self, w, h )
		draw.RoundedBox( 3, 0, 0, w, h, gPhone.colors.softRed )
	end
	endCall.DoClick = function( self ) 
		APP.EndCall()
	end
end

function APP.EndCall( bAppClose )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	LocalPlayer():ConCommand("-voicerecord")
	
	net.Start("gPhone_Call")
		net.WriteString("end")
	net.SendToServer()
	
	gPhone.removeAllPanels( objects )
	
	if not bAppClose then
		APP.Run( objects, screen )
	end
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), gPhone.colors.whiteBG)
end

function APP.Close()
	hook.Remove("Think", "gPhone_callScreenHandler")
	APP.EndCall( true )
end


gPhone.addApp(APP)