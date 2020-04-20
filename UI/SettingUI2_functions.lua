local _addonName, _addon = ...;
local L = _addon:GetLocalization();

local HEIGHT_NO_CONTENT = 71;
local listItemHeight = ZKYBOMB_SettingUI.scrollFrame.items[1]:GetHeight();
local listElementCount = #ZKYBOMB_SettingUI.scrollFrame.items;
local maxElementCount = listElementCount;

local sortedEntries = {};
local entryCount = 0;

----------------------------------------------------------------------------------------------------------------
-- Top bar button actions
----------------------------------------------------------------------------------------------------------------
--- Fill list from SV data

--- Open settings menu
ZKYBOMB_SettingUI.settingsBtn:SetScript("OnClick", function(self) 
    -- _addon:SettingUI_UpdateList()
end);

--- Open add frame
ZKYBOMB_SettingUI.addBtn:SetScript("OnClick", function(self)
    -- _addon:MainUI_ShowAddForm();
    _addon:SettingUI_UpdateList()
end);

--- Toggle addon on/off
ZKYBOMB_SettingUI.toggleBtn:SetScript("OnClick", function(self) 
    -- _addon:ToggleAddon();
    -- ZKYBOMB_SettingUI:UpdateAddonState();
end);

--- Open delete frame
ZKYBOMB_SettingUI.deleteBtn:SetScript("OnClick", function(self) 
    -- ZKYBOMB_SettingUI:ShowContent("RM");
end);

--- currentEdit
ZKYBOMB_SettingUI.currentEdit:SetScript("OnTextChanged", function(self) 
    ZkyBombDB['Times']['Current'] = self:GetText()
end);

--- perRoundEdit
ZKYBOMB_SettingUI.perRoundEdit:SetScript("OnTextChanged", function(self) 
    ZkyBombDB['Times']['PerRound'] = self:GetText()
end);

--- totalEdit
ZKYBOMB_SettingUI.totalEdit:SetScript("OnTextChanged", function(self) 
    ZkyBombDB['Times']['Total'] = self:GetText()
end);


----------------------------------------------------------------------------------------------------------------
-- Control functions
----------------------------------------------------------------------------------------------------------------

--- Update scroll frame 
local function UpdateScrollFrame()
    local scrollHeight = 0;
	if entryCount > 0 then
        scrollHeight = (entryCount - listElementCount) * listItemHeight;
        if scrollHeight < 0 then
            scrollHeight = 0;
        end
    end

    local maxRange = (entryCount - listElementCount) * listItemHeight;
    if maxRange < 0 then
        maxRange = 0;
    end

    ZKYBOMB_SettingUI.scrollFrame.ScrollBar:SetMinMaxValues(0, maxRange);
    ZKYBOMB_SettingUI.scrollFrame.ScrollBar:SetValueStep(listItemHeight);
    ZKYBOMB_SettingUI.scrollFrame.ScrollBar:SetStepsPerPage(listElementCount-1);

    if ZKYBOMB_SettingUI.scrollFrame.ScrollBar:GetValue() == 0 then
        ZKYBOMB_SettingUI.scrollFrame.ScrollBar.ScrollUpButton:Disable();
    else
        ZKYBOMB_SettingUI.scrollFrame.ScrollBar.ScrollUpButton:Enable();
    end

    if (ZKYBOMB_SettingUI.scrollFrame.ScrollBar:GetValue() - scrollHeight) == 0 then
        ZKYBOMB_SettingUI.scrollFrame.ScrollBar.ScrollDownButton:Disable();
    else
        ZKYBOMB_SettingUI.scrollFrame.ScrollBar.ScrollDownButton:Enable();
    end	

    for line = 1, listElementCount, 1 do
      local offsetLine = line + FauxScrollFrame_GetOffset(ZKYBOMB_SettingUI.scrollFrame);
      local item = ZKYBOMB_SettingUI.scrollFrame.items[line];
      if offsetLine <= entryCount then
        curdta = sortedEntries[offsetLine];

        item.searchString:SetText(sortedEntries[offsetLine].fullname);
		if curdta.active then
			item.disb:SetNormalTexture([[Interface\AddOns\ZkyBomb\img\on]]);
            item.disb:SetHighlightTexture([[Interface\AddOns\ZkyBomb\img\on]]);
            item.disb:GetParent():SetBackdropColor(0.2,0.2,0.2,0.8);
            item.searchString:SetTextColor(1, 1, 1, 1);
		else
			item.disb:SetNormalTexture([[Interface\AddOns\ZkyBomb\img\off]]);
            item.disb:SetHighlightTexture([[Interface\AddOns\ZkyBomb\img\off]]);
            item.disb:GetParent():SetBackdropColor(0.2,0.2,0.2,0.4);
            item.searchString:SetTextColor(0.5, 0.5, 0.5, 1);
        end
        item:Show();
      else
        item:Hide();
      end
    end
