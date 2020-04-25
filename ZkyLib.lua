local _addonName, _addon = ...;
local SendChatMessage = SendChatMessage
local GetChannelList = GetChannelList

local L = _addon:GetLocalization();

_addon.sv = {}
_addon.sv.times = {}

_addon.func = {}
_addon.func.times = {}
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
        return svTable.Times.NotifyType
    end
end

function _addon:ResetCurrentTimes()
    local svTable = self:GetSavedVariables()
    if svTable then
        svTable.Times.Current = 0;
        if self.sv.times:GetIsNotify() then
            SendChatMessage(self.sv.times:GetResetMessage(), self.sv.times:GetNotifyType())
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

function _addon.sv.times:GetIsNotifyIncrease()
    local svTable = _addon:GetSavedVariables()
    if svTable.Times.IsNotifyIncrease ~= nil then
        return svTable.Times.IsNotifyIncrease
    else
        return true
    end
end

function _addon.sv.times:SetIsNotifyIncrease(checked)
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        svTable.Times.IsNotifyIncrease = checked
    end
end

function _addon.sv.times:GetIsNotifyReset()
    local svTable = _addon:GetSavedVariables()
    if svTable.Times.IsNotifyReset ~= nil then
        return svTable.Times.IsNotifyReset
    else
        return true
    end
end

function _addon.sv.times:SetIsNotifyReset(checked)
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        svTable.Times.IsNotifyReset = checked
    end
end

function _addon.sv.times:GetIsNotifyEnterInstance()
    local svTable = _addon:GetSavedVariables()
    if svTable.Times.IsNotifyEnterInstance ~= nil then
        return svTable.Times.IsNotifyEnterInstance
    else
        return true
    end
end

function _addon.sv.times:SetIsNotifyEnterInstance(checked)
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        svTable.Times.IsNotifyEnterInstance = checked
    end
end

function _addon.sv.times:GetIsNotifyFinished()
    local svTable = _addon:GetSavedVariables()
    if svTable.Times.IsNotifyFinished ~= nil then
        return svTable.Times.IsNotifyFinished
    else
        return true
    end
end

function _addon.sv.times:SetIsNotifyFinished(checked)
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        svTable.Times.IsNotifyFinished = checked
    end
end

function _addon.sv.times:GetNotifyType()
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        return svTable.Times.NotifyType
    end
end

function _addon.sv.times:SetNotifyType(msg)
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        svTable.Times.NotifyType = msg
    end
end

function _addon.sv.times:GetIncreaseMessage()
    local svTable = _addon:GetSavedVariables()
    if svTable.Times.IncreaseMessage == nil or svTable.Times.IncreaseMessage == '' then
        return '{R}---{T}'
    else
        return svTable.Times.IncreaseMessage
    end
end

function _addon.sv.times:SetIncreaseMessage(msg)
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        svTable.Times.IncreaseMessage = msg
    end
end

function _addon.sv.times:GetResetMessage()
    local svTable = _addon:GetSavedVariables()
    if svTable.Times.ResetMessage == nil or svTable.Times.ResetMessage == '' then
        return '本轮结束，计数清零！'
    else
        return svTable.Times.ResetMessage
    end
end

function _addon.sv.times:SetResetMessage(msg)
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        svTable.Times.ResetMessage = msg
    end
end

function _addon.func.times:Increase()
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        local timePerRound = _addon:GetTimesPerRound()
        local current = _addon:GetCurrentTimes()
        local total = _addon:GetTotalTimes()
        current = current + 1
        total = total + 1
        svTable['Times']['Current'] = current
        svTable['Times']['Total'] = total
        local msg = _addon.sv.times:GetIncreaseMessage()
        msg = string.gsub(msg, '{R}', timePerRound)
        msg = string.gsub(msg, '{T}', current)
        if _addon.sv.times:GetIsNotifyIncrease() then
            SendChatMessage(msg, _addon.sv.times:GetNotifyType())
        end
    end
end

function _addon.func.times:Reset()
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        svTable.Times.Current = 0
        if _addon.sv.times:GetIsNotifyReset() then
            SendChatMessage(_addon.sv.times:GetResetMessage(), _addon.sv.times:GetNotifyType())
        end
    end
end

function _addon.sv.times:GetTimesCurrent()
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        return svTable['Times']['Current']
    end
end

function _addon.sv.times:SetTimesCurrent(val)
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        svTable['Times']['Current'] = val
    end
end

function _addon.sv.times:GetTimesPerRound()
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        return svTable['Times']['PerRound']
    end
end

function _addon.sv.times:SetTimesPerRound(val)
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        svTable['Times']['PerRound'] = val
    end
end

function _addon.sv.times:GetTimesTotal()
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        return svTable['Times']['Total']
    end
end

function _addon.sv.times:SetTimesTotal(val)
    local svTable = _addon:GetSavedVariables()
    if svTable ~= nil then
        svTable['Times']['Total'] = val
    end
end
