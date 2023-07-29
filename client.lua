local ui = false;

RegisterNetEvent('ps_refunds:client:openRefunds', function()
    ui = not ui
    if ui then
        TriggerServerEvent('ps_refunds:server:getRefunds')
    else
        SetNuiFocus(false, false)
        SendNUIMessage({showUI = false; }) -- Sends a message to the js file.
    end
end)

RegisterNetEvent('ps_refunds:client:getRefunds', function (data, allPlayers, onlinePlayers)
    SetNuiFocus(true, true)
    SendNUIMessage({showUI = true; data = data; allPlayers = allPlayers; onlinePlayers = onlinePlayers}) -- Sends a message to the js file.
end)

RegisterNUICallback('close', function(data, cb)
    ui = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback('submit', function (data, cb)
    TriggerServerEvent('ps_refunds:server:addRefund', data)
    TriggerServerEvent('ps_refunds:server:getRefunds')   --refresh
end)

RegisterNUICallback('remove', function (data, cb)
    TriggerServerEvent('ps_refunds:server:remove', data.index)
    TriggerServerEvent('ps_refunds:server:getRefunds')   --refresh
end)