end

--- Recalculates height and shown item count
-- @param ignoreHeight If true will not resize and reanchor UI
local function RecalculateSize(ignoreHeight)
    local oldHeight = ZKYBOMB_SettingUI:GetHeight();
    local showCount = math.floor((oldHeight - HEIGHT_NO_CONTENT + (listItemHeight/2 + 2)) / listItemHeight);

    if ignoreHeight ~= true then
        local newHeight = showCount * listItemHeight + HEIGHT_NO_CONTENT;

        ZKYBOMB_SettingUI:SetHeight(newHeight);

        local point, relTo, relPoint, x, y = ZKYBOMB_SettingUI:GetPoint(1);
        local yadjust = 0;

        if point == "CENTER" or point == "LEFT" or point == "RIGHT" then
            yadjust = (oldHeight - newHeight) / 2;
        elseif point == "BOTTOM" or point == "BOTTOMRIGHT" or point == "BOTTOMLEFT" then
            yadjust = oldHeight - newHeight;
        end

        ZKYBOMB_SettingUI:ClearAllPoints();
        ZKYBOMB_SettingUI:SetPoint(point, relTo, relPoint, x, y + yadjust);
    end

    for i = 1, maxElementCount, 1 do
        if i > showCount then
            ZKYBOMB_SettingUI.scrollFrame.items[i]:Hide();
        end
    end

    listElementCount = showCount;
    UpdateScrollFrame();
end

--- Fill list from SV data
function _addon:SettingUI_UpdateList()
    -- print('_addon:SettingUI_UpdateList')
    entryCount = 0
    wipe(sortedEntries)
        local dbChannels = _addon:GetDbChannels()
        local joinedChannels = _addon:GetJoinedChannels()
        
    for i = 1, #joinedChannels, 1 do
        local key = joinedChannels[i].fullname
        if dbChannels[key] ~= nil then 
            local tempActive =dbChannels[key].active or false
            dbChannels[key] = joinedChannels[i]
            dbChannels[key].active = tempActive
        else 
            dbChannels[key] = joinedChannels[i]
            dbChannels[key].active = false
        end
        
        -- print(dbChannels[key].fullname .. ', ' .. dbChannels[key].active)
        table.insert(sortedEntries, joinedChannels[i])
        entryCount = entryCount + 1
    end

    table.sort(
        sortedEntries,
        function(e1, e2)
            return tonumber(e1.id) < tonumber(e2.id)
        end
    )

    UpdateScrollFrame()
    RecalculateSize();

    ZKYBOMB_SettingUI.currentEdit:SetText(_addon:GetCurrentTimes());
    ZKYBOMB_SettingUI.perRoundEdit:SetText(_addon:GetTimesPerRound());
    ZKYBOMB_SettingUI.totalEdit:SetText(_addon:GetTotalTimes());
end

--- Fill list from SV data
function _addon:SettingUI_UpdateList2()
    ZKYBOMB_SettingUI2.messageEdit:SetText(_addon:GetResetMessage());
     UIDropDownMenu_SetText(ZKYBOMB_SettingUI2.sendTypeDropdown, _addon.SENDTYPES[_addon:GetResetMessageSendType()])
end


--- Open the main list frame
function _addon:SettingUI_OpenList()
    print("_addon:SettingUI_OpenList")
    ZKYBOMB_SettingUI:Show();
    ZKYBOMB_SettingUI:ShowContent("LIST");
    -- ZKYBOMB_SettingUI:UpdateAddonState();
    RecalculateSize(true);
    UpdateScrollFrame();
end


----------------------------------------------------------------------------------------------------------------
-- Resize behaviour
----------------------------------------------------------------------------------------------------------------

-- Trigger update on scroll action
ZKYBOMB_SettingUI.scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, listItemHeight, UpdateScrollFrame);
end);

ZKYBOMB_SettingUI.resizeBtn:SetScript("OnMouseDown", function(self, button) 
    ZKYBOMB_SettingUI:StartSizing("BOTTOMRIGHT"); 
end);

-- Resize snaps to full list items shown, updates list accordingly
ZKYBOMB_SettingUI.resizeBtn:SetScript("OnMouseUp", function(self, button) 
    ZKYBOMB_SettingUI:StopMovingOrSizing(); 
    RecalculateSize();
end);