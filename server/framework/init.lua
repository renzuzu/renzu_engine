mufflers = {}
Inventory = {}
ESX,QBCore = nil, nil
if GetResourceState('es_extended') == 'started' then
	ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
	QBCore = exports['qb-core']:GetCoreObject()
end