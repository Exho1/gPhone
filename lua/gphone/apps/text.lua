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
	
	objects.Title = vgui.Create( "DLabel", screen )
	objects.Title:SetText( "Settings" )
	objects.Title:SetTextColor(Color(0,0,0))
	objects.Title:SetFont("gPhone_TitleLite")
	objects.Title:SizeToContents()
	objects.Title:SetPos( screen:GetWide()/2 - objects.Title:GetWide()/2, 25 )
	
	objects.Layout = vgui.Create( "DIconLayout", screen)
	objects.Layout:SetSize( screen:GetWide(), screen:GetTall() - 50 )
	objects.Layout:SetPos( 0, 80 )
	objects.Layout:SetSpaceY( 0 )
	
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), Color(200, 200, 200))
		
	draw.RoundedBox(2, 0, 0, screen:GetWide(), 50, Color(250, 250, 250))
	draw.RoundedBox(0, 0, 50, screen:GetWide(), 1, Color(20, 40, 40))
end

gPhone.AddApp(APP)