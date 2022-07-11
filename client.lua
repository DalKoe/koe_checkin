----Gets ESX-------------------------------------------------------------------------------------------------------------------------------
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	PlayerLoaded = true
	ESX.PlayerData = ESX.GetPlayerData()

end)

Citizen.CreateThread(function()
	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function (xPlayer)
		while ESX == nil do
			Citizen.Wait(0)
		end
		ESX.PlayerData = xPlayer
		PlayerLoaded = true
        TriggerServerEvent('koe_checkin:getEmsCount')
        ESX.TriggerServerCallback('koe_checkin:emsCount', function(emscount)
            numberofems = emscount
        end)
	end)
end) 

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job

end)
---------------------------------------------------------------------------------------------------------------------------------------


local npcSpawned = false
local nancy
local numberofems = 0
local PlayerData = {}

--Spawn NPC--
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        for k, v in pairs(Config.NPCLocations) do 
            local npcCoords = v.npccoords
            local pedCoords = GetEntityCoords(PlayerPedId()) 
            local dst = #(npcCoords - pedCoords)
            
            if dst < 50 and npcSpawned == false then
                TriggerEvent('koe_checkin:spawnPed')
                TriggerServerEvent('koe_checkin:getEmsCount')
                ESX.TriggerServerCallback('koe_checkin:emsCount', function(emscount)
                    numberofems = emscount
                end)
                npcSpawned = true
            end
            -- if dst >= 51  then
            --     npcSpawned = false
            --     DeleteEntity(npc)
            -- end
        end
    end
end)

RegisterNetEvent('koe_checkin:spawnPed')
AddEventHandler('koe_checkin:spawnPed',function()
    for locations, info in pairs(Config.NPCLocations) do

        local hash = GetHashKey(info.npcmodel)
        if not HasModelLoaded(hash) then
            RequestModel(hash)
            Wait(10)
        end
        while not HasModelLoaded(hash) do 
            Wait(10)
        end

        npc = CreatePed(5, hash, info.npccoords , info.npcheading, false, false)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        SetModelAsNoLongerNeeded(hash)

        exports['qtarget']:AddEntityZone(info.location, npc, 
                {                
                    name=info.location,
                    debugPoly=false,
                    useZ = true
                }, 
                {
                    options = {
                        {
                        event = "koe_checkin:checkin",
                        icon = "fa-solid fa-clipboard",
                        label = "Check In",
                        illegal = info.illegal,
                        },                                     
                    },
                        distance = 2.5
                })  
    end

end)


RegisterNetEvent('koe_checkin:checkin')
AddEventHandler('koe_checkin:checkin',function(data)
    illegal = data.illegal
    TriggerServerEvent('koe_checkin:getEmsCount')
    ESX.TriggerServerCallback('koe_checkin:emsCount', function(emscount)
		numberofems = emscount
	end)
    Citizen.Wait(1500)
    
    for k, v in pairs(Config.NPCLocations) do

            if illegal == true then
                if lib.progressBar({
                    duration = 60000,
                    label = 'Checking In',
                    useWhileDead = true,
                    canCancel = false,
                    disable = {
                        car = true,
                        move = true,
                    },
                    anim = {
                        dict = 'missheistdockssetup1clipboard@base',
                        clip = 'base' 
                    },
                    prop = {
                        model = `p_amb_clipboard_01`,
                        pos = vec3(0.03, 0.03, 0.02),
                        rot = vec3(0.0, 0.0, -1.5) 
                    },
                })  then 
                    TriggerEvent('koe_checkin:revive')
                    lib.notify({
                        description = 'You have been healed!',
                        type = 'success',
                        duration = 10000,
                        position = 'top'
                    })
                end
                break
            end
            if numberofems >= 1 and illegal == false then
                lib.notify({
                    description = 'Please contact a EMS to be healed',
                    type = 'inform',
                    duration = 10000,
                    position = 'top'
                })
                break
            elseif numberofems == 0 and illegal == false then
                if lib.progressBar({
                    duration = 30000,
                    label = 'Checking In',
                    useWhileDead = true,
                    canCancel = false,
                    disable = {
                        car = true,
                        move = true,
                    },
                    anim = {
                        dict = 'missheistdockssetup1clipboard@base',
                        clip = 'base' 
                    },
                    prop = {
                        model = `p_amb_clipboard_01`,
                        pos = vec3(0.03, 0.03, 0.02),
                        rot = vec3(0.0, 0.0, -1.5) 
                    },
                })  then 
                    TriggerEvent('koe_checkin:revive')
                    lib.notify({
                        description = 'You have been healed!!!',
                        type = 'success',
                        duration = 10000,
                        position = 'top'
                    })
                end
                break
            end
    end
        

end)


RegisterNetEvent('koe_checkin:revive')
AddEventHandler('koe_checkin:revive', function()
    local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
    
    if Config.cd_playerhud then
        TriggerEvent('cd_playerhud:status:add', 'hunger', 20)
        TriggerEvent('cd_playerhud:status:add', 'thirst', 20)
        TriggerEvent('cd_playerhud:status:remove', 'stress', 20)
    end

	TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

	local formattedCoords = {
		x = ESX.Math.Round(coords.x, 1),
		y = ESX.Math.Round(coords.y, 1),
		z = ESX.Math.Round(coords.z, 1)
	}

	Citizen.Wait(200)
	ESX.SetPlayerData('lastPosition',{
		x = coords.x,
		y = coords.y,
		z = coords.z
	})

	Citizen.Wait(200)
	TriggerServerEvent('esx:updateLastPosition', {
		x = coords.x,
		y = coords.y,
		z = coords.z
	})

	Citizen.Wait(200)

	RespawnPed(playerPed, formattedCoords, 0.0)

	StopScreenEffect('DeathFailOut')

end)

function RespawnPed(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	ClearPedBloodDamage(ped)

	TriggerServerEvent('esx:onPlayerSpawn')
	TriggerEvent('esx:onPlayerSpawn')
	TriggerEvent('playerSpawned')
end