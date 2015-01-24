local APP = {}

APP.PrintName = "Finances"
APP.Icon = "vgui/gphone/finances.png"
APP.Gamemode = "DarkRP"
APP.Tags = {"Money", "Transfer", "Funds"}

local bodyWidth
function APP.Run( objects, screen )
	gPhone.lightenStatusBar()
	bodyWidth = screen:GetWide()-20
	
	local toDraw = {
		"Current User: "..LocalPlayer():Nick(),
		"Balance: $"..LocalPlayer():getDarkRPVar("money") or "N/A",
		"Salary: $"..LocalPlayer():getDarkRPVar("salary") or "N/A",
		"_SPACE_",
		"Wire Funds",
		--"_SPACE_",
		"Transaction Log",
	}
	
	local isButton = { -- Is the object a button? Poor way of handling this
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = true,
		[6] = true,
	}
	
	local offset = 20 -- A little trick to push the scrollbar off the screen
	objects.LayoutScroll = vgui.Create( "DScrollPanel", screen )
	objects.LayoutScroll:SetSize( screen:GetWide() + offset, screen:GetTall() - 120 )
	objects.LayoutScroll:SetPos( 30, 90 )
	objects.LayoutScroll.Paint = function() 
		--draw.RoundedBox(0, 0, 0, objects.LayoutScroll:GetWide(), objects.LayoutScroll:GetTall(), Color(250, 250, 250))
	end
	
	objects.Container = vgui.Create("DPanel", screen)
	objects.Container:SetSize( bodyWidth - 20, 30 )
	objects.Container:SetPos( screen:GetWide()/2 - objects.Container:GetWide()/2, 35 )
	objects.Container.Paint = function()
		draw.RoundedBox(0, 0, 0, objects.Container:GetWide(), objects.Container:GetTall(), Color(250, 250, 250))
	end
	
	objects.Title = vgui.Create( "DLabel", screen )
	objects.Title:SetText( "Finance Manager" ) 
	objects.Title:SetFont("gPhone_18Lite")
	objects.Title:SetTextColor(Color(0,0,0))
	objects.Title:SizeToContents()
	objects.Title:SetPos( screen:GetWide()/2 - objects.Title:GetWide()/2, 40 )
	
	-- Layout system copied from the settings app
	objects.Layout = vgui.Create( "DIconLayout", objects.LayoutScroll)
	objects.Layout:SetSize( bodyWidth - 40, screen:GetTall() - 50 )
	objects.Layout:SetPos( 0,0  )
	objects.Layout:SetSpaceY( 0 )
	
	local pnlWidth = bodyWidth - 40
	
	for key, name in pairs(toDraw) do
		if name == "_SPACE_" then
			local fake = objects.Layout:Add("DPanel")
			fake:SetSize(pnlWidth, 30)
			fake.Paint = function() end
		else
			local background, title
			if isButton[key] then
				background = objects.Layout:Add("DButton")
				background:SetSize(pnlWidth, 30)
				background:SetText("")
				background.Paint = function()
					if not background:IsDown() then
						draw.RoundedBox(0, 0, 0, background:GetWide(), background:GetTall(), Color(250, 250, 250))
					else
						draw.RoundedBox(0, 0, 0, background:GetWide(), background:GetTall(), Color(230, 230, 230))
					end
				end
				background.DoClick = function()
					APP.ButtonClick( objects, name )
				end
				
				title = vgui.Create( "DLabel", background )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 0, 5 )
				gPhone.setTextAndCenter(title, name, background)
			else
				background = objects.Layout:Add("DPanel")
				background:SetSize(pnlWidth, 30)
				background:SetText("")
				background.Paint = function()
					draw.RoundedBox(0, 0, 0, background:GetWide(), background:GetTall(), Color(250, 250, 250))
				end
				
				title = vgui.Create( "DLabel", background )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 10, 5 )
				gPhone.setTextAndCenter(title, name, background)
			end
		end
	end
end

