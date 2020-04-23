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

-- Times Management
do
    local timesFrame = theFrame;
    timesFrame.currentLabel = timesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    timesFrame.currentLabel:SetPoint("TOPLEFT", theFrame, "TOPLEFT", 10, -35);
    timesFrame.currentLabel:SetText(L["UI_TIMES_CURRENT"]);
    timesFrame.currentLabel:SetJustifyH("LEFT");
    timesFrame.currentEdit = MakeEditBox(timesFrame, 3, 27, false);
    timesFrame.currentEdit:SetPoint("LEFT", timesFrame.currentLabel, "RIGHT", 5, -1);
    timesFrame.currentEdit:SetWidth(40);
    timesFrame.currentEdit:SetNumeric(true)
    timesFrame.currentEdit:SetScript('OnChar', mustnumber)
    timesFrame.currentEdit:SetScript("OnTextChanged", function(self)
        local svTable = _addon:GetSavedVariables()
        if svTable then
            svTable['Times']['Current'] = self:GetText()
        end
    end);
end

do
    local timesFrame = theFrame;
    timesFrame.perRoundLabel = timesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    timesFrame.perRoundLabel:SetPoint("LEFT", timesFrame.currentEdit, "RIGHT", 10, 1);
    timesFrame.perRoundLabel:SetText(L["UI_TIMES_PERROUND"]);
    timesFrame.perRoundLabel:SetJustifyH("LEFT");
    timesFrame.perRoundEdit = MakeEditBox(timesFrame, 3, 27, false);
    timesFrame.perRoundEdit:SetPoint("LEFT", timesFrame.perRoundLabel, "RIGHT", 5, -1);
    timesFrame.perRoundEdit:SetWidth(40);
    timesFrame.perRoundEdit:SetNumeric(true)
    timesFrame.currentEdit:SetScript('OnChar', mustnumber)
    timesFrame.perRoundEdit:SetScript("OnTextChanged", function(self) 
        local svTable = _addon:GetSavedVariables()
        if svTable then
            svTable['Times']['PerRound'] = self:GetText()
        end
    end);
end

do
    local timesFrame = theFrame;
    timesFrame.totalLabel = timesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    timesFrame.totalLabel:SetPoint("LEFT", timesFrame.perRoundEdit, "RIGHT", 10, 1);
    timesFrame.totalLabel:SetText(L["UI_TIMES_TAOTAL"]);
    timesFrame.totalLabel:SetJustifyH("LEFT");
    timesFrame.totalEdit = MakeEditBox(timesFrame, 3, 27, false);
    timesFrame.totalEdit:SetPoint("LEFT", timesFrame.totalLabel, "RIGHT", 5, -1);
    timesFrame.totalEdit:SetWidth(40);
    timesFrame.totalEdit:SetNumeric(true)
    timesFrame.totalEdit:SetScript('OnChar', mustnumber)
    timesFrame.totalEdit:SetScript("OnTextChanged", function(self) 
        local svTable = _addon:GetSavedVariables()
        if svTable then
            svTable['Times']['Total'] = self:GetText()
        end
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
        ZkyBombDB.Times.Reset.MessageSendType = k;
        UIDropDownMenu_SetText(self, v);
    end;
        local sendType = _addon:GetResetMessageSendType()
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
    local resetFrame = theFrame;
    resetFrame.increaseLabel = resetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    resetFrame.increaseLabel:SetPoint("TOPLEFT", resetFrame.Inset, "TOPLEFT", 10, -15);
    resetFrame.increaseLabel:SetText('计数通知');
    resetFrame.increaseLabel:SetJustifyH("LEFT");
    resetFrame.increaseEdit = MakeEditBox(resetFrame, 100, 27, false);
    resetFrame.increaseEdit:SetPoint("LEFT", resetFrame.increaseLabel, "RIGHT", 5, -1);
    resetFrame.increaseEdit:SetPoint("RIGHT", resetFrame.Inset, "RIGHT", -10, -1);
    resetFrame.increaseEdit:SetScript("OnTextChanged", function(self) 
        
    end);
end

do
    local resetFrame = theFrame;
    resetFrame.messageLabel = resetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    resetFrame.messageLabel:SetPoint("TOPLEFT", resetFrame.increaseLabel, "BOTTOMLEFT", 0, -20);
    resetFrame.messageLabel:SetText('重置通知');
    resetFrame.messageLabel:SetJustifyH("LEFT");
    resetFrame.messageEdit = MakeEditBox(resetFrame, 100, 27, false);
    resetFrame.messageEdit:SetPoint("LEFT", resetFrame.messageLabel, "RIGHT", 5, -1);
    resetFrame.messageEdit:SetPoint("RIGHT", resetFrame.Inset, "RIGHT", -10, -1);
    resetFrame.messageEdit:SetScript("OnTextChanged", function(self) 
        ZkyBombDB.Times.Reset.Message = self:GetText()
    end);
end

do
    local resetFrame = theFrame;
    resetFrame.sendTypeLabel = resetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    resetFrame.sendTypeLabel:SetPoint("TOPLEFT", resetFrame.messageLabel, "BOTTOMLEFT", 0, -20);
    resetFrame.sendTypeLabel:SetText('通知类型');
    resetFrame.sendTypeLabel:SetJustifyH("LEFT");
    resetFrame.sendTypeDropdown = CreateFrame("Frame", nil, resetFrame, "UIDropDownMenuTemplate");
    resetFrame.sendTypeDropdown:SetPoint("LEFT", resetFrame.sendTypeLabel, "RIGHT", -10, -4);
    resetFrame.sendTypeDropdown:SetPoint("RIGHT", resetFrame.Inset, "RIGHT", 10, 0);
    resetFrame.sendTypeDropdown.RefreshState = DropdownRefresh;
    resetFrame.sendTypeDropdown.GetListItems = function() return SENDTYPES end;
    UIDropDownMenu_SetWidth(resetFrame.sendTypeDropdown, resetFrame.messageEdit:GetWidth()-10);
    -- UIDropDownMenu_SetText(resetFrame.sendTypeDropdown,'队伍')
    UIDropDownMenu_Initialize(resetFrame.sendTypeDropdown, DropdownOpen)
end