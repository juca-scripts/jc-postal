local configPostal = {}

Citizen.CreateThread(function()
    configPostal = MySQL.Sync.fetchAll("SELECT `data` FROM `jc-postal`", {})
    configPostal = next(configPostal[1]) and json.decode(configPostal[1].data) or {x = 0, y = 0}
end)

RegisterServerEvent('jc-postal:getConfig')
AddEventHandler('jc-postal:getConfig', function()
	TriggerClientEvent('jc-postal:initPostal', source, configPostal)
end)

RegisterServerEvent('jc-postal:saveConfig')
AddEventHandler('jc-postal:saveConfig', function(config)
    local src = source
    if src then
        if isAdmin(src) then
            configPostal = config
            MySQL.Async.execute("UPDATE `jc-postal` SET `data` = @data",{ 
                ['@data'] = json.encode(config)
            })
            TriggerClientEvent('jc-postal:setConfig', -1, configPostal)
        end
    end
end)

RegisterCommand(Config.commands.edit, function(source)
    local src = source
    if src then
        if isAdmin(src) then
            TriggerClientEvent('jc-postal:openEdit', source)
        end
    end
end)

function isAdmin(source)
    return IsPlayerAceAllowed(source, 'command')
end