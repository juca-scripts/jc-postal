local Wait, format, nearestPostalText, upper, format = Citizen.Wait, string.format, "", string.upper, string.format
local postals, nearest, pBlip, lastPostal = nil, nil, nil, nil

local showPostal = false
CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
			TriggerServerEvent('jc-postal:getConfig')
			return
		end
	end
end)

RegisterNetEvent('jc-postal:setConfig') 
AddEventHandler('jc-postal:setConfig', function(config)
    SendNUIMessage({
        action = 'sendConfig',
        config = config
    })
end)

RegisterNetEvent('jc-postal:initPostal') 
AddEventHandler('jc-postal:initPostal', function(config)
	Wait(1000)
    SendNUIMessage({
        action = 'sendConfig',
        config = config
    })
    Citizen.CreateThread(function()
        while true do
            local sleep = 1000
            if ((IsPedInAnyVehicle(PlayerPedId()) and Config.OnlyPostalInCar) or (not Config.OnlyPostalInCar)) and (not IsPauseMenuActive() or not Config.HideInPauseMenu) then
                sleep = 1
                if lastPostal ~= nearest.code then
                    SendNUIMessage({
                        action = 'update',
                        postal = nearestPostalText
                    })
                    lastPostal = nearest.code
                end
                if not showPostal then
                    SendNUIMessage({
                        action = 'show'
                    })
                    showPostal = true
                end
            elseif (Config.OnlyPostalInCar and showPostal) then
                SendNUIMessage({
                    action = 'hide'
                })
                showPostal = false
            end
            Wait(sleep)
        end
    end)
end)


RegisterNetEvent('jc-postal:openEdit') 
AddEventHandler('jc-postal:openEdit', function()
	SetNuiFocus(true, true)
    SendNUIMessage({
		action = 'edit'
	})
end)

Citizen.CreateThread(function()
    postals = LoadResourceFile(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'postal_file'))
    postals = json.decode(postals)
    for i, postal in ipairs(postals) do postals[i] = { vec(postal.x, postal.y), code = postal.code } end
end)

Citizen.CreateThread(function()
    while postals == nil do Wait(1) end

    local delay = math.max(Config.updateDelay and tonumber(Config.updateDelay) or 300, 50)
    if not delay or tonumber(delay) <= 0 then
        error("Invalid render delay provided, it must be a number > 0")
    end

    local postals = postals
    local deleteDist = Config.blip.distToDelete
    local formatTemplate = Config.text.format
    local _total = #postals

    while true do
        local coords = GetEntityCoords(PlayerPedId())
        local _nearestIndex, _nearestD
        coords = vec(coords[1], coords[2])

        for i = 1, _total do
            local D = #(coords - postals[i][1])
            if not _nearestD or D < _nearestD then
                _nearestIndex = i
                _nearestD = D
            end
        end

        if pBlip and #(pBlip.p[1] - coords) < deleteDist then
            TriggerEvent('chat:addMessage', {
                template = '<div class="chat-message advert"><table border="0" cellspacing="0" cellpadding="0"><tbody><tr><td class="bg-title-color gray"><b>{0}: </b></td><td class="bg-text-body"> {1}</td></tr></tbody></table></div>',
                args = {
                    'Postals',
                    "Has llegado a tu destino."
                }
            })
            RemoveBlip(pBlip.hndl)
            pBlip = nil
        end

        local _code = postals[_nearestIndex].code
        nearest = { code = _code, dist = _nearestD }
        nearestPostalText = format(formatTemplate, _code, _nearestD)
        Wait(delay)
    end
end)

TriggerEvent('chat:addSuggestion', '/'..Config.commands.postal, 'Set the GPS to a specific postal',{ { name = 'Postal Code', help = 'The postal code you would like to go to' } })

RegisterCommand(Config.commands.postal, function(_, args)
    if #args < 1 then
        if pBlip then
            RemoveBlip(pBlip.hndl)
            pBlip = nil
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0 },
                args = {
                    'Postals',
                    Config.blip.deleteText
                }
            })
        end
        return
    end

    local userPostal = upper(args[1])
    local foundPostal

    for _, p in ipairs(postals) do
        if upper(p.code) == userPostal then
            foundPostal = p
            break
        end
    end

    if foundPostal then
        if pBlip then RemoveBlip(pBlip.hndl) end
        local blip = AddBlipForCoord(foundPostal[1][1], foundPostal[1][2], 0.0)
        pBlip = { hndl = blip, p = foundPostal }
        SetBlipRoute(blip, true)
        SetBlipSprite(blip, Config.blip.sprite)
        SetBlipColour(blip, Config.blip.color)
        SetBlipRouteColour(blip, Config.blip.color)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(format(Config.blip.blipText, pBlip.p.code))
        EndTextCommandSetBlipName(blip)
        TriggerEvent('chat:addMessage', {
            template = '<div class="chat-message nonemergency"><table border="0" cellspacing="0" cellpadding="0"><tbody><tr><td class="bg-title-color gray"><b>{0}: </b></td><td class="bg-text-body"> {1}</td></tr></tbody></table></div>',
            args = {
                'Postals',
                format(Config.blip.drawRouteText, foundPostal.code)
            }
        })
    else
        
        TriggerEvent('chat:addMessage', {
            template = '<div class="chat-message advert"><table border="0" cellspacing="0" cellpadding="0"><tbody><tr><td class="bg-title-color gray"><b>{0}: </b></td><td class="bg-text-body"> {1}</td></tr></tbody></table></div>',
            args = {
                'Postals',
                Config.blip.notExistText
            }
        })
    end
end)

RegisterNUICallback("close", function(data, cb)
	SetNuiFocus(false, false)
end)

RegisterNUICallback("save", function(data, cb)
    TriggerServerEvent('jc-postal:saveConfig', data)
end)

exports('getPostal', function() return nearest and nearest.code or nil end)