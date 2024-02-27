function IsInstrument(name)
    return name:match('^VST3i: ') ~= nil or name:match('^VSTi: ') ~= nil
end

-- Returns an array containing FX offline states, or nil if the track shouldn't be rendered
function PrepareForFreeze(track)
    local fx_count = reaper.TrackFX_GetCount(track)

    -- No FX at all, don't freeze
    if fx_count == 0 then return nil end

    local fxArray = {} --  the offline state of the FX
    local instFx = -1  -- instrument FX's index

    -- TODO: investigate if reaper.TrackFX_GetInstrument() can do the same thing

    for fx = 0, fx_count - 1 do
        local _, name = reaper.TrackFX_GetFXName(track, fx, '')
        local is_offline = reaper.TrackFX_GetOffline(track, fx)

        -- Instrument already found, record the current offline state of the effect
        if instFx ~= -1 then
            table.insert(fxArray, is_offline)
        end

        -- Check if there exists a non-offline instrument FX
        if IsInstrument(name) and not is_offline then
            if instFx ~= -1 then
                -- Multiple instruments, TODO: error message
                return nil
            end
            instFx = fx + 1
        end
    end

    -- instrument not found, or it's offline
    if instFx == -1 then return nil end

    for index = 0, #fxArray - 1 do
        reaper.TrackFX_SetOffline(track, index + instFx, true)
    end

    return fxArray
end

function RestoreFx(track, fxArray)
    for index, value in ipairs(fxArray) do
        -- Restore the offline state previous to render
        reaper.TrackFX_SetOffline(track, index - 1, value)
    end
end

local selected_count = reaper.CountSelectedTracks2(0, false)

-- No tracks selected
if selected_count == 0 then return end

local trackArr = {} -- hold selected tracks in an array as might need to render only a subset

-- Get sel tracks ------
for i = 1, selected_count do
    trackArr[i] = reaper.GetSelectedTrack(0, i - 1)
end

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

local trackRestoreArr = {} -- contains tuples of the track and array containing FX offline states

for i = 1, selected_count do
    local track = trackArr[i]
    local restore = PrepareForFreeze(track)

    if restore == nil then
        reaper.SetTrackSelected(track, false) -- unselect track if it doesn't have instruments
    else
        table.insert(trackRestoreArr, { track, restore })
    end
end

reaper.Main_OnCommand(41223, 0) -- Freeze selected tracsk to stereo stems

for i = 1, #trackRestoreArr do
    RestoreFx(trackRestoreArr[i][1], trackRestoreArr[i][2])
end

-- Restore the selection in case some tracks weren't frozen
for i = 1, selected_count do
    reaper.SetTrackSelected(trackArr[i], true)
end

reaper.Undo_EndBlock(string.format("Freeze instruments of %d track(s)", #trackRestoreArr), 1)
reaper.PreventUIRefresh(-1)
