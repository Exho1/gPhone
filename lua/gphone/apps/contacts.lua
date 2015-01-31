local APP = {}

APP.PrintName = "Contacts"
APP.Icon = "vgui/gphone/contacts.png"
APP.Tags = {"Contacts", "Lists", "Players"}

function APP.Run( objects, screen )
	
	gPhone.darkenStatusBar()
	
	objects.Title = vgui.Create( "DLabel", screen )
	objects.Title:SetText( "Contacts" )
	objects.Title:SetTextColor(Color(0,0,0))
	objects.Title:SetFont("gPhone_18Lite")
	objects.Title:SizeToContents()
	objects.Title:SetPos( screen:GetWide()/2 - objects.Title:GetWide()/2, 25 )
	
	local offset = 20 -- A little trick to push the scrollbar off the screen
	objects.LayoutScroll = vgui.Create( "DScrollPanel", screen )
	objects.LayoutScroll:SetSize( screen:GetWide() + offset, screen:GetTall() - 50 )
	objects.LayoutScroll:SetPos( 0, 80 )
	
	objects.Layout = vgui.Create( "DIconLayout", objects.LayoutScroll)
	objects.Layout:SetSize( screen:GetWide(), 0 )
	objects.Layout:SetPos( 0, 0 )
	objects.Layout:SetSpaceY( 0 )
	
	APP.ImportContacts( objects, objects.Layout )
end

function APP.ImportContacts( objects, layout )
	local screen = gPhone.phoneScreen	
	local contactList = {}
	local contactPanels = {}
	local categoryPanels = {}
	
	-- Create a table of online playeres
	for k, v in pairs(player.GetAll()) do
		table.insert(contactList, v:Nick())
	end
	table.sort(contactList)
	
	objects.SearchBar = vgui.Create("DTextEntry", screen)
	objects.SearchBar:SetSize(screen:GetWide(), 20)
	objects.SearchBar:SetPos(0, 50)
	objects.SearchBar:SetText( "Search" )
	objects.SearchBar:SetFont("gPhone_18")
	objects.SearchBar:SetSize( screen:GetWide(), 30 )
	objects.SearchBar.OnTextChanged = function( self )
		local needle = self:GetText():lower()
		
		-- Nothing in the search bar
		if needle == nil or needle == "" then
			for k, v in pairs( categoryPanels ) do
				v:SetVisible(true)
			end
			for k, v in pairs( contactPanels ) do
				v:SetVisible(true)
			end
			return 
		end
		
		-- Start searching
		for k, v in pairs( categoryPanels ) do
			v:SetVisible(false) -- Hide letter categories
		end
		for k, v in pairs( contactPanels ) do
			local haystack = v:GetChildren()[1]:GetText():lower() -- Get the button's label's text
			
			if string.find(haystack, needle) then
				v:SetVisible(true) -- This contact matches the search
			else
				v:SetVisible(false)
			end
		end
		layout:LayoutIcons_TOP() -- Layout the contact list
	end
	
	-- Populate the contact list
	local prevLetter = 0
	for k, nick in pairs(contactList) do
		local nickLetter = nick[1] -- Grab the first letter of the string
		
		if string.lower(nickLetter) != string.lower(prevLetter) then -- Create a new letter category
			prevLetter = nickLetter
			local key = string.lower(nickLetter)
			
			categoryPanels[key] = layout:Add("DPanel")
			categoryPanels[key]:SetSize(screen:GetWide(), 20)
			categoryPanels[key].Paint = function( self )
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(240, 240, 240))
				--draw.RoundedBox(0, 30, self:GetTall()-1, self:GetWide()-30, 1, gPhone.colors.greyAccent)
			end
			
			local letter = vgui.Create( "DLabel", categoryPanels[key] )
			letter:SetText( string.upper(prevLetter) )
			letter:SetTextColor( Color(0,0,0) )
			letter:SetFont("gPhone_18")
			letter:SizeToContents()
			letter:SetPos( 30, 0 )
		end
		
		APP.AddContact( layout, contactPanels, nick )
	end
end

function APP.AddContact( layout, pnlTable, nick )
	local screen = gPhone.phoneScreen
	
	pnlTable[nick] = layout:Add("DButton")
	pnlTable[nick]:SetSize(screen:GetWide(), 30)
	pnlTable[nick]:SetText("")
	pnlTable[nick].Paint = function( self )
		if not self:IsDown() then
			draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.whiteBG)
		else
			draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.darkWhiteBG)
		end
		
		draw.RoundedBox(0, 25, self:GetTall()-1, self:GetWide()-25, 1, gPhone.colors.greyAccent)
	end
	pnlTable[nick].DoClick = function()
		APP.ContactInfo( nick )
	end
	
	local contactName = vgui.Create( "DLabel", pnlTable[nick] )
	contactName:SetText( nick )
	contactName:SetTextColor(Color(0,0,0))
	contactName:SetFont("gPhone_18")
	contactName:SizeToContents()
	local w, h = contactName:GetSize()
	contactName:SetSize( screen:GetWide() - 35, h)
	contactName:SetPos( 30, 5 )
