local APP = {}

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

	APP.CreateKeypad()
end

function APP.CreateKeypad()
	local objects = gApp["_children_"]
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
				--draw.RoundedBox(10, 0, 0, w, h, color_black)
				surface.SetDrawColor( Color(218,165,32) ) -- TEMP: Need either a netural color or wallpaper
				surface.SetMaterial( matCircle ) 
				surface.DrawTexturedRect( 0, 0, w, h )
			end
			numButton.DoClick = function( self )
				editNumber( num )
			end
		elseif num == "_PHONE_" then
			local numButton = vgui.Create("DButton", buttonBG)
			numButton:SetSize( 50, 50 )
			numButton:SetPos( 15 + xBuffer, 15 + yBuffer )
			numButton:SetText( "" )
			numButton:SetColor( color_white )
			local matPhone = Material( "vgui/gphone/phone_icon.png" )
			local matCircle = Material("vgui/gphone/circle_filled.png")
			numButton.Paint = function( self, w, h )
				--draw.RoundedBox(10, 0, 0, w, h, color_black)
				surface.SetDrawColor( gPhone.colors.green )
				surface.SetMaterial( matCircle ) 
				surface.DrawTexturedRect( 0, 0, w, h )
				
				surface.SetDrawColor( color_white )
				surface.SetMaterial( matPhone ) 
				surface.DrawTexturedRect( 5, 5, w-10, h-10 )
			end
			numButton.DoClick = function( self )
				APP.StartCall( numberText:GetText() )
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
	PrintTable(connectedNumbers)

	if connectedNumbers[number] then
		print("Online")
		net.Start("gPhone_DataTransfer")
			net.WriteTable({header=GPHONE_START_CALL, number=number})
		net.SendToServer()
		
		local function createCallScreen( timeStarted )
			LocalPlayer():ConCommand("+voicerecord")
			
			local buttons = {
				"mute",
				"keypad",
				"speaker",
				"_SPACE_",
				"add",
			}
			
			gPhone.hideChildren( objects.layout )
				
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
					local matIcon = Material("vgui/gphone/i_"..name..".png")
					local matSecondIcon = nil
					
					if name == "mute" then
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
						
						if name == "mute" then
							if self.bool == false then
								LocalPlayer():ConCommand("+voicerecord")
								numButton.text = "mute"
							else
								LocalPlayer():ConCommand("-voicerecord")
								numButton.text = "unmute"
							end
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
			endCall:SetText( "End Call" )
			endCall:SetTextColor( color_white )
			endCall:SetFont("gPhone_24")
			endCall.Paint = function( self, w, h )
				draw.RoundedBox( 3, 0, 0, w, h, gPhone.colors.softRed )
			end
			endCall.DoClick = function( self ) 
				APP.EndCall()
			end
		end
		
		-- Wait until we have entered the call to enter the calling screen
		hook.Add("Think", "gPhone_callWait", function()
			if LocalPlayer():inCall() then
				createCallScreen( CurTime() )
				hook.Remove("Think", "gPhone_callWait")
			end
		end)
	else
		gPhone.msgC( GPHONE_MSGC_WARNING, number.." is not tied to an online player!" )
	end
end

function APP.EndCall( bAppClose )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	LocalPlayer():ConCommand("-voicerecord")
	
	net.Start("gPhone_DataTransfer")
		net.WriteTable({header=GPHONE_END_CALL})
	net.SendToServer()
	
	if not bAppClose then
		gPhone.hideChildren( objects.layout )
		
		APP.Run( objects, screen )
	end
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), gPhone.colors.whiteBG)
end

function APP.Close()
	APP.EndCall( true )
end


gPhone.addApp(APP)