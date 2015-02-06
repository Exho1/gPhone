local APP = {}

APP.PrintName = "Camera"
APP.Icon = "vgui/gphone/camera.png"
APP.Author = "Exho"
APP.Tags = {"Photos", "Images", "Selfies"}

function APP.Run( objects, screen )
	gPhone.hideStatusBar()
	
	objects.TakePicture = vgui.Create( "DImageButton", screen )
	objects.TakePicture:SetText( "" )
	objects.TakePicture:SetColor( color_white )
	objects.TakePicture:SetImage( "vgui/gphone/button.png" )
	objects.TakePicture:SetSize(32, 32)
	objects.TakePicture:SetPos( screen:GetWide()/2 - objects.TakePicture:GetWide()/2, screen:GetTall() - 50 )
	objects.TakePicture.DoClick = function()
		gPhone.phoneBase:SetVisible(false)

		hook.Add("HUDPaint", "gPhone_TakingPhoto", function() -- Hacky fix to "freeze" the player's view
			cam.Start2D()
				local CamData = {}
				CamData.angles = LocalPlayer():EyeAngles()
				CamData.origin = LocalPlayer():GetShootPos()
				CamData.drawviewmodel = false
				CamData.x = 0
				CamData.y = 0
				CamData.w = ScrW()
				CamData.h = ScrH()
				
				render.RenderView( CamData )
			cam.End2D()
		end)
		
		LocalPlayer():ConCommand( "screenshot" )
		
		timer.Simple(1, function()
			gPhone.phoneBase:SetVisible(true)
			hook.Remove("HUDPaint", "gPhone_TakingPhoto")
		end)
	end

end

function APP.Paint(screen)
	local x, y = nil
	x, y = gPhone.phoneBase:GetPos() 
	local sX, sY = screen:GetPos()
	x, y = x + sX, y + sY
	
	cam.Start2D()
		local CamData = {}
		CamData.angles = LocalPlayer():EyeAngles()
		CamData.origin = LocalPlayer():GetShootPos()
		CamData.x = x
		CamData.y = y
		CamData.drawviewmodel = true
		CamData.w = screen:GetWide()
		CamData.h = screen:GetTall()
		
		render.RenderView( CamData )
		
	cam.End2D()
end

gPhone.addApp(APP)