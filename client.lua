local vehicle_sounds = {}
RegisterNetEvent("engine:sound")
AddEventHandler("engine:sound", function(name,plate)
    if vehicle_sounds[plate] == nil then
        vehicle_sounds[plate] = {}
    end
    vehicle_sounds[plate].plate = plate
    vehicle_sounds[plate].name = name
end)

Citizen.CreateThread(function()
    while true do
        local mycoords = GetEntityCoords(PlayerPedId())
        for k,v in pairs(GetGamePool('CVehicle')) do
            if #(mycoords - GetEntityCoords(v, false)) < 100 then
                local plate = string.gsub(GetVehicleNumberPlateText(v), "%s+", "")
                if vehicle_sounds[plate] ~= nil and vehicle_sounds[plate].plate ~= nil and plate == vehicle_sounds[plate].plate and vehicle_sounds[plate].current ~= vehicle_sounds[plate].name then
                    ForceVehicleEngineAudio(v,vehicle_sounds[plate].name)
                    vehicle_sounds[plate].current = vehicle_sounds[plate].name
                end
            end
        end
        Wait(2000)
    end
end)