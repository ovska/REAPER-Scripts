-- function Check_If_FX_Exist_In_Container(Track, cont, name)
--     if not cont then
--         return
--     end
--     local _, HowManyFXinContainer = reaper.TrackFX_GetNamedConfigParm(Track, cont, "container_count")
--     local found
--     local id
--     for i = 0, HowManyFXinContainer - 1, 1 do
--         local _, id = reaper.TrackFX_GetNamedConfigParm(Track, cont, "container_item." .. i)
--         local _, nm = reaper.TrackFX_GetNamedConfigParm(Track, tonumber(id) or 0, "fx_name")

--         if nm == name then
--             found = true
--         end
--     end

--     if found then
--         return id
--     else
--         return false
--     end
-- end

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
            return current, current - total_container_fx
        end

        return nil
    end
end

function BringToTop(trackName)
    local arr = reaper.new_array({}, 1024)
    reaper.JS_Window_ArrayAllTop(arr)
    local adr = arr.table()

    for i = 1, #adr do
        local hwnd = reaper.JS_Window_HandleFromAddress(adr[i])
        if reaper.JS_Window_GetClassName(hwnd) == "#32770" and IsFxWindow(hwnd) then
            local title = reaper.JS_Window_GetTitle(hwnd)

            if string.find(title, "VST3i: ") and string.find(title, trackName) then
                reaper.JS_Window_SetForeground(hwnd)
                return
            end
        end
    end
end

function IsInstrument(name)
    return (name:match('^VST3i: ') ~= nil or name:match('^VSTi: ') ~= nil)
        and name:match('^VST3i: Human') == nil
end

-- returns true if trakc has kontakt
function ShowKontaktForTrack(track)
    for fx, absoluteFx in IterateFx(track) do
        local _, name = reaper.TrackFX_GetFXName(track, fx, '')
        -- local _, name = reaper.BR_TrackFX_GetFXModuleName(track, fx, "", 64)
        if IsInstrument(name) then
            reaper.TrackFX_Show(track, fx, 3) -- 3 = show as floating.

            local retVal, trackName = reaper.GetTrackName(track)

            -- reaper.ShowConsoleMsg(
            -- "Found kontakt on slot " ..
            --         tostring(fx) .. "/" .. tostring(absoluteFx) .. ", track: " .. trackName .. "\n"
            -- )

            if not retVal then
                return true
            end

            -- if track is named, search for its names in quotes, e.g. "1st Violins"
            if not StartsWith(trackName, "Track ") then
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

local count_sel_tracks = reaper.CountSelectedTracks(0)

if count_sel_tracks == 0 then
    return
end

if count_sel_tracks > 1 then
    for i = 0, count_sel_tracks - 1 do
        local selected_track = reaper.GetSelectedTrack(0, i)
        ShowKontaktForTrack(selected_track)
    end
    return
end

local track = reaper.GetSelectedTrack(0, 0)

if not track then
    return
end

if ShowKontaktForTrack(track) then
    return
end

local addKontakt = reaper.ShowMessageBox("Add Kontakt 8?", "No VST3i on track", 4)

-- 'VST3i: Kontakt 7 (Native Instruments)'
if addKontakt == 6 then
    reaper.TrackFX_AddByName(track, "Kontakt 8", false, -1)
end
