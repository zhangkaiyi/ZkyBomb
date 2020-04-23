local _addonName, _addon = ...;
local L = _addon:GetLocalization();

local HEIGHT_NO_CONTENT = 71;
local listItemHeight = ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.items[1]:GetHeight();
local listElementCount = #ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.items;
local maxElementCount = listElementCount;

local sortedEntries = {};
local entryCount = 0;

----------------------------------------------------------------------------------------------------------------
-- Top bar button actions
----------------------------------------------------------------------------------------------------------------

--- Open settings menu
ZKYBOMB_SETTINGUI_MESSAGES.settingsBtn:SetScript("OnClick", function(self) 
    -- InterfaceOptionsFrame_OpenToCategory(_addonName);
    -- InterfaceOptionsFrame_OpenToCategory(_addonName);
    ZKYBOMB_SETTINGUI_CHANNELS:Show()
end);

--- Open add frame
ZKYBOMB_SETTINGUI_MESSAGES.addBtn:SetScript("OnClick", function(self)
    _addon:MainUI_ShowAddForm();
end);

--- Toggle addon on/off
ZKYBOMB_SETTINGUI_MESSAGES.toggleBtn:SetScript("OnClick", function(self) 
    _addon:ToggleAddon();
    -- ZKYBOMB_SETTINGUI_MESSAGES:UpdateAddonState();
end);

--- Open delete frame
ZKYBOMB_SETTINGUI_MESSAGES.deleteBtn:SetScript("OnClick", function(self) 
    ZKYBOMB_SETTINGUI_MESSAGES:ShowContent("RM");
end);


----------------------------------------------------------------------------------------------------------------
-- Content frame button actions
----------------------------------------------------------------------------------------------------------------

-- Delete all frame buttons
ZKYBOMB_SETTINGUI_MESSAGES.deleteAllFrame.okbutton:SetScript("OnClick", function(self) 
    _addon:ClearList();
    ZKYBOMB_SETTINGUI_MESSAGES:ShowContent("LIST");
end);
ZKYBOMB_SETTINGUI_MESSAGES.deleteAllFrame.backbutton:SetScript("OnClick", function(self) 
    ZKYBOMB_SETTINGUI_MESSAGES:ShowContent("LIST");
end);

-- Add frame buttons
ZKYBOMB_SETTINGUI_MESSAGES.addFrame.okbutton:SetScript("OnClick", function (self)
    local sstring = ZKYBOMB_SETTINGUI_MESSAGES.addFrame.searchEdit:GetText();
    sstring = strtrim(sstring);
    if string.len(sstring) == 0 then
        _addon:PrintError(L["UI_ADDFORM_ERR_NO_INPUT"]);
		return;
    end
	_addon:AddToList(sstring);
	ZKYBOMB_SETTINGUI_MESSAGES:ShowContent("LIST");
end);
ZKYBOMB_SETTINGUI_MESSAGES.addFrame.backbutton:SetScript("OnClick", function (self)
	ZKYBOMB_SETTINGUI_MESSAGES:ShowContent("LIST");
end);

-- Edit frame functions
ZKYBOMB_SETTINGUI_MESSAGES.editFrame:SetScript("OnShow", function(self)
    self.oldsearch = self.searchEdit:GetText()
end)

ZKYBOMB_SETTINGUI_MESSAGES.editFrame.backbutton:SetScript("OnClick", function(self)
    ZKYBOMB_SETTINGUI_MESSAGES:ShowContent("LIST")
end)

ZKYBOMB_SETTINGUI_MESSAGES.editFrame.okbutton:SetScript("OnClick", function(self)
    local nstring = strtrim(ZKYBOMB_SETTINGUI_MESSAGES.editFrame.searchEdit:GetText())
    if string.len(nstring) == 0 then
        _addon:PrintError(L["UI_ADDFORM_ERR_NO_INPUT"]);
		return;
    end
     _addon:RemoveFromList(ZKYBOMB_SETTINGUI_MESSAGES.editFrame.oldsearch)
     _addon:AddToList(nstring); 
    ZKYBOMB_SETTINGUI_MESSAGES:ShowContent("LIST")
end)


----------------------------------------------------------------------------------------------------------------
-- Control functions
----------------------------------------------------------------------------------------------------------------

