RegisterCommand("changesound", function(source, args, rawCommand)
  local veh = GetVehiclePedIsIn(GetPlayerPed(source))
  if args[1] ~= nil and veh ~= 0 then
      plate = string.gsub(GetVehicleNumberPlateText(veh), "%s+", "")
      TriggerClientEvent("engine:sound", -1, tostring(args[1]),plate)
  end
end, false)