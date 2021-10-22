local vehicle_sounds = {}
RegisterNetEvent("engine:sound")
AddEventHandler("engine:sound", function(name,plate)
  print(name,plate)
    if vehicle_sounds[plate] == nil then
        vehicle_sounds[plate] = {}
    end
    vehicle_sounds[plate].plate = plate
    vehicle_sounds[plate].muffler = name
end)

vehiclehandling = {}
enginespec = false
Citizen.CreateThread(function()
    if Config.engine_handling then
      local f = LoadResourceFile("renzu_engine","handling.min.json")
      vehiclehandling = json.decode(f)
      Wait(100)
      collectgarbage()
    end
    while true do
      local mycoords = GetEntityCoords(PlayerPedId())
      local invehicle = IsPedInAnyVehicle(PlayerPedId())
      if not invehicle then enginespec = false end
      for k,v in pairs(GetGamePool('CVehicle')) do
          local veh = Entity(v).state
          if #(mycoords - GetEntityCoords(v, false)) < 100 and veh and veh.muffler and veh.engine then
            local plate = GetVehicleNumberPlateText(v)
            if vehicle_sounds[plate] == nil then
              vehicle_sounds[plate] = {}
              vehicle_sounds[plate].muffler = veh.muffler
              vehicle_sounds[plate].plate = plate
              vehicle_sounds[plate].entity = v
              vehicle_sounds[plate].engine = veh.engine
            end
            vehicle_sounds[plate].muffler = veh.muffler
            if vehicle_sounds[plate] ~= nil and vehicle_sounds[plate].plate ~= nil and plate == vehicle_sounds[plate].plate and vehicle_sounds[plate].current ~= vehicle_sounds[plate].muffler then
                ForceVehicleEngineAudio(v,vehicle_sounds[plate].muffler)
                SetEngineSpecs(v, vehicle_sounds[plate].engine)
                print(vehicle_sounds[plate].engine)
                vehicle_sounds[plate].current = vehicle_sounds[plate].muffler
            end
          elseif #(mycoords - GetEntityCoords(v, false)) > 100 and vehicle_sounds[plate] ~= nil and vehicle_sounds[plate].current ~= nil then
            vehicle_sounds[plate].current = nil
          end
      end
      for k,v in pairs(vehicle_sounds) do
        if not DoesEntityExist(v.entity) then
          vehicle_sounds[k] = nil
        end
      end
      Wait(2000)
    end
end)

nextgearhash = `SET_VEHICLE_NEXT_GEAR`
setcurrentgearhash = `SET_VEHICLE_CURRENT_GEAR`