--// Custom button handling function
function APP.ButtonClick( objects, name )
	local screen = gPhone.phoneScreen
	
	if name == "Wire Funds" then
		for k, v in pairs(objects.Layout:GetChildren()) do
			v:SetVisible(false)
		end
		
		local pnlWidth = bodyWidth - 40
		local targetPlayer, moneyAmount = nil
		
		local targetEntry = objects.Layout:Add("DComboBox")
		targetEntry:SetValue( "Reciever" )
		targetEntry:SetFont("gPhone_18")
		targetEntry:SetSize( pnlWidth, 30 )
		for k, v in pairs(player.GetAll()) do 
			if v != LocalPlayer() then
				targetEntry:AddChoice(v:Nick()) -- Add all players to the list
			end
		end
		targetEntry.OnSelect = function( panel, index, value )
			for k, v in pairs(player.GetAll()) do
				if v:Nick() == value then
					targetPlayer = v -- Set the target player
				end
			end
		end
		
		local moneyEntry = objects.Layout:Add("DTextEntry")
		moneyEntry:SetText( "Amount" )
		moneyEntry:SetFont("gPhone_18")
		moneyEntry:SetSize( pnlWidth, 30 )
		moneyEntry.OnTextChanged = function( self )
			
			local val = tonumber(self:GetValue())
			
			if val != nil and val < tonumber(LocalPlayer():getDarkRPVar("money")) and val > 0 then
				-- Valid amount of money to transfer (unsafe)
				self:SetTextColor(Color(0,255,0))
				moneyAmount = val
			else
				-- Invalid
				self:SetTextColor(Color(255,0,0))
				moneyAmount = 0
			end
		end
		
		local fake = objects.Layout:Add("DPanel") -- Space
		fake:SetSize(pnlWidth, 30)
		fake.Paint = function() end
		
		local sendMoney = objects.Layout:Add("DButton")
		sendMoney:SetSize(pnlWidth, 30)
		sendMoney:SetText("")
		sendMoney.Paint = function( self )
			if not self:IsDown() then
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(250, 250, 250))
			else
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(230, 230, 230))
			end
		end
		sendMoney.DoClick = function()
			-- Clientside checks to stop the honest users, this will be double checked on the server to stop cheaters
			if not IsValid(targetPlayer) or targetPlayer == LocalPlayer() then
				gPhone.chatMsg( "Invalid target to wire money to!" )
				return
			elseif moneyAmount == nil or moneyAmount <= 0 or math.abs(moneyAmount) != moneyAmount then
				gPhone.chatMsg( "Invalid amount of money to wire!" )
				return
			elseif moneyAmount > tonumber( LocalPlayer():getDarkRPVar("money") ) then
				gPhone.chatMsg( "You do not have enough money to send!" )
				return
			end
			
			gPhone.msgC( GPHONE_MSGC_NONE, "Transaction send to the server for verification" )
			-- Send the transaction data to the server
			net.Start("gPhone_DataTransfer")
				net.WriteTable( {header=GPHONE_MONEY_TRANSFER, target=targetPlayer, amount=moneyAmount} )
			net.SendToServer()
		end
		
		local title = vgui.Create( "DLabel", sendMoney )
		title:SetTextColor(Color(0,0,0))
		title:SetFont("gPhone_18")
		title:SizeToContents()
		title:SetPos( 0, 5 )
		gPhone.setTextAndCenter(title, "Transfer", sendMoney)
		
		local cancelTransaction = objects.Layout:Add("DButton")
		cancelTransaction:SetSize(pnlWidth, 30)
		cancelTransaction:SetText("")
		cancelTransaction.Paint = function( self )
			if not self:IsDown() then
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(250, 250, 250))
			else
				draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(230, 230, 230))
			end
		end
		cancelTransaction.DoClick = function()
			for k, pnl in pairs(objects.Layout:GetChildren()) do
				if pnl:IsVisible() then
					pnl:Remove()
				else
					pnl:SetVisible(true)
				end
			end
		end
		
		local title = vgui.Create( "DLabel", cancelTransaction )
		title:SetTextColor(Color(0,0,0))
		title:SetFont("gPhone_18")
		title:SizeToContents()
		title:SetPos( 0, 5 )
		gPhone.setTextAndCenter(title, "Cancel", cancelTransaction)
	elseif name == "Transaction Log" then
		for k, v in pairs(objects.Layout:GetChildren()) do
			v:SetVisible( false )
		end
		
		if file.Exists( "gphone/appdata/t_log.txt", "DATA" ) then 
			local readFile = file.Read( "gphone/appdata/t_log.txt", "DATA" )
			local readTable = util.JSONToTable( gPhone.unscrambleJSON( readFile ) ) 
			
			for key, tbl in pairs( readTable ) do
				local background = objects.Layout:Add("DPanel")
				background:SetSize(screen:GetWide()-60, 30)
				background:SetText("")
				background.Paint = function()
					draw.RoundedBox(0, 0, 0, background:GetWide(), background:GetTall(), Color(250, 250, 250))
				end
				
				local title = vgui.Create( "DLabel", background )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_12")
				title:SizeToContents()
				title:SetPos( 10, 15 )
				gPhone.setTextAndCenter(title, tbl.time, background)
				
				local title = vgui.Create( "DLabel", background )
				title:SetText( tbl.target.." - $"..tbl.amount )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_18")
				title:SizeToContents()
				title:SetPos( 10, 0 )
				gPhone.setTextAndCenter(title, nil, background)
				
				local fake = objects.Layout:Add("DPanel")
				fake:SetSize(screen:GetWide()-60, 5)
				fake.Paint = function() end
			end
		else
		
		end
	else
	
	end
end

local bg = Material( "vgui/gphone/wallpapers/finances_bg.png" )
function APP.Paint(screen)
	draw.RoundedBox(0, 0, 0, screen:GetWide(), gPhone.StatusBarHeight, Color(0, 0, 0))
	
	surface.SetMaterial( bg )
	surface.SetDrawColor(255,255,255)
	surface.DrawTexturedRect(0, 15, screen:GetWide(), screen:GetTall()-15)
	
	draw.RoundedBox(0, 10, 25, bodyWidth, screen:GetTall()-35, Color(200, 200, 200))
end

gPhone.addApp(APP)