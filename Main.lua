local _addonName, _addon = ...;

_addon.Main = "Main Lib"
local SendChatMessage = SendChatMessage

local L = _addon:GetLocalization();

local frame = CreateFrame("Frame");
local handlers = {};
local playerName = UnitName("player");

--- Add new entry to the list
-- @param search The string to search for
function _addon:AddToList(search)
    local ntable = {active = false, words = {}};

    ntable.words = search

    ZkyBombDB['Messages'][search] = ntable;
    _addon:MainUI_UpdateList();

end

--- Remove entry from list
-- @param search The string to remove
function _addon:RemoveFromList(search)
    ZkyBombDB['Messages'][search] = nil;
    _addon:MainUI_UpdateList();
end

--- Toggle entry active state
-- @param search The search string to toggle
-- @return the new state
function _addon:ToggleEntry(search)
    -- if ZkyBombDB['Messages'][search] ~= nil then
    --     ZkyBombDB['Messages'][search].active = not ZkyBombDB['Messages'][search].active;
    --     return ZkyBombDB['Messages'][search].active;
    -- end
    -- return false;
    local target = ZkyBombDB['Messages'][search]
    if target ~= nil then
        local val = target.active

        for k, v in pairs(ZkyBombDB['Messages']) do v.active = false end
        target.active = not val

        _addon:MainUI_UpdateList()

        return target.active
    end
    return false
end

--- Toggle entry active state
-- @param search The search string to toggle
-- @return the new state
function _addon:ToggleChannel(search)
    local dbChannels = _addon:GetDbChannels()
    if dbChannels[search] ~= nil then
        dbChannels[search].active = not dbChannels[search].active
        return dbChannels[search].active
    end
    return false
end

--- Clear the whole list
function _addon:ClearList()
    wipe(ZkyBombDB['Messages']);
    -- _addon:MainUI_UpdateList();
end

--- Toggle search on/off
function _addon:ToggleAddon()
    ZkyBombDB.isActive = not ZkyBombDB.isActive;
    -- UpdateAddonState();
end

------------------------------------------------
-- Events
------------------------------------------------

function handlers.ADDON_LOADED(addonName)
    if addonName ~= _addonName then return end
    frame:UnregisterEvent('ADDON_LOADED')
    if ZkyBombDB == nil then ZkyBombDB = {} end
    if ZkyBombDB.Messages == nil then ZkyBombDB.Messages = {} end
    if ZkyBombDB.Times == nil then ZkyBombDB.Times = {} end
    if ZkyBombDB.Times.Current == nil then ZkyBombDB.Times.Current = 0 end
    if ZkyBombDB.Times.PerRound == nil then ZkyBombDB.Times.PerRound = 5 end
    if ZkyBombDB.Times.Total == nil then ZkyBombDB.Times.Total = 0 end
    if ZkyBombDB.Channels == nil then ZkyBombDB.Channels = {} end
    if ZkyBombDB.Times.Reset == nil then ZkyBombDB.Times.Reset = {} end
    if ZkyBombDB.Times.Reset.Message == nil then ZkyBombDB.Times.Reset.Message = '' end
    if ZkyBombDB.Times.Reset.MessageSendType == nil then ZkyBombDB.Times.Reset.MessageSendType = 'YELL' end
    if ZkyBombDB.Times.Reset.MessageIsSend == nil then ZkyBombDB.Times.Reset.MessageIsSend = true end

    -- _addon:SetupSettings();

    _addon:MainUI_UpdateList()
    _addon:Update_SettingUI_Channels()
    _addon:Update_SettingUI_Times()
    -- UpdateAddonState();

    -- if ZkyBombDB.firstStart then
    --     _addon:MainUI_OpenList();
    --     print(L["FIRST_START_MSG"]);
    --     ZkyBombDB.firstStart = false;
    --     ZkyBombDB.outputFormat = L["CHAT_NOTIFY_FORMAT"];
    -- end
end

frame:SetScript("OnEvent", function(self, event, ...) handlers[event](...); end)

frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");

function handlers.ZONE_CHANGED_NEW_AREA(event)
    print('ZONE_CHANGED_NEW_AREA')
    local currentTimes = tostring(_addon:GetCurrentTimes())
    local timesPerRound = tostring(_addon:GetTimesPerRound())
    local isFinished = (currentTimes >= timesPerRound)
    if IsInInstance() then
        if isFinished then
            _addon:ShowResetWhenFinished()
        else
            _addon:ShowIncrease();
        end
    else
        _addon:HideReset()
    end
end

function handlers.PLAYER_ENTERING_WORLD(event)
    print('PLAYER_ENTERING_WORLD')
end

------------------------------------------------
-- Slash command
------------------------------------------------

SLASH_ZKYBOMB1 = "/zb";
SlashCmdList["ZKYBOMB"] = function(arg) _addon:MainUI_OpenList(); end;

BINDING_HEADER_ZKYBOMB = "飙车助手"
BINDING_NAME_ZKYBOMB_TOGGLE = "开/关"
BINDING_NAME_ZKYBOMB_WORLD_MESSAGE = "世界喊话"
BINDING_NAME_ZKYBOMB_OTHER_MESSAGE = "其他喊话"
BINDING_NAME_ZKYBOMB_ONEKEY_MESSAGE = "一键喊话"
BINDING_NAME_ZKYBOMB_TIMES_INCREASE = "计数增加"
BINDING_NAME_ZKYBOMB_TIMES_RESET = "计数重置"


_bindings = {}
_bindings._addon = _addon