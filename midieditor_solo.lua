function Msg(param)
    if false then
        reaper.ShowConsoleMsg(tostring(param) .. "\n")
    end
end

function Main()
    local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())

    if not reaper.ValidatePtr(take, "MediaItem_Take*") then
        Msg('invalid')
        return
    end

    local item = reaper.GetMediaItemTake_Item(take)
    local track = reaper.GetMediaItemTrack(item)
    
    local is_soloed = reaper.GetMediaTrackInfo_Value(track, 'I_SOLO')
    local action

    Msg('Is soloed: ' .. is_soloed)

    reaper.Undo_BeginBlock()

    if is_soloed ~= 0 then
        reaper.CSurf_OnSoloChange(track, 0)
        -- reaper.SetMediaTrackInfo_Value(track, 'I_SOLO', 0)
        action = 'Unsolo'
    else
        reaper.CSurf_OnSoloChange(track, 1)
        -- reaper.SetMediaTrackInfo_Value(track, 'I_SOLO', 1)
        action = 'Solo'
    end

    reaper.Undo_EndBlock(action .. ' active MIDI editor track', 1)
end

Main()
