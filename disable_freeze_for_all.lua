local selected_count = reaper.CountSelectedTracks2(0, false)

if selected_count == 0 then
    return
end

for i = 1, selected_count do
    track = reaper.GetSelectedTrack(0, i - 1)
    numFX = reaper.TrackFX_GetCount(track)

    if numFX > 0 then
        -- Iterate through all FX instances on the track
        for i = 0, numFX - 1 do
            -- Get the FX name
            retval, fxName = reaper.TrackFX_GetFXName(track, i, "")

            -- Example: Do something with a specific FX
            if fxName:find("LoCut") then -- Change "Kontakt" to match the name of the FX you are looking for
                numParams = reaper.TrackFX_GetNumParams(track, i)

                for iParam = 0, numParams - 1 do
                    retval, name = reaper.TrackFX_GetParamName(track, i, iParam)

                    if name == "Analyzer Freeze" then
                        -- local v = reaper.TrackFX_GetParamNormalized(track, i, iParam)
                        local success = reaper.TrackFX_SetParamNormalized(track, i, iParam, 0)
                    end
                end
            end
        end
    end
end
