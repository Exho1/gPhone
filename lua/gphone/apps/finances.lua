local APP = {}

APP.PrintName = "Finances"
APP.Icon = "vgui/gphone/finances_new.png"
APP.Gamemode = "DarkRP"

local bodyWidth
function APP.Run( objects, screen )
	gPhone.LightenStatusBar()
	bodyWidth = screen:GetWide()-20
	
	local toDraw = {
		"Budget: $"..LocalPlayer():getDarkRPVar("money") or "N/A",
		"Salary: $"..LocalPlayer():getDarkRPVar("salary") or "N/A",
		"_SPACE_",
		"Wire Funds",
	}
	
	local isButton = { -- Is the object a button? Poor way of handling this
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = true,
	}
	
	objects.Container = vgui.Create("DPanel", screen)
	objects.Container:SetSize( bodyWidth - 20, 30 )
	objects.Container:SetPos( screen:GetWide()/2 - objects.Container:GetWide()/2, 35 )
	objects.Container.Paint = function()
		draw.RoundedBox(0, 0, 0, objects.Container:GetWide(), objects.Container:GetTall(), Color(250, 250, 250))
	end
	
	objects.Title = vgui.Create( "DLabel", screen )
	objects.Title:SetText( "Finance Manager" ) 
	objects.Title:SetFont("gPhone_TitleLite")
	objects.Title:SetTextColor(Color(0,0,0))
	objects.Title:SizeToContents()
	objects.Title:SetPos( screen:GetWide()/2 - objects.Title:GetWide()/2, 40 )
	
	-- Layout system copied from the settings app
	objects.Layout = vgui.Create( "DIconLayout", screen)
	objects.Layout:SetSize( bodyWidth - 40, screen:GetTall() - 50 )
	objects.Layout:SetPos( 30, 90 )
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
				title:SetText( name )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_Title")
				title:SizeToContents()
				title:SetPos( 0, 5 )
				gPhone.SetTextAndCenter(title, background)
			else
				background = objects.Layout:Add("DPanel")
				background:SetSize(pnlWidth, 30)
				background:SetText("")
				background.Paint = function()
					draw.RoundedBox(0, 0, 0, background:GetWide(), background:GetTall(), Color(250, 250, 250))
				end
				
				title = vgui.Create( "DLabel", background )
				title:SetText( name )
				title:SetTextColor(Color(0,0,0))
				title:SetFont("gPhone_Title")
				title:SizeToContents()
				title:SetPos( 10, 5 )
			end
		end
	end
end

--// Custom button handling function
function APP.ButtonClick( objects, name )
	if name == "Wire Funds" then
		for k, v in pairs(objects.Layout:GetChildren()) do
			v:SetVisible(false)
		end
		
		local pnlWidth = bodyWidth - 40
		local targetPlayer, moneyAmount = nil
		
		local targetEntry = objects.Layout:Add("DComboBox")
		targetEntry:SetValue( "Reciever" )
		targetEntry:SetFont("gPhone_Title")
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
		moneyEntry:SetFont("gPhone_Title")
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
				gPhone.ChatMsg( "Invalid target to wire money to!" )
				return
			elseif moneyAmount == nil or moneyAmount <= 0 or math.abs(moneyAmount) != moneyAmount then
				gPhone.ChatMsg( "Invalid amount of money to wire!" )
				return
			elseif moneyAmount > tonumber( LocalPlayer():getDarkRPVar("money") ) then
				gPhone.ChatMsg( "You do not have enough money to send!" )
				return
			end
			
			gPhone.MsgC( GPHONE_MSGC_NONE, "Transaction send to the server for verification" )
			-- Send the transaction data to the server
			net.Start("gPhone_DataTransfer")
				net.WriteTable( {header=GPHONE_MONEY_TRANSFER, target=targetPlayer, amount=moneyAmount} )
			net.SendToServer()
		end
		
		local title = vgui.Create( "DLabel", sendMoney )
		title:SetText( "Transfer" )
		title:SetTextColor(Color(0,0,0))
		title:SetFont("gPhone_Title")
		title:SizeToContents()
		title:SetPos( 0, 5 )
		gPhone.SetTextAndCenter(title, sendMoney)
		
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
		title:SetText( "Cancel" )
		title:SetTextColor(Color(0,0,0))
		title:SetFont("gPhone_Title")
		title:SizeToContents()
		title:SetPos( 0, 5 )
		gPhone.SetTextAndCenter(title, cancelTransaction)
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

gPhone.AddApp(APP)