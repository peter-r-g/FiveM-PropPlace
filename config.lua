Config = {}

--- The distance a player must be within a prop to delete it.
Config.DeleteDistance = 2
--- The maximum amount of props someone can place.
Config.MaxProps = 10

--- Messages used by this resource.
Config.Messages = {
    ["prop_noargs"] = "Missing prop to place",
    ["prop_nodata"] = "No prop exists with that name",
    ["propdel_nonearby"] = "No props nearby to remove"
}

--- General props all players can use.
Config.Props = {
    ["campfire"] = {
        ["mdl"] = "prop_beach_fire",
        ["limit"] = 1,
        ["zOffset"] = -0.5
    },
    ["microphone"] = {
        ["mdl"] = "	v_ilev_fos_mic",
        ["limit"] = 1
    },
    ["speaker"] = {
        ["mdl"] = "prop_speaker_05",
        ["limit"] = 2
    },
    ["tent"] = {
        ["mdl"] = "prop_skid_tent_cloth",
        ["limit"] = 1
    }
}
--- Props that can only be used by certain jobs.
Config.JobProps = {
    ["police"] = {
        ["barrier"] = {
            ["mdl"] = "prop_barrier_work06a",
            ["limit"] = 2
        },
        ["cone"] = {
            [1] = {
                ["mdl"] = "prop_mp_cone_02"
            },
            [2] = {
                ["mdl"] = "prop_roadcone02c"
            },
            ["default"] = 1,
            ["limit"] = 5
        }
    },
    ["ems"] = {
        ["firstaid"] = {
            ["mdl"] = "prop_medstation_03",
            ["limit"] = 3
        }
    }
}

--- Handler for error messages.
---@param msg string The message to send in the chatbox.
function Config:ErrorMessage(msgName)
    TriggerEvent("chat:addMessage", {
        color = { 255, 0, 0 },
        multiline = true,
        args = { "Error", self.Messages[msgName] or msgName }
    })
end

local QBCore = exports['qb-core']:GetCoreObject()
local function GetVariation(propData, variation)
    if variation then
        local data = propData[variation]
        if data then return data, propData.limit or -1 end
    end

    if propData.default then
        local data = propData[propData.default]
        if data then return data, propData.limit or -1 end
    end

    return propData, propData.limit or -1
end

function Config:GetProp(propName, variation, source)
    local generalPropData = self.Props[propName]
    if generalPropData then return GetVariation(generalPropData, variation) end

    local jobs = Config:GetJobs(source)
    for i = 1, #jobs do
        local jobPropData = self.JobProps[jobs[i]][propName]
        if jobPropData then return GetVariation(jobPropData, variation) end
    end
end

function Config:GetJobs(source)
    if SERVER then
        return {QBCore.Functions.GetPlayer(source).PlayerData.job.name}
    end

    return {QBCore.Functions.GetPlayerData(source).job.name}
end