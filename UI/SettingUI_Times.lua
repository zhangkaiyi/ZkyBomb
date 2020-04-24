local _addonName, _addon = ...;
local L = _addon:GetLocalization();

local parentFrame = ZKYBOMB_SETTINGUI_CHANNELS

local theFrame = CreateFrame("Frame", "ZKYBOMB_SETTINGUI_TIMES", parentFrame, "ButtonFrameTemplate");
theFrame:SetPoint('TOP', parentFrame, 'BOTTOM', 0, -5)
theFrame:SetPoint('LEFT', parentFrame, 'LEFT', 0, 0)
theFrame:SetPoint('RIGHT', parentFrame, 'RIGHT', 0, 0)
theFrame:SetPoint('BOTTOM', ZKYBOMB_SETTINGUI_MESSAGES, 'BOTTOM', 0, 0)
-- theFrame:SetWidth(320);
-- theFrame:SetHeight(MIN_ITEMS*LIST_ITEM_HEIGHT + HEIGHT_NO_CONTENT);
-- frame:SetResizable(true);
theFrame:SetClampedToScreen(true);
-- frame:SetMaxResize(600, MAX_ITEMS*LIST_ITEM_HEIGHT + HEIGHT_NO_CONTENT);
-- frame:SetMinResize(250, MIN_ITEMS*LIST_ITEM_HEIGHT + HEIGHT_NO_CONTENT);
-- frame:SetMovable(true);
theFrame:EnableMouse(true);
theFrame.TitleText:SetText('次数');
-- theFrame.portrait:SetTexture([[Interface\AddOns\ZkyBomb\img\logo]]);
-- frame.CloseButton:SetScript('OnClick',nil)
theFrame.CloseButton:Hide()
theFrame.TopRightCorner:SetWidth(18);
theFrame.TopRightCorner:SetTexCoord(0.75, 0.89062500, 0.00781250, 0.26562500);
theFrame.TitleBg:SetPoint("TOPLEFT",2,-3)
theFrame.TitleBg:SetPoint("TOPRIGHT",-2,-3)
-- ZKYBOMB_SettingUI2CloseButton:SetScript('OnClick',nil)
-- frame:Hide();

ButtonFrameTemplate_HideButtonBar(theFrame);
ButtonFrameTemplate_HidePortrait(theFrame);
-- ButtonFrameTemplate_HideAttic(theFrame);

--- Make an editbox
-- @param parent The parent frame
-- @param maxLen Maxmimum input length
-- @param height (optional)
-- @param isMultiline (optional)
local function MakeEditBox(parent, maxLen, height, isMultiline)
    local edit = CreateFrame("EditBox", nil, parent);
    edit:SetMaxLetters(maxLen);
    edit:SetAutoFocus(false);
    if height then
        edit:SetHeight(height);
    end
    edit:SetFontObject("GameFontWhite");
    edit:SetJustifyH("LEFT");
    edit:SetJustifyV("CENTER");
    edit:SetTextInsets(7,7,7,7);
    edit:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
        edgeSize = 14,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    });
    edit:SetBackdropColor(0, 0, 0);
    edit:SetBackdropBorderColor(0.3, 0.3, 0.3);
    if isMultiline then
        edit:SetSpacing(3);
        edit:SetMultiLine(true);
    end
    edit:SetScript("OnEnterPressed", function(self) self:ClearFocus(); end);
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus(); end);
    edit:SetScript("OnEditFocusLost", function(self) EditBox_ClearHighlight(self); end);

    return edit;
end

