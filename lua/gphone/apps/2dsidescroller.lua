local APP = {}

APP.PrintName = "2D Game" 
APP.Icon = "vgui/gphone/app_image.png"
APP.Author = "Exho"
APP.FPS = 30

local gameRunning = false

local img_main_player = "vgui/gphone/apps/2d_player.png"
local img_player = Material( "vgui/gphone/apps/2d_player_side.png" )
local img_player_jump = Material( "vgui/gphone/apps/2d_player_side_jump.png" )
local img_player_arm = Material( "vgui/gphone/apps/2d_arm_mount.png" )
local img_player_front = Material( "vgui/gphone/apps/2d_player.png" )

local img_bullet = Material( "vgui/gphone/apps/2d_bullet.png" )
local img_explosion = Material( "vgui/gphone/apps/2d_explosion.png" )


local groundLevel = 0
local gravity = 0.2
local jumpTime = 0

function APP.Run( objects, screen )
	gPhone.setOrientation( "landscape" )
	gPhone.hideStatusBar()
	
	groundLevel = screen:GetTall() - screen:GetTall()/4
	gameRunning = false
	
	local options = {
		"Single Player",
		"Options",
	}
	
	objects.Layout = vgui.Create( "DIconLayout", screen)
	objects.Layout:SetSize( screen:GetWide(), screen:GetTall())
	objects.Layout:SetPos( 0, 20 )
	objects.Layout:SetSpaceY( 0 )
	
	local titleButton = objects.Layout:Add("DButton")
	titleButton:SetSize(screen:GetWide(), 50)
	titleButton:SetText("")
	titleButton.Paint = function( self, w, h )
		if self:IsDown() then
			--draw.RoundedBox(2, 5, 5, w-10, h-10, Color(180, 180, 180))
		end
		draw.RoundedBox(2,  w/2 - w/4, 5, w/2, h-10, Color(31, 118, 175))
			
		surface.SetDrawColor( color_white )
		surface.DrawOutlinedRect( w/2 - w/4, 5, w/2, h-10 )
	end
	
	local title = vgui.Create( "DLabel", titleButton)
	title:SetTextColor( color_white )
	title:SetFont("gPhone_22")
	title:SizeToContents()
	gPhone.setTextAndCenter(title, "My 2D Game", titleButton, true)
	
	--[[local fake = objects.Layout:Add("DPanel")
	fake:SetSize(screen:GetWide(), 50)
	fake.Paint = function() end]]
	
	local imageBackground = objects.Layout:Add("DPanel")
	imageBackground:SetSize(screen:GetWide(), 50)
	imageBackground.Paint = function() end
	
	local image = vgui.Create( "DImage", imageBackground )
	image:SetImage( img_main_player )
	image:SetSize( 50, 50 )
	image:SetPos( imageBackground:GetWide()/2 - image:GetWide()/2, 0)
	--image:SetSize(screen:GetWide(), 30)
	
	for k, text in pairs( options ) do
		local titleButton = objects.Layout:Add("DButton")
		titleButton:SetSize(screen:GetWide(), 50)
		titleButton:SetText("")
		titleButton.Paint = function( self, w, h )
			if self:IsDown() then
				--draw.RoundedBox(2, 5, 5, w-10, h-10, Color(180, 180, 180))
			end
			
			draw.RoundedBox(2,  w/2 - w/4, 5, w/2, h-10, Color(41, 128, 185))
			
			surface.SetDrawColor( color_white )
			surface.DrawOutlinedRect( w/2 - w/4, 5, w/2, h-10 )
		end
		titleButton.DoClick = function( self )
			if text == options[1] then
				APP.SetUpGame( objects )
			end
		end
		
		local title = vgui.Create( "DLabel", titleButton)
		title:SetTextColor( color_white )
		title:SetFont("gPhone_22")
		title:SizeToContents()
		gPhone.setTextAndCenter(title, text, titleButton, true)
	end
	
end

