local PANEL = {}

function PANEL:Init()

	self:SetSize(40, 25)
	self:SetText("")
	
	self.toggled = false
end

function PANEL:SetBool( b )
	self.toggled = b
end

function PANEL:DoClick()
	self.toggled = !self.toggled
	self:OnValueChanged( self.toggled )
end

function PANEL:Paint( w, h )
	local col, x
	if self.toggled then
		col = gPhone.colors.green
		x = self:GetWide() - self:GetWide()/2 - 2
	else
		col = gPhone.colors.darkerWhite
		x = 2
	end
	
	draw.RoundedBox(10, 0, 0, self:GetWide(), self:GetTall(), gPhone.colors.greyAccent )
	draw.RoundedBox(10, 1, 1, self:GetWide() - 2, self:GetTall()-2, col )
	
	draw.RoundedBox(10, x, 2, self:GetWide()/2, self:GetTall()-4, color_white )
end


derma.DefineControl( "gPhoneToggleButton", "iOS Style", PANEL, "DButton" )