-- 当前次数
do
    theFrame.currentLabel = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.currentLabel:SetPoint("TOPLEFT", theFrame, "TOPLEFT", 10, -35);
    theFrame.currentLabel:SetText(L["UI_TIMES_CURRENT"]);
    theFrame.currentLabel:SetJustifyH("LEFT");
    theFrame.currentEdit = MakeEditBox(theFrame, 3, 27, false);
    theFrame.currentEdit:SetPoint("LEFT", theFrame.currentLabel, "RIGHT", 5, -1);
    theFrame.currentEdit:SetWidth(40);
    theFrame.currentEdit:SetNumeric(true)
    theFrame.currentEdit:SetScript('OnChar', mustnumber)
    theFrame.currentEdit:SetScript("OnTextChanged", function(self)
        _addon.sv.times:SetTimesCurrent(self:GetText())
    end);
end
-- 每轮次数
do
    theFrame.perRoundLabel = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.perRoundLabel:SetPoint("LEFT", theFrame.currentEdit, "RIGHT", 10, 1);
    theFrame.perRoundLabel:SetText(L["UI_TIMES_PERROUND"]);
    theFrame.perRoundLabel:SetJustifyH("LEFT");
    theFrame.perRoundEdit = MakeEditBox(theFrame, 3, 27, false);
    theFrame.perRoundEdit:SetPoint("LEFT", theFrame.perRoundLabel, "RIGHT", 5, -1);
    theFrame.perRoundEdit:SetWidth(40);
    theFrame.perRoundEdit:SetNumeric(true)
    theFrame.currentEdit:SetScript('OnChar', mustnumber)
    theFrame.perRoundEdit:SetScript("OnTextChanged", function(self) 
        _addon.sv.times:SetTimesPerRound(self:GetText())
    end);
end
-- 完成总数
do
    theFrame.totalLabel = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.totalLabel:SetPoint("LEFT", theFrame.perRoundEdit, "RIGHT", 10, 1);
    theFrame.totalLabel:SetText(L["UI_TIMES_TAOTAL"]);
    theFrame.totalLabel:SetJustifyH("LEFT");
    theFrame.totalEdit = MakeEditBox(theFrame, 3, 27, false);
    theFrame.totalEdit:SetPoint("LEFT", theFrame.totalLabel, "RIGHT", 5, -1);
    theFrame.totalEdit:SetWidth(40);
    theFrame.totalEdit:SetNumeric(true)
    theFrame.totalEdit:SetScript('OnChar', mustnumber)
    theFrame.totalEdit:SetScript("OnTextChanged", function(self) 
        _addon.sv.times:SetTimesTotal(self:GetText())
    end);
end

_addon.SENDTYPES = {
    ["PARTY"] = "队伍",
    ["YELL"] = "大喊",
    ["GUILD"] = "公会",
    ["RAID"] = "团队",
    ["SAY"] = "说"
};
local SENDTYPES = _addon.SENDTYPES;

-- Hanlde dropdown refresh
local function DropdownRefresh(self)
    print('DropdownRefresh')
    local optionName = "NOT SET!";
    for k,v in pairs(self.GetListItems()) do
        if k == svTable[self.settingName] then
            optionName = v;
            break;
        end
    end
    UIDropDownMenu_SetText(self, optionName);
end;
local function DropdownOpen(self, level, menuList)
    devPrint('DropdownOpen Start')
    local info = UIDropDownMenu_CreateInfo();
    info.func = function(selfb, k, v)
        _addon.sv.times:SetNotifyType(k)
        UIDropDownMenu_SetText(self, v);
    end;
        local sendType = _addon.sv.times:GetNotifyType()
        for arg1, arg2 in pairs(self.GetListItems()) do
        info.text = arg2;
        info.arg1 = arg1;
        info.arg2 = arg2;
        if sendType ~= nil then
            info.checked = (arg1 == sendType);
        else
            info.checked = false;
        end
        UIDropDownMenu_AddButton(info);
    end
    devPrint('DropdownOpen End')
end

