local _, _addon = ...

_addon.lib = "Remote Lib"

-- Hanlde dropdown refresh
function DropdownRefresh(self)
    local optionName = "NOT SET!";
    for k,v in pairs(self.GetListItems()) do
        if k == svTable[self.settingName] then
            optionName = v;
            break;
        end
    end
    UIDropDownMenu_SetText(self, optionName);
end;

function DropdownOpen(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo();
    info.func = function(selfb, arg1, arg2)
        tempSettings[self.settingName] = arg1;
        UIDropDownMenu_SetText(self, arg2);
    end;
    for k, v in pairs(self.GetListItems()) do
        info.text = v;
        info.arg1 = k;
        info.arg2 = v;
        if tempSettings[self.settingName] ~= nil then
            info.checked = (k == tempSettings[self.settingName]);
        else
            info.checked = (k == svTable[self.settingName]);
        end
        UIDropDownMenu_AddButton(info);
    end
end

--- Create dropdown
-- @param settingName The key in the settings saved vars
-- @param labelText The label text
-- @param tooltipText The tooltip text
-- @param width The width of the dropdown
-- @param func The function to get list items from (value is displayed name)
-- @param labelWidth Set label to static width, ignore string width (optional)
-- @param row Row to insert it into, if nit row is created (optional)
-- @return The button frame object
function _addon:MakeDropdown(settingName, labelText, tooltipText, width, func, labelWidth, row)
    local row = row

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    label:SetText(labelText);
    if labelWidth then
        label:SetJustifyH("LEFT");
        label:SetWidth(labelWidth);
    end

    local dropDown = CreateFrame("Frame", nil, row, "UIDropDownMenuTemplate");
    dropDown.settingName = settingName;
    dropDown.RefreshState = DropdownRefresh;
    dropDown.GetListItems = func;
    dropDown.Text:SetJustifyH("LEFT");
    dropDown:SetPoint("LEFT", label, "RIGHT", -3, 0);
    UIDropDownMenu_SetWidth(dropDown, width);
    UIDropDownMenu_Initialize(dropDown, DropdownOpen);

    if tooltipText then
        SetTooltip(dropDown, tooltipText);
	end

    -- TODO: width is a bit strange on the dropdown template, fix when needed
    -- row:AddElement(label, label:GetWidth() + dropDown:GetWidth() - 15);

    -- inputs[settingName] = dropDown;
	return dropDown;
end