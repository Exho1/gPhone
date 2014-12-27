--[[
if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName 				= "gPhone"
SWEP.Author					= "Exho"
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Category				= "Garry Phone" 

SWEP.Slot					= 3
SWEP.SlotPos				= 1
SWEP.DrawAmmo 				= false
SWEP.DrawCrosshair 			= false
SWEP.HoldType				= "normal"
SWEP.Primary.Ammo       	= "none"
SWEP.Spawnable			 	= true
SWEP.AdminSpawnable			= true 

SWEP.ViewModel           	= ""
SWEP.WorldModel          	= ""
SWEP.ViewModelFlip		 	= false

if not IsValid(gPhone) then
	-- If the phone hasn't loaded by now, force it to
	include("autorun/phone_config.lua")
end

function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end

function SWEP:Deploy()
	-- Hacky fix for console spam due to no view model
	self.Owner:ConCommand( "con_filter_enable 1" )
	self.Owner:ConCommand( "con_filter_text_out mod_studio: MOVETYPE_FOLLOW with no model" )
	
	if CLIENT then
		gPhone.BuildPhone()
	end
	return true
end

function SWEP:Holster()
	self.Owner:ConCommand( "gphone_close" )
	return true
end

function SWEP:OnDrop()
	self.Owner:ConCommand( "gphone_close" )
	SafeRemoveEntityDelayed( self, 0.5 )
end

function SWEP:OnRemove()
	self.Owner:ConCommand( "gphone_close" )
end


Giving Exho a swep_construction_kit
*********************************************
SWEP.HoldType = "pistol"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_357.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {
	["Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, -0.186, 0), angle = Angle(21.111, 0, 38.888) },
	["Base"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 2.036), angle = Angle(0, 0, 0) },
	["Arm"] = { scale = Vector(1, 1, 1), pos = Vector(-30, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger0"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -25.556, 0) },
	["Bip01_L_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -10, 0) },
	["Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(11.666, 0, 0), angle = Angle(0, 0, 0) },
	["Bip01_L_Finger4"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 27.777, 0) }
}
*********************************************
Code printed to console!


]]