do
    theFrame.increaseLabel = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.increaseLabel:SetPoint("TOPLEFT", theFrame.Inset, "TOPLEFT", 10, -15);
    theFrame.increaseLabel:SetText('计数通知');
    theFrame.increaseLabel:SetJustifyH("LEFT");
    theFrame.increaseEdit = MakeEditBox(theFrame, 100, 27, false);
    theFrame.increaseEdit:SetPoint("LEFT", theFrame.increaseLabel, "RIGHT", 5, -1);
    theFrame.increaseEdit:SetPoint("RIGHT", theFrame.Inset, "RIGHT", -10, -1);
    theFrame.increaseEdit:SetScript("OnTextChanged", function(self) 
        _addon.sv.times:SetIncreaseMessage(self:GetText())
    end);
end

do
    theFrame.messageLabel = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.messageLabel:SetPoint("TOPLEFT", theFrame.increaseLabel, "BOTTOMLEFT", 0, -20);
    theFrame.messageLabel:SetText('清零通知');
    theFrame.messageLabel:SetJustifyH("LEFT");
    theFrame.messageEdit = MakeEditBox(theFrame, 100, 27, false);
    theFrame.messageEdit:SetPoint("LEFT", theFrame.messageLabel, "RIGHT", 5, -1);
    theFrame.messageEdit:SetPoint("RIGHT", theFrame.Inset, "RIGHT", -10, -1);
    theFrame.messageEdit:SetScript("OnTextChanged", function(self) 
        _addon.sv.times:SetResetMessage(self:GetText())
    end);
end

do
    theFrame.isNotifyLabel = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.isNotifyLabel:SetPoint("TOPLEFT", theFrame.messageLabel, "BOTTOMLEFT", 0, -15);
    theFrame.isNotifyLabel:SetText('是否通知');
    theFrame.isNotifyLabel:SetJustifyH("LEFT");
    theFrame.isNotifyCheckbox = CreateFrame("CheckButton", nil, theFrame);
    theFrame.isNotifyCheckbox:SetScript("OnClick", function(self)	
        local svTable = _addon:GetSavedVariables()
        if svTable then
            _addon.sv.times:SetIsNotify(self:GetChecked());
        end
    end);
    theFrame.isNotifyCheckbox:SetNormalTexture([[Interface\Buttons\UI-CheckBox-Up]]);
    theFrame.isNotifyCheckbox:SetPushedTexture([[Interface\Buttons\UI-CheckBox-Down]]);
    theFrame.isNotifyCheckbox:SetHighlightTexture([[Interface\Buttons\UI-CheckBox-Highlight]], "ADD");
    theFrame.isNotifyCheckbox:SetCheckedTexture([[Interface\Buttons\UI-CheckBox-Check]]);
    theFrame.isNotifyCheckbox:SetDisabledCheckedTexture([[Interface\Buttons\UI-CheckBox-Check-Disabled]]);
    theFrame.isNotifyCheckbox:SetPoint("LEFT", theFrame.isNotifyLabel, "RIGHT", 5, -1);
    theFrame.isNotifyCheckbox:SetSize(24, 24);
    -- theFrame.isNotifyCheckbox:SetPoint("RIGHT", theFrame.Inset, "RIGHT", 10, 0);
end

do
    theFrame.isNotifyLabel2 = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.isNotifyLabel2:SetPoint("TOPLEFT", theFrame.isNotifyLabel, "BOTTOMLEFT", 0, -15);
    theFrame.isNotifyLabel2:SetText('进本提示');
    theFrame.isNotifyLabel2:SetJustifyH("LEFT");
    theFrame.isNotifyCheckbox2 = CreateFrame("CheckButton", nil, theFrame);
    theFrame.isNotifyCheckbox2:SetScript("OnClick", function(self)	
        local svTable = _addon:GetSavedVariables()
        if svTable then
            _addon.sv.times:SetIsNotify(self:GetChecked());
        end
    end);
    theFrame.isNotifyCheckbox2:SetNormalTexture([[Interface\Buttons\UI-CheckBox-Up]]);
    theFrame.isNotifyCheckbox2:SetPushedTexture([[Interface\Buttons\UI-CheckBox-Down]]);
    theFrame.isNotifyCheckbox2:SetHighlightTexture([[Interface\Buttons\UI-CheckBox-Highlight]], "ADD");
    theFrame.isNotifyCheckbox2:SetCheckedTexture([[Interface\Buttons\UI-CheckBox-Check]]);
    theFrame.isNotifyCheckbox2:SetDisabledCheckedTexture([[Interface\Buttons\UI-CheckBox-Check-Disabled]]);
    theFrame.isNotifyCheckbox2:SetPoint("LEFT", theFrame.isNotifyLabel2, "RIGHT", 5, -1);
    theFrame.isNotifyCheckbox2:SetSize(24, 24);
    -- theFrame.isNotifyCheckbox:SetPoint("RIGHT", theFrame.Inset, "RIGHT", 10, 0);