end

function APP.ContactInfo( name )
	local ply = util.getPlayerByNick( name )
	if not IsValid(ply) then return end
	
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	local layout = objects.Layout
	
	for k, v in pairs(objects.Layout:GetChildren()) do
		v:SetVisible(false)
	end
	objects.SearchBar:SetVisible(false)
	objects.LayoutScroll:SetPos( 0, 50 )
	
	local tX, tY = objects.Title:GetPos()
	
	objects.Back = vgui.Create("DButton", screen)
	objects.Back:SetText("Back")
	objects.Back:SetFont("gPhone_18Lite")
	objects.Back:SetTextColor( gPhone.colors.blue )
	objects.Back:SetPos( 10, tY )
	objects.Back.Paint = function() end
	objects.Back:SetSize( gPhone.getTextSize("Back", "gPhone_18Lite") )
	objects.Back.DoClick = function()
		objects.Back:Remove()
		
		objects.LayoutScroll:SetPos( 0, 80 )
		objects.SearchBar:SetVisible(true)
		for k, pnl in pairs(objects.Layout:GetChildren()) do
			if pnl:IsVisible() then
				pnl:Remove()
			else
				pnl:SetVisible(true)
			end
		end
	end
	
	local titlePanel = layout:Add("DPanel")
	titlePanel:SetSize(screen:GetWide(), 70)
	titlePanel.Paint = function( self )
		draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.whiteBG)
		draw.RoundedBox(0, 0, 1, self:GetWide(), 1, Color(20, 40, 40))
	end
	
	local contactAvatar = vgui.Create("AvatarImage", titlePanel)
	contactAvatar:SetPos( 10, 10 )
	contactAvatar:SetSize( 50, 50 )
	contactAvatar:SetPlayer( ply, 64 )
	
	local contactName = vgui.Create( "DLabel", titlePanel )
	contactName:SetText( name )
	contactName:SetTextColor(Color(0,0,0))
	contactName:SetFont("gPhone_18")
	contactName:SizeToContents()
	contactName:SetPos( 70, 25 )
	
	local numberPanel = layout:Add("DPanel")
	numberPanel:SetSize(screen:GetWide(), 50)
	numberPanel.Paint = function( self )
		draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.whiteBG)
	end
	
	local text = vgui.Create( "DLabel", numberPanel )
	text:SetText( "Number" )
	text:SetTextColor( gPhone.colors.blue )
	text:SetFont("gPhone_14")
	text:SizeToContents()
	text:SetPos( 10, 10 )
	
	local number = ply:getPhoneNumber()
	local contactNumber = vgui.Create( "DTextEntry", numberPanel )
	contactNumber:SetText( ply:getPhoneNumber() )
	contactNumber:SetTextColor(Color(0,0,0))
	contactNumber:SetFont("gPhone_18")
	local w, h = gPhone.getTextSize( number, "gPhone_18" )
	contactNumber:SetSize( w + 15, h )
	contactNumber:SetPos( 15, 25 )
	
	-- Make it look like a label and not be editable
	contactNumber:SetDrawBackground(false)
	contactNumber:SetDrawBorder(false)
	contactNumber.OnTextChanged = function( self )
		self:SetText( number )
	end
	
	local textContact = vgui.Create( "DImageButton", numberPanel ) 
	textContact:SetSize( 24, 24 )
	textContact:SetPos( numberPanel:GetWide() - textContact:GetWide() - 15, 10 )
	textContact:SetImage( "vgui/gphone/text.png"  )	
	textContact:SetColor( gPhone.colors.blue )
	textContact.DoClick = function()
		gPhone.toHomeScreen()
		gPhone.switchApps( "messages" )
	end
	
	local callContact = vgui.Create( "DImageButton", numberPanel ) 
	callContact:SetSize( 24, 24 )
	callContact:SetPos( numberPanel:GetWide() - callContact:GetWide() - textContact:GetWide() - 20, 10 )
	callContact:SetImage( "vgui/gphone/phone.png"  )		
	callContact:SetColor( gPhone.colors.blue )
	callContact.DoClick = function()
		gPhone.toHomeScreen()
		gPhone.switchApps( "phone" )
	end
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), Color(200, 200, 200))
		
	draw.RoundedBox(2, 0, 0, screen:GetWide(), 50, gPhone.colors.whiteBG)
	draw.RoundedBox(0, 0, 50, screen:GetWide(), 1, Color(20, 40, 40))
end

gPhone.addApp(APP)