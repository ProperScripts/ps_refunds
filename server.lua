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

if Config.refundCommand then
  RegisterCommand(Config.refundCommand, function (source, args, rawCommand)
    claimRefund(source)
  end)
end

RegisterNetEvent('ps_refunds:server:checkitemvalid', function (item)
  local source = source
  local value = false;
  if ESX.Items[item] then
    value = true;
  else
    value = false
  end
  TriggerClientEvent('ps_refunds:client:checkitemvalid', source, value)
end)


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
      local itemString = ""
      if Config.useESX then
        local player = ESX.GetPlayerFromId(source);
        if tonumber(v.count) > 1 then
          player.addAccountMoney('bank', tonumber(v.count), "Received refund: " .. v.reason)
        end
        for j, k in pairs(v.items) do
          local itemname = k[1]
          local count = tonumber(k[2])
          player.addInventoryItem(itemname, count)
          itemString = itemString .. count .. "x " .. itemname .. "; "
        end
      else
        -- need to add giveitem function
        QBCore.Functions.GetPlayer(source).Functions.AddMoney('bank', tonumber(v.count), "Received refund: " .. v.reason)
      end
      Config.receivedRefund(source, v, itemString)
      -- print to json
      SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(data), -1)
      break
    end
  end
end


RegisterNetEvent('ps_refunds:server:addRefund', function(args)
  local source = source
  if not IsPlayerAceAllowed(source, 'command.' .. Config.adminmenuCommand) then return print(GetPlayerName(source) .. ' (' .. tostring(source) .. ') tried to use ps_refunds:server:addRefund but lacks the ace permission `command.' .. Config.adminmenuCommand .. '`') end
  local encoded = LoadResourceFile(GetCurrentResourceName(), "./data.json")
  local data = json.decode(encoded)
  local identifier = args.values
  local items = {}
  local itemString = ""
  for i, v in pairs(args.items) do
    if v ~= nil then
      items[#items+1] = v
      itemString = itemString .. v[2] .. "x " .. v[1] .. "; "
    end
  end
  -- if identifier = -1 (all players in the database)
  for _, v in pairs(identifier) do
    data = addToTable(data, v, args.amount, args.reason, items)
  end

  SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(data), -1)

  if Config.useProperLogs and Config.useESX then
    local logsData = {
      ['creator'] = json.encode(ESX.GetPlayerFromId(source).getIdentifier()),
      ['target'] = json.encode(identifier),
      ['reason'] = args.reason,
      ['money'] = args.amount,
      ['items'] = itemString,
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
  local source = source
  if not IsPlayerAceAllowed(source, 'command.' .. Config.adminmenuCommand) then return print(GetPlayerName(source) .. ' (' .. tostring(source) .. ') tried to use ps_refunds:server:remove but lacks the ace permission `command.' .. Config.adminmenuCommand .. '`') end
  local encoded = LoadResourceFile(GetCurrentResourceName(), "/data.json")
  local data = json.decode(encoded)

  table.remove(data, index + 1) --remove index

  SaveResourceFile(GetCurrentResourceName(), "./data.json", json.encode(data), -1)
end)

function addToTable(data, identifier, count, reason, items)
  local t =
  {
    identifier = identifier,
    count = count,
    reason = reason,
    items = items
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