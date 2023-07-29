Config = {}

Config.useESX = true                                -- true for esx, false for QBCore
Config.refundOnJoin = true                           -- give refund when player joins
Config.adminmenuCommand = "refunds"                  -- Command to open refund menu for admins
Config.bonusCommand = 'claimrefund'                  -- Command to claim refund, (false) to disable

Config.useProperLogs = false                         -- own logs system (Comming soon :) ), keep on false


Config.receivedRefund = function (source, data)
    if Config.useESX then
        TriggerClientEvent("esx:showNotification", source, "Received refund ($" .. data.count .. "): " .. data.reason)
    else
        TriggerClientEvent('QBCore:Notify', source, "Received refund ($" .. data.count .. "): " .. data.reason, 'success')
    end
end