for i = 0, reaper.CountSelectedTracks(0) - 1 do
    local track = reaper.GetSelectedTrack(0, i)

    local index = reaper.TrackFX_AddByName(track, 'SlickEQ (Tokyo Dawn Labs)', false, 1)
    reaper.TrackFX_Show(track, index, 3)
end
