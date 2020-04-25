local _, _addon = ...
local L = _addon:GetLocalization();

_addon.dialog = "Dialog Lib"

local CreateFrame = CreateFrame
local UIParent = UIParent

local me = {}

function me:CreateResetWindow()
	me.ResetFrame = CreateFrame("Frame", nil, UIParent)

	local theFrame = me.ResetFrame

	theFrame:ClearAllPoints()
	theFrame:SetPoint("BOTTOM", ZKYBOMB_MainUI, 'TOP', 0, 20)
	theFrame:SetHeight(100)
	theFrame:SetWidth(210)

	theFrame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\AddOns\\ZkyBomb\\textures\\otravi-semi-full-border", edgeSize = 32,
		insets = {left = 1, right = 1, top = 20, bottom = 1},
	})
	theFrame:SetBackdropBorderColor(1.0, 0.0, 0.0)
	theFrame:SetBackdropColor(24 / 255, 24 / 255, 24 / 255)
	-- Recount.Colors:RegisterBorder("Other Windows","Title",theFrame)
	-- Recount.Colors:RegisterBackground("Other Windows","Background",theFrame)

	theFrame:EnableMouse(true)
	theFrame:SetMovable(true)


	theFrame:SetScript("OnMouseDown", function(this, button)
		if (((not this.isLocked) or (this.isLocked == 0)) and (button == "LeftButton")) then
			-- Recount:SetWindowTop(this)
			this:StartMoving()
			this.isMoving = true
		end
	end)
	theFrame:SetScript("OnMouseUp", function(this)
		if (this.isMoving) then
			this:StopMovingOrSizing()
			this.isMoving = false
		end
	end)
	theFrame:SetScript("OnShow", function(this)
		-- Recount:SetWindowTop(this)
	end)
	theFrame:SetScript("OnHide", function(this)
		if (this.isMoving) then
			this:StopMovingOrSizing()
			this.isMoving = false
		end
	end)

	theFrame.Title = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	theFrame.Title:SetPoint("TOPLEFT", theFrame, "TOPLEFT", 6, -15)
	theFrame.Title:SetTextColor(1.0, 1.0, 1.0, 1.0)
	theFrame.Title:SetText(L["Reset Times?"])
	-- Recount:AddFontString(theFrame.Title)

	-- Recount.Colors:UnregisterItem(me.ResetFrame.Title)
	-- Recount.Colors:RegisterFont("Other Windows", "Title Text", me.ResetFrame.Title)

	theFrame.Text = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	theFrame.Text:SetPoint("CENTER", theFrame, "CENTER", 0, 0)
	theFrame.Text:SetTextColor(1.0, 1.0, 1.0)
	theFrame.Text:SetText(L["This time is in instance. Do you wish to increase the time count?"])
	-- Recount:AddFontString(theFrame.Text)

	theFrame.YesButton = CreateFrame("Button", nil, theFrame, "OptionsButtonTemplate")
	theFrame.YesButton:SetWidth(90)
	theFrame.YesButton:SetHeight(28)
	theFrame.YesButton:SetPoint("BOTTOMRIGHT", theFrame, "BOTTOM", -4, 4)
	theFrame.YesButton:SetScript("OnClick", function()
		-- Recount:ResetData()
		-- _addon:ResetCurrentTimes()
		_addon.func.times:Increase()
		theFrame:Hide()
	end)
	theFrame.YesButton:SetText(L["Yes"])

	theFrame.NoButton = CreateFrame("Button", nil, theFrame, "OptionsButtonTemplate")
	theFrame.NoButton:SetWidth(90)
	theFrame.NoButton:SetHeight(28)
	theFrame.NoButton:SetPoint("BOTTOMLEFT", theFrame, "BOTTOM", 4, 4)
	theFrame.NoButton:SetScript("OnClick", function()
		theFrame:Hide()
	end)
	theFrame.NoButton:SetText(L["No"])

	theFrame:Hide()

	theFrame:SetFrameStrata("DIALOG")

	--Need to add it to our window ordering system
	-- Recount:AddWindow(theFrame)
end

function _addon:ShowIncrease()
	if me.ResetFrame == nil then
		me:CreateResetWindow()
	end

	me.ResetFrame:Show()
end

function _addon:HideIncrease()
	if me.ResetFrame == nil then
		me:CreateResetWindow()
	end

	me.ResetFrame:Hide()
end