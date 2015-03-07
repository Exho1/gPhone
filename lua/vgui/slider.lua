local PANEL = {}


function PANEL:Init()	
	
	self.bgCol = color_black
	self.fgCol = Color( 200, 200, 200 )
	self.kCol = color_white
	self.cornerRadius = 2 

	self.knob = vgui.Create( "DButton", self )
	self.knob:SetText( "" )
	self.knob:SetSize( 15, 15 )
	self.knob:NoClipping( true )
	self.knob.Paint = function( panel, w, h ) 
		draw.RoundedBox( 8, 0, 0, w, h, self.kCol )
	end
	self.knob.OnCursorMoved = function( panel, origX, origY ) 
		local x, y = panel:LocalToScreen( origX, origY )
		x, y = self:ScreenToLocal( x, y )
		
		if panel:IsDown() then
			self.dragging = true
			x = math.Clamp(x, 0, self:GetWide())
			self:SetValue( x / self:GetWide() )
		else
			self.dragging = false
		end
	end
end

function PANEL:SetMin( num )
	self.min = num
end

function PANEL:SetMax( num )
	self.max = num
end

function PANEL:SetValue( num )
	self.value = num
	self.filled = self.value / (self.max - self.min)
	self.knob:SetPos( self:GetWide() * self.filled - self.knob:GetWide()/2, 0 )
	self:OnValueChanged( self.value )
end

function PANEL:SetBackgroundColor( col )
	self.bgCol = col
end

function PANEL:SetForegroundColor( col )
	self.fgCol = col
end

function PANEL:SetKnobColor( col )
	self.kCol = col
end

function PANEL:GetValue()
	return self.value
end

function PANEL:GetPercent()
	return self.filled * 100
end

function PANEL:IsDown()
	return self.dragging
end

function PANEL:SetCornerRadius( num )
	self.cornerRadius = num
end

function PANEL:SetWide( w )
	self:SetSize( w, 10 )
end

function PANEL:OnValueChanged( val )
	
end

function PANEL:Paint( w, h )
	draw.RoundedBox( self.cornerRadius, 0, h/2, w, h/4, self.bgCol )
	local width = self:GetWide() * self.filled - self.knob:GetWide()/2
	draw.RoundedBox( self.cornerRadius, 0, h/2, width, h/4, self.fgCol )
end


derma.DefineControl( "gPhoneSlider", "iOS Style", PANEL, "Panel" )





