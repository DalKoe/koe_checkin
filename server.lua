----Gets ESX-----
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local emscount = 0

RegisterNetEvent("koe_checkin:getEmsCount")
AddEventHandler("koe_checkin:getEmsCount", function(count)
			local ems = 0
			local xPlayers = ESX.GetPlayers()
			for i=1, #xPlayers, 1 do
				local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
				if xPlayer.job.name == 'ambulance' then
					ems = ems + 1
				end
			end
			emscount = ems
end)


ESX.RegisterServerCallback("koe_checkin:emsCount", function(source, cb)
	cb(emscount)
end)