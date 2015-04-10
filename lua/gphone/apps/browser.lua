local APP = {}
local trans = gPhone.getTranslation

APP.PrintName = "Venture"
APP.Icon = "vgui/gphone/venture.png"
APP.Author = "Exho"
APP.Tags = {"Internet", "Browse", "Surfing"}

function APP.Run( objects, screen )
	gPhone.darkenStatusBar()
	
	APP.Buffer = gPhone.statusBarHeight * 2.5 
	
	-- Underlying connecting "animation" that provides something in between web pages
	objects.connecting = vgui.Create("DLabel", screen)
	objects.connecting:SetFont("gPhone_24")
	objects.connecting:SetTextColor( color_black )
	objects.connecting:SizeToContents()
	objects.connecting:SetPos( screen:GetWide()/2 - objects.connecting:GetWide()/2, screen:GetTall()/2 - objects.connecting:GetTall()/2 )
	local nextDot, dots = 0, ""
	objects.connecting.Think = function( self )
		if CurTime() > nextDot then
			dots = dots.."."
			gPhone.setTextAndCenter(self, trans("connecting")..dots, screen, true)
			nextDot = CurTime() + 0.3
			
			if string.find( dots, "[.][.][.]") then
				dots = ""
			end
		end
	end
	
	-- The DHTML panel that displays the web
	objects.browser = vgui.Create( "DHTML", screen )
	objects.browser:SetPos( 0, APP.Buffer )
	objects.browser:SetSize( screen:GetWide() + 17, screen:GetTall() - APP.Buffer )
	objects.browser:OpenURL( "http://www.google.com/" )	

	-- Address bar
	local xBuffer = 40
	objects.textBox = vgui.Create( "DTextEntry", screen )
	objects.textBox:SetSize( screen:GetWide() - xBuffer, gPhone.statusBarHeight * 1.5)
	objects.textBox:SetPos( xBuffer, gPhone.statusBarHeight )
	objects.textBox:SetText( "http://www.google.com/" )
	objects.textBox:SetDrawBackground( true )
	objects.textBox:SetTextColor(Color(0,0,0))
	objects.textBox:SetFont("gPhone_16")
	objects.textBox.OnEnter = function( self )
		objects.browser:OpenURL( self:GetText() )
	end
	
	-- Back button
	objects.back = vgui.Create("DImageButton", screen)
	objects.back:SetImage("vgui/gphone/backspace.png")
	objects.back:SetSize( 20, 15 )
	objects.back:SetColor( gPhone.colors.blue )
	objects.back:SetPos( 5, gPhone.statusBarHeight + 2 )
	objects.back.DoClick = function( self )
		objects.browser:QueueJavascript( [[ window.history.back() ]] )
	end
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), gPhone.colors.whiteBG)
end

gPhone.addApp(APP)