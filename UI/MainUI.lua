local _, _addon = ...

local btnConfig = {
    ['Width'] = 60,
    ['Height'] = 32
}

-- tricky way to clear all editbox focus
local clearAllFocus = (function()
    local fedit = CreateFrame('EditBox')
    fedit:SetAutoFocus(false)
    fedit:SetScript('OnEditFocusGained', fedit.ClearFocus)

    return function()
        local focusFrame = GetCurrentKeyBoardFocus()

        if not focusFrame then
            return
        end

        local p = focusFrame:GetParent()
        local owned = false
        while p ~= nil do
            if p == GUI.mainframe then
                fedit:SetFocus()
                fedit:ClearFocus()
                return
            end
            p = p:GetParent()
        end
    end
end)()

--- Set tooltip for the frame element
-- @param element A frame object
-- @param tooltip The tooltip text
local function SetTooltip(element, tooltip)
    element:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
        GameTooltip:SetText('次数', 1, 0.9, 0.9, 1, true);
        GameTooltip:AddLine('左键：递增', 1, 0.9, 0.9, 1, true);
        GameTooltip:AddLine('右键：重置', 1, 0.9, 0.9, 1, true);
        -- GameTooltip:Show()
    end);

    element:SetScript("OnLeave", GameTooltip_Hide);
end


local mainframe = CreateFrame('Button', nil, UIParent, 'OptionsButtonTemplate')
local TT_H_1, TT_H_2 = "|cff00FF00".."ZkyBomb".."|r", string.format("|cffFFFFFF%s|r", 'v1.0')
local TT_ENTRY = "|cFFCFCFCF%s:|r %s" --|cffFFFFFF%s|r"
SetTooltip(mainframe, TT_H_1 .. ' ' .. TT_H_2)

mainframe:SetWidth(btnConfig.Height)
mainframe:SetHeight(btnConfig.Height)
mainframe:SetPoint('BOTTOM', 0, 95)
mainframe:SetText('∷')
mainframe:SetToplevel(true)
mainframe:EnableMouse(true)
mainframe:SetMovable(true)
mainframe:RegisterForDrag('LeftButton')
mainframe:SetScript('OnDragStart', mainframe.StartMoving)
mainframe:SetScript('OnDragStop', mainframe.StopMovingOrSizing)
mainframe:SetScript('OnMouseDown', clearAllFocus)
mainframe:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
mainframe:SetScript(
    'OnClick',
    function(self, button)
        if button == 'RightButton' then
            init:UpdateOptionFrame()
            optionframe:Show()
        else
            -- print(_addon.lib)
            -- print(_addon.Creator)
            -- print(_addon.SettingUI)
            devPrint(_addon.Main)
            devPrint(_addon:GetCurrentTimes()..' / '.._addon:GetTimesPerRound())
            devPrint(_addon:GetTotalTimes())
            _addon:MainUI_OpenList()
            _addon:SettingUI_UpdateList()
            _addon:SettingUI_UpdateList2()
            -- ZKYBOMB_SETTINGUI:Show()
        end
    end
)

-------------------------------------
-- 重置副本
-------------------------------------
do
    local resetButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
    resetButton:SetWidth(btnConfig.Width)
    resetButton:SetHeight(btnConfig.Height)
    resetButton:SetPoint('LEFT', -btnConfig.Width - btnConfig.Width, 0)
    resetButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    resetButton:SetText('重置')
    resetButton:SetScript(
        'OnClick',
        function(self, button)
            if button == 'RightButton' then
                -- mainframe:SetPoint('TOP', 0, -20)
                mainframe:ClearAllPoints()
                mainframe:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 95)
            else
                ResetInstances()
                SendChatMessage('副本已重置', msgType.Party)
            end
        end
    )
end

-------------------------------------
-- 团队就位
-------------------------------------
do
    local resetButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
    resetButton:SetWidth(btnConfig.Width)
    resetButton:SetHeight(btnConfig.Height)
    resetButton:SetPoint('LEFT', -btnConfig.Width, 0)
    resetButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    resetButton:SetText('就位')
    resetButton:SetScript(
        'OnClick',
        function(self, button)
            if button == 'RightButton' then
                mainframe:SetPoint('TOP', 0, -20)
            else
                DoReadyCheck()
            end
        end
    )
end

-------------------------------------
-- 世界喊话
-------------------------------------

do
    local msgButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
    msgButton:SetWidth(btnConfig.Width)
    msgButton:SetHeight(btnConfig.Height)
    msgButton:SetPoint('LEFT', btnConfig.Height, 0)
    msgButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    msgButton:SetText('世界')
    msgButton:SetScript(
        'OnClick',
        function(self, button)
            if button == 'RightButton' then
            else
                _addon:SendWorldMessage()
            end
        end
    )
    -- title = MessageButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    -- title:SetPoint('CENTER', MessageButton, 0, 0)
    -- title:SetTextColor(1.0, 1.0, 1.0, 1.0)
    -- title:SetText('喊话')
    -- title:SetFont('Fonts\\ARHei.TTF', 12)
end

-------------------------------------
-- 组队喊话
-------------------------------------

do
    local msgButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
    msgButton:SetWidth(btnConfig.Height)
    msgButton:SetHeight(btnConfig.Height)
    msgButton:SetPoint('LEFT', btnConfig.Width + btnConfig.Height, 0)
    msgButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    msgButton:SetText('喊')
    msgButton:SetScript(
        'OnClick',
        function(self, button)
            if button == 'RightButton' then
            else
                _addon:SendOtherMessage()
            end
        end
    )
end

-------------------------------------
-- 刷本计数
-------------------------------------

do
    local countButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
    countButton:SetWidth(btnConfig.Height)
    countButton:SetHeight(btnConfig.Height)
    countButton:SetPoint('LEFT', btnConfig.Width + btnConfig.Height + btnConfig.Height, 0)
    countButton:SetText('＋')
    countButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    countButton:SetScript(
        'OnClick',
        function(self, button)
            if button == 'RightButton' then
                _addon:ShowReset()
            else
                _addon:TimesIncrease()
            end
        end
    )
    SetTooltip(countButton, '左键：增加计数\r\n右键：重置计数')
end

-- -------------------------------------
-- -- 刷本计数重置
-- -------------------------------------

-- do
--     local countButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
--     countButton:SetWidth(btnConfig.Height)
--     countButton:SetHeight(btnConfig.Height)
--     countButton:SetPoint('LEFT', btnConfig.Width + btnConfig.Height + btnConfig.Height + btnConfig.Height, 0)
--     countButton:SetText('■')
--     countButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
--     countButton:SetScript(
--         'OnClick',
--         function(self, button)
--             _addon:ShowReset()
--         end
--     )
-- end