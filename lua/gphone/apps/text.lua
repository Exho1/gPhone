local APP = {}

APP.PrintName = "Messages"
APP.Icon = "vgui/gphone/text.png"

function APP.Run( objects, screen )
	gPhone.DarkenStatusBar()
	
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
	objects.NewText:SetColor( gPhone.Config.ColorBlue )
	objects.NewText.DoClick = function() 
		APP.NewConversation()
	end
	
	objects.Back = vgui.Create("gPhoneBackButton", screen)
	objects.Back:SetTextColor( gPhone.Config.ColorBlue )
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
	
	messageTable = gPhone.LoadTextMessages()
	
	for id, tbl in pairs( messageTable ) do
		local background = layout:Add("DButton")
		background:SetSize(screen:GetWide(), 50)
		background:SetText("")
		background.Paint = function( self )
			if not self:IsDown() then
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(250, 250, 250))
			else
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(230, 230, 230))
			end
			
			draw.RoundedBox(0, 25, self:GetTall()-1, self:GetWide()-25, 1, Color(150, 150, 150))
		end
		background.DoClick = function()
			gPhone.HideChildren( layout )
			print("Open conversation: "..id)
			APP.PopulateMessages( id )
		end
		
		local senderName = vgui.Create( "DLabel", background )
		senderName:SetText( util.GetPlayerByID( id ):Nick() )
		senderName:SetTextColor(Color(0,0,0))
		senderName:SetFont("gPhone_18")
		senderName:SizeToContents()
		local w, h = senderName:GetSize()
		senderName:SetSize( screen:GetWide() - 35, h)
		senderName:SetPos( 25, 2 )
		
		-- Create a time or date stamp 
		local dateStamp = tbl[1].date
		local timeStamp = tbl[1].time
		if curDate != dateStamp then
			local dateFrags = string.Explode( "/", curDate )
			local stampFrags = string.Explode( "/", dateStamp )
			
			if dateFrags[3] != stampFrags[3] then -- Different year
				local yearDif = tonumber(dateFrags[3]) - tonumber(stampFrags[3]) 
				if yearDif == 1 then
					timeStamp = "Last Year"
				else -- HA, like this will ever happen
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
	id = gPhone.FormatToSteamID( id )
	print("Update messages using id: "..id)
	APP.PopulateMessages( id )
end