function APP.SetUpGame( objects )
	local screen = gPhone.phoneScreen
	
	gameRunning = true
	
	objects.Layout:SetVisible( false )
	
	objects.Player = vgui.Create("DPanel", screen)
	objects.Player:SetSize( 32, 64 )
	objects.Player:SetPos( 15, groundLevel - objects.Player:GetTall())
	objects.Player.Texture = img_player
	objects.Player.Paint = function( self, w, h )
		surface.SetDrawColor( color_white )
		surface.SetMaterial( self.Texture ) 
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	objects.Player.Health = 100
	objects.Player.VelocityX = 0
	objects.Player.VelocityY = 0
	
	objects.PlayerArm = vgui.Create("DPanel", screen)
	objects.PlayerArm:SetSize( 32, 64 )
	objects.PlayerArm.Rotation = 0
	objects.PlayerArm.Paint = function( self, w, h )
		--draw.RoundedBox(0, 0, 0, w, h, color_white )
		
		surface.SetDrawColor( color_white )
		surface.SetMaterial( img_player_arm ) 
		
		self.Rotation = math.Clamp(self.Rotation, -90, 90)
		surface.DrawTexturedRectRotated( 5, 25, w*1.5, w/2, self.Rotation )
	end
	objects.PlayerArm.Think = function( self )
		local x, y = objects.Player:GetPos()
		objects.PlayerArm:SetPos( x, y )
	end
	objects.PlayerArm.GetPos = function() -- Returns the true location of the arm, the pivot point
		local pX, pY = objects.Player:GetPos()
		local armMountPos = { x=pX+5, y=pY+25 }
		return armMountPos.x, armMountPos.y
	end
	objects.PlayerArm.GetGunPos = function( self )
		local gunX, gunY = 0,0
		local armX, armY = self:GetPos()
		local w, h = self:GetSize()
		local ang = self.Rotation
	
		-- I need to find the gun's barrel position 
		gunX = armX + w
		gunY = armY + w
		
		return gunX, gunY
	end
	
	-- Detect shooting
	screen.OnMousePressed = function( self, code )
		if code == MOUSE_LEFT then
			objects.Player.ShouldFire = true
		end
	end
	
	objects.Bullets = {}
end

local shotCount = 0
local function createBullet( x, y )
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	local projectile = vgui.Create("DPanel", screen)
	projectile:SetSize( 8, 4 )
	projectile:SetPos( x, y )
	projectile.Rotation = 0
	projectile.Paint = function( self, w, h )
		draw.RoundedBox(0, 0, 0, w, h, color_white )
		
		surface.SetDrawColor( color_white )
		surface.SetMaterial( img_bullet ) 
		
		surface.DrawTexturedRectRotated( w/2, h/2, w, w, self.Rotation )
	end
	projectile.VelocityX = 0
	projectile.VelocityY = 0
	
	objects.Bullets[shotCount] = projectile
	shotCount = shotCount + 1
	
	return projectile
end

local function shootBullet()
	local objects = gApp["_children_"]
	
	if objects.Player.ShouldFire == true then
		local x, y = objects.PlayerArm:GetPos()
		local ang = objects.PlayerArm.Rotation
		
		-- The bullet needs to be created where the gun's barrel is
		--local gX, gY = get gun pos
		local bullet = createBullet( x + objects.Player:GetWide(), y )
		
		local mX, mY = gPhone.phoneScreen:ScreenToLocal( gui.MouseX(), gui.MouseY() )
		local shootAngle = math.atan2((mY - y), (mX - x))
		shootAngle = -math.Clamp(shootAngle, -90, 90) 
		
		if math.deg(shootAngle) > 90 or math.deg(shootAngle) < -90 then
			bullet:Remove()
			return
		end
		
		-- The bullet needs proper velocity for its trajectory
		bullet.VelocityX = math.cos(shootAngle) * 5 
		bullet.VelocityY = math.sin(-shootAngle) * 5
		bullet.Rotation = shootAngle
	
		objects.Player.ShouldFire = false
	end
end

local function movePlayer( x, y )
	local objects = gApp["_children_"]
	objects.Player.VelocityX = x or objects.Player.VelocityX
	objects.Player.VelocityY = y or objects.Player.VelocityY
