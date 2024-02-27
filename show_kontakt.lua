function StartsWith(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function IsFxWindow(hwnd)
    local container = reaper.JS_Window_FindChildByID(hwnd, 0)
    if container then
        local cntrl = reaper.JS_Window_FindChildByID(container, 1000)
        if cntrl then
            if reaper.JS_Window_GetClassName(cntrl) == "ComboBox" then
                return true
            end
        end
    end
    return false
end

function BringToTop(trackName)
    local arr = reaper.new_array({}, 1024)
    reaper.JS_Window_ArrayAllTop(arr)
    local adr = arr.table()

    for i = 1, #adr do
        local hwnd = reaper.JS_Window_HandleFromAddress(adr[i])
        if reaper.JS_Window_GetClassName(hwnd) == "#32770" and IsFxWindow(hwnd) then
            title = reaper.JS_Window_GetTitle(hwnd)

            if string.find(title, "VST3i: Kontakt 7") and string.find(title, trackName) then
                reaper.JS_Window_SetForeground(hwnd)
                return
            end
        end
    end
end

-- returns true if trakc has kontakt
function ShowKontaktForTrack(track)
    for fx = 0, reaper.TrackFX_GetCount(track) - 1 do
        local _, name = reaper.BR_TrackFX_GetFXModuleName(track, fx, '', 64)
        if name == FXFILE then
            reaper.TrackFX_Show(track, fx, 3) -- 3 = show as floating.

            local retVal, trackName = reaper.GetTrackName(track)

            if not retVal then return true end

            -- if track is named, search for its names in quotes, e.g. "1st Violins"
            if not StartsWith(trackName, 'Track ') then
                trackName = '"' .. trackName .. '"'
            end

            if trackName and trackName ~= "" then
                function BringTrackToTop()
                    BringToTop(trackName)
                end

                reaper.defer(BringTrackToTop)
            end
            return true
        end
    end
    return false
end

FXFILE = 'Kontakt 7.vst3' --< file name of FX (modify as needed).

local count_sel_tracks = reaper.CountSelectedTracks(0)

if count_sel_tracks == 0 then return end

if count_sel_tracks > 1 then
    for i = 0, count_sel_tracks - 1 do
        local selected_track = reaper.GetSelectedTrack(0, i)
        ShowKontaktForTrack(selected_track)
    end
    return
end

local track = reaper.GetSelectedTrack(0, 0)

if not track then return end
if ShowKontaktForTrack(track) then return end

local addKontakt = reaper.ShowMessageBox(
    'No Kontakt 7 on track, add it?',
    'Add Kontakt',
    4
)

-- 'VST3i: Kontakt 7 (Native Instruments)'
if addKontakt == 6 then
    reaper.TrackFX_AddByName(track, 'Kontakt 7', false, -1)
end
