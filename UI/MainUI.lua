local _, _addon = ...

local btnConfig = {
    Width = 48,
    Height = 32,
    Spacing = 5
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

local TT_H_1, TT_H_2 = "|cff00FF00".."ZkyBomb".."|r", string.format("|cffFFFFFF%s|r", 'v1.0')
local TT_TITLE = "|cffffd100%s|r"
local TT_SINGLE = "%s：%s"
local TT_SINGLE_WHITE = "%s：|cffffffff%s|r"
local TT_SINGLE_LIGHT = "%s：|cff00ff00%s|r"
local TT_SINGLE_HEAVY = "%s：|cffff0000%s|r"
local TT_DOUBLE_L = "%s"
local TT_DOUBLE_R = "|cff00ff00%s|r"
local TT_ENTRY = "|cFFCFCFCF%s:|r %s"

local mainframe = CreateFrame('Button', 'ZKYBOMB_MainUI', UIParent, 'OptionsButtonTemplate')

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
            mainframe:ClearAllPoints()
            mainframe:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 95)
        else
            devPrint(_addon.Main)
            devPrint(_addon:GetCurrentTimes()..' / '.._addon:GetTimesPerRound())
            devPrint(_addon:GetTotalTimes())
            _addon:MainUI_OpenList()
            _addon:SettingUI_UpdateList()
            _addon:SettingUI_UpdateList2()
        end
    end
)
mainframe:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
    GameTooltip:SetText(string.format(TT_TITLE, '飙车助手'), 1, 0.9, 0.9, 1, true)
    GameTooltip:AddLine(string.format(TT_SINGLE_LIGHT, '左键','选项'));
    GameTooltip:AddLine(string.format(TT_SINGLE_LIGHT, '长按','移动位置'));
    GameTooltip:AddLine(string.format(TT_SINGLE_LIGHT, '右键','重置位置'));
    GameTooltip:Show()
end);

mainframe:SetScript("OnLeave", GameTooltip_Hide);

-------------------------------------
-- 世界喊话
-------------------------------------

do
    mainframe.worldMsgButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
    mainframe.worldMsgButton:SetWidth(btnConfig.Height)
    mainframe.worldMsgButton:SetHeight(btnConfig.Height)
    mainframe.worldMsgButton:SetPoint('LEFT', mainframe,'RIGHT', 0, 0)
    mainframe.worldMsgButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    mainframe.worldMsgButton:SetText('世')
    mainframe.worldMsgButton:SetScript(
        'OnClick',
        function(self, button)
            if button == 'RightButton' then
            else
                _addon:SendWorldMessage()
            end
        end
    )
    mainframe.worldMsgButton:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
        GameTooltip:SetText(string.format(TT_TITLE, '世界喊话'))
        GameTooltip:AddLine(string.format(TT_SINGLE_LIGHT, '内容', _addon:GetActiveMessage()))
        GameTooltip:Show()
    end);

    mainframe.worldMsgButton:SetScript("OnLeave", GameTooltip_Hide);
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
    mainframe.otherMsgButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
    mainframe.otherMsgButton:SetWidth(btnConfig.Height)
    mainframe.otherMsgButton:SetHeight(btnConfig.Height)
    mainframe.otherMsgButton:SetPoint('LEFT', mainframe.worldMsgButton, 'RIGHT', 0, 0)
    mainframe.otherMsgButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    mainframe.otherMsgButton:SetText('喊')
    mainframe.otherMsgButton:SetScript(
        'OnClick',
        function(self, button)
            if button == 'RightButton' then
            else
                _addon:SendOtherMessage()
            end
        end
    )
    mainframe.otherMsgButton:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
        GameTooltip:SetText(string.format(TT_TITLE, '其他喊话'))
        GameTooltip:AddLine(string.format(TT_SINGLE_LIGHT, '内容', _addon:GetActiveMessage()))
        GameTooltip:Show()
    end);

    mainframe.otherMsgButton:SetScript("OnLeave", GameTooltip_Hide);
end

-------------------------------------
-- 刷本计数
-------------------------------------

do
    mainframe.countButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
    mainframe.countButton:SetWidth(btnConfig.Height)
    mainframe.countButton:SetHeight(btnConfig.Height)
    mainframe.countButton:SetPoint('LEFT', mainframe.otherMsgButton, 'RIGHT', 0, 0)
    mainframe.countButton:SetText('＋')
    mainframe.countButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    mainframe.countButton:SetScript(
        'OnClick',
        function(self, button)
            if button == 'RightButton' then
                _addon:ShowReset()
            else
                _addon:TimesIncrease()
            end
        end
    )
    mainframe.countButton:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
        GameTooltip:SetText(string.format(TT_TITLE, '统计'))
        GameTooltip:AddLine(string.format(TT_SINGLE_LIGHT,'已完',_addon:GetTimesPerRound() .. ' - ' .. _addon:GetCurrentTimes()));
        GameTooltip:AddLine(string.format(TT_SINGLE_LIGHT,'左键','增加计数'));
        GameTooltip:AddLine(string.format(TT_SINGLE_LIGHT,'右键','清零'));
        GameTooltip:Show()
    end);

    mainframe.countButton:SetScript("OnLeave", GameTooltip_Hide);
end

-------------------------------------
-- 团队就位
-------------------------------------
do
    mainframe.readyButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
    mainframe.readyButton:SetWidth(btnConfig.Width)
    mainframe.readyButton:SetHeight(btnConfig.Height)
    mainframe.readyButton:SetPoint('RIGHT', mainframe, 'LEFT', 0, 0)
    mainframe.readyButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    mainframe.readyButton:SetText('准备')
    mainframe.readyButton:SetScript(
        'OnClick',
        function(self, button)
            if button == 'RightButton' then
                -- mainframe:SetPoint('TOP', 0, -20)
            else
                DoReadyCheck()
            end
        end
    )
    mainframe.readyButton:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
        GameTooltip:SetText(string.format(TT_TITLE, '就位准备'))
        GameTooltip:AddLine(string.format(TT_SINGLE_WHITE, '通知', '否'))
        GameTooltip:Show()
    end);

    mainframe.readyButton:SetScript("OnLeave", GameTooltip_Hide);
end

-------------------------------------
-- 重置副本
-------------------------------------
do
    mainframe.resetButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
    mainframe.resetButton:SetWidth(btnConfig.Width)
    mainframe.resetButton:SetHeight(btnConfig.Height)
    mainframe.resetButton:SetPoint('RIGHT', mainframe.readyButton, 'LEFT', 0, 0)
    mainframe.resetButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    mainframe.resetButton:SetText('重置')
    mainframe.resetButton:SetScript(
        'OnClick',
        function(self, button)
            if button == 'RightButton' then
                
            else
                ResetInstances()
                SendChatMessage('副本已重置', _addon:GetNotifyType())
            end
        end
    )
    mainframe.resetButton:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
        GameTooltip:SetText(string.format(TT_TITLE, '重置副本'))
        GameTooltip:AddLine(string.format(TT_SINGLE_LIGHT,'通知','是'));
        GameTooltip:AddLine(string.format(TT_SINGLE_LIGHT,'内容','副本已重置'));
        GameTooltip:Show()
    end);

    mainframe.resetButton:SetScript("OnLeave", GameTooltip_Hide);
end