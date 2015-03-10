local APP = {}

APP.PrintName = "Notes"
APP.Icon = "vgui/gphone/notes.png"
APP.Author = "Exho"
APP.Tags = {"Notes", "Useful", "Writing"}

function APP.Run( objects, screen )
	gPhone.darkenStatusBar()
	
	-- Read from file
	local contents = file.Read( "gphone/notes.txt", "DATA" )
	
	-- Multiline text entry
	objects.textBox = vgui.Create( "DTextEntry", screen )
	objects.textBox:SetText( contents or "" )
	objects.textBox:SetTextColor(Color(0,0,0))
	objects.textBox:SetMultiline( true )
	objects.textBox:SetFont("gPhone_14")
	objects.textBox:SetSize( screen:GetWide() - 20, screen:GetTall() - 20 - gPhone.statusBarHeight)
	objects.textBox:SetPos( 10, gPhone.statusBarHeight + 10 )
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), gPhone.colors.whiteBG)
end

function APP.Close() 
	-- Write to file
	local objects = gApp["_children_"]
	file.Write( "gphone/notes.txt", objects.textBox:GetText() )
end

gPhone.addApp(APP)