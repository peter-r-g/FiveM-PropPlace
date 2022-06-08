local props = props or {}

--- Gets the closest player-owned prop.
---@return The closest prop
---@return The props distance from the player
---@return The props index in the props table.
local function GetClosestProp()
    local pos = GetEntityCoords(PlayerPedId())
    local currentProp
    local currentPropDist = -1
    local currentPropIndex = -1

    for index, prop in pairs(props) do
        local dist = #(pos - GetEntityCoords(prop))
        if currentProp then
            if dist < currentPropDist then
                currentProp = prop
                currentPropDist = dist
                currentPropIndex = index
            end
        else
            currentProp = prop
            currentPropDist = dist
            currentPropIndex = index
        end
    end

    return currentProp, currentPropDist, currentPropIndex
end

--- Places a new prop.
---@param nextIndex The index the prop will be saved in
---@param propName The name of the prop to create
---@param variation The variation of the prop that is being created
local function PlaceProp(nextIndex, propName, variation)
    local propData = Config:GetProp(propName, variation)
    local playerPed = PlayerPedId()
    local pos, heading = GetEntityCoords(playerPed) + GetEntityForwardVector(playerPed) * 2, GetEntityHeading(playerPed)

    local prop = CreateObject(propData.mdl, pos.x, pos.y, pos.z, true, false, false)
    SetEntityHeading(prop, heading)
    PlaceObjectOnGroundProperly(prop)
    if propData.zOffset then
        SetEntityCoords(prop, GetEntityCoords(prop) + vector3(0, 0, propData.zOffset))
    end

    props[nextIndex] = prop
    TriggerServerEvent("pp:server:PropPlaced", nextIndex, NetworkGetNetworkIdFromEntity(prop))
end
RegisterNetEvent("pp:client:PlaceProp", PlaceProp)

--- Deletes a prop.
---@param index The index of the prop to delete
local function DeleteProp(index)
    NetworkRequestControlOfEntity(props[index])
    DeleteObject(props[index])
    props[index] = nil
end
RegisterNetEvent("pp:client:DeleteProp", DeleteProp)

--- The prop command handler.
---@param _ Unused
---@param args The whitespace-seperated chat arguments
local function PropCmd(_, args)
    if not args[1] then
        Config:ErrorMessage("prop_noargs")
        return
    end

    local prop = string.lower(args[1])
    local propData = Config:GetProp(prop)
    if not propData then
        Config:ErrorMessage("prop_nodata")
        return
    end

    TriggerServerEvent("pp:server:RequestPlaceProp", prop, tonumber(args[2]))
end
RegisterCommand("prop", PropCmd, false)

--- The prop delete command handler.
---@param _ Unused
---@param args The whitespace-seperated chat arguments
local function PropDelCmd(_, args)
    local prop, propDist, propIndex = GetClosestProp()
    if not prop or propDist > Config.DeleteDistance then
        Config:ErrorMessage("propdel_nonearby")
        return
    end

    TriggerServerEvent("pp:server:RequestDeleteProp", propIndex)
end
RegisterCommand("propdel", PropDelCmd, false)