--- Show the add form
-- @param search A search string to prefill (optional)
function _addon:MainUI_ShowAddForm(search)
    if search == nil and ZKYBOMB_SETTINGUI_MESSAGES:IsShown() and ZKYBOMB_SETTINGUI_MESSAGES.addFrame:IsShown() then 
        return; 
    end
    
	ZKYBOMB_SETTINGUI_MESSAGES.addFrame.searchEdit:SetText("");
	if search ~= nil then
		ZKYBOMB_SETTINGUI_MESSAGES.addFrame.searchEdit:SetText(search);
		ZKYBOMB_SETTINGUI_MESSAGES.addFrame.searchEdit:SetCursorPosition(0);
    else
        ZKYBOMB_SETTINGUI_MESSAGES.addFrame.searchEdit:SetFocus();
    end
    
    ZKYBOMB_SETTINGUI_MESSAGES:Show();
    ZKYBOMB_SETTINGUI_MESSAGES:ShowContent("ADD");
end

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

    ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.ScrollBar:SetMinMaxValues(0, maxRange);
    ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.ScrollBar:SetValueStep(listItemHeight);
    ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.ScrollBar:SetStepsPerPage(listElementCount-1);

    if ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.ScrollBar:GetValue() == 0 then
        ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.ScrollBar.ScrollUpButton:Disable();
    else
        ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.ScrollBar.ScrollUpButton:Enable();
    end

    if (ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.ScrollBar:GetValue() - scrollHeight) == 0 then
        ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.ScrollBar.ScrollDownButton:Disable();
    else
        ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.ScrollBar.ScrollDownButton:Enable();
    end	

    for line = 1, listElementCount, 1 do
      local offsetLine = line + FauxScrollFrame_GetOffset(ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame);
      local item = ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.items[line];
      if offsetLine <= entryCount then
        curdta = ZkyBombDB['Messages'][sortedEntries[offsetLine]];
        item.searchString:SetText(sortedEntries[offsetLine]);
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
    local oldHeight = ZKYBOMB_SETTINGUI_MESSAGES:GetHeight();
    local showCount = math.floor((oldHeight - HEIGHT_NO_CONTENT + (listItemHeight/2 + 2)) / listItemHeight);

    if ignoreHeight ~= true then
        local newHeight = showCount * listItemHeight + HEIGHT_NO_CONTENT;

        ZKYBOMB_SETTINGUI_MESSAGES:SetHeight(newHeight);

        local point, relTo, relPoint, x, y = ZKYBOMB_SETTINGUI_MESSAGES:GetPoint(1);
        local yadjust = 0;

        if point == "CENTER" or point == "LEFT" or point == "RIGHT" then
            yadjust = (oldHeight - newHeight) / 2;
        elseif point == "BOTTOM" or point == "BOTTOMRIGHT" or point == "BOTTOMLEFT" then
            yadjust = oldHeight - newHeight;
        end

        ZKYBOMB_SETTINGUI_MESSAGES:ClearAllPoints();
        ZKYBOMB_SETTINGUI_MESSAGES:SetPoint(point, relTo, relPoint, x, y + yadjust);
    end

    for i = 1, maxElementCount, 1 do
        if i > showCount then
            ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame.items[i]:Hide();
        end
    end

    listElementCount = showCount;
    UpdateScrollFrame();
end

--- Fill list from SV data
function _addon:MainUI_UpdateList()
	entryCount = 0;
	wipe(sortedEntries);
	for k in pairs(ZkyBombDB['Messages']) do 
		table.insert(sortedEntries, k);
		entryCount = entryCount + 1;
	end
    table.sort(sortedEntries);
    UpdateScrollFrame();
end

--- Open the main list frame
function _addon:MainUI_OpenList()
    ZKYBOMB_SETTINGUI_MESSAGES:Show();
    ZKYBOMB_SETTINGUI_MESSAGES:ShowContent("LIST");
    -- ZKYBOMB_SETTINGUI_MESSAGES:UpdateAddonState();
    RecalculateSize(true);
    UpdateScrollFrame();
end


----------------------------------------------------------------------------------------------------------------
-- Resize behaviour
----------------------------------------------------------------------------------------------------------------

-- Trigger update on scroll action
ZKYBOMB_SETTINGUI_MESSAGES.scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, listItemHeight, UpdateScrollFrame);
end);

ZKYBOMB_SETTINGUI_MESSAGES.resizeBtn:SetScript("OnMouseDown", function(self, button) 
    ZKYBOMB_SETTINGUI_MESSAGES:StartSizing("BOTTOMRIGHT"); 
end);

-- Resize snaps to full list items shown, updates list accordingly
ZKYBOMB_SETTINGUI_MESSAGES.resizeBtn:SetScript("OnMouseUp", function(self, button) 
    ZKYBOMB_SETTINGUI_MESSAGES:StopMovingOrSizing(); 
    RecalculateSize();
end);