local _, _addon = ...

local Lib = _addon.lib

GetDatabase = function()
    return ZkyBombDB
end

local db = {}
function db:SetConfig(key, v)
    local config = GetDatabase()
    config[key] = v
end

function db:GetConfigOrDefault(key, def)
    local config = GetDatabase()

    if not config[key] then
        config[key] = def
    end

    return config[key]
end

msgType = {}
msgType.Say = 'SAY'
msgType.Party = 'PARTY'
msgType.Yell = 'YELL'
msgType.Raid = 'RAID'

btnConfig = {
    ['Width'] = 60,
    ['Height'] = 32
}

--callText = '监狱（JY）速刷，爆本效率，20G/5，来大班!'

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

local mainframe = CreateFrame('Button', nil, UIParent, 'OptionsButtonTemplate')
mainframe:RegisterEvent('ADDON_LOADED')
mainframe:SetScript(
    'OnEvent',
    function(self, event, ...)
        if event == 'ADDON_LOADED' then
            ZkyBombDB = ZkyBombDB or {['Message'] = '', ['Count'] = 0}
            init:CreateOptionFrame()
        end
    end
)
-- mainframe:SetWidth(200)
-- mainframe:SetHeight(80)
-- mainframe:SetBackdrop(
--     {
--         --bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
--         --edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
--         tile = true,
--         tileSize = 32,
--         --edgeSize = 32,
--         insets = {left = 8, right = 8, top = 10, bottom = 10}
--     }
-- )
-- mainframe:SetBackdropColor(0, 0, 0)

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
            print(_addon.Main)
            print(_addon:GetCurrentTimes()..' / '.._addon:GetTimesPerRound())
            print(_addon:GetTotalTimes())
            _addon:MainUI_OpenList()
            _addon:SettingUI_UpdateList()
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
                local channels = _addon:GetDbChannels()
                local sortedChannels = {}
                for k, v in pairs(channels) do
                    if v.active then
                    table.insert(sortedChannels, v.id)
                    end
                end
                table.sort(sortedChannels)
                for i=1,#sortedChannels,1 do
                        SendChannelMessage(_addon:GetActiveMessage(), sortedChannels[i])
                    end
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
                SendChatMessage(_addon:GetActiveMessage(), msgType.Yell)
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
                ZkyBombDB['Times']['Current'] = 0;
                SendChatMessage('计数已重置', msgType.Party)
            else
                local timePerRound = _addon:GetTimesPerRound()
                local current = _addon:GetCurrentTimes()
                local total = _addon:GetTotalTimes()
                current = current + 1
                total = total +1
                ZkyBombDB['Times']['Current'] = current;
                ZkyBombDB['Times']['Total'] = total;
                SendChatMessage(timePerRound .. '-------' .. current, msgType.Party)
            end
        end
    )
end

-------------------------------------
-- 刷本计数重置
-------------------------------------

do
    local countButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
    countButton:SetWidth(btnConfig.Height)
    countButton:SetHeight(btnConfig.Height)
    countButton:SetPoint('LEFT', btnConfig.Width + btnConfig.Height + btnConfig.Height + btnConfig.Height, 0)
    countButton:SetText('■')
    countButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    countButton:SetScript(
        'OnClick',
        function(self, button)
            _addon:ShowReset()
            -- ZkyBombDB['Times']['Current'] = 0;
            -- SendChatMessage('计数已重置', msgType.Party)
        end
    )
end

-------------------------------------
-- 拖拽按钮
-------------------------------------

-- do
--     local dragButton = CreateFrame('Button', nil, mainframe, 'OptionsButtonTemplate')
--     dragButton:SetWidth(btnConfig.Height)
--     dragButton:SetHeight(btnConfig.Height)
--     dragButton:SetPoint('RIGHT', 15, 0)
--     dragButton:SetText('∷')
--     -- dragButton:EnableMouse(true)
--     -- dragButton:SetMovable(true)
--     -- dragButton:RegisterForDrag('LeftButton')
--     -- dragButton:SetScript('OnDragStart', dragButton.StartMoving)
--     -- dragButton:SetScript('OnDragStop', dragButton.StopMovingOrSizing)
-- end

