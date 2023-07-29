if Config.useESX then
  ESX = exports["es_extended"]:getSharedObject()
else
  QBCore = exports['qb-core']:GetCoreObject()
end

RegisterCommand(Config.adminmenuCommand, function(source, args, rawCommand)
  TriggerClientEvent('ps_refunds:client:openRefunds', source)
end, true)

-- on player join

if Config.refundOnJoin then
  if Config.useESX then
    RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
      claimRefund(xPlayer.source)
    end)
  else
    AddEventHandler('QBCore:Server:PlayerLoaded', function(qbPlayer)
      claimRefund(qbPlayer.PlayerData.source)
    end)
  end
end

if Config.bonusCommand then
  RegisterCommand(Config.bonusCommand, function (source, args, rawCommand)
    claimRefund(source)
  end)
end


-- check for refunds
function claimRefund(source)
  local identifier
  if Config.useESX then
    identifier = ESX.GetPlayerFromId(source).getIdentifier()
  else
    identifier = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
  end
  local encoded = LoadResourceFile(GetCurrentResourceName(), "/data.json")
  local data = json.decode(encoded)
  for i, v in pairs (data) do
    local iden = mysplit(v.identifier, " -")
    if iden[1] == identifier then
      table.remove(data, i)
      if Config.useESX then
        ESX.GetPlayerFromId(source).addAccountMoney('bank', tonumber(v.count), "Received bonus: " .. v.reason)
      else
        QBCore.Functions.GetPlayer(source).Functions.AddMoney('bank', tonumber(v.count), "Received bonus: " .. v.reason)
      end
      Config.receivedRefund(source, v)
      -- print to json
      SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(data), -1)
      break
    end
  end
end


RegisterNetEvent('ps_refunds:server:addRefund', function(args)
  local source = source
  local encoded = LoadResourceFile(GetCurrentResourceName(), "./data.json") --data ophalen
  local data = json.decode(encoded)
  local identifier = args.values
  -- if identifier = -1 (all players in the database)
  for _, v in pairs(identifier) do
    data = addToTable(data, v, args.amount, args.reason)
  end

  SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(data), -1)

  if Config.useProperLogs and Config.useESX then
    local logsData = {
      ['creator'] = json.encode(ESX.GetPlayerFromId(source).getIdentifier()),
      ['target'] = json.encode(identifier),
      ['reason'] = args.reason,
      ['value'] = args.amount,
    }
    exports['properlogs']:registerLog('refunds', logsData)
  end
end)

function getPlayers(allPlayers)
  local players = {}
  if allPlayers then
    if Config.useESX then
      local playerIdentifiers = MySQL.Sync.fetchAll('SELECT identifier, firstname, lastname FROM users')
      for _, v in pairs(playerIdentifiers) do
        table.insert(players, v.identifier .. " - " .. (v.firstname or "?") .. " " .. (v.lastname or "?"))
      end
    else
      local playerIdentifiers = MySQL.Sync.fetchAll('SELECT citizenid, charinfo from players')
      for _, v in pairs(playerIdentifiers) do
        table.insert(players, v.citizenid .. " - " .. (json.decode(v.charinfo).firstname or "?") .. " " .. (json.decode(v.charinfo).lastname or "?"))
      end
    end
  else
    if Config.useESX then
      for _, v in pairs(ESX.GetExtendedPlayers()) do
        table.insert(players, v.getIdentifier() .. " - " .. v.getName() .. " - " .. v.source)
      end
    else
      for _, v in pairs(QBCore.Functions.GetPlayers()) do
        print(QBCore.Functions.GetIdentifier(v, 'license'))
        local p = QBCore.Functions.GetPlayer(v).PlayerData
        table.insert(players, p.citizenid .. " - " .. p.charinfo.firstname .. " " .. p.charinfo.lastname)
      end
    end
  end
  return players
end

RegisterNetEvent('ps_refunds:server:getRefunds', function ()
  local source = source
  local encoded = LoadResourceFile(GetCurrentResourceName(), "/data.json")
  local data = json.decode(encoded)

  -- players

  local allPlayers = getPlayers(true)
  local onlinePlayers = getPlayers(false)

  TriggerClientEvent('ps_refunds:client:getRefunds', source, data, allPlayers, onlinePlayers)
end)

RegisterNetEvent('ps_refunds:server:remove', function(index)
  local source = GetPedSourceOfDamage
  local encoded = LoadResourceFile(GetCurrentResourceName(), "/data.json")
  local data = json.decode(encoded)

  table.remove(data, index + 1) --remove index

  SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(data), -1)
end)

function addToTable(data, identifier, count, reason)
  local t =
  {
    identifier = identifier,
    count = count,
    reason = reason
  }
  table.insert(data, t)
  return data
end


function mysplit (inputstr, sep)
  if sep == nil then
          sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          table.insert(t, str)
  end
  return t
end