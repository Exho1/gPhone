local APP = {}

APP.PrintName = "Messages"
APP.Icon = "vgui/gphone/text.png"

--[[ // Plan //
	- App
* Save all messages clientside using JSON
* Populate the Layout with the conversations sorted by most recent
]]

function APP.Run( objects, screen )
	gPhone.DarkenStatusBar()
	
	-- These need to be removed because I call the Run function in objects.Back.DoClick
	if objects.Title then objects.Title:Remove() end
	if objects.Back then objects.Back:Remove() end
	if objects.LayoutScroll then objects.LayoutScroll:Remove() end
	if objects.Layout then objects.Layout:Remove() end
	
	objects.Title = vgui.Create( "DLabel", screen )
	objects.Title:SetText( "Messages" )
	objects.Title:SetTextColor(Color(0,0,0))
	objects.Title:SetFont("gPhone_18Lite")
	objects.Title:SizeToContents()
	objects.Title:SetPos( screen:GetWide()/2 - objects.Title:GetWide()/2, 25 )
	
	objects.Back = vgui.Create("gPhoneBackButton", screen)
	objects.Back:SetTextColor( gPhone.Config.ColorBlue )
	local x, y = objects.Title:GetPos()
	objects.Back:SetPos( 10, y )
	objects.Back:SetVisible( false )
	
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
	
	APP.GetFromTxt()
	APP.PopulateMain( objects.Layout )
end

local messageTable = {}
function APP.GetFromTxt()


end

function APP.PopulateMain( layout )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	local curDate = os.date( "%x" ) -- 01/02/15
	
	messageTable["Exho"] = { {self = true, time="12:18am", date = "01/02/15", message="Hello"} }
	messageTable["Bot01"] = { {self = false, time="12:12pm", date = "01/01/15", message="Helsdfasdfasdflo"} }
	messageTable["Bot02"] = { {self = false, time="11:18am", date = "12/23/14", message="asdsdfasdfwerawetafsdf\r\nasdf"} }
	
	-- table[ nick ] = { {timestamp, message}, {timestamp, message} }
	
	for name, tbl in pairs( messageTable ) do
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
			APP.PopulateMessages( name )
		end
		
		local senderName = vgui.Create( "DLabel", background )
		senderName:SetText( name )
		senderName:SetTextColor(Color(0,0,0))
		senderName:SetFont("gPhone_18")
		senderName:SizeToContents()
		local w, h = senderName:GetSize()
		senderName:SetSize( screen:GetWide() - 35, h)
		senderName:SetPos( 25, 2 )
		
		local dateStamp = tbl[1].date
		local timeStamp = tbl[1].time
		if curDate != dateStamp then
			local dateFrags = string.Explode( "/", curDate )
			local stampFrags = string.Explode( "/", dateStamp )
			
			if dateFrags[3] != stampFrags[3] then -- Different year
				local yearDif = tonumber(dateFrags[3]) - tonumber(stampFrags[3]) 
				if yearDif == 1 then
					timeStamp = "Last Year"
				else
					timeStamp = yearDif.." Years Ago"
				end
			end
			
			if dateFrags[1] == stampFrags[1] then -- Same month
				local dayDif = tonumber(dateFrags[2]) - tonumber(stampFrags[2]) 
				if dayDif == 1 then
					timeStamp = "Yesterday"
				else 
					timeStamp = dayDif.." Days Ago"
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
		lastMsg:SetText( tbl[1].message )
		lastMsg:SetTextColor(Color(90,90,90))
		lastMsg:SetFont("gPhone_14")
		lastMsg:SizeToContents()
		lastMsg:SetPos( 25, 22 )
	end
end

function APP.PopulateMessages( name )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	objects.Back:SetVisible( true )
	
	local oldPaint = objects.LayoutScroll.Paint
	
	objects.Back.DoClick = function()
		objects.Back:SetVisible( false )
		objects.LayoutScroll.Paint = oldPaint
		gPhone.SetTextAndCenter(objects.Title, screen)
		
		gPhone.HideChildren( objects )
		APP.Run( objects, screen )
	end
	
	for k, tbl in pairs( messageTable[name] ) do
		objects.LayoutScroll.Paint = function( self, w, h )
			draw.RoundedBox(0, 0, 0, w, h, Color(250, 250, 250))
		end
		
		if tbl.self then
			local background = vgui.Create("DPanel", objects.LayoutScroll)
			background:SetSize(100, 50)
			background.Paint = function( self, w, h )
				draw.RoundedBox(0, 0, 0, w, h, Color(100, 235, 100))
			end
			background:SetPos(screen:GetWide() - background:GetWide() - 10, 60)
		else
		
		end
		
	end

	
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), Color(200, 200, 200))
		
	draw.RoundedBox(2, 0, 0, screen:GetWide(), 50, Color(250, 250, 250))
	draw.RoundedBox(0, 0, 50, screen:GetWide(), 1, Color(20, 40, 40))
end

gPhone.AddApp(APP)