CreateThread(function()
    local dist,index
    while true do
        local ped = GetPlayerPed(-1)
        if IsControlJustPressed(0,75) then 
            if IsPedInAnyVehicle(ped) then 
                local veh = GetVehiclePedIsIn(ped)
                if GetIsVehicleEngineRunning(veh) then
                    TaskLeaveVehicle(ped, veh, 0)
                    Wait(1000)
                    SetVehicleEngineOn(veh, true, true, true)
                end
            else 
                local veh = GetVehiclePedIsTryingToEnter(ped)
                if veh ~= 0 then 
                    local coords = GetEntityCoords(ped)
                    if #(coords-GetEntityCoords(veh)) <= 3.5 then
                        ClearPedTasks(ped)
                        ClearPedSecondaryTask(ped)
                        for i=0,GetNumberOfVehicleDoors(veh),1 do 
                            local coord = GetEntryPositionOfDoor(veh, i)
                            if (IsVehicleSeatFree(veh,i-1) and GetVehicleDoorLockStatus(veh) ~= 2) then
                                if dist == nil then dist = #(coords-coord);index = i end 
                                if #(coords-coord) < dist then dist = #(coords-coord);index = i end
                            end
                        end 
                        if index then
                            TaskEnterVehicle(ped, veh, 10000, index - 1, 1.0, 1, 0) 
                        end
                        index,dist = nil,nil
                    end
                end
            end
        end
        Wait(1)
    end
end)