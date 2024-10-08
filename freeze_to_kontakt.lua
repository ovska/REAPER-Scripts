---@diagnostic disable: redundant-parameter
function IsInstrument(name)
    return (name:match("^VST3i: ") ~= nil or name:match("^VSTi: ") ~= nil) and name:match("^VST3i: Human") == nil
end

function IterateFx(track)
    local fx = 0
    local total_container_fx = 0
    local count = reaper.TrackFX_GetCount(track)

    return function()
        if fx < count + total_container_fx then
            local _, container_fx_count_str = reaper.TrackFX_GetNamedConfigParm(track, fx, "container_count")
            local container_fx_count = tonumber(container_fx_count_str) or 0

            if container_fx_count > 1 then
                total_container_fx = total_container_fx + container_fx_count - 1
            end

            local current = fx
            fx = fx + 1
            return current
        end

        return nil
    end
end

function Log(msg, ...)
    if false then
        local m = string.format(msg, ...)
        reaper.ShowConsoleMsg(m .. "\n")
    end
end

function Is_Instrument(track, fx)
    local _, name = reaper.TrackFX_GetFXName(track, fx, "")
    local is_offline = reaper.TrackFX_GetOffline(track, fx)

    local is_online_instrument = (not is_offline) and IsInstrument(name)

    if is_online_instrument then
        Log("%s - %s %i is instrument", is_online_instrument, name, fx)
    end

    return is_online_instrument
end

function Should_Freeze(track, fx)
    local _, name = reaper.TrackFX_GetFXName(track, fx, "")

    local is_offline = reaper.TrackFX_GetOffline(track, fx)

    -- offline, can't be eof
    if is_offline then
        Log("%s - %s %i is offline", false, name, fx)
        return false
    end

    if name:match(" LoCut") then
        Log("%s - %s %i is Lo Cut", true, name, fx)
        return true
    end

    if name:match("^JS: Stereo Channel") then
        Log("%s - %s %i is stereo swap", true, name, fx)
        return true
    end

    local _, container_fx_count_str = reaper.TrackFX_GetNamedConfigParm(track, fx, "container_count")

    -- containers right after instruments should be frozen
    if (tonumber(container_fx_count_str) or 0) ~= 0 then
        Log("%s - %s %i is Container", true, name, fx)
        return true
    end

    Log("%s - %s %i should not be frozen", false, name, fx)
    return false
end

-- Returns an array containing FX offline states, or nil if the track shouldn't be rendered
function PrepareForFreeze(track)
    local fx_count = reaper.TrackFX_GetCount(track)

    -- No FX at all, don't freeze
    if fx_count == 0 then
        return nil
    end

    local fxArray = {} --  the offline state of the FX
    local instFx = -1 -- instrument FX's index

    for fx in IterateFx(track) do
        if instFx ~= -1 then
            -- already found an instrument, see if we should freeze after
            if #fxArray == 0 and Should_Freeze(track, fx) then
                -- is container or low cut
                instFx = fx + 1
            else
                -- should freeze
                table.insert(fxArray, reaper.TrackFX_GetOffline(track, fx))
            end
        elseif Is_Instrument(track, fx) then
            instFx = fx + 1
        end
    end

    -- instrument not found, or it's offline
    if instFx == -1 then
        return nil
    end

    -- local _, name = reaper.GetTrackName(track)
    -- Log('%s freezing at index %s', name, instFx)

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
if selected_count == 0 then
    return
end

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
        table.insert(trackRestoreArr, {track, restore})
    end
end

reaper.Main_OnCommand(41223, 0) -- Freeze selected tracks to stereo stems

for i = 1, #trackRestoreArr do
    RestoreFx(trackRestoreArr[i][1], trackRestoreArr[i][2])
end

-- Restore the selection in case some tracks weren't frozen
for i = 1, selected_count do
    reaper.SetTrackSelected(trackArr[i], true)
end

reaper.Undo_EndBlock(string.format("Freeze instruments of %d track(s)", #trackRestoreArr), 1)
reaper.PreventUIRefresh(-1)
