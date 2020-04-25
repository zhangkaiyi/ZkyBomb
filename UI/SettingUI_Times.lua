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
    -- devPrint('DropdownOpen Start')
    local info = UIDropDownMenu_CreateInfo()
    info.func = function(selfb, k, v)
        _addon.sv.times:SetNotifyType(k)
        UIDropDownMenu_SetText(self, v)
    end

    local notifyType = _addon.sv.times:GetNotifyType()

    for arg1, arg2 in pairs(self.GetListItems()) do
        info.text = arg2
        info.arg1 = arg1
        info.arg2 = arg2
        if notifyType ~= nil then
            info.checked = (arg1 == notifyType)
        else
            info.checked = false
        end
        UIDropDownMenu_AddButton(info)
    end
    -- devPrint('DropdownOpen End')
end


do
    local cb = MakeCheckbox(theFrame, nil, 24, 24)
    cb:SetPoint('TOPLEFT', theFrame.Inset, 'TOPLEFT', 8, -12)
    theFrame.cbNotifyIncrease = cb
    theFrame.labelNotifyIncrease = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.labelNotifyIncrease:SetPoint("LEFT", cb, "RIGHT", 5, 2);
    theFrame.labelNotifyIncrease:SetText('计数通知');
    theFrame.labelNotifyIncrease:SetJustifyH("LEFT");
    theFrame.editNotifyIncrease = MakeEditBox(theFrame, 100, 27, false);
    theFrame.editNotifyIncrease:SetPoint("LEFT", theFrame.labelNotifyIncrease, "RIGHT", 5, 1);
    theFrame.editNotifyIncrease:SetPoint("RIGHT", theFrame.Inset, "RIGHT", -10, 0);
    theFrame.editNotifyIncrease:SetScript("OnTextChanged", function(self) 
        _addon.sv.times:SetIncreaseMessage(self:GetText())
    end);
end

do
    local cb = MakeCheckbox(theFrame, nil, 24, 24)
    cb:SetPoint('TOPLEFT', theFrame.cbNotifyIncrease, 'BOTTOMLEFT', 0, -8)
    theFrame.cbNotifyReset = cb
    theFrame.labelNotifyReset = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.labelNotifyReset:SetPoint("LEFT", cb, "RIGHT", 5, 2);
    theFrame.labelNotifyReset:SetText('清零通知');
    theFrame.labelNotifyReset:SetJustifyH("LEFT");
    theFrame.editNotifyReset = MakeEditBox(theFrame, 100, 27, false);
    theFrame.editNotifyReset:SetPoint("LEFT", theFrame.labelNotifyReset, "RIGHT", 5, 1);
    theFrame.editNotifyReset:SetPoint("RIGHT", theFrame.Inset, "RIGHT", -10, 0);
    theFrame.editNotifyReset:SetScript("OnTextChanged", function(self) 
        _addon.sv.times:SetResetMessage(self:GetText())
    end);
end

do
    local cb = MakeCheckbox(theFrame, nil, 24, 24)
    cb:SetPoint('TOPLEFT', theFrame.cbNotifyReset, 'BOTTOMLEFT', 0, -8)
    theFrame.cbNotifyEnterInstance = cb
    theFrame.labelNotifyEnterInstance = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.labelNotifyEnterInstance:SetPoint("LEFT", cb, "RIGHT", 5, 2);
    theFrame.labelNotifyEnterInstance:SetText('进本计数提醒');
    theFrame.labelNotifyEnterInstance:SetJustifyH("LEFT");
    -- theFrame.editNotifyEnterInstance = MakeEditBox(theFrame, 100, 27, false);
    -- theFrame.editNotifyEnterInstance:SetPoint("LEFT", theFrame.labelNotifyEnterInstance, "RIGHT", 5, 1);
    -- theFrame.editNotifyEnterInstance:SetPoint("RIGHT", theFrame.Inset, "RIGHT", -10, 0);
end

do
    local cb = MakeCheckbox(theFrame, nil, 24, 24)
    cb:SetPoint('LEFT', theFrame.labelNotifyEnterInstance, 'RIGHT', 8, -2)
    theFrame.cbNotifyFinished = cb
    theFrame.labelNotifyFinished = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.labelNotifyFinished:SetPoint("LEFT", cb, "RIGHT", 5, 2);
    theFrame.labelNotifyFinished:SetText('完成重置提醒');
    theFrame.labelNotifyFinished:SetJustifyH("LEFT");
end

do
    local cb = MakeCheckbox(theFrame, nil, 24, 24)
    cb:SetPoint('TOPLEFT', theFrame.cbNotifyEnterInstance, 'BOTTOMLEFT', 0, -8)
    theFrame.cblNotifyType = cb
    theFrame.labelNotifyType = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    theFrame.labelNotifyType:SetPoint("LEFT", cb, "RIGHT", 5, 2);
    theFrame.labelNotifyType:SetText('通知方式');
    theFrame.labelNotifyType:SetJustifyH("LEFT");
    theFrame.sendTypeDropdown = CreateFrame("Frame", nil, theFrame, "UIDropDownMenuTemplate");
    theFrame.sendTypeDropdown:SetPoint("LEFT", theFrame.labelNotifyType, "RIGHT", -10, -3);
    theFrame.sendTypeDropdown.RefreshState = DropdownRefresh;
    theFrame.sendTypeDropdown.GetListItems = function() return SENDTYPES end;
    UIDropDownMenu_SetWidth(theFrame.sendTypeDropdown, theFrame.labelNotifyType:GetWidth());
    UIDropDownMenu_Initialize(theFrame.sendTypeDropdown, DropdownOpen)
end
