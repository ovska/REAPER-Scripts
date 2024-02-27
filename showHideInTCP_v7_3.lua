-- -------------------
-- Author swumpf
-- 2022-02-20
-- showHideInTCP_v7_3.lua
-- -------------------
--
--
--
folderPNG = "folder.png" -- icon to indicate that the folder has hidden children
-- Custom folder icon must be in the "track_icons" folder. 
-- /Users/xxx/Library/Application Support/REAPER/Data/track_icons/
--
toggleInMixer = false -- change value to true to also toggle the visibility in the mixer
useBlankIcon = false -- change value to true if you want to have the icon bar visible at all times.
--
--
--
--
reaper.ClearConsole()

function main()

    local parentSelected = reaper.GetSelectedTrack(0, 0)
    -- check is track is a folder
    if reaper.GetMediaTrackInfo_Value(parentSelected, "I_FOLDERDEPTH") == 1 then
        reaper.Undo_BeginBlock()
        toggleIcon(parentSelected)
        reaper.TrackList_AdjustWindows(0)
        reaper.Undo_EndBlock("Folder track visibility toggle", 1)
    else
        -- track is not a folder
    end
end

function iconName(path_name)
    str_sep = package.config:sub(1, 1)
    if str_sep == "/" then
        str_match = "([^/]+)$"
    else
        str_match = "([^\\]+)$"
    end
    file_name = path_name:match(str_match)
    return file_name
end

function toggleIcon(parentSelected)
    ret, iconCurrent = reaper.GetSetMediaTrackInfo_String(parentSelected, "P_ICON", folderPNG, false)
    ret, iconCached = reaper.GetSetMediaTrackInfo_String(parentSelected, "P_EXT:iconCached", "", false)

    if useBlankIcon == false then
        if iconName(iconCached) == "blank.png" then
            ret, iconCached = reaper.GetSetMediaTrackInfo_String(parentSelected, "P_EXT:iconCached", "", true)
        end
    end

    if iconCached == "" then
        if useBlankIcon == true then
            blankPNG = "blank.png"
        else
            blankPNG = ""
        end

        ret, seticonCached = reaper.GetSetMediaTrackInfo_String(parentSelected, "P_EXT:iconCached", iconCurrent, true)
    else
        blankPNG = iconCached
        ret, seticonCached = reaper.GetSetMediaTrackInfo_String(parentSelected, "P_EXT:iconCached", iconCurrent, true)

    end

    -- ------------------------ TOGGLA IKON ------------------------------------

    if iconName(iconCurrent) == folderPNG then
        ret, iconCurrent = reaper.GetSetMediaTrackInfo_String(parentSelected, "P_ICON", blankPNG, true)
        forceHide = 0
    else
        ret, iconCurrent = reaper.GetSetMediaTrackInfo_String(parentSelected, "P_ICON", folderPNG, true)
        forceHide = 1
    end

    ----------------------------------------------------
    parentNumber = reaper.GetMediaTrackInfo_Value(parentSelected, 'IP_TRACKNUMBER')
    parentDepth = reaper.GetTrackDepth(parentSelected)
    x = -1
    breakLoop = 0
    trackLimit = reaper.CountTracks()
    childIcon = ""
    subParentDepth = 0
    ----------------------------------------------------

    while (breakLoop == 0) do

        x = x + 1
        status = " "

        childTrack = reaper.GetTrack(0, parentNumber + x)
        childIsFolder = reaper.GetMediaTrackInfo_Value(childTrack, "I_FOLDERDEPTH")
        childNumber = reaper.GetMediaTrackInfo_Value(childTrack, 'IP_TRACKNUMBER')
        childDepth = reaper.GetTrackDepth(childTrack)
        local ret, childIcon = reaper.GetSetMediaTrackInfo_String(childTrack, "P_ICON", folderPNG, false)

        -------------------------------------------------------
        if childDepth <= parentDepth then
            break
        end
        -------------------------------------------------------

        if iconName(iconCurrent) ~= folderPNG and childDepth == parentDepth + 1 then
            forceHide = 0

        end

        if childDepth < subParentDepth then
            subParentDepth = 0
        end

        if childDepth == subParentDepth then
            reaper.SetMediaTrackInfo_Value(childTrack, "B_SHOWINTCP", 0)

            if toggleInMixer == true then
                reaper.SetMediaTrackInfo_Value(childTrack, "B_SHOWINMIXER", 0)
            end
            forceHide = 1
        else

            reaper.SetMediaTrackInfo_Value(childTrack, "B_SHOWINTCP", 1)
            if toggleInMixer == true then
                reaper.SetMediaTrackInfo_Value(childTrack, "B_SHOWINMIXER", 1)
            end
        end

        if forceHide == 1 then
            reaper.SetMediaTrackInfo_Value(childTrack, "B_SHOWINTCP", 0)
            if toggleInMixer == true then
                reaper.SetMediaTrackInfo_Value(childTrack, "B_SHOWINMIXER", 0)
            end
        end

        --  HIDE NEXT CHILD IN FOLDER TRACK -------------------
        if iconName(childIcon) == folderPNG then
            subParentDepth = childDepth + 1
            status = status .. " folder: " .. subParentDepth
            forceHide = 1
        end
        -- ----------------------------------------------------

        if childNumber == trackLimit then
            break

        end

    end

end

main()

reaper.TrackList_AdjustWindows(0)

