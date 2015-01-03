local PANEL = {}


function PANEL:Init()

	self.m_ImageButton = vgui.Create( "DImage", self )
	self.m_ImageButton:SetImage( "vgui/gphone/left_arrow.png" )
	self.m_ImageButton:SetSize( self:GetTall()/2, self:GetTall() )
	local x, y = self.m_ImageButton:GetPos()
	self.m_ImageButton:SetPos( 0, y  )
	self.m_Label = vgui.Create("DLabel", self)
	self.m_Label:SetText( "Back" )
	self.m_Label:SetFont( "gPhone_18Lite" )
	self.m_Label:SizeToContents()
	local x, y = self.m_Label:GetPos()
	self.m_Label:SetPos( 15, y + 1 )
	
	self:SetText("")
	local w, h = self:GetSize()
	self:SetSize( 15 + self.m_Label:GetWide(), h )
end

function PANEL:SetFont( font )

	self.m_Label:SetFont( font )

end

function PANEL:SetTextColor( col )

	self.m_Label:SetTextColor( col )
	self.m_ImageButton:SetImageColor( col )

end

function PANEL:Paint( w, h )
	
end


derma.DefineControl( "gPhoneBackButton", "iOS Style", PANEL, "DButton" )





