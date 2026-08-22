

local function GlobalShowNotice(id)
    pcall(function()
        if _G.ShowNotice then
            _G.ShowNotice(id)
        else
            local UIUtil = require("client.common.ui_util")
            if UIUtil and UIUtil.ShowNotice then UIUtil.ShowNotice(id) end
        end
    end)
end


pcall(function()
    local logic_roleinfo_title = require("client.slua.logic.roleInfo.logic_roleinfo_title")
    if logic_roleinfo_title then
        local old_initAliasInfo = logic_roleinfo_title.initAliasInfo
        logic_roleinfo_title.initAliasInfo = function(self)
            local CDataTable = _G.CDataTable or require("client.logic.data.CDataTable")
            local aliasTable = CDataTable.GetTableData and CDataTable.GetTableData("AliasCfg") or (CDataTable.GetTable and CDataTable.GetTable("AliasCfg"))
            if aliasTable then
                logic_roleinfo_title.alias_list_info = logic_roleinfo_title.alias_list_info or {}
                for k, cfg in pairs(aliasTable) do
                    local id = tonumber(type(cfg) == "table" and (cfg.ID or cfg.id) or k)
                    if id and id > 0 then
                        if not logic_roleinfo_title.alias_list_info[id] then
                            local title_str = (type(cfg) == "table" and cfg.AliasName) or ""
                            pcall(function()
                                local FuncUtil = require("client.common.FuncUtil") or require("client.common.func_util") or require("common.func_util")
                                if FuncUtil and FuncUtil.Gen_title then
                                    title_str = FuncUtil.Gen_title(id, 1, nil, 0)
                                end
                            end)
                            logic_roleinfo_title.alias_list_info[id] = { id = id, state = 1, rank = 1, expire_ts = 0, receive_time = 0, have_used = 1, nation = "", rank_id = 0, title = title_str }
                        end
                        -- We do NOT overwrite state if it already exists, so equipped items stay equipped!
                    end
                end
            end
            if old_initAliasInfo then old_initAliasInfo(self) end
        end
    end
end)


pcall(function()
    local CDataTable = _G.CDataTable or require("client.logic.data.CDataTable")
    if CDataTable and CDataTable.GetTable and not _G.GodzillaCDataTableHooked then
        _G.GodzillaCDataTableHooked = true
        local old_GetTable = CDataTable.GetTable
        CDataTable.GetTable = function(...)
            local name = select(1, ...)
            local ret = old_GetTable(...)
            if name == "Headportrait" and ret then
                pcall(function()
                    local sys = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
                    if sys then
                        local newList = {}
                        if sys.HeadportraitList then for k, v in pairs(sys.HeadportraitList) do newList[k] = v end end
                        for k, cfg in pairs(ret) do
                            local id = tonumber(type(cfg) == "table" and (cfg.ID or cfg.id) or k)
                            if id and id > 0 then newList[tostring(id)] = 1 end
                        end
                        sys.HeadportraitList = newList
                        sys.HasOwnHeadPortrait = function() return true end
                        sys.HasAvatar = function() return true end
                    end
                end)
            elseif name == "AvatarFrame" and ret then
                pcall(function()
                    local sys = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
                    if sys then
                        local newList = {}
                        if sys.AvatarFrameList then for k, v in pairs(sys.AvatarFrameList) do newList[k] = v end end
                        for k, cfg in pairs(ret) do
                            local id = tonumber(type(cfg) == "table" and (cfg.ID or cfg.id) or k)
                            if id and id > 0 then
                                newList[id] = { id = id, expire_time = 1 }
                            end
                        end
                        sys.AvatarFrameList = newList
                        sys.HasAvatarFrame = function() return true end
                        sys.HasAvatarFrameCond = function() return true end
                    end
                end)
            elseif (name == "NicknameFrame" or name == "FriendNicknameSkin") and ret then
                pcall(function()
                    local m = require("client.module_framework.module_manager")
                    if m then
                        local sys = m.GetModule(m.LobbyModuleConfig.logic_roleInfo_nicknameframe)
                        if sys then
                            local newList = {}
                            if sys.unlockData then for k, v in pairs(sys.unlockData) do newList[k] = v end end
                            for k, cfg in pairs(ret) do
                                local id = tonumber(type(cfg) == "table" and (cfg.ID or cfg.id) or k)
                                if id and id > 0 then newList[id] = { skin_id = id, expire_time = 0 } end
                            end
                            sys.unlockData = newList
                            if sys.ProcUnlockData then sys:ProcUnlockData() end
                            sys.IsLocked = function() return false end
                        end
                    end
                end)
            elseif (name == "ChatBubble" or name == "ChatFrame") and ret then
                pcall(function()
                    local m = require("client.module_framework.module_manager")
                    if m then
                        local sys = m.GetModule(m.LobbyModuleConfig.logic_roleInfo_chatframe)
                        if sys then
                            local newList = {}
                            if sys.unlockData then for k, v in pairs(sys.unlockData) do newList[k] = v end end
                            for k, cfg in pairs(ret) do
                                local id = tonumber(type(cfg) == "table" and (cfg.ID or cfg.id) or k)
                                if id and id > 0 then newList[id] = { bubble_id = id, expire_time = 0 } end
                            end
                            sys.unlockData = newList
                            if sys.ProcUnlockData then sys:ProcUnlockData() end
                            sys.IsLocked = function() return false end
                        end
                    end
                end)
            elseif name == "CarteFrame" and ret then
                pcall(function()
                    local m = require("client.module_framework.module_manager")
                    if m then
                        local sys = m.GetModule(m.LobbyModuleConfig.logic_roleinfo_carte_frame)
                        if sys then
                            local newList = {}
                            if sys.active_frame_list then for k, v in pairs(sys.active_frame_list) do newList[k] = v end end
                            for k, cfg in pairs(ret) do
                                local id = tonumber(type(cfg) == "table" and (cfg.ID or cfg.id) or k)
                                if id and id > 0 then table.insert(newList, id) end
                            end
                            sys.active_frame_list = newList
                            sys.IsLocked = function() return false end
                            sys.HasOwnCarteFrame = function() return true end
                        end
                    end
                end)
            end
            return ret
        end
    end
end)



pcall(function()
    local CharacterHandler = require("client.network.Protocol.CharacterHandler")
    if CharacterHandler then
        CharacterHandler.send_change_alias_req = function(id, state)
            GlobalShowNotice(49951)
            pcall(function()
                local DataMgr = _G.DataMgr
                local EventSystem = _G.EventSystem
                local logic_roleinfo_title = require("client.slua.logic.roleInfo.logic_roleinfo_title")
                DataMgr.roleData.alias.id = tonumber(id) or id
                if CDataTable and CDataTable.GetTableData then
                    local cfg = CDataTable.GetTableData("AliasCfg", id)
                    if cfg then DataMgr.roleData.alias.title = cfg.AliasName or "" end
                end
                if logic_roleinfo_title then
                    logic_roleinfo_title.newCheckId = id
                    logic_roleinfo_title.selectAliasId = tonumber(id) or id
                    if logic_roleinfo_title.aliasList then
                        for _, item in ipairs(logic_roleinfo_title.aliasList) do
                            if tostring(item.id) == tostring(id) then item.aliasState = 2 else item.aliasState = 1 end
                        end
                    end
                    if logic_roleinfo_title.arr_temp then
                        for _, item in pairs(logic_roleinfo_title.arr_temp) do
                            if tostring(item.id) == tostring(id) then item.aliasState = 2 else item.aliasState = 1 end
                        end
                    end
                    if logic_roleinfo_title.alias_list_info then
                        for _, v in pairs(logic_roleinfo_title.alias_list_info) do
                            if tostring(v.id) == tostring(id) then v.state = 2 else v.state = 1 end
                        end
                    end
                end
                EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ALL_TITLE)
            end)
        end
        
        CharacterHandler.send_change_user_avatar = function(item_url)
            GlobalShowNotice(49951)
            pcall(function()
                local DataMgr = _G.DataMgr
                local EventSystem = _G.EventSystem
                DataMgr.UpdateHeadIconUrl(item_url)
                EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_USE_AVATAR)
                EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_AVATAR)
            end)
        end
        
        CharacterHandler.send_change_avatar_box = function(item_id)
            GlobalShowNotice(49951)
            pcall(function()
                local DataMgr = _G.DataMgr
                local EventSystem = _G.EventSystem
                DataMgr.UpdateAvatarBoxId(tonumber(item_id) or 0)
                DataMgr.roleData.cur_avatar_box_id = tonumber(item_id) or 0
                pcall(function()
                    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
                    RoleInfoSystem.PersonalBasicInfo.role_avatar_frame = tonumber(item_id) or 0
                end)
                EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_AVATAR_FRAME_INFO)
                EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_AVATAR)
            end)
        end
    end
end)

pcall(function()
    local RoleInfoHandler = require("client.network.Protocol.RoleInfoHandler")
    if RoleInfoHandler then
        RoleInfoHandler.send_set_friend_nickname_skin_req = function(skin_id)
            GlobalShowNotice(49951)
            pcall(function()
                local DataMgr = _G.DataMgr
                local EventSystem = _G.EventSystem
                DataMgr.roleData.friend_nickname_skin = tonumber(skin_id) or skin_id
                local m = require("client.module_framework.module_manager")
                if m then
                    local sys = m.GetModule(m.LobbyModuleConfig.logic_roleInfo_nicknameframe)
                    if sys and sys.ProcChangeRsp then sys:ProcChangeRsp(skin_id) end
                end
                EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_NICKNAME_FRAME_UPDATE, true)
            end)
        end
        
        RoleInfoHandler.send_set_chat_bubble_req = function(bubble_id)
            GlobalShowNotice(49951)
            pcall(function()
                local DataMgr = _G.DataMgr
                local EventSystem = _G.EventSystem
                DataMgr.roleData.chat_bubble = tonumber(bubble_id) or bubble_id
                local m = require("client.module_framework.module_manager")
                if m then
                    local sys = m.GetModule(m.LobbyModuleConfig.logic_roleInfo_chatframe)
                    if sys and sys.ProcChangeRsp then sys:ProcChangeRsp(bubble_id) end
                end
                EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CHAT_FRAME_UPDATE, true)
            end)
        end
        
        RoleInfoHandler.send_equip_carte_frame_req = function(frame_id, bEquip)
            GlobalShowNotice(49951)
            pcall(function()
                local DataMgr = _G.DataMgr
                local EventSystem = _G.EventSystem
                DataMgr.roleData.carte_frame = tonumber(frame_id) or frame_id
                EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CARTE_FRAME_CHANGE)
            end)
        end
    end
end)
