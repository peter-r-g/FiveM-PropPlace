SERVER = true
local props = props or {}

--- Gets the number of entities created of the prop name.
---@param src The players source
---@param propName The prop name to check
---@return The number of entities of the prop name
local function GetNumberOfType(src, propName)
    props[src] = props[src] or {}
    local numType = 0

    for index, tbl in pairs(props[src]) do
        if tbl.type == propName then
            numType = numType + 1
        end
    end

    return numType
end

--- Handles deletion of a players props when they disconnect.
local function HandlePlayerDisconnect()
    local src = source
    props[src] = props[src] or {}

    for index, data in pairs(props[src]) do
        DeleteEntity(NetworkGetEntityFromNetworkId(data.networkId))
    end

    props[src] = nil
end
AddEventHandler("playerDropped", HandlePlayerDisconnect)

--- Handles caching the network ID of a created prop so that it can be deleted by the server.
---@param index The prop index this network ID is for
---@param propNetworkId The props entity network ID
local function PropPlaced(index, propNetworkId)
    local src = source
    props[src] = props[src] or {}
    props[src][index] = props[src][index] or {}
    props[src][index]["networkId"] = propNetworkId
end
RegisterNetEvent("pp:server:PropPlaced", PropPlaced)

--- Checks if a placement request is valid.
---@param propName The prop name that is being requested
---@param variation The variation of the prop that is being requested
local function PropPlaceRequested(propName, variation)
    local src = source
    local propData, limit = Config:GetProp(propName, variation, src)
    if not propData then return end

    props[src] = props[src] or {}
    local nextIndex = #props[src] + 1
    if nextIndex > Config.MaxProps then return end
    if limit ~= -1 and GetNumberOfType(src, propName) >= limit then return end

    props[src][nextIndex] = {
        ["type"] = propName
    }
    TriggerClientEvent("pp:client:PlaceProp", src, nextIndex, propName, variation)
end
RegisterNetEvent("pp:server:RequestPlaceProp", PropPlaceRequested)

--- Checks if a delete request is valid.
---@param propIndex The prop index that is being deleted
local function DeletePropRequested(propIndex)
    local src = source
    props[src] = props[src] or {}
    if not props[src][propIndex] then return end

    props[src][propIndex] = nil
    TriggerClientEvent("pp:client:DeleteProp", src, propIndex)
end
RegisterNetEvent("pp:server:RequestDeleteProp", DeletePropRequested)