function SetEngineSpecs(veh, model)
  if not Config.engine_handling then return end
	if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
		enginespec = false
		--print("INSIDE LOOP")
    plate = GetVehicleNumberPlateText(v)
		Wait(1300)
    veh = GetVehiclePedIsIn(PlayerPedId())
		Citizen.CreateThread(function()
			local model = model
			local handling = GetHandlingfromModel(model)
			local getcurrentvehicleweight = GetVehStats(veh , "CHandlingData","fMass")
			local multiplier = 1.0
			multiplier = (handling['fMass'] / getcurrentvehicleweight)
			enginespec = true
			Wait(10)
			if tonumber(handling['nInitialDriveGears']) > GetVehicleHandlingInt(veh , "CHandlingData","nInitialDriveGears") then
				-- another anti weird bug ( if the new engine gears is > the existing one, the existing old max gear persist, so we use this native below to cheat the bug)
				SetVehicleHighGear(veh ,tonumber(handling['nInitialDriveGears']) )
				Citizen.InvokeNative(0x8923dd42, veh , tonumber(handling['nInitialDriveGears']) )
				Citizen.InvokeNative(setcurrentgearhash & 0xFFFFFFFF, veh , tonumber(handling['nInitialDriveGears']) )
				Citizen.InvokeNative(nextgearhash & 0xFFFFFFFF, veh , tonumber(handling['nInitialDriveGears']) )
				Wait(11)
				Citizen.InvokeNative(setcurrentgearhash & 0xFFFFFFFF, veh , 1)
			end
			while enginespec do
        veh = GetVehiclePedIsIn(PlayerPedId())
				for k,v in pairs(handling) do
          local v = tonumber(v)
					if k == 'nInitialDriveGears' then
						gears = tonumber(v)
						if gears < 6 and tonumber(GetVehicleMod(veh,13)) > 0 then
							gears = tonumber(v) + 1
						end
						SetVehicleHandlingInt(veh , "CHandlingData", "nInitialDriveGears", gears)
						SetVehicleHandlingField(veh, 'CHandlingData', "nInitialDriveGears", gears)
					elseif k == 'fDriveInertia' then
						if multiplier < 0.8 then -- weight does not affect reving power
							m = 0.8
						else
							m = multiplier
						end
						SetVehStats(veh, "CHandlingData", "fDriveInertia", v * m)
					elseif k == 'fInitialDriveForce' then
						SetVehStats(veh, "CHandlingData", "fInitialDriveForce", v * multiplier)
					elseif k == 'fInitialDriveMaxFlatVel' then
						  mult = 1.0
							if tonumber(GetVehicleMod(veh,13)) > 0 then
								mult = 1.25
							end
              SetVehicleHandlingField(veh, "CHandlingData", "fInitialDriveMaxFlatVel", v * mult)
					elseif k ~= 'fMass' then
						SetVehStats(veh, "CHandlingData", tostring(k), v * 1.0)
					end
				end
				SetVehicleEnginePowerMultiplier(veh, 1.0) -- needed if maxvel and inertia is change, weird.. this can be call once only to trick the bug, but this is a 1 sec loop it doesnt matter.
				
				Wait(1000)
			end
			return
		end)
	end
	--SetVehicleHandlingField()
end

function GetHandlingfromModel(model)
	local model = GetHashKey(model)
	if Config.custom_engine_enable and Config.custom_engine[model] ~= nil then
		if Config.custom_engine[model].turboinstall then
			ToggleVehicleMod(GetVehiclePedIsIn(PlayerPedId()) , 18, true)
		end
		local t = {
			['fDriveInertia'] = tonumber(Config.custom_engine[model].fDriveInertia),
			['nInitialDriveGears'] = tonumber(Config.custom_engine[model].nInitialDriveGears),
			['fInitialDriveForce'] = tonumber(Config.custom_engine[model].fInitialDriveForce),
			['fClutchChangeRateScaleUpShift'] = tonumber(Config.custom_engine[model].fClutchChangeRateScaleUpShift),
			['fClutchChangeRateScaleDownShift'] = tonumber(Config.custom_engine[model].fClutchChangeRateScaleDownShift),
			['fInitialDriveMaxFlatVel'] = tonumber(Config.custom_engine[model].fInitialDriveMaxFlatVel),
			['fMass'] = tonumber(Config.custom_engine[model].fMass),
		}
		return t
	else
		for k,v in pairs(vehiclehandling) do
			--print(v.VehicleModels[1],model)
			if GetHashKey(v.VehicleModels[1]) == model then
				local t = {
					['fDriveInertia'] = tonumber(v.DriveInertia),
					['nInitialDriveGears'] = tonumber(v.InitialDriveGears),
					['fInitialDriveForce'] = tonumber(v.InitialDriveForce),
					['fClutchChangeRateScaleUpShift'] = tonumber(v.ClutchChangeRateScaleUpShift),
					['fClutchChangeRateScaleDownShift'] = tonumber(v.ClutchChangeRateScaleDownShift),
					['fInitialDriveMaxFlatVel'] = tonumber(v.InitialDriveMaxFlatVel),
					['fMass'] = tonumber(v.Mass),
				}
				return t
			end
		end
	end
	return false
end

function GetVehStats(veh,field,stat)
  return Citizen.InvokeNative(0x642FC12F, veh, field, stat, Citizen.ResultAsFloat())
end

function SetVehStats(veh,field,stat,float)
  SetVehicleHandlingFloat(veh, field, stat, float)
end