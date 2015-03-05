local APP = {}

APP.PrintName = "Jobs"
APP.Icon = "vgui/gphone/jobs.png"
APP.Author = "Exho"
APP.Gamemode = "DarkRP"
APP.Tags = {"Jobs", "Teams", "Occupation"}

function APP.Run( objects, screen )
	--RPExtraTeams
	
	-- Create a f4 menu like thing
	
	local offset = 20 -- A little trick to push the scrollbar off the screen
	objects.LayoutScroll = vgui.Create( "DScrollPanel", screen )
	objects.LayoutScroll:SetSize( screen:GetWide() + offset, screen:GetTall() - 15 )
	objects.LayoutScroll:SetPos( 0, 15 )
	
	objects.Layout = vgui.Create( "DIconLayout", objects.LayoutScroll)
	objects.Layout:SetSize( screen:GetWide(), 0 )
	objects.Layout:SetPos( 0, 0 )
	objects.Layout:SetSpaceY( 20 )
	
	for _, data in pairs( RPExtraTeams ) do
	
		if not data.team then
			continue
		end	
		
		local requiresVote = data.vote or data.RequiresVote and data.RequiresVote(LocalPlayer(), data.team)
		
		local bgPanel = objects.Layout:Add("DPanel")
		bgPanel:SetSize(screen:GetWide(), 120)
		bgPanel.Paint = function( self, w, h ) 
			draw.RoundedBox(0, 0, 0, w, h, gPhone.colors.whiteBG)	
		end
		
		local playerModel = vgui.Create( "SpawnIcon" , bgPanel )
		playerModel:SetPos( 10, 10 )
		playerModel:SetSize(64,64)
		playerModel:SetModel( type(data.model)=="table" and data.model[1] or data.model )
		playerModel.PaintOver = function( self, w, h ) 	
			surface.SetDrawColor( data.color )
			surface.DrawOutlinedRect( 0, 0, w, h )
			surface.DrawOutlinedRect( 1, 1, w - 2 , h - 2 )
			surface.DrawOutlinedRect( 2, 2, w - 4 , h - 4 )
		end
		
		local jobName = vgui.Create( "DLabel", bgPanel )
		jobName:SetText( data.name )
		jobName:SetTextColor(Color(0,0,0))
		jobName:SetFont("gPhone_20")
		jobName:SizeToContents()
		jobName:SetPos( 10 + playerModel:GetWide() + 10, 15 )
		
		local function getMaxOfTeam(job)
			if not job.max or job.max == 0 then return "∞" end
			if job.max % 1 == 0 then return tostring(job.max) end

			return tostring(math.floor(job.max * #player.GetAll()))
		end
		
		local space = vgui.Create( "DLabel", bgPanel )
		space:SetText( team.NumPlayers(data.team).."/"..getMaxOfTeam(data) )
		space:SetTextColor(Color(0,0,0))
		space:SetFont("gPhone_16")
		space:SizeToContents()
		local x, y = jobName:GetPos()
		space:SetPos( x + 3, y + space:GetTall() + 5 )
		space.Think = function( self )
			self:SetText( team.NumPlayers(data.team).."/"..getMaxOfTeam(data) )
		end
		
		local salary = vgui.Create( "DLabel", bgPanel )
		salary:SetText( "$"..data.salary or "" )
		salary:SetTextColor(Color(0,0,0))
		salary:SetFont("gPhone_16")
		salary:SizeToContents()
		local x, y = space:GetPos()
		salary:SetPos( x, y + space:GetTall() + 3 )
		
		local becomeButton = vgui.Create("DButton", bgPanel )
		becomeButton:SetSize( bgPanel:GetWide()/2, 30 )
		becomeButton:SetPos( 10, bgPanel:GetTall() - becomeButton:GetTall() - 10 )
		becomeButton:SetFont("gPhone_16")
		becomeButton:SetTextColor( color_white )
		becomeButton:SetText( requiresVote and DarkRP.getPhrase("create_vote_for_job") or DarkRP.getPhrase("become_job"))
		becomeButton.Paint = function( self, w, h )
			draw.RoundedBox(0, 0, 0, w, h, Color(140, 0, 0, 250) )
		end
		if requiresVote then
			becomeButton.DoClick = fn.Compose{function()end, fn.Partial(RunConsoleCommand, "darkrp", "vote" .. data.command)}
		else
			becomeButton.DoClick = function()
				LocalPlayer():ConCommand( "darkrp ".. data.command )
			end
		end
	end
end

function APP.Paint( screen )
	draw.RoundedBox(0, 0, 0, screen:GetWide(), screen:GetTall(), Color(50, 50, 50, 255))	
	draw.RoundedBox(0, 0, 0, screen:GetWide(), 15, Color(30, 30, 30, 255))		
end

gPhone.addApp(APP)