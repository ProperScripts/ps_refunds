ps_refunds Config information Any questions about this? Things we didn't include? Bugs or suggestions? Please join our discord: https://discord.gg/7qkZWdc67Y

**Config options**

Config.useESX: if you use the esx framework: true, for QBCore: false. If you want to use a custom framework, you need to edit the esx or qbcore functions in the code
Config.refundOnJoin: give refund when player joins (true/false)
Config.adminmenuCommand = Command to open refund menu for admins (String)
Config.bonusCommand = Command to claim refund, (false (boolean)) to disable (String)

Config.useProperLogs = own logs system (Comming soon), keep on false (Boolean)


Config.receivedRefund: the function on the SERVER side that will trigger when a player claims hes refund (example: for a chatmessage)
data.count: price of the refund (String)
data.reason: reason of the refund (String)
