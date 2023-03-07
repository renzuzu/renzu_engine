vehiclehandling = {}
local customengine = {}
refresh = false
AddStateBagChangeHandler('muffler' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(0)
	local entity = GetEntityFromStateBagName(bagName)
	if not value or entity == 0 then return end
	local ent = Entity(entity).state
	local plate = GetVehicleNumberPlateText(entity)
	ForceVehicleEngineAudio(entity,value)
end)

AddStateBagChangeHandler('engine' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(0)
	local entity = GetEntityFromStateBagName(bagName)
	if not value or entity == 0 then return end
	local ent = Entity(entity).state
	local plate = GetVehicleNumberPlateText(entity)
	SetEngineSpecs(entity, value)
	customengine[plate] = Entity(entity).state.engine
	exports.renzu_tuners:SetDefaultHandling(entity,GetHandlingfromModel(value))
end)


Citizen.CreateThread(function()
	Wait(1)
    if Config.engine_handling then
      local f = LoadResourceFile("renzu_engine","data/handling.min.json")
      vehiclehandling = json.decode(f)
      Wait(100)
      collectgarbage()
    end
end)

AddEventHandler('gameEventTriggered', function (name, args)
	if name == 'CEventNetworkPlayerEnteredVehicle' then
		if args[1] == PlayerId() then
			local plate = GetVehicleNumberPlateText(args[2])
			print(args[1],args[2],customengine[plate],plate)
			if customengine[plate] and DoesEntityExist(args[2]) then
				refresh = true
				Wait(500)
				print('set specs')
				SetEngineSpecs(args[2], customengine[plate])
			end
		end
	end
	--print(name)
end)

RegisterNetEvent('renzu_engine:Notify', function(type,msg)
	lib.defaultNotify({
		title = 'Engine',
		description = msg,
		status = type
	})
end)

nextgearhash = `SET_VEHICLE_NEXT_GEAR`
setcurrentgearhash = `SET_VEHICLE_CURRENT_GEAR`

currentengine = nil
function SetEngineSpecs(veh, model)
	print(veh,model)
	if not Config.engine_handling then return end
	if currentengine == model then return end
	if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
		currentengine = model
		local model = model
		local handling = GetHandlingfromModel(model)
		if not handling then return end
		while refresh do Wait(1) end
    	plate = GetVehicleNumberPlateText(v)
    	veh = GetVehiclePedIsIn(PlayerPedId())
		Citizen.CreateThread(function()
			local getcurrentvehicleweight = GetVehStats(veh , "CHandlingData","fMass")
			local multiplier = 1.0
			multiplier = (handling['fMass'] / getcurrentvehicleweight)
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
			while currentengine == model and IsPedInAnyVehicle(PlayerPedId()) and not refresh do
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
			if currentengine == model then
				currentengine = nil
			end
			refresh = false
			return
		end)
	end
	--SetVehicleHandlingField()
end

FindModelFromTable = function(model)
	for k,v in pairs(Config.custom_engine) do
       if v.soundname == model then
           return k
	   end
	end
	return model
end

function GetHandlingfromModel(m)
	local model = GetHashKey(m)
	if not Config.custom_engine[m] then
        model = FindModelFromTable(m)
	end
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
			if GetHashKey(v.VehicleModels[1]) == GetHashKey(m) then
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