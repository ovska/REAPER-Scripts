local function main()
    local track = reaper.GetSelectedTrack(0, 0)
    -- check is track is a folder
    if reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1 then
        reaper.Undo_BeginBlock()
        reaper.PreventUIRefresh(-1)
        local newState = ToggleState(track)
        local _, name = reaper.GetTrackName(track)

        local stateName
        if newState then stateName = 'expanded' else stateName = 'collapsed' end

        reaper.PreventUIRefresh(0)
        reaper.TrackList_AdjustWindows(false)
        reaper.Undo_EndBlock("Folder track '" .. name .. "' " .. stateName, 1)
    end
end

function ToggleState(parent)
    local folder = 'folder.png'
    local _, iconCurrent = reaper.GetSetMediaTrackInfo_String(parent, "P_ICON", folder, false)

    if not iconCurrent or iconCurrent == "" then return end

    local isCollapsed = iconCurrent == folder

    local _, iconCached = reaper.GetSetMediaTrackInfo_String(parent, "P_EXT:ORIGINAL_ICON", "", false)

    if isCollapsed then
        if not iconCached or iconCached == "" then return end
    else
        -- cache original icon
        reaper.GetSetMediaTrackInfo_String(parent, "P_EXT:ORIGINAL_ICON", iconCurrent, true)
    end

    

    -- change icon for track
    local newIcon
    if isCollapsed then newIcon = iconCached else newIcon = folder end
    reaper.GetSetMediaTrackInfo_String(parent, "P_ICON", newIcon, true)

    -- return new state
    return isCollapsed
end

function SetTrackVisibility(track)
end

main()
