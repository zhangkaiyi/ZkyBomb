local _addonName, _addon = ...;
local SendChatMessage = SendChatMessage
local GetChannelList = GetChannelList

local L = _addon:GetLocalization();

_addon.sv = {}
_addon.sv.times = {}
------------------------------------------------
-- Helper
------------------------------------------------

--- Print error message (red)
-- @param msg The message to print
function _addon:PrintError(msg)
    print("|cFFFF3333" .. _addonName .. ": " .. msg:gsub("|r", "|cFFFF3333"));
end

function _addon:GetSavedVariables()
    if ZkyBombDB == nil then
        self:PrintError('SV is nil');
    end
    return ZkyBombDB
end

function _addon:GetActiveMessage()
    local svTable = self:GetSavedVariables()
    if svTable then
        local messages = svTable['Messages']
        local message = ''
        for k, v in pairs(messages) do if v.active then message = k end end
        return message
    end
end


function _addon:GetCurrentTimes()
    local svTable = self:GetSavedVariables()
    if svTable then
        return svTable['Times']['Current']
    end
end

function _addon:GetTimesPerRound()
    local svTable = self:GetSavedVariables()
    if svTable then
        return svTable['Times']['PerRound']
    end
end

function _addon:GetTotalTimes()
    local svTable = self:GetSavedVariables()
    if svTable then
        return svTable['Times']['Total']
    end
end

function _addon:GetDbChannels()
    local svTable = self:GetSavedVariables()
    if svTable then
        return svTable['Channels']
    end
end

function _addon:GetJoinedChannels()
    local channels = {}
    local chanList = {GetChannelList()}
    for i = 1, #chanList, 3 do
        table.insert(channels, {
            id = chanList[i],
            name = chanList[i + 1],
            isDisabled = chanList[i + 2], -- Not sure what a state of "blocked" would be
            fullname = chanList[i] .. '. ' .. chanList[i + 1]
        })
    end
    return channels
end

function _addon:GetResetMessage()
    local svTable = self:GetSavedVariables()
    if svTable then
        return svTable.Times.Reset.Message
    end
end

function _addon:IsSendResetMessage()
    local svTable = self:GetSavedVariables()
    if svTable then
        return svTable.Times.Reset.MessageIsSend
    end
end

function _addon:GetResetMessageSendType()
    local svTable = self:GetSavedVariables()
    if svTable then
        return svTable.Times.Reset.MessageSendType
    end
end

function _addon:GetNotifyType()
    local svTable = self:GetSavedVariables()
    if svTable then
        return svTable.Messages.NotifyType or 'PARTY'
    end
end

function _addon:ResetCurrentTimes()
    local svTable = self:GetSavedVariables()
    if svTable then
        svTable.Times.Current = 0;
        if self:IsSendResetMessage() then
            SendChatMessage(self:GetResetMessage(), self:GetResetMessageSendType())
        end
    end
end

function _addon:SendChannelMessage(msg, channelId)
    SendChatMessage(msg, 'channel', '', channelId)
end

function _addon:SendWorldMessage()
    local channels = self:GetDbChannels()
    local sortedChannels = {}
    for k, v in pairs(channels) do
        if v.active then
            table.insert(sortedChannels, v.id)
        end
    end
    table.sort(sortedChannels)
    for i = 1, #sortedChannels, 1 do
        self:SendChannelMessage(self:GetActiveMessage(), sortedChannels[i])
    end
end


function _addon:SendOtherMessage()
    SendChatMessage(self:GetActiveMessage(), "YELL")
end

function _addon:SendOneKeyMessage()
    self:SendWorldMessage()
    self:SendOtherMessage()
end

function _addon:TimesIncrease()
    local svTable = self:GetSavedVariables()
    if svTable then
        local timePerRound = self:GetTimesPerRound()
        local current = self:GetCurrentTimes()
        local total = self:GetTotalTimes()
        current = current + 1
        total = total + 1
        svTable['Times']['Current'] = current
        svTable['Times']['Total'] = total
        SendChatMessage(timePerRound .. '-------' .. current, 'PARTY')
    end
end


function _addon:TimesReset()
    local svTable = self:GetSavedVariables()
    if svTable then
        svTable.Times.Current = 0;
        if self:IsSendResetMessage() then
            SendChatMessage(self:GetResetMessage(), self:GetResetMessageSendType())
        end
    end
end


function _addon.sv.times:GetIsNotify()
    local svTable =_addon:GetSavedVariables();
    return svTable.Times.IsNotify;
end

function _addon.sv.times:SetIsNotify(checked)
    local svTable =_addon:GetSavedVariables();
    svTable.Times.IsNotify = checked;
end