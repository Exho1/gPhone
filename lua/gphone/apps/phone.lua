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
				surface.SetDrawColor( Color(218,165,32) )
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
	local connectedNumbers = gPhone.getPhoneNumbers()
	PrintTable(connectedNumbers)

	if connectedNumbers[number] then
		print("Online")
		net.Start("gPhone_DataTransfer")
			net.WriteTable({header=GPHONE_START_CALL, number=number})
		net.SendToServer()
		
		-- I need a screen here for the call
	else
		gPhone.msgC( GPHONE_MSGC_WARNING, number.." is not tied to an online player!" )
	end
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), gPhone.colors.whiteBG)
end

gPhone.addApp(APP)