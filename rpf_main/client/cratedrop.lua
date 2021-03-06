CrateBlip = nil

local crateDropData = nil


local function resetCrateDropData()
	RemovePickup(crateDropData.pickup)

	RemoveBlip(CrateBlip)
	CrateBlip = nil

	crateDropData = nil
end


AddEventHandler('lsv:init', function()
	while true do
		if crateDropData then
			if HasPickupBeenCollected(crateDropData.pickup) then
				TriggerServerEvent('lsv:cratePickedUp')
			elseif DoesPickupExist(crateDropData.pickup) then
				local pickupX, pickupY, pickupZ = table.unpack(GetPickupCoords(crateDropData.pickup))
				Gui.DrawPlaceMarker(pickupX, pickupY, pickupZ - 1, Settings.placeMarkerRadius, 240, 200, 80, Settings.placeMarkerOpacity)
			end
		end

		Citizen.Wait(0)
	end
end)


RegisterNetEvent('lsv:spawnCrate')
AddEventHandler('lsv:spawnCrate', function(positionIndex, weaponIndex)
	crateDropData = { }
	crateDropData.pickup = CreatePickupRotate(GetHashKey('PICKUP_PORTABLE_CRATE_UNFIXED'), Settings.crateDropSettings.positions[positionIndex].x,
		Settings.crateDropSettings.positions[positionIndex].y, Settings.crateDropSettings.positions[positionIndex].z, 0.0, 0.0, 0.0, 512)
	crateDropData.weaponIndex = weaponIndex

	CrateBlip = Map.CreatePlaceBlip(Blip.CrateDrop(), Settings.crateDropSettings.positions[positionIndex].x, Settings.crateDropSettings.positions[positionIndex].y,
		Settings.crateDropSettings.positions[positionIndex].z)
	SetBlipAsShortRange(CrateBlip, false)
	SetBlipColour(CrateBlip, Color.BlipYellow())
	SetBlipScale(CrateBlip, 1.5)
	Map.SetBlipFlashes(CrateBlip)

	FlashMinimapDisplay()
	PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
	vRP.notifyPicture({"DIA_GOON", 1, "COLIS SPECIAL", "~g~Va vite la recuperer !", "Va cherche le colis pour avoir le ~g~cash~w~ et ~g~matariel..."})
	Gui.DisplayNotification('~y~A Special Crate has been dropped.')
end)


RegisterNetEvent('lsv:removeCrate')
AddEventHandler('lsv:removeCrate', function(player, weaponClipCount, cash)
	if PlayerId() ~= GetPlayerFromServerId(player) then
		Gui.DisplayNotification(Gui.GetPlayerName(player, '~y~')..' Va chercher le colis special.')
	else
		local playerPed = PlayerPedId()
		SetPedArmour(playerPed, GetPlayerMaxArmour(PlayerId()))

		local weapon = Settings.crateDropSettings.weapons[crateDropData.weaponIndex]
		local weaponHash = GetHashKey(weapon.id)
		GiveWeaponToPed(playerPed, weaponHash, GetWeaponClipSize(weaponHash) * weaponClipCount, false, true)

		Gui.DisplayNotification('Vous avez reçu :~w~\n+ €'..cash..'\n+ '..weapon.name..'\n+ Armure')

		Player.SaveWeapons()
	end

	if crateDropData then resetCrateDropData() end
end)


RegisterNetEvent('lsv:notifyAboutCrate')
AddEventHandler('lsv:notifyAboutCrate', function()
	Gui.DisplayHelpText('A plane is on its way to drop a Crate ~BLIP_CRATEDROP~ which contains useful equipment.')
	Gui.DisplayNotification('Crate Drop inbound.')
end)