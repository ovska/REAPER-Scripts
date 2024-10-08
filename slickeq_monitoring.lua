function Main()
    local master = reaper.GetMasterTrack()
    local fx_index = 0x1000000 + 1;
    local retval, name = reaper.TrackFX_GetFXName(master, fx_index)

    if not retval then return end

    if not name:match('Slick') then
        reaper.ShowMessageBox('Not slick EQ on slot 2', 'Wrong monitor fx', 0)
        return
    end

    local is_active = reaper.TrackFX_GetOffline(master, fx_index)
    local new_state = 0

    if is_active then
        new_state = 1
    end

    local _, _, sectionID, cmdID, _, _, _ = reaper.get_action_context()

    reaper.TrackFX_SetOffline(master, fx_index, not is_active)
    reaper.SetToggleCommandState(sectionID, cmdID, new_state);
    reaper.RefreshToolbar2(sectionID, cmdID);

end

Main()
