ESX = nil
local coreLoaded = false
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	coreLoaded = true
end)

local blip = false
local aktifblipler = {}
RegisterNetEvent("esx-bank:blipAcKapa")
AddEventHandler("esx-bank:blipAcKapa", function()
	if blip then
		pasifblip()
		blip = false
	else
		aktifblip()
		blip = true
	end
end)

function aktifblip()
	for k,v in ipairs(banks)do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite(blip, v.id)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.5)
		SetBlipColour (blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Banka")
		EndTextCommandSetBlipName(blip)
		table.insert(aktifblipler, blip)
	end	
end
  
function pasifblip()
	for i = 1, #aktifblipler do
		RemoveBlip(aktifblipler[i])
	end
	aktifblipler = {}
end

local nearAtm, nearBank, disable, bankOpen = false, false, false, false
local lastObj = nil
local ATMObjects = {
	-870868698,
	-1126237515,
	-1364697528,
	506770882,
}

local banks = {
	{name="Bank", id=108, x=150.266, y=-1040.203, z=29.374},
	{name="Bank", id=108, x=-1212.980, y=-330.841, z=37.787},
	{name="Bank", id=108, x=-2962.582, y=482.627, z=15.703},
	{name="Bank", id=108, x=-112.202, y=6469.295, z=31.626},
	{name="Bank", id=108, x=314.187, y=-278.621, z=54.170},
	{name="Bank", id=108, x=-351.534, y=-49.529, z=49.042},
}

function openGui(atm)
	bankOpen = true
	local ped = PlayerPedId()
	local text = "Banka Hesabına Giriş Yapıyorsun!"
	if atm then
		text = "Kart ATM'ye Sokuluyor.."
		TaskStartScenarioInPlace(ped, "PROP_HUMAN_ATM", 0, true)
	end
	ESX.TriggerServerCallback("banking:get-infos", function(data)
		SendNUIMessage({
			type = "open",
			data = data,
		})
		SetNuiFocus(true, true)
	end)
	if atm then
		ClearPedTasksImmediately(ped)
	end
end

Citizen.CreateThread(function()
	while true do
		time = 1000
		if not disable and coreLoaded then
			if not bankOpen then
				local pos = GetEntityCoords(PlayerPedId())
				nearAtm, nearBank = false, false
				if lastObj then
					if #(GetEntityCoords(lastObj) - pos) > 2 then
						lastObj = nil
					else
						nearAtm, nearBank = true, false
					end
				else
					nearAtm, nearBank = IsNearATMorBank()
				end
				
				if nearAtm or nearBank then
					time = 1
					ESX.Game.Utils.DrawText3D(vector3(pos.x, pos.y, pos.z), '[E] Banka Hesabına Eriş')
					if IsControlJustPressed(1, 38)  then
						if (IsInVehicle()) then
							ESX.ShowNotification('Araç İçinde İken Bu İşlemi Yapamazsın')
						else
							if lastObj then
								TaskTurnPedToFaceEntity(PlayerPedId(), lastObj, -1)
								Citizen.Wait(1500)
							end

							if bankOpen then
								closeGui(nearAtm)
							else
								openGui(nearAtm)
							end
						end
					end
				end
			end
		end
   	 	Citizen.Wait(time)
    end
end)

Citizen.CreateThread(function()
	while true do
		if bankOpen then
			DisableControlAction(0, 1, true) -- LookLeftRight
			DisableControlAction(0, 2, true) -- LookUpDown
			DisableControlAction(0, 24, true) -- Attack
			DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
		end
		Citizen.Wait(0)
	end
end)

function IsNearATMorBank()
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply)
	local nearAtm = false
	for k, v in pairs(ATMObjects) do
		local closestObj = GetClosestObjectOfType(plyCoords.x, plyCoords.y, plyCoords.z, 3.0, v, false, 0, 0)
		local objCoords = GetEntityCoords(closestObj)
		if closestObj ~= 0 then
			if #(plyCoords - objCoords) <= 2 then
				lastObj = closestObj
				nearAtm = true
				break
			end
		end
	end
  
	local nearBank = false
	for _, item in pairs(banks) do
		if #(vector3(item.x, item.y, item.z) - plyCoords) <= 2 then
			nearBank = true
			break
	  	end
	end
  
	return nearAtm, nearBank
end
  
function IsInVehicle()
	if IsPedSittingInAnyVehicle(PlayerPedId()) then
	  	return true
	else
	  	return false
	end
end
  
RegisterNetEvent('pw-bank:reloaddata', function()
    ESX.TriggerServerCallback("banking:get-infos", function(data)
        SendNUIMessage({
            type = "open",
            data = data
        })
    end)
end)

RegisterNUICallback('closeapp', function()
    closeGui()
end)

function closeGui(atm)
	SendNUIMessage({type = 'closeAll'})
	local ped = PlayerPedId()
	if atm then
		TaskStartScenarioInPlace(ped, "PROP_HUMAN_ATM", 0, true)
		Citizen.Wait(2500)
		ClearPedTasksImmediately(ped)
	end
	bankOpen = false
	lastObj = nil
	SetNuiFocus(false, false)
end

RegisterNetEvent('pw-bank:reloadcleintdata', function()
    ESX.TriggerServerCallback("banking:get-infos", function(data)
        SendNUIMessage({
            type = "open",
            data = data
        })
    end)
end)

RegisterNUICallback('yatir', function(miktar)
    TriggerServerEvent('pw-bank:server:parayatir', miktar['para'])
end)

RegisterNUICallback('cek', function(miktar)
    TriggerServerEvent('pw-bank:server:paracek', miktar['para'])
end)

RegisterNUICallback('transfer', function(data)
    TriggerServerEvent('esx-bank:TransferMoney', tonumber(data["iban"]), tonumber(data["para"]), true)
end)

RegisterNetEvent('pw-bank:ui:clear')
AddEventHandler('pw-bank:ui:clear', function()
    SendNUIMessage({
        type = "clearui"
    })
end)

RegisterNUICallback('PayInvoice', function(data, cb)
	ESX.TriggerServerCallback('esx_billing:payBill', function()
		ESX.TriggerServerCallback("banking:get-infos", function(data)
			SendNUIMessage({
				type = "open",
				data = data
			})
		end)
	end, data.invoiceId)
end)

RegisterNetEvent('banking-disable')
AddEventHandler('banking-disable', function(bool)
  	disable = bool
end)

RegisterNetEvent('NotifBestServerKFAq')
AddEventHandler('NotifBestServerKFAq', function(notif)
	ESX.ShowNotification(notif)
	print(notif)
end)