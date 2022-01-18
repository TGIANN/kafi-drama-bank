ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) 

ESX.RegisterServerCallback("banking:get-infos", function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local playerData = checkPlayerData(xPlayer.identifier)
    local data = {
        bank = xPlayer.getAccount("bank").money,
        cash = xPlayer.getAccount("money").money,
        firstname = playerData.firstname,
        lastname = playerData.lastname,
        job = playerData.job,
        iban = src,
        profilepicture = "Gönderen Profil Resim",
    }

    data.banklog = MySQL.Sync.fetchAll('SELECT * FROM banklog WHERE identifier = @identifier ORDER BY id DESC', {
      ['@identifier'] = xPlayer.identifier
    })

    data.banklogsontransfer = MySQL.Sync.fetchAll('SELECT * FROM banklogsontransfer WHERE identifier = @identifier ORDER BY id DESC',{
      ['@identifier'] = xPlayer.identifier
    })

    data.billing = MySQL.Sync.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
      ['@identifier'] = xPlayer.identifier
    })

    cb(data)
end)

RegisterServerEvent('pw-bank:server:parayatir')
AddEventHandler('pw-bank:server:parayatir', function(para)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local amount = tonumber(para)
  if xPlayer.getAccount("money").money >= amount then
    xPlayer.removeAccountMoney('money', amount)
    xPlayer.addAccountMoney('bank', amount)
  end
  TriggerClientEvent('pw-bank:reloadcleintdata', src)
end)

RegisterServerEvent('pw-bank:server:paracek')
AddEventHandler('pw-bank:server:paracek', function(para)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local amount = tonumber(para)
  if xPlayer.getAccount("bank").money >= amount then
    xPlayer.removeAccountMoney('bank', amount)
    xPlayer.addAccountMoney('money', amount)
  end
  TriggerClientEvent('pw-bank:reloadcleintdata', src)
end)

RegisterServerEvent('esx-bank:TransferMoney')
AddEventHandler('esx-bank:TransferMoney', function(iban, amount_, isBank)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local tPlayer = ESX.GetPlayerFromId(iban)
    local amount = RoundAQ(amount_, 1)
    if xPlayer.getAccount("bank").money >= amount then
        local ibanHave = false
        if tPlayer then
          if tPlayer.source == src then
              TriggerClientEvent("NotifBestServerKFAq", src, "Kendi Hesabına Para Gönderemezsin!")
              return
          else
              ibanHave = true
              TriggerClientEvent("NotifBestServerKFAq", tPlayer.source, "Banka", xPlayer.source.." İban Adresinden "..amount.."$ Banka Hesabınıza Yatırıldı")
              tPlayer.addAccountMoney('bank', amount)
              local xPlayerData = checkPlayerData(xPlayer.identifier)
              local tPlayerData = checkPlayerData(tPlayer.identifier)

              insertBankLogSonTransfer(xPlayer.identifier, tPlayerData.firstname.." "..tPlayerData.lastname, "Gönderilen Profil Resim", tPlayer.source)
              insertBankLog(tPlayer.identifier, xPlayerData.firstname.." "..xPlayerData.lastname, "Gelen Para", xPlayer.source, amount, "1eff00", "Gönderen Profil Resim" or "default")
              insertBankLog(xPlayer.identifier, tPlayerData.firstname.." "..tPlayerData.lastname, "Giden Para", tPlayer.source, amount, "1eff00", "Gönderilen Profil Resim" or "default")
         end
        end
        if ibanHave then
            xPlayer.removeAccountMoney('bank', amount)
            TriggerClientEvent("NotifBestServerKFAq", src, iban.." İban Adresine "..amount.."$ Gönderildi!")
            if isBank then TriggerClientEvent('pw-bank:reloadcleintdata', src) end
        else
            TriggerClientEvent("NotifBestServerKFAq", src, "Bu İban Adresi Kimseye Ait Değil!")
        end
    else
        TriggerClientEvent("NotifBestServerKFAq", src, "Bankanda yeterli miktarda para yok!")
    end
end)

function insertBankLogSonTransfer(citizenid, name, profilepicture, iban)
    MySQL.Sync.fetchAll('DELETE FROM banklogsontransfer WHERE identifier = ? AND iban = ?', {citizenid, iban})
    MySQL.Async.insert('INSERT INTO banklogsontransfer (identifier, isim, foto, iban) VALUES (@identifier, @isim, @foto, @iban)',  {
        ['@identifier'] = citizenid,
        ['@isim'] = name,
        ['@foto'] = profilepicture,
        ['@iban'] = iban
    })
end

function insertBankLog(identifier, name, action, iban, para, renk, profilepicture)
    MySQL.Async.insert('INSERT INTO banklog (identifier, action, money, color, sender, iban, profilepicture) VALUES (@identifier, @action, @money, @color, @sender, @iban, @profilepicture)', {
        ['@identifier'] = identifier,
        ['@action']     = action,
        ['@money']      = para,
        ['@color']      = renk,
        ['@sender']     = name,
        ['@iban']       = iban,
        ['@profilepicture'] = profilepicture
    })
end

function checkPlayerData(identifier)
  local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
    ['@identifier'] = identifier
  })
  if result[1] then
    result[1].accounts = json.decode(result[1].accounts)
  end
  return result[1]
end

ESX.RegisterServerCallback('pw-bank:server:CanPayInvoice', function(source, cb, amount)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  cb(xPlayer.getAccount("bank").money >= amount)
end)

RoundAQ = function(value, numDecimalPlaces)
  if not numDecimalPlaces then return math.floor(value + 0.5) end
  local power = 10 ^ numDecimalPlaces
  return math.floor((value * power) + 0.5) / (power)
end