end

do
    theFrame.isNotifyLabel3 = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.isNotifyLabel3:SetPoint("TOPLEFT", theFrame.isNotifyLabel2, "BOTTOMLEFT", 0, -15);
    theFrame.isNotifyLabel3:SetText('完成提示');
    theFrame.isNotifyLabel3:SetJustifyH("LEFT");
    theFrame.isNotifyCheckbox3 = CreateFrame("CheckButton", nil, theFrame);
    theFrame.isNotifyCheckbox3:SetScript("OnClick", function(self)	
        local svTable = _addon:GetSavedVariables()
        if svTable then
            _addon.sv.times:SetIsNotify(self:GetChecked());
        end
    end);
    theFrame.isNotifyCheckbox3:SetNormalTexture([[Interface\Buttons\UI-CheckBox-Up]]);
    theFrame.isNotifyCheckbox3:SetPushedTexture([[Interface\Buttons\UI-CheckBox-Down]]);
    theFrame.isNotifyCheckbox3:SetHighlightTexture([[Interface\Buttons\UI-CheckBox-Highlight]], "ADD");
    theFrame.isNotifyCheckbox3:SetCheckedTexture([[Interface\Buttons\UI-CheckBox-Check]]);
    theFrame.isNotifyCheckbox3:SetDisabledCheckedTexture([[Interface\Buttons\UI-CheckBox-Check-Disabled]]);
    theFrame.isNotifyCheckbox3:SetPoint("LEFT", theFrame.isNotifyLabel3, "RIGHT", 5, -1);
    theFrame.isNotifyCheckbox3:SetSize(24, 24);
    -- theFrame.isNotifyCheckbox:SetPoint("RIGHT", theFrame.Inset, "RIGHT", 10, 0);
end

do
    theFrame.sendTypeLabel = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.sendTypeLabel:SetPoint("LEFT", theFrame.isNotifyCheckbox, "RIGHT", 5, 0);
    theFrame.sendTypeLabel:SetPoint("TOP", theFrame.isNotifyLabel, "TOP", 0, 0);
    theFrame.sendTypeLabel:SetText('通知类型');
    theFrame.sendTypeLabel:SetJustifyH("LEFT");
    theFrame.sendTypeDropdown = CreateFrame("Frame", nil, theFrame, "UIDropDownMenuTemplate");
    theFrame.sendTypeDropdown:SetPoint("LEFT", theFrame.sendTypeLabel, "RIGHT", -10, -3);
    -- theFrame.sendTypeDropdown:SetPoint("RIGHT", theFrame.Inset, "RIGHT", 10, 0);
    theFrame.sendTypeDropdown.RefreshState = DropdownRefresh;
    theFrame.sendTypeDropdown.GetListItems = function() return SENDTYPES end;
    UIDropDownMenu_SetWidth(theFrame.sendTypeDropdown, theFrame.messageEdit:GetWidth()-theFrame.isNotifyLabel:GetWidth() -24 -5 -10);
    -- UIDropDownMenu_SetText(resetFrame.sendTypeDropdown,'队伍')
    UIDropDownMenu_Initialize(theFrame.sendTypeDropdown, DropdownOpen)
end