end

local spaceHoldTime = 0
local function grabKeys()
	local objects = gApp["_children_"]
	
	if input.IsKeyDown( KEY_A ) then
		movePlayer( -3, nil )
	elseif input.IsKeyDown( KEY_D ) then
		movePlayer( 3, nil )
	end
	
	if input.IsKeyDown( KEY_SPACE ) and spaceHoldTime < 5 then
		movePlayer( nil, -5 )
		jumpTime = 5
		spaceHoldTime = spaceHoldTime + 1
	end
end

local function moveGun()
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	
	local mX, mY = screen:ScreenToLocal( gui.MouseX(), gui.MouseY() )
	local aX, aY = objects.PlayerArm:GetPos()
	
	local difX = mX - aX
	local difY = mY - aY
	local ang = math.deg( math.atan2( difY, difX ) )
	
	objects.PlayerArm.Rotation = -ang
end

local function handleVelocity()
	local objects = gApp["_children_"]
	for num, pnl in pairs(objects) do
		if IsValid(pnl) then
			if pnl.VelocityX and pnl.VelocityY then
				local x, y = pnl:GetPos()
				pnl:SetPos(x + pnl.VelocityX, y + pnl.VelocityY)
			end
		end
	end
	
	for num, pnl in pairs(objects.Bullets) do
		if IsValid(pnl) then
			local x, y = pnl:GetPos()
			pnl:SetPos(x + pnl.VelocityX, y + pnl.VelocityY)
		else
			objects.Bullets[num] = nil
		end
	end
end

local function handleGravity()
	local objects = gApp["_children_"]
	for num, pnl in pairs(objects) do
		if IsValid(pnl) then
			if pnl.VelocityX and pnl.VelocityY then
				local x, y = pnl:GetPos()
				if pnl.VelocityX < 0 then
					pnl.VelocityX = pnl.VelocityX * -gravity
				else
					pnl.VelocityX = pnl.VelocityX * gravity
				end
				--pnl.VelocityY = math.Clamp(pnl.VelocityY + (jumpTime * gravity), -3, 3)
				
				y = math.Clamp(y, 0, 111)
				if y == 111 then
					objects.Player.Texture = img_player
					pnl.OnGround = true
					spaceHoldTime = 0
				else
					objects.Player.Texture = img_player_jump
					pnl.VelocityY = math.Clamp(pnl.VelocityY + (jumpTime * gravity), -3, 3)
					pnl.OnGround = false
				end
				
				pnl:SetPos( x, y )
			end
		end
	end
end

local function handleCollisions()
	local objects = gApp["_children_"]
	local screen = gPhone.phoneScreen
	for num, pnl in pairs(objects) do
		if IsValid(pnl) and pnl != objects.PlayerArm then
			local x, y = pnl:GetPos()
			
			x = math.Clamp( x, 0, screen:GetWide() )
			y = math.Clamp( y, 0, groundLevel )
			pnl:SetPos( x, y )
		end
	end
	for num, pnl in pairs(objects.Bullets) do
		if IsValid(pnl) then
			local x, y = pnl:GetPos()
			
			if y >= groundLevel then
				pnl:Remove()
			end
			
			if x <= 0 then
				pnl:Remove()
			else
			
			end
			pnl:SetPos( x, y )
		end
	end
end

function APP.Think( screen )
	
	if gameRunning then
		grabKeys()
		
		moveGun()
		shootBullet()
		
		handleVelocity()
		handleGravity()
		handleCollisions()
	end
end

function APP.Paint( screen )
	draw.RoundedBox(2, 0, 0, screen:GetWide(), screen:GetTall(), Color(135, 206, 235))
	
	draw.RoundedBox(2, 40, 20, 20, 20, Color(253, 184, 19))
	
	draw.RoundedBox(2, 0, groundLevel, screen:GetWide(), screen:GetTall() - groundLevel, Color(227, 211, 175))
end


--gPhone.addApp(APP)