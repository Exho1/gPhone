local APP = {}

APP.PrintName = "Messages"
APP.Icon = "vgui/gphone/messages.png"
APP.Author = "Exho"
APP.Tags = {"Messaging", "Contact", "Communication"}

function APP.Run( objects, screen )
	gPhone.darkenStatusBar()
	
	objects.Title = vgui.Create( "DLabel", screen )
	objects.Title:SetText( "Messages" )
	objects.Title:SetTextColor(Color(0,0,0))
	objects.Title:SetFont("gPhone_18Lite")
	objects.Title:SizeToContents()
	objects.Title:SetPos( screen:GetWide()/2 - objects.Title:GetWide()/2, 25 )
	
	local x, y = objects.Title:GetPos()
	
	objects.NewText = vgui.Create( "DImageButton", screen ) 
	objects.NewText:SetSize( 16, 16 )
	objects.NewText:SetPos( screen:GetWide() - objects.NewText:GetWide() - 10, y )
	objects.NewText:SetImage( "materials/vgui/gphone/writenew.png" )
	objects.NewText:SetColor( gPhone.colors.blue )
	objects.NewText.DoClick = function() 
		APP.NewConversation()
	end
	
	objects.Back = vgui.Create("gPhoneBackButton", screen)
	objects.Back:SetTextColor( gPhone.colors.blue )
	objects.Back:SetPos( 10, y )
	objects.Back:SetVisible( false ) -- We dont need this right now
	
	local offset = 20 -- A little trick to push the scrollbar off the screen
	objects.LayoutScroll = vgui.Create( "DScrollPanel", screen )
	objects.LayoutScroll:SetSize( screen:GetWide() + offset, screen:GetTall() - 50 )
	objects.LayoutScroll:SetPos( 0, 50 )
	objects.LayoutScroll.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, self:GetWide(), self:GetTall(), 0, Color(0, 235, 0))
	end
	
	objects.Layout = vgui.Create( "DIconLayout", objects.LayoutScroll )
	objects.Layout:SetSize( screen:GetWide(), screen:GetTall() - 1 )
	objects.Layout:SetPos( 0, 1 )
	objects.Layout:SetSpaceY( 0 )
	
	APP.PopulateMain( objects.Layout )
end

--// Create the main menu with previews of all open conversations
local messageTable = {}
function APP.PopulateMain( layout )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	local curDate = os.date( "%x" ) -- 01/10/15
	local curTime = os.date( "%I:%M%p" )  -- 9:34am
	
	messageTable = gPhone.loadTextMessages()
	
	for id, tbl in pairs( messageTable ) do
		local isPlayerOnline -- Can't message offline players, yet.
		
		local backbackground = layout:Add("DPanel")
		backbackground:SetSize(screen:GetWide(), 50)
		backbackground.Paint = function() end
		
		local deleteOffset = 50
		local deleteConvo = vgui.Create( "DButton", backbackground )
		deleteConvo:SetSize(deleteOffset, deleteOffset)
		deleteConvo:SetPos(backbackground:GetWide()-deleteOffset,0)
		deleteConvo:SetText("Delete")
		deleteConvo:SetFont("gPhone_18lite")
		deleteConvo:SetColor( color_white )
		deleteConvo:SetVisible(false)
		deleteConvo.Paint = function( self, w, h )
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.red)
		end
		deleteConvo.DoClick = function( self )
			-- Deletes the conversation from the phone, this CANNOT be undone
			backbackground:Remove()
			local fmat = gPhone.steamIDToFormat( id )
			gPhone.discardFile( "gphone/messages/"..fmat..".txt" )
			--file.Delete( "gphone/messages/"..fmat..".txt" )
			layout:LayoutIcons_TOP()
		end
		
		local background = vgui.Create("DButton", backbackground )
		background:SetSize(screen:GetWide(), 50)
		background:SetText("")
		background.Paint = function( self )
			if not self:IsDown() and isPlayerOnline then -- Normal
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.whiteBG)
			elseif isPlayerOnline then -- Held
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.darkWhiteBG)
			else -- Player offline
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(210, 210, 210))
			end
			
			draw.RoundedBox(0, 25, self:GetTall()-1, self:GetWide()-25, 1, gPhone.colors.greyAccent)
		end
		background.DoClick = function( self )
			local x, y = self:ScreenToLocal( gui.MouseX(), gui.MouseY() )
			
			if x >= self:GetWide() - (deleteOffset - 10) and not background.DeleteMode  then
				local bX, bY = background:GetPos()
				background:MoveTo( bX - deleteOffset, bY, 0.5, 0, -1 )
				background.DeleteMode = true
				deleteConvo:SetVisible(true)
				return
			elseif background.DeleteMode then
				local bX, bY = background:GetPos()
				background:MoveTo( bX + deleteOffset, bY, 0.5, 0, -1, function() deleteConvo:SetVisible(false) end)
				background.DeleteMode = false
				return
			end
			
			if isPlayerOnline then
				gPhone.hideChildren( layout )
				APP.PopulateMessages( id )
			end
		end
		
		local senderNick
		if IsValid( util.getPlayerByID( id ) ) then
			isPlayerOnline = true
			senderNick = util.getPlayerByID( id ):Nick()
		else
			isPlayerOnline = false
			background:SetCursor("arrow")
			senderNick = gPhone.steamIDToPhoneNumber( id )
		end
		
		local senderName = vgui.Create( "DLabel", background )
		senderName:SetText( senderNick )
		senderName:SetTextColor(Color(0,0,0))
		senderName:SetFont("gPhone_18")
		senderName:SizeToContents()
		local w, h = senderName:GetSize()
		senderName:SetSize( screen:GetWide() - 35, h)
		senderName:SetPos( 25, 2 )
		
		-- Create a time or date stamp 
		local dateStamp = tbl[#tbl].date
		local timeStamp = tbl[#tbl].time
		if curDate != dateStamp then
			local dateFrags = string.Explode( "/", curDate )
			local stampFrags = string.Explode( "/", dateStamp )
			
			if dateFrags[3] != stampFrags[3] then -- Different year
				local yearDif = tonumber(dateFrags[3]) - tonumber(stampFrags[3]) 
				if yearDif == 1 then
					timeStamp = "Last Year"
				else -- Ha, like this will ever happen.
					timeStamp = yearDif.." Years Ago"
				end
			end
			
			if dateFrags[1] == stampFrags[1] then -- Same month
				local dayDif = tonumber(dateFrags[2]) - tonumber(stampFrags[2]) 
				if dayDif == 1 then
					timeStamp = "Yesterday"
				elseif dayDif <= 7 then
					timeStamp = dayDif.." Days Ago"
				else
					timeStamp = dateStamp
				end
			else
				timeStamp = dateStamp
			end
		end
		
		local lastTime = vgui.Create( "DLabel", background )
		lastTime:SetText( timeStamp )
		lastTime:SetTextColor(Color(90,90,90))
		lastTime:SetFont("gPhone_14")
		lastTime:SizeToContents()
		lastTime:SetPos( background:GetWide() - lastTime:GetWide() - 5, 3 )
		
		local lastMsg = vgui.Create( "DLabel", background )
		lastMsg:SetText( tbl[#tbl].message )
		lastMsg:SetTextColor(Color(90,90,90))
		lastMsg:SetFont("gPhone_14")
		lastMsg:SizeToContents()
		local w, h = lastMsg:GetSize()
		lastMsg:SetSize( background:GetWide() - 50, h )
		lastMsg:SetPos( 25, 22 )
	end
end

--// Update the messages from outside the application
function APP.UpdateMessages( id )
	id = gPhone.formatToSteamID( id )
	gPhone.msgC( GPHONE_MSGC_NONE, "Updating phone messages for conversation "..id)
	APP.PopulateMessages( id )
end

--// Create the texting interface and display all messages
function APP.PopulateMessages( id )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	objects.Back:SetVisible( true )
	objects.NewText:SetVisible( false ) 
	
	gPhone.decrementBadge( "Messages", gPhone.steamIDToFormat(id) .."_message" )
	
	local oldPaint = objects.LayoutScroll.Paint
	local oldW, oldH = objects.LayoutScroll:GetSize()
	
	-- If this isn't removed, a new panel will be created each time there is a text
	if IsValid( objects.WritePanel ) then
		objects.WritePanel:Remove()
	end
	
	objects.Back.DoClick = function()
		objects.Back:SetVisible( false )
		objects.NewText:SetVisible( true )
		objects.LayoutScroll.Paint = oldPaint
		gPhone.setTextAndCenter(objects.Title, nil, screen)
		objects.LayoutScroll:SetSize( oldW, oldH )
		
		objects.WritePanel:SetVisible( false )
		
		for k, v in pairs(objects) do
			if IsValid(v) then
				v:Remove()
			end
		end
		APP.Run( objects, screen )
	end

	messageTable = gPhone.loadTextMessages()
	
	-- Panel to write and send new gMessages
	local writePanelOffset = 30
	local send, textBox
	objects.WritePanel = vgui.Create( "DPanel", screen )
	objects.WritePanel:SetSize( screen:GetWide(), writePanelOffset )
	objects.WritePanel:SetPos( 0, screen:GetTall() - objects.WritePanel:GetTall())
	objects.WritePanel.Paint = function( self, w, h )
		draw.RoundedBox(2, 0, 0, w, h, Color(220, 220, 220))
	end
	
	textBox = vgui.Create( "DTextEntry", objects.WritePanel )
	textBox:SetText( "" )
	textBox:SetTextColor(Color(0,0,0))
	textBox:SetFont("gPhone_14")
	textBox:SetSize( screen:GetWide()/3 * 2, 20 )
	textBox:SetPos( 30, 5 )
	textBox.OnEnter = function()
		-- Simulate clicking the send button for efficiency
		send:DoClick()
	end
	
	send = vgui.Create( "DButton", objects.WritePanel )
	send:SetSize( 30, 20 )
	send:SetPos( objects.WritePanel:GetWide() - 40, 5 )
	send:SetText("Send")
	send:SetFont("gPhone_16")
	send.Paint = function() end
	send.DoClick = function()
		-- Send a text message
		if textBox:GetText() != nil and textBox:GetText() != "" then
			local nick = util.getPlayerByID( id ):Nick()
			local text = textBox:GetText()
			gPhone.sendTextMessage( util.getPlayerByID( id ):Nick(), textBox:GetText() ) 
			textBox:SetText("")
			
			objects.LayoutScroll:SetSize( oldW, oldH )
		end
	end
	
	local w, h = objects.LayoutScroll:GetSize()
	objects.LayoutScroll:SetSize( w, h - writePanelOffset ) -- Shrink the scroll panel so the chat box fits nicely
	
	-- Create the messages 
	local messageCount = 0
	local function createConversation( tbl )
		tbl = tbl or {}
		
		local yBuffer = 0
		for k, tbl in pairs( tbl ) do
			objects.LayoutScroll.Paint = function( self, w, h )
				draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)
			end
			
			-- Manage colors
			local col, textcol
			if tbl.self then
				col = Color(80, 235, 80)
				textcol = color_white
			else
				col = gPhone.colors.darkerWhite
				textcol = color_black
			end
			
			background = vgui.Create("DPanel", objects.LayoutScroll)
			background:SetSize(150, 50)
			background.Paint = function( self, w, h )
				draw.RoundedBox(6, 0, 0, w, h, col)
			end
			
			local message = vgui.Create( "DLabel", background )
			message:SetText( tbl.message )
			message:SetTextColor( textcol )
			message:SetFont("gPhone_14")
			message:SizeToContents()
			message:SetPos( 5, 5 )
			message.Paint = function() end
			
			gPhone.WordWrap( message, background:GetWide(), 10 )

			-- Clamp the width to 2/3s of the screen width and the height to the screen height
			local w, h = message:GetSize()
			local newW = math.Clamp( w + 10, 10, screen:GetWide() / 3 * 2)
			local newH = math.Clamp( h + 10, 10, screen:GetTall() )
			background:SetSize( newW, newH )
			
			-- Align the newly sized message boxes 
			if tbl.self then
				background:SetPos(screen:GetWide() - background:GetWide() - 10, yBuffer)
			else
				background:SetPos(10, yBuffer)
			end
			
			-- Increase the buffer and move the scroll panel down using modified PANEL:ScrollToChild code
			yBuffer = yBuffer + background:GetTall() + 1
			
			local x, y = objects.LayoutScroll.pnlCanvas:GetChildPosition( background )
			local w, h = background:GetSize()
			y = y + h * 0.5
			y = y - objects.LayoutScroll:GetTall() * 0.5
			objects.LayoutScroll.VBar:AnimateTo( y, 0, 0, 0.5 )
			
			messageCount = messageCount + 1
		end
	end
	createConversation( messageTable[id] )
end

--// Create the interface for a new conversation
function APP.NewConversation()
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	objects.NewText:SetVisible( false )
	objects.Back:SetVisible( true )
	gPhone.hideChildren( objects.Layout )
	gPhone.setTextAndCenter( objects.Title, "New Message", screen )
	
	local oldPaint = objects.LayoutScroll.Paint
	local oldW, oldH = objects.LayoutScroll:GetSize()
	
	objects.Back.DoClick = function()
		objects.NewText:SetVisible( true )
		objects.Back:SetVisible( false )
		objects.LayoutScroll.Paint = oldPaint
		gPhone.setTextAndCenter(objects.Title, nil, screen)
		objects.LayoutScroll:SetSize( oldW, oldH )
		
		for k, v in pairs(objects) do
			if IsValid(v) then
				v:Remove()
			end
		end
		APP.Run( objects, screen )
	end
	
	objects.LayoutScroll.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, 1, w, h, gPhone.colors.whiteBG)
	end
	
	local writePanelOffset = 30
	local w, h = objects.LayoutScroll:GetSize()
	objects.LayoutScroll:SetSize( w, h - writePanelOffset )
	
	objects.TargetPanel = vgui.Create( "DPanel", screen )
	objects.TargetPanel:SetSize( screen:GetWide(), writePanelOffset + 10 )
	objects.TargetPanel:SetPos( 0, 50 )
	objects.TargetPanel.Paint = function( self, w, h )
		draw.RoundedBox(2, 0, 1, w, h, Color(220, 220, 220))
	end
	
	-- Gotta get a new icon layout for the player panels
	local layout = vgui.Create( "DIconLayout", objects.LayoutScroll )
	local w, h = objects.LayoutScroll:GetSize()
	layout:SetSize( w - 20, h )
	layout:SetPos( objects.LayoutScroll:GetPos() )
	layout:SetSpaceY( 0 )
	
	local playerPanels = {}
	local playerList = {}
	for k, v in pairs( player.GetAll() ) do 
		table.insert(playerList, {name=v:Nick(), number=v:getPhoneNumber()})
	end
	
	-- Create a list of all connected players to help with sending messages
	local messageTarget
	for k, tbl in pairs( playerList ) do 
		local nick = tbl.name
		local number = tbl.number
		
		playerPanels[nick] = vgui.Create( "DButton", layout )
		playerPanels[nick]:SetSize(screen:GetWide(), 30)
		playerPanels[nick]:SetText("")
		playerPanels[nick].Paint = function( self )
			if not self:IsDown() then
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.whiteBG)
			else
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.darkWhiteBG)
			end
			
			draw.RoundedBox(0, 25, self:GetTall()-1, self:GetWide()-25, 1, gPhone.colors.greyAccent)
		end
		playerPanels[nick].DoClick = function()
			-- When I later add group chats, use a table
			messageTarget:SetText(nick)
			
			for k, v in pairs(playerPanels) do
				v:SetVisible(false)
			end
		end

		local ply = util.getPlayerByNick( nick )
		local contactName = vgui.Create( "DLabel", playerPanels[nick] )
		contactName:SetText( nick )
		contactName.number = number -- Index the player's phone number too so it can be searched
		contactName:SetTextColor(Color(0,0,0))
		contactName:SetFont("gPhone_18")
		contactName:SizeToContents()
		local w, h = contactName:GetSize()
		contactName:SetSize( screen:GetWide() - 35, h)
		contactName:SetPos( 30, 5 )
		
		playerPanels[nick]:SetVisible(false)
	end
	
	messageTarget = vgui.Create( "DTextEntry", objects.TargetPanel )
	messageTarget:SetText( "" )
	messageTarget:SetTextColor(Color(0,0,0))
	messageTarget:SetFont("gPhone_14")
	messageTarget:SetSize( screen:GetWide()/3 * 2, 20 )
	messageTarget:SetPos( 30, 10 )
	messageTarget.OnTextChanged = function( self )
		-- Modified code from the contact list
		local needle = self:GetText():lower()
		
		if needle == nil or needle == "" then
			for k, v in pairs( playerPanels ) do
				v:SetVisible( false )
			end
			return 
		end
		
		for k, v in pairs( playerPanels ) do
			local lbl = v:GetChildren()[1]
			local haystack = lbl:GetText():lower() -- Player's name
			local morehay = lbl.number -- Player's phone number
			
			if string.find(haystack, needle) or string.find(morehay, needle) then
				v:SetVisible(true)
			else
				v:SetVisible(false)
			end
		end
		layout:LayoutIcons_TOP() 
	end
	
	objects.To = vgui.Create( "DLabel", objects.TargetPanel )
	objects.To:SetText( "To:" )
	objects.To:SetTextColor(Color(0,0,0))
	objects.To:SetFont("gPhone_14")
	objects.To:SizeToContents()
	local x, y = messageTarget:GetPos()
	objects.To:SetPos( x - objects.To:GetWide() - 3, y + 3 )

	objects.WritePanel = vgui.Create( "DPanel", screen )
	objects.WritePanel:SetSize( screen:GetWide(), writePanelOffset )
	objects.WritePanel:SetPos( 0, screen:GetTall() - objects.WritePanel:GetTall())
	objects.WritePanel.Paint = function( self, w, h )
		draw.RoundedBox(2, 0, 0, w, h, Color(220, 220, 220))
	end
	
	local sendButton
	local messageBox = vgui.Create( "DTextEntry", objects.WritePanel )
	messageBox:SetText( "" )
	messageBox:SetTextColor(Color(0,0,0))
	messageBox:SetFont("gPhone_14")
	messageBox:SetSize( screen:GetWide()/3 * 2, 20 )
	messageBox:SetPos( 30, 5 )
	messageBox.OnEnter = function()
		sendButton:DoClick()
	end
	
	sendButton = vgui.Create( "DButton", objects.WritePanel )
	sendButton:SetSize( 30, 20 )
	sendButton:SetPos( objects.WritePanel:GetWide() - 40, 5 )
	sendButton:SetText("Send")
	sendButton:SetFont("gPhone_16")
	sendButton.Paint = function() end
	sendButton.DoClick = function()
		-- Create a new conversation
		if messageBox:GetText() != nil and messageBox:GetText() != "" then
			gPhone.setTextAndCenter(objects.Title, "Messages",  screen)
			
			gPhone.sendTextMessage( messageTarget:GetText(), messageBox:GetText() ) 
			messageBox:SetText("")
			
			-- Remove all the objects
			for k, v in pairs(objects) do
				if IsValid(v) then
					v:Remove()
				end
			end
			
			-- Recreate the main screen and fix the scroll panel (hacky but it gets the job done)
			APP.Run( objects, screen )
			gPhone.hideChildren( objects.Layout )
			objects.LayoutScroll.Paint = oldPaint
			objects.LayoutScroll:SetSize( oldW, oldH + 30 )
			
			-- Build the conversation screen
			APP.PopulateMessages( util.getPlayerByNick(messageTarget:GetText()):SteamID() )
		end
	end
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), gPhone.colors.darkerWhite)
		
	draw.RoundedBox(2, 0, 0, screen:GetWide(), 50, gPhone.colors.whiteBG)
	draw.RoundedBox(0, 0, 50, screen:GetWide(), 1, Color(20, 40, 40))
end

gPhone.addApp(APP)