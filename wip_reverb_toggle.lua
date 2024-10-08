-- Get the currently selected track
track = reaper.GetSelectedTrack(0, 0)  -- 0 is the first selected track (index starts at 0)

if track == nil then
    reaper.ShowConsoleMsg("No track selected.\n")
else
    -- Get the number of FX on the selected track
    numFX = reaper.TrackFX_GetCount(track)

    if numFX > 0 then
        -- Iterate through all FX instances on the track
        for i = 0, numFX - 1 do
            -- Get the FX name
            retval, fxName = reaper.TrackFX_GetFXName(track, i, "")

            -- Print FX name to the console
            reaper.ShowConsoleMsg("FX " .. (i+1) .. ": " .. fxName .. "\n")

            -- Example: Do something with a specific FX
            if fxName:find("Kontakt") then  -- Change "Kontakt" to match the name of the FX you are looking for
                reaper.ShowConsoleMsg("Found Kontakt at FX index " .. i .. "\n")
                -- Now you can manipulate this FX instance as needed
                -- Example: Bypass/unbypass the FX
                reaper.TrackFX_SetEnabled(track, i, true) -- Enable (unbypass) the FX

                numParams = reaper.TrackFX_GetNumParams(track, i)

                for iParam = 0, numParams - 1 do
                    retval, name = reaper.TrackFX_GetParamName(track, i, iParam)

                    if name == "Reverb Toggle" then
                        local v = reaper.TrackFX_GetParamNormalized(track, i, iParam)
                        local success = reaper.TrackFX_SetParamNormalized(track, i, iParam, 0)
                        reaper.ShowConsoleMsg('Param ' .. name .. ' is at ' .. v .. ' ' .. tostring(success) .. '\n')
                    end

                end
            end
        end
    else
        reaper.ShowConsoleMsg("No FX found on the selected track.\n")
    end
end