--// Create the texting interface and display all messages
function APP.PopulateMessages( id )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	objects.Back:SetVisible( true )
	objects.NewText:SetVisible( false ) 
	
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
		gPhone.SetTextAndCenter(objects.Title, screen)
		objects.LayoutScroll:SetSize( oldW, oldH )
		
		objects.WritePanel:SetVisible( false )
		
		for k, v in pairs(objects) do
			if IsValid(v) then
				v:Remove()
			end
		end
		APP.Run( objects, screen )
	end

	messageTable = gPhone.LoadTextMessages()
	
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
	textBox:SetText( "gMessage" )
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
			local nick = util.GetPlayerByID( id ):Nick()
			local text = textBox:GetText()
			print("Sent text message: ", nick, text, id)
			gPhone.SendTextMessage( util.GetPlayerByID( id ):Nick(), textBox:GetText() ) 
			textBox:SetText("")
			
			objects.LayoutScroll:SetSize( oldW, oldH )
		end
	end
	
	local w, h = objects.LayoutScroll:GetSize()
	objects.LayoutScroll:SetSize( w, h - writePanelOffset ) -- Shrink the scroll panel so the chat box fits nicely
	
	-- Create the messages 
	local function createConversation( tbl )
		print("**** Build message boxes", tbl )
		local yBuffer = 0
		for k, tbl in pairs( tbl ) do
			objects.LayoutScroll.Paint = function( self, w, h )
				draw.RoundedBox(0, 0, 0, w, h, Color(250, 250, 250))
			end
			
			-- Manage colors
			local col, textcol
			if tbl.self then
				col = Color(80, 235, 80)
				textcol = color_white
			else
				col = Color(200, 200, 200)
				textcol = color_black
			end
			
			background = vgui.Create("DPanel", objects.LayoutScroll)
			background:SetSize(150, 50)
			background.Paint = function( self, w, h )
				draw.RoundedBox(4, 0, 0, w, h, col)
			end
			
			local message = vgui.Create( "DLabel", background )
			message:SetText( tbl.message )
			message:SetTextColor( textcol )
			message:SetFont("gPhone_14")
			message:SizeToContents()
			message:SetPos( 5, 5 )
			message.Paint = function() end
			
			local w, h = message:GetSize()
			if w - 10 >= background:GetWide() then
				local text = message:GetText()
				surface.SetFont(message:GetFont())
				
				-- Simulates Word Wrapping in order to figure out how to properly size the message box
				-- At this point I could probably just make my own word wrapping...
				local frags = string.Explode( "", text )
				local width, lineBreaks = 0, 1
				for k, v in pairs( frags ) do
					width = width + surface.GetTextSize(v)
					
					if width >= background:GetWide() then 
						lineBreaks = lineBreaks + 1
						width = 0 
					end
				end
				
				-- Use Gmod's wrapping
				message:SetWrap( true ) 
				
				-- Use our simulate word wrap to size the message's background
				local wid, heig = background:GetSize()
				message:SetSize( wid - 10, h * (lineBreaks)) 
			else
				message:SizeToContents()
			end

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
			yBuffer = yBuffer + background:GetTall() + 10
			local x, y = objects.LayoutScroll.pnlCanvas:GetChildPosition( background )
			local w, h = background:GetSize()
			y = y + h * 0.5
			y = y - objects.LayoutScroll:GetTall() * 0.5

			objects.LayoutScroll.VBar:AnimateTo( y, 0, 0, 0.5 )
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
	gPhone.HideChildren( objects.Layout )
	objects.Title:SetText("New Message")
	gPhone.SetTextAndCenter(objects.Title, screen)
	
	local oldPaint = objects.LayoutScroll.Paint
	local oldW, oldH = objects.LayoutScroll:GetSize()
	
	objects.Back.DoClick = function()
		objects.NewText:SetVisible( true )
		objects.Back:SetVisible( false )
		objects.LayoutScroll.Paint = oldPaint
		gPhone.SetTextAndCenter(objects.Title, screen)
		objects.LayoutScroll:SetSize( oldW, oldH )
		
		for k, v in pairs(objects) do
			if IsValid(v) then
				v:Remove()
			end
		end
		APP.Run( objects, screen )
	end
	
	objects.LayoutScroll.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, 1, w, h, Color(250, 250, 250))
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
		table.insert(playerList, {name=v:Nick(), number=v:GetPhoneNumber()})
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
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(250, 250, 250))
			else
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(230, 230, 230))
			end
			
			draw.RoundedBox(0, 25, self:GetTall()-1, self:GetWide()-25, 1, Color(150, 150, 150))
		end
		playerPanels[nick].DoClick = function()
			-- When I later add group chats, use a table
			messageTarget:SetText(nick)
			
			for k, v in pairs(playerPanels) do
				v:SetVisible(false)
			end
		end

		local ply = util.GetPlayerByNick( nick )
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
			objects.Title:SetText("Messages")
			gPhone.SetTextAndCenter(objects.Title, screen)
			
			gPhone.SendTextMessage( messageTarget:GetText(), messageBox:GetText() ) 
			messageBox:SetText("")
			
			-- Remove all the objects
			for k, v in pairs(objects) do
				if IsValid(v) then
					v:Remove()
				end
			end
			
			-- Recreate the main screen and fix the scroll panel (hacky but it gets the job done)
			APP.Run( objects, screen )
			gPhone.HideChildren( objects.Layout )
			objects.LayoutScroll.Paint = oldPaint
			objects.LayoutScroll:SetSize( oldW, oldH + 30 )
			
			-- Build the conversation screen
			APP.PopulateMessages( util.GetPlayerByNick(messageTarget:GetText()):SteamID() )
		end
	end
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), Color(200, 200, 200))
		
	draw.RoundedBox(2, 0, 0, screen:GetWide(), 50, Color(250, 250, 250))
	draw.RoundedBox(0, 0, 50, screen:GetWide(), 1, Color(20, 40, 40))
end

gPhone.AddApp(APP)