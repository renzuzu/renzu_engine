

ESX = exports['es_extended']:getSharedObject()
local mufflers = {}

RegisterCommand("changeengine", function(source, args, rawCommand)
  local source = source
  local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
  print(veh,GetPlayerPed(source))
  if args[1] ~= nil and veh ~= 0 and Config.Command then
      plate = GetVehicleNumberPlateText(veh)
      --TriggerClientEvent("engine:sound", -1, tostring(args[1]),plate)
      if mufflers[plate] == nil then
        mufflers[plate] = {}
      end
      mufflers[plate].current = mufflers[plate].muffler or args[1]
      mufflers[plate].muffler = args[1]
      mufflers[plate].engine = args[1]
      mufflers[plate].plate = plate
      local ent = Entity(veh).state
      local hash = GetHashKey(mufflers[plate].muffler)
      ent:set('muffler', Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or mufflers[plate].muffler, true)
      ent:set('engine', mufflers[plate].engine, true)
      SaveMuffler(plate,mufflers[plate])
  end
end, false)

EngineSwap = function(net,type)
  local vehicle = NetworkGetEntityFromNetworkId(net)
  if not DoesEntityExist(vehicle) then return end
  local plate = string.gsub(GetVehicleNumberPlateText(vehicle), '^%s*(.-)%s*$', '%1'):upper()
  if mufflers[plate] == nil then
    mufflers[plate] = {}
  end
  mufflers[plate].current = mufflers[plate].muffler or type
  mufflers[plate].muffler = type
  mufflers[plate].engine = type
  mufflers[plate].plate = plate
  local ent = Entity(vehicle).state
  local hash = GetHashKey(mufflers[plate].muffler)
  ent:set('muffler', Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or mufflers[plate].muffler, true)
  ent:set('engine', mufflers[plate].engine, true)
  SaveMuffler(plate,mufflers[plate])
end

exports('EngineSwap', EngineSwap)
RegisterNetEvent('renzu_engine:EngineSwap', EngineSwap)

Citizen.CreateThread(function()
  local ret = json.decode(GetResourceKvpString('renzu_engine') or '[]') or {}
  for k,v in pairs(ret) do
    if not mufflers[v.plate] then mufflers[v.plate] = {} end
    mufflers[v.plate].plate = v.plate
    mufflers[v.plate].engine = v.muffler
    mufflers[v.plate].muffler = v.muffler
    mufflers[v.plate].current = v.muffler
  end

  for k,v in ipairs(GetAllVehicles()) do
    local plate = GetVehicleNumberPlateText(v)
    if mufflers[plate] and plate == mufflers[plate].plate then
      local ent = Entity(v).state
      local hash = GetHashKey(mufflers[plate].muffler)
      ent:set('muffler', Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or mufflers[plate].muffler, true)
      ent:set('engine', mufflers[plate].engine, true)
    end
  end
end)

CreateEngine = function(name)
  local data = Engines[name]
  local metadata = {
    description = data.name..' Engine - Can be installed to any vehicle. | brand: '..data.brand,
    image = 'engine',
    engine = data.model or data.handlingName,
    label = data.name..' Engine'
  }
  exports.ox_inventory:AddItem(source,'enginegago',1,metadata, false, function(success, reason)
  end)
end

exports('CreateEngine', function(name)
  CreateEngine(name)
end)

RegisterNetEvent('buyengine', function(k)
  local data = Engines[k]
  local money = exports.ox_inventory:GetItem(source, 'money', nil, false)
  if data.name == nil then data.name = data.handlingName end
  if data.brand == nil then data.brand = 'Custom' end
  if money.count >= data.price then
    CreateEngine(k)
    exports.ox_inventory:RemoveItem(source, 'money', data.price, nil)
    TriggerClientEvent('renzu_engine:Notify',source, 'success', data.name..' Engine has been Bought')
  end
end)

function SaveMuffler(plate,muffler)
    local plate_ = plate
    local data = json.decode(GetResourceKvpString('renzu_engine') or '[]') or {}
    if data[plate] == nil then
      data[plate] = muffler
      SetResourceKvp('renzu_engine',json.encode(data))
    elseif data[plate] then
      data[plate] = muffler
      SetResourceKvp('renzu_engine',json.encode(data))
    end
end

function firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end

Citizen.CreateThread(function()
  while ESX == nil do Wait(1011) end
  if Config.Ox_Inventory then
    ESX.RegisterUsableItem("enginegago", function(source,item,data)
      local xPlayer = ESX.GetPlayerFromId(source)
      print('data',data)
      if Config.jobonly and xPlayer.job.name ~= tostring(Config.mufflerjob) then print("not mech") return end
      local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
      local enginename = data.metadata.engine
      local muffler = Config.custom_engine[GetHashKey(enginename)] ~= nil and Config.custom_engine[GetHashKey(enginename)].soundname or enginename
      if muffler ~= nil and veh ~= 0 then
        plate = GetVehicleNumberPlateText(veh)
        if mufflers[plate] == nil then
          mufflers[plate] = {}
        end
        mufflers[plate].current = mufflers[plate].muffler or muffler
        mufflers[plate].muffler = muffler
        mufflers[plate].plate = plate
        mufflers[plate].engine = muffler
        local ent = Entity(veh).state
        local hash = GetHashKey(mufflers[plate].muffler)
        TriggerClientEvent('renzu_engine:OnEngineChange',source)
        ent:set('muffler', Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or mufflers[plate].muffler, true)
        ent:set('engine', mufflers[plate].engine, true)
        xPlayer.removeInventoryItem("enginegago", 1)
        SaveMuffler(plate,mufflers[plate])
      end
      print(enginename,data.metadata,'aso')
    end)
  end
  print(" MUFFLER LOADED ")
end)

local servervehicles = {}
AddEventHandler('entityCreated', function(entity)
  local entity = entity
  Wait(2000)
  if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
    local plate = GetVehicleNumberPlateText(entity)
    if mufflers[plate] and mufflers[plate].muffler then
      local ent = Entity(entity).state
      local hash = GetHashKey(mufflers[plate].muffler)
      ent:set('muffler', Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or mufflers[plate].muffler, true)
      ent:set('engine', mufflers[plate].engine, true)
      if servervehicles[plate] and DoesEntityExist(NetworkGetEntityFromNetworkId(servervehicles[plate])) and GetEntityType(NetworkGetEntityFromNetworkId(servervehicles[plate])) == 2 and servervehicles[GetVehicleNumberPlateText(NetworkGetEntityFromNetworkId(servervehicles[plate]))] then
        DeleteEntity(NetworkGetEntityFromNetworkId(servervehicles[plate])) -- delete duplicate vehicle with the same plate wandering in the server
      end
      servervehicles[plate] = NetworkGetNetworkIdFromEntity(entity)
    end
  end
end)
