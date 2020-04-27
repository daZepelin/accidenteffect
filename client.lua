local effectActive = false            -- Blur screen effect active
local blackOutActive = false          -- Blackout effect active
local currAccidentLevel = 0           -- Level of accident player has effect active of
local wasInCar = false
local oldBodyDamage = 0.0
local oldSpeed = 0.0
local currentDamage = 0.0
local currentSpeed = 0.0
local vehicle

IsCar = function(veh)
        local vc = GetVehicleClass(veh)
        return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end 

function InfoRanny(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

RegisterNetEvent("crashEffect")
AddEventHandler("crashEffect", function(countDown, accidentLevel)

    if not effectActive or (accidentLevel > currAccidentLevel) then
        currAccidentLevel = accidentLevel
        effectActive = true
        blackOutActive = true
		DoScreenFadeOut(100)
		Wait(Config.BlackoutTime)
        DoScreenFadeIn(250)
        blackOutActive = false

        -- Starts screen effect
        StartScreenEffect('PeyoteEndOut', 0, true)
        StartScreenEffect('Dont_tazeme_bro', 0, true)
        StartScreenEffect('MP_race_crash', 0, true)
    
        while countDown > 0 do

            -- Adds screen moving effect while remaining countdown is 3 times the accident level,
            -- In order to stop screen shaking BEFORE the 'blur' effect finishes
            if countDown > (3.5*accidentLevel)   then 
                ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", (accidentLevel * 0.3))
            end 
            Wait(750)
--[[             TriggerEvent('chatMessage', "countdown: " .. countDown) -- Debug printout ]]

            countDown = countDown - 1

            -- Stops screen effect before countdown finishes
            if countDown <= 1 then
                StopScreenEffect('PeyoteEndOut')
                StopScreenEffect('Dont_tazeme_bro')
                StopScreenEffect('MP_race_crash')
            end
        end
        currAccidentLevel = 0
        effectActive = false
    end
end)




Citizen.CreateThread(function()
	while true do
        Citizen.Wait(10)
        
            -- If the damage changed, see if it went over the threshold and blackout if necesary
            vehicle = GetVehiclePedIsIn(PlayerPedId(-1), false)
            if DoesEntityExist(vehicle) and (wasInCar or IsCar(vehicle)) then
                wasInCar = true
                oldSpeed = currentSpeed
                oldBodyDamage = currentDamage
                currentDamage = GetVehicleBodyHealth(vehicle)
                currentSpeed = GetEntitySpeed(vehicle) * 2.23

                if currentDamage ~= oldBodyDamage then
                    print("crash")
                    if not effect and currentDamage < oldBodyDamage then
                        print("effect")
                        print(oldBodyDamage - currentDamage)
                        if (oldBodyDamage - currentDamage) >= Config.BlackoutDamageRequiredLevel5 or
                        (oldSpeed - currentSpeed)  >= Config.BlackoutSpeedRequiredLevel5
                        then
                            --[[ InfoRanny("lv5") ]]
                            oldBodyDamage = currentDamage
                            TriggerEvent("crashEffect", Config.EffectTimeLevel5, 5)
                            --[[ InfoRanny(oldSpeed - currentSpeed)
                            InfoRanny(oldBodyDamage - currentDamage) ]]
                            
                            
                            

                        elseif (oldBodyDamage - currentDamage) >= Config.BlackoutDamageRequiredLevel4 or
                        (oldSpeed - currentSpeed)  >= Config.BlackoutSpeedRequiredLevel4
                        then
                            --[[ InfoRanny("lv4") ]]
                            TriggerEvent("crashEffect", Config.EffectTimeLevel4, 4)
                            oldBodyDamage = currentDamage
                           --[[  InfoRanny(oldSpeed - currentSpeed)
                            InfoRanny(oldBodyDamage - currentDamage) ]]
                            
                        

                        elseif (oldBodyDamage - currentDamage) >= Config.BlackoutDamageRequiredLevel3 or
                        (oldSpeed - currentSpeed)  >= Config.BlackoutSpeedRequiredLevel3
                        then   
                            --[[ InfoRanny(oldSpeed - currentSpeed)
                            InfoRanny(oldBodyDamage - currentDamage)
                            InfoRanny("lv3") ]]
                            oldBodyDamage = currentDamage
                            TriggerEvent("crashEffect", Config.EffectTimeLevel3, 3)
                            
                        

                        elseif (oldBodyDamage - currentDamage) >= Config.BlackoutDamageRequiredLevel2 or
                        (oldSpeed - currentSpeed)  >= Config.BlackoutSpeedRequiredLevel2
                        then
                            --[[ InfoRanny(-(oldSpeed - currentSpeed))
                            InfoRanny(oldBodyDamage - currentDamage)
                            InfoRanny("lv2") ]]
                            oldBodyDamage = currentDamage
                            TriggerEvent("crashEffect", Config.EffectTimeLevel2, 2)


                        elseif (oldBodyDamage - currentDamage) >= Config.BlackoutDamageRequiredLevel1 or
                        (oldSpeed - currentSpeed)  >= Config.BlackoutSpeedRequiredLevel1
                        then
                            --[[ InfoRanny(-(oldSpeed - currentSpeed))
                            InfoRanny(oldBodyDamage - currentDamage)
                            InfoRanny("lv1") ]]
                            oldBodyDamage = currentDamage
                            TriggerEvent("crashEffect", Config.EffectTimeLevel1, 1)
                        end
                    end
                end
            else
                oldBodyDamage = 0
                oldSpeed = 0
            end
            
        if blackOutActive and Config.DisableControlsOnBlackout then
            -- Controls to disable while player is on blackout
			DisableControlAction(0,71,true) -- veh forward
			DisableControlAction(0,72,true) -- veh backwards
			DisableControlAction(0,63,true) -- veh turn left
			DisableControlAction(0,64,true) -- veh turn right
			DisableControlAction(0,75,true) -- disable exit vehicle
		end
	end
end)
