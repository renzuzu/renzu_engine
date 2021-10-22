

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
mufflers = {}

RegisterCommand("changesound", function(source, args, rawCommand)
  local source = source
  local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
  print(veh,GetPlayerPed(source))
  if args[1] ~= nil and veh ~= 0 then
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
      ent.muffler = Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or mufflers[plate].muffler
      ent.engine = mufflers[plate].engine
  end
end, false)

Citizen.CreateThread(function()
  local ret = SqlFunc(Config.Mysql,'fetchAll','SELECT * FROM renzu_muffler', {})
  for k,v in pairs(ret) do
    mufflers[v.plate] = v
    mufflers[v.plate].engine = v.muffler
    mufflers[v.plate].current = v.muffler
  end

  for k,v in ipairs(GetAllVehicles()) do
    local plate = GetVehicleNumberPlateText(v)
    if mufflers[plate] and plate == mufflers[plate].plate then
      local ent = Entity(v).state
      local hash = GetHashKey(mufflers[plate].muffler)
      ent.muffler = Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or mufflers[plate].muffler
      ent.engine = mufflers[plate].engine
    end
  end
end)

RegisterNetEvent('renzu_muffler:setmuffler')
AddEventHandler('renzu_muffler:setmuffler', function(muffler,plate)
  mufflers[plate] = muffler
end)

function SaveMuffler(plate,muffler)
    local result = SqlFunc(Config.Mysql,'fetchAll','SELECT * FROM renzu_muffler WHERE TRIM(plate) = @plate', {['@plate'] = plate})
    if result[1] == nil then
        SqlFunc(Config.Mysql,'execute','INSERT INTO renzu_muffler (plate, muffler) VALUES (@plate, @muffler)', {
            ['@plate']   = plate,
            ['@muffler']   = muffler,
        })
    elseif result[1] then
        SqlFunc(Config.Mysql,'execute','UPDATE renzu_muffler SET muffler = @muffler WHERE TRIM(plate) = @plate', {
            ['@plate'] = plate,
            ['@muffler'] = muffler,
        })
    end
end

function SqlFunc(plugin,type,query,var)
	local wait = promise.new()
    if type == 'fetchAll' and plugin == 'mysql-async' then
		    MySQL.Async.fetchAll(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'mysql-async' then
        MySQL.Async.execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'ghmattisql' then
        exports['ghmattimysql']:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'ghmattisql' then
        exports.ghmattimysql:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'execute' and plugin == 'oxmysql' then
        exports.oxmysql:execute(query, var, function(result)
            wait:resolve(result)
        end)
    end
    if type == 'fetchAll' and plugin == 'oxmysql' then
		exports['oxmysql']:fetch(query, var, function(result)
			wait:resolve(result)
		end)
    end
	return Citizen.Await(wait)
end

function firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end

Citizen.CreateThread(function()
  c = 0
  if Config.custom_engine_enable then
    for k, v in pairs(Config.custom_engine) do
      Config.engine[k] = v
    end
  end
  for v, k in pairs(Config.engine) do
    c = c + 1
    if tonumber(v) then
      v = k.handlingName
      --print(v)
    end
    local enginename = string.lower(v)
    local label = string.upper(v)
    foundRow = SqlFunc(Config.Mysql,'fetchAll',"SELECT * FROM items WHERE name = @name", {
      ['@name'] = "muffler_"..enginename..""
    })
    if foundRow[1] == nil then
      local weight = 'limit'
      if Config.weight_type then
        SqlFunc(Config.Mysql,'execute',"INSERT INTO items (name, label, weight) VALUES (@name, @label, @weight)", {
          ['@name'] = "muffler_"..enginename.."",
          ['@label'] = ""..firstToUpper(enginename).." Exhaust",
          ['@weight'] = Config.weight
        })
        print("Inserting "..enginename.."")
      else
        SqlFunc(Config.Mysql,'execute',"INSERT INTO items (name, label) VALUES (@name, @label)", {
          ['@name'] = "muffler_"..enginename.."",
          ['@label'] = ""..firstToUpper(enginename).." Exhaust",
        })
        print("Inserting "..enginename.."")
      end
    end
  end
  while ESX == nil do Wait(10) end
  for v, k in pairs(Config.engine) do
    if tonumber(v) then
      v = k.handlingName
    end
    local enginename = string.lower(v)
    --print("register item", enginename)
    ESX.RegisterUsableItem("muffler_"..enginename.."", function(source)
      local xPlayer = ESX.GetPlayerFromId(source)
      if Config.jobonly and xPlayer.job.name ~= tostring(Config.mufflerjob) then print("not mech") return end
      xPlayer.removeInventoryItem("muffler_"..enginename.."", 1)
      local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
      local muffler = Config.custom_engine[GetHashKey(enginename)] ~= nil and Config.custom_engine[GetHashKey(enginename)].soundname or enginename
      if muffler ~= nil and veh ~= 0 then
        plate = GetVehicleNumberPlateText(veh)
        if mufflers[plate] == nil then
          mufflers[plate] = {}
        end
        mufflers[plate].current = mufflers[plate].muffler or muffler
        mufflers[plate].muffler = muffler
        mufflers[plate].plate = plate
        mufflers[plate].engine = v
        local ent = Entity(veh).state
        local hash = GetHashKey(mufflers[plate].muffler)
        ent.muffler = Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or mufflers[plate].muffler
        ent.engine = mufflers[plate].engine
        SaveMuffler(plate,v)
      end
    end)
  end
  print(" MUFFLER LOADED ")
end)

AddEventHandler('entityCreated', function(entity)
  local entity = entity
  if GetEntityPopulationType(entity) == 7 and DoesEntityExist(entity) then
    Wait(4000)
    local plate = GetVehicleNumberPlateText(entity)
    if mufflers[plate] and mufflers[plate].muffler then
      local ent = Entity(entity).state
      local hash = GetHashKey(mufflers[plate].muffler)
      ent.muffler = Config.custom_engine[hash] ~= nil and Config.custom_engine[hash].soundname or mufflers[plate].muffler
      ent.engine = mufflers[plate].engine
    end
  end
end)