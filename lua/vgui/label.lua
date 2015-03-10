local PANEL = {}

function PANEL:SetTextColor( col )

	self:SetTextColor( col )
	self:SetFGColor( col )
	
end

function PANEL:Think()
	
	self:SetFGColor( self:GetTextColor() ) 
	
end	

derma.DefineControl( "gPhoneLabel", "iOS Style", PANEL, "DLabel" )