init = {}
function init:CreateOptionFrame()
    -------------------------------------
    -- 设置窗口
    -------------------------------------

    optionframe = CreateFrame('Frame', nil, UIParent)
    optionframe:SetWidth(320)
    optionframe:SetHeight(480)
    optionframe:SetBackdrop(
        {
            bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
            edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = {left = 8, right = 8, top = 10, bottom = 10}
        }
    )

    optionframe:SetBackdropColor(0, 0, 0)
    optionframe:SetPoint('CENTER', 0, 0)
    optionframe:SetToplevel(true)
    optionframe:EnableMouse(true)
    optionframe:SetMovable(true)
    optionframe:RegisterForDrag('LeftButton')
    optionframe:SetScript('OnDragStart', mainframe.StartMoving)
    optionframe:SetScript('OnDragStop', mainframe.StopMovingOrSizing)
    optionframe:SetScript('OnMouseDown', clearAllFocus)
    optionframe:Hide()

    do
        optionframe.MessageEditBox = CreateFrame('EditBox', nil, optionframe, 'InputBoxTemplate')
        local t = optionframe.MessageEditBox
        -- t:SetMultiLine(true)
        -- t:SetMaxBytes(256)
        t:SetWidth(280)
        t:SetHeight(25)
        t:SetPoint('TOPLEFT', optionframe, 20, -20)
        t:SetAutoFocus(false)
        t:SetMaxLetters(150)
        t:SetText(db:GetConfigOrDefault('Message'))
        t:SetScript(
            'OnTextChanged',
            function(self, userInput)
                db:SetConfig('Message', self:GetText())
            end
        )
    end

    do
        optionframe.CountEditBox = CreateFrame('EditBox', nil, optionframe, 'InputBoxTemplate')
        local t = optionframe.CountEditBox
        t:SetWidth(50)
        t:SetHeight(25)
        t:SetPoint('TOPLEFT', optionframe.MessageEditBox, 0, -30)
        t:SetAutoFocus(false)
        t:SetMaxLetters(150)
        t:SetNumeric(true)
        t:SetText(db:GetConfigOrDefault('Count'))
        t:SetScript('OnChar', mustnumber)
        t:SetScript(
            'OnTextChanged',
            function(self, userInput)
                db:SetConfig('Count', self:GetText())
            end
        )
    end

    do
        local b = CreateFrame('Button', nil, optionframe, 'OptionsButtonTemplate')
        b:SetWidth(60)
        b:SetHeight(40)
        b:SetPoint('BOTTOMRIGHT', -20, 20)
        b:SetText('关闭')
        b:SetScript(
            'OnClick',
            function()
                optionframe:Hide()
            end
        )
    end
end

function init:ResetPosition()
    mainframe:SetPoint('BOTTOM', 0, 95)
end

function init:UpdateOptionFrame()
    optionframe.MessageEditBox:SetText(_addon:GetActiveMessage())
    -- optionframe.CountEditBox:SetText(_addon:GetCurrentTimes())
    MakeChannelsCheckBox()
    local channels = _addon:GetChannels()
    for k, v in pairs(channels) do
        optionframe.checkboxes[k]:SetChecked(true)
    end
end

function MakeChannelsCheckBox()
    optionframe.checkboxes = {}
    local channels = GetJoinedChannels()
    for i = 1, #channels, 1 do
        local cb = CreateFrame('CheckButton', nil, optionframe)
        cb:SetSize(24, 24)
        cb.Channel = channels[i]
        cb.RefreshState = CheckBoxRefresh
        cb:SetScript('OnClick', CheckBoxOnClick)
        cb:SetNormalTexture([[Interface\Buttons\UI-CheckBox-Up]])
        cb:SetPushedTexture([[Interface\Buttons\UI-CheckBox-Down]])
        cb:SetHighlightTexture([[Interface\Buttons\UI-CheckBox-Highlight]], 'ADD')
        cb:SetCheckedTexture([[Interface\Buttons\UI-CheckBox-Check]])
        cb:SetDisabledCheckedTexture([[Interface\Buttons\UI-CheckBox-Check-Disabled]])
        cb:SetPoint('TOPLEFT', optionframe, 20, -80 - 30 * (i - 1))
        optionframe.checkboxes[cb.Channel.fullname] = cb

        local label = cb:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        label:SetPoint('LEFT', cb, 'RIGHT', 7, 0)
        label:SetText(channels[i].fullname)
    end
end

function GetJoinedChannels()
    local channels = {}
    local chanList = {GetChannelList()}
    for i = 1, #chanList, 3 do
        table.insert(
            channels,
            {
                id = chanList[i],
                name = chanList[i + 1],
                isDisabled = chanList[i + 2], -- Not sure what a state of "blocked" would be
                fullname = chanList[i] .. '. ' .. chanList[i + 1]
            }
        )
    end
    return channels
end

local function my_comp_new(element1, elemnet2)
    return element1.id > elemnet2.id
end

tempSettings = {}
--- Checkbox OnClick handler
function CheckBoxOnClick(self)
    --ChatConfigFrame_PlayCheckboxSound(self:GetChecked())
    if self:GetChecked() then
        tempSettings[self.Channel.fullname] = self.Channel
    else
        tempSettings[self.Channel.fullname] = nil
    end

    table.sort(tempSettings, my_comp_new)
    -- for k, v in pairs(tempSettings) do
    --     if v then
    --         print(k)
    --     end
    -- end
    ZkyBombDB['Channels'] = tempSettings
end

function SendChannelMessage(msg, num)
    SendChatMessage(msg, 'channel', '', num)
end
