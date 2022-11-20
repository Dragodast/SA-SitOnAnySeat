local Settings = {
    KeepEngineOn = true, ---Keeps The engine on after leaving the vehicle if the engine is on,
    NPCCheck = false --- Adds NPC Check to the code(Checks if there is any ped inside vehicle or not)
}

local dist, index,ped

local function CanSit(veh)
    if not Settings.NPCCheck then 
        return true 
    end
    for i = -1, 15 do
        if IsEntityAPed(GetPedInVehicleSeat(veh, i)) then return false end
    end
    return true
end

local function SitIntoCar()
    ped = PlayerPedId()
    if IsPedInAnyVehicle(ped) then
        if Settings.KeepEngineOn then
            local veh = GetVehiclePedIsIn(ped)
            if GetIsVehicleEngineRunning(veh) then
                TaskLeaveVehicle(ped, veh, 0)
                Wait(1000)
                SetVehicleEngineOn(veh, true, true, true)
            end
        end
    else
        --local veh = GetVehiclePedIsTryingToEnter(ped)
        local pos = GetEntityCoords(ped)
        local entityWorld = GetOffsetFromEntityInWorldCoords(ped, 0.0, 20.0, 0.0)

        local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, ped, 0)

        local a, b, c, d, veh = GetRaycastResult(rayHandle)
        
        if veh ~= 0 then
            if CanSit(veh) then
                local coords = GetEntityCoords(ped)
                if #(coords - GetEntityCoords(veh)) <= 3.5 then
                    ClearPedTasks(ped)
                    ClearPedSecondaryTask(ped)
                    for i = 0, GetNumberOfVehicleDoors(veh), 1 do
                        local coord = GetEntryPositionOfDoor(veh, i)
                        if (IsVehicleSeatFree(veh, i - 1) and
                            GetVehicleDoorLockStatus(veh) ~= 2) then
                            if dist == nil then
                                dist = #(coords - coord)
                                index = i
                            end
                            if #(coords - coord) < dist then
                                dist = #(coords - coord)
                                index = i
                            end
                        end
                    end
                    if index then
                        TaskEnterVehicle(ped, veh, 10000, index - 1,1.0, 1, 0)
                    end
                    index, dist = nil, nil
                end
            end
        end
    end
end

RegisterCommand('+SitPasssenger', function()
    SitIntoCar()
end)

RegisterKeyMapping('+SitPasssenger', 'Sit as passenger', 'keyboard', 'g')        

--[[ CreateThread(function()
    while true do
        if IsControlJustPressed(0, 75) then
            SitIntoCar()
        end
        Wait(10)
    end
end) ]]
