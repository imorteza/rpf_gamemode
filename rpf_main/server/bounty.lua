local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","lsv-main")

local logger = Logger:CreateNamedLogger('Bounty')

local bountyPlayerId = nil
local eventFinishedTime = nil


Citizen.CreateThread(function()
	eventFinishedTime = GetGameTimer()

	while true do
		Citizen.Wait(Settings.bounty.timeout)

		local timePassedSinceLastEvent = GetGameTimer() - eventFinishedTime
		if timePassedSinceLastEvent < Settings.bounty.timeout then Citizen.Wait(Settings.bounty.timeout - timePassedSinceLastEvent) end

		if not bountyPlayerId and Scoreboard.GetPlayersCount() > 1 then
			bountyPlayerId = Scoreboard.GetRandomPlayer()

			logger:Info('Set { '..GetPlayerName(bountyPlayerId)..', '..bountyPlayerId..' }')

			TriggerClientEvent('lsv:setBounty', -1, bountyPlayerId)
		end
	end
end)


AddEventHandler('baseevents:onPlayerKilled', function(killer)
	local victim = source

	if not bountyPlayerId or victim ~= bountyPlayerId or killer == -1 then return end

	logger:Info('Tuer par { '..GetPlayerName(bountyPlayerId)..', '..bountyPlayerId..' }')

	bountyPlayerId = nil
	eventFinishedTime = GetGameTimer()

	vRP.giveMoney({killer, Settings.bounty.reward})
		TriggerClientEvent('lsv:bountyKilled', -1, killer)
end)


AddEventHandler('lsv:playerConnected', function(player)
	if bountyPlayerId ~= nil then TriggerClientEvent('lsv:setBounty', player, bountyPlayerId) end
end)


AddEventHandler('lsv:playerDropped', function(player)
	if player ~= bountyPlayerId then return end

	bountyPlayerId = nil

	TriggerClientEvent('lsv:setBounty', -1, bountyPlayerId)
end)