local _addonName, _addon = ...;
local L = _addon:GetLocalization();

local LIST_ITEM_HEIGHT = 27;
local MAX_ITEMS = 14;
local MIN_ITEMS = 9;
local HEIGHT_NO_CONTENT = 71;

-- Main frame
local frame = CreateFrame("Frame", "ZKYBOMB_SETTINGUI_CHANNELS", ZKYBOMB_SETTINGUI_MESSAGES, "ButtonFrameTemplate");
frame:SetPoint('TOPLEFT', ZKYBOMB_SETTINGUI_MESSAGES, 'TOPRIGHT', 5, 0)
frame:SetPoint('BOTTOMLEFT', ZKYBOMB_SETTINGUI_MESSAGES, 'BOTTOMRIGHT', 5, 180)
frame:SetWidth(300);
frame:SetHeight(MIN_ITEMS*LIST_ITEM_HEIGHT + HEIGHT_NO_CONTENT);
-- frame:SetResizable(true);
frame:SetClampedToScreen(true);
-- frame:SetMaxResize(600, MAX_ITEMS*LIST_ITEM_HEIGHT + HEIGHT_NO_CONTENT);
-- frame:SetMinResize(250, MIN_ITEMS*LIST_ITEM_HEIGHT + HEIGHT_NO_CONTENT);
-- frame:SetMovable(true);
frame:EnableMouse(true);
frame.TitleText:SetText('频道');
-- frame.portrait:SetTexture([[Interface\AddOns\ZkyBomb\img\logo]]);
-- frame.CloseButton:SetScript('OnClick',nil)
frame.CloseButton:Hide()
frame.TopRightCorner:SetWidth(18);
frame.TopRightCorner:SetTexCoord(0.75, 0.89062500, 0.00781250, 0.26562500);
frame.TitleBg:SetPoint("TOPLEFT",2,-3)
frame.TitleBg:SetPoint("TOPRIGHT",-2,-3)
-- ZKYBOMB_SettingUI2CloseButton:SetScript('OnClick',nil)
-- frame:Hide();

ButtonFrameTemplate_HideButtonBar(frame);
ButtonFrameTemplate_HidePortrait(frame)
ButtonFrameTemplate_HideAttic(frame);


-- Delete button for delete all function
    frame.deleteBtn = CreateFrame("Button", nil, frame);
    frame.deleteBtn:SetSize(18, 18);
    frame.deleteBtn:SetPoint("TOPRIGHT", -15, -35);
    frame.deleteBtn:SetNormalTexture([[Interface\AddOns\ZkyBomb\img\trash]]);
    frame.deleteBtn:SetHighlightTexture([[Interface\AddOns\ZkyBomb\img\trash]]);
    frame.deleteBtn:Hide()
    
    -- Add button for switching to add content
    frame.addBtn = CreateFrame("Button", nil, frame);
    frame.addBtn:SetSize(15, 15);
    frame.addBtn:SetPoint("RIGHT", frame.deleteBtn, "LEFT", -15, 1);
    frame.addBtn:SetNormalTexture([[Interface\AddOns\ZkyBomb\img\iplus]]);
    frame.addBtn:SetHighlightTexture([[Interface\AddOns\ZkyBomb\img\iplus]]);
    frame.addBtn:Hide()
    
    -- Add button for toggling addon on/off
    frame.toggleBtn = CreateFrame("Button", nil, frame);
    frame.toggleBtn:SetSize(15, 15);
    frame.toggleBtn:SetPoint("RIGHT", frame.addBtn, "LEFT", -15, 0);
    frame.toggleBtn:SetNormalTexture([[Interface\AddOns\ZkyBomb\img\on]]);
    frame.toggleBtn:SetHighlightTexture([[Interface\AddOns\ZkyBomb\img\on]]);
    frame.toggleBtn:Hide()
    
    -- Settings button
    frame.settingsBtn = CreateFrame("Button", nil, frame);
    frame.settingsBtn:SetSize(18, 18);
    frame.settingsBtn:SetPoint("TOPLEFT", 70, -35);
    frame.settingsBtn:SetNormalTexture([[interface/scenarios/scenarioicon-interact.blp]]);
    frame.settingsBtn:SetHighlightTexture([[interface/scenarios/scenarioicon-interact.blp]]);
    frame.settingsBtn:Hide()

----------------------------------------------------------------------------------------------------------------
-- Content frames
----------------------------------------------------------------------------------------------------------------

-- Scrollframe for the list
frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame.Inset, "FauxScrollFrameTemplate");
frame.scrollFrame:SetPoint("TOPLEFT", 3, -3);
frame.scrollFrame:SetPoint("BOTTOMRIGHT", -3, 3);
frame.scrollFrame.ScrollBar:ClearAllPoints();
frame.scrollFrame.ScrollBar:SetPoint("TOPRIGHT", -1, -18);
frame.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", -1, 16);

frame.scrollFrame.ScrollBarTop = frame.scrollFrame:CreateTexture(nil, "BACKGROUND");
frame.scrollFrame.ScrollBarTop:SetPoint("TOPRIGHT", 6, 2);
frame.scrollFrame.ScrollBarTop:SetTexture ([[Interface\PaperDollInfoFrame\UI-Character-ScrollBar]]);
frame.scrollFrame.ScrollBarTop:SetSize(31, 256);
frame.scrollFrame.ScrollBarTop:SetTexCoord(0, 0.484375, 0, 1);

frame.scrollFrame.ScrollBarBottom = frame.scrollFrame:CreateTexture(nil, "BACKGROUND");
frame.scrollFrame.ScrollBarBottom:SetPoint("BOTTOMRIGHT", 6, -2);
frame.scrollFrame.ScrollBarBottom:SetTexture ([[Interface\PaperDollInfoFrame\UI-Character-ScrollBar]]);
frame.scrollFrame.ScrollBarBottom:SetSize(31, 106);
frame.scrollFrame.ScrollBarBottom:SetTexCoord(0.515625, 1, 0, 0.4140625);

frame.scrollFrame.ScrollBarMiddle = frame.scrollFrame:CreateTexture(nil, "BACKGROUND");
frame.scrollFrame.ScrollBarMiddle:SetPoint("BOTTOM", frame.scrollFrame.ScrollBarBottom, "TOP", 0, 0);
frame.scrollFrame.ScrollBarMiddle:SetPoint("TOP", frame.scrollFrame.ScrollBarTop, "BOTTOM", 0, 0);
frame.scrollFrame.ScrollBarMiddle:SetTexture ([[Interface\PaperDollInfoFrame\UI-Character-ScrollBar]]);
frame.scrollFrame.ScrollBarMiddle:SetSize(31, 60);
frame.scrollFrame.ScrollBarMiddle:SetTexCoord(0, 0.484375, 0.75, 1);

frame.scrollFrame:SetClipsChildren(true);

----------------------------------------------------------------------------------------------------------------
-- List items for scroll frame
----------------------------------------------------------------------------------------------------------------

frame.scrollFrame.items = {};

--- Toggle the list item on/off
local function ToggleItem(self)
    if _addon:ToggleChannel(self:GetParent().searchString:GetText()) then
        self:SetNormalTexture([[Interface\AddOns\ZkyBomb\img\on]]);
        self:SetHighlightTexture([[Interface\AddOns\ZkyBomb\img\on]]);
        self:GetParent():SetBackdropColor(0.2,0.2,0.2,0.8);
        self:GetParent().searchString:SetTextColor(1, 1, 1, 1);
    else
        self:SetNormalTexture([[Interface\AddOns\ZkyBomb\img\off]]);
        self:SetHighlightTexture([[Interface\AddOns\ZkyBomb\img\off]]);
        self:GetParent():SetBackdropColor(0.2,0.2,0.2,0.4);
        self:GetParent().searchString:SetTextColor(0.5, 0.5, 0.5, 1);
    end
end

--- Remove the list item
local function RemoveItem(self)
    _addon:RemoveFromList(self:GetParent().searchString:GetText());
end

for i = 1, MAX_ITEMS, 1 do	
    local item = CreateFrame("Button", nil, frame.scrollFrame);
    
	item:SetHeight(LIST_ITEM_HEIGHT);
    item:SetPoint("TOPLEFT", 0, -LIST_ITEM_HEIGHT * (i-1));
    item:SetPoint("TOPRIGHT", -23, -LIST_ITEM_HEIGHT * (i-1));
    item:SetBackdrop({bgFile = [[Interface\AddOns\ZkyBomb\img\bar]]});
    item:SetBackdropColor(0.2,0.2,0.2,0.8);
	
	item.searchString = item:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    item.searchString:SetPoint("LEFT", 10, 0);
    item.searchString:SetPoint("RIGHT", -70, 0);
    item.searchString:SetHeight(10);
    item.searchString:SetJustifyH("LEFT");
    
	item.delb = CreateFrame("Button", nil, item);
	item.delb:SetWidth(12);
	item.delb:SetHeight(12);
	item.delb:SetPoint("RIGHT", item, "RIGHT", -10, 0);
	item.delb:SetNormalTexture([[Interface\AddOns\ZkyBomb\img\iclose]]);
	item.delb:SetHighlightTexture([[Interface\AddOns\ZkyBomb\img\iclose]]);
    item.delb:SetScript("OnClick", RemoveItem);
    item.delb:Hide()

    item.disb = CreateFrame("Button", nil, item);
	item.disb:SetWidth(12);
	item.disb:SetHeight(12);
	item.disb:SetPoint("RIGHT", item, "RIGHT", -10, 0);
	item.disb:SetNormalTexture([[Interface\AddOns\ZkyBomb\img\on]]);
	item.disb:SetHighlightTexture([[Interface\AddOns\ZkyBomb\img\on]]);
    item.disb:SetScript("OnClick", ToggleItem);

---- { Add search item edit button
    item.edit = CreateFrame("Button", nil, item)
    item.edit:SetWidth(15);
    item.edit:SetHeight(15);
    item.edit:SetPoint("RIGHT", item.disb, "LEFT", -10, 0)
    item.edit:SetNormalTexture([[Interface\AddOns\ZkyBomb\img\pencil.tga]])
    item.edit:SetHighlightTexture([[Interface\AddOns\ZkyBomb\img\pencil.tga]])
    item.edit:SetScript("OnClick", function(self)
        frame.editFrame.searchEdit:SetText(item.searchString:GetText())
        frame:ShowContent("EDIT")
    end)
    item.edit:Hide()
---- hk }
    
	frame.scrollFrame.items[i] = item;
end


-- Main frame
local frame2 = CreateFrame("Frame", "ZKYBOMB_SETTINGUI_TIMES", frame, "ButtonFrameTemplate");
frame2:SetPoint('TOP', frame, 'BOTTOM', 0, -5)
frame2:SetPoint('LEFT', frame, 'LEFT', 0, 0)
frame2:SetPoint('RIGHT', frame, 'RIGHT', 0, 0)
frame2:SetPoint('BOTTOM', ZKYBOMB_SETTINGUI_MESSAGES, 'BOTTOM', 0, 0)
-- frame2:SetWidth(320);
-- frame2:SetHeight(MIN_ITEMS*LIST_ITEM_HEIGHT + HEIGHT_NO_CONTENT);
-- frame:SetResizable(true);
frame2:SetClampedToScreen(true);
-- frame:SetMaxResize(600, MAX_ITEMS*LIST_ITEM_HEIGHT + HEIGHT_NO_CONTENT);
-- frame:SetMinResize(250, MIN_ITEMS*LIST_ITEM_HEIGHT + HEIGHT_NO_CONTENT);
-- frame:SetMovable(true);
frame2:EnableMouse(true);
frame2.TitleText:SetText('次数');
-- frame2.portrait:SetTexture([[Interface\AddOns\ZkyBomb\img\logo]]);
-- frame.CloseButton:SetScript('OnClick',nil)
frame2.CloseButton:Hide()
frame2.TopRightCorner:SetWidth(18);
frame2.TopRightCorner:SetTexCoord(0.75, 0.89062500, 0.00781250, 0.26562500);
frame2.TitleBg:SetPoint("TOPLEFT",2,-3)
frame2.TitleBg:SetPoint("TOPRIGHT",-2,-3)
-- ZKYBOMB_SettingUI2CloseButton:SetScript('OnClick',nil)
-- frame:Hide();

ButtonFrameTemplate_HideButtonBar(frame2);
ButtonFrameTemplate_HidePortrait(frame2);
-- ButtonFrameTemplate_HideAttic(frame2);

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
    local timesFrame = ZKYBOMB_SETTINGUI_TIMES;
    timesFrame.currentLabel = timesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    timesFrame.currentLabel:SetPoint("TOPLEFT", ZKYBOMB_SETTINGUI_TIMES, "TOPLEFT", 10, -35);
    timesFrame.currentLabel:SetText(L["UI_TIMES_CURRENT"]);
    timesFrame.currentLabel:SetJustifyH("LEFT");
    timesFrame.currentEdit = MakeEditBox(timesFrame, 3, 27, false);
    timesFrame.currentEdit:SetPoint("LEFT", timesFrame.currentLabel, "RIGHT", 5, -1);
    timesFrame.currentEdit:SetWidth(40);
    timesFrame.currentEdit:SetNumeric(true)
    timesFrame.currentEdit:SetScript('OnChar', mustnumber)
    timesFrame.currentEdit:SetScript("OnTextChanged", function(self)
        local svTable = self:GetSavedVariables()
        if svTable then
            svTable['Times']['Current'] = self:GetText()
        end
    end);
end

do
    local timesFrame = ZKYBOMB_SETTINGUI_TIMES;
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
        local svTable = self:GetSavedVariables()
        if svTable then
            svTable['Times']['PerRound'] = self:GetText()
        end
    end);
end

do
    local timesFrame = ZKYBOMB_SETTINGUI_TIMES;
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
        local svTable = self:GetSavedVariables()
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
    local resetFrame = ZKYBOMB_SETTINGUI_TIMES;
    resetFrame.increaseLabel = resetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    resetFrame.increaseLabel:SetPoint("TOPLEFT", resetFrame.Inset, "TOPLEFT", 10, -10);
    resetFrame.increaseLabel:SetText('计数通知');
    resetFrame.increaseLabel:SetJustifyH("LEFT");
    resetFrame.increaseEdit = MakeEditBox(resetFrame, 100, 27, false);
    resetFrame.increaseEdit:SetPoint("LEFT", resetFrame.increaseLabel, "RIGHT", 5, -1);
    resetFrame.increaseEdit:SetPoint("RIGHT", resetFrame.Inset, "RIGHT", -10, -1);
    resetFrame.increaseEdit:SetScript("OnTextChanged", function(self) 
        
    end);
end

do
    local resetFrame = ZKYBOMB_SETTINGUI_TIMES;
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
    local resetFrame = ZKYBOMB_SETTINGUI_TIMES;
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