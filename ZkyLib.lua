local _addonName, _addon = ...;
local SendChatMessage = SendChatMessage
local GetChannelList = GetChannelList

local L = _addon:GetLocalization();
------------------------------------------------
-- Helper
------------------------------------------------

--- Print error message (red)
-- @param msg The message to print
function _addon:PrintError(msg)
    print("|cFFFF3333" .. _addonName .. ": " .. msg:gsub("|r", "|cFFFF3333"));
end

function _addon:GetActiveMessage()
    local messages = ZkyBombDB['Messages']
    local message = ''
    for k, v in pairs(messages) do if v.active then message = k end end
    return message
end

function _addon:GetCurrentTimes()
    return ZkyBombDB.Times.Current
end

function _addon:GetTimesPerRound()
    local current = ZkyBombDB['Times']['PerRound']
    return current
end

function _addon:GetTotalTimes()
    local current = ZkyBombDB['Times']['Total']
    return current
end

function _addon:GetDbChannels()
    local channels = ZkyBombDB['Channels']
    return channels
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
    return ZkyBombDB.Times.Reset.Message
end

function _addon:IsSendResetMessage()
    local current = ZkyBombDB.Times.Reset.MessageIsSend
    return current
end

function _addon:GetResetMessageSendType()
    return ZkyBombDB.Times.Reset.MessageSendType
end

function _addon:GetNotifyType()
    -- return ZkyBombDB.NotifyType
    return 'PARTY'
end

function _addon:ResetCurrentTimes()
    print('ResetCurrentTimes')
    ZkyBombDB.Times.Current = 0;
    print(_addon:IsSendResetMessage())
    if _addon:IsSendResetMessage() then 
        -- print(_addon:GetResetMessageSendType())
        SendChatMessage(_addon:GetResetMessage(), _addon:GetResetMessageSendType())
    end
end

function _addon:SendChannelMessage(msg, channelId)
    SendChatMessage(msg, 'channel', '', channelId)
end

function _addon:SendWorldMessage()
    local channels = _addon:GetDbChannels()
                local sortedChannels = {}
                for k, v in pairs(channels) do
                    if v.active then
                    table.insert(sortedChannels, v.id)
                    end
                end
                table.sort(sortedChannels)
                for i=1,#sortedChannels,1 do
                    _addon:SendChannelMessage(_addon:GetActiveMessage(), sortedChannels[i])
                    end
end

function _addon:SendOtherMessage()
    SendChatMessage(_addon:GetActiveMessage(), "YELL")
end

function _addon:TimesIncrease()
    local timePerRound = _addon:GetTimesPerRound()
    local current = _addon:GetCurrentTimes()
    local total = _addon:GetTotalTimes()
    current = current + 1
    total = total +1
    ZkyBombDB['Times']['Current'] = current;
    ZkyBombDB['Times']['Total'] = total;
    SendChatMessage(timePerRound .. '-------' .. current, 'PARTY')
end

function _addon:TimesReset()
    ZkyBombDB.Times.Current = 0;
    if _addon:IsSendResetMessage() then 
        SendChatMessage(_addon:GetResetMessage(), _addon:GetResetMessageSendType())
    end
end