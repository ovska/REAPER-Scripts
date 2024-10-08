function Main()
    local command_id = reaper.NamedCommandLookup("_S&M_SAVE_TRTEMPLATE_SLOT1")

    if not command_id then
        return
    end

    local selected_count = reaper.CountSelectedTracks2(0, false)

    -- No tracks selected
    if selected_count == 0 then
        return
    end

    reaper.PreventUIRefresh(1)

    local trackArr = {} -- hold selected tracks in an array as might need to render only a subset

    -- Get sel tracks ------
    for i = 1, selected_count do
        trackArr[i] = reaper.GetSelectedTrack(0, i - 1)
    end

    for i = 1, selected_count do
        local track = trackArr[i]
        reaper.SetTrackSelected(track, false)
    end

    for i = 1, selected_count do
        local track = trackArr[i]
        reaper.SetTrackSelected(track, true)
        reaper.Main_OnCommand(command_id, 0)
        reaper.SetTrackSelected(track, false)
    end

    for i = 1, selected_count do
        local track = trackArr[i]
        reaper.SetTrackSelected(track, true)
    end

    reaper.PreventUIRefresh(-1)
end

Main()
