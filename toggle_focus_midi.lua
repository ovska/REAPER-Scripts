function Msg(param)
    if false then
        reaper.ShowConsoleMsg(tostring(param) .. "\n")
    end
end

function GetMidiEditorHwnd()
    local arr = reaper.new_array({}, 1)
    reaper.JS_MIDIEditor_ArrayAll(arr)
    local adr = arr.table()

    if adr[1] then
        return reaper.JS_Window_HandleFromAddress(adr[1])
    end

    return nil
end

function ReaticulateMain()
    if not ReaticulateCommandId then
        ReaticulateCommandId = reaper.NamedCommandLookup("_RSbe259504561f6a52557d2d1c64e52ef13527bf17")
    end

    if reaper.ReverseNamedCommandLookup(ReaticulateCommandId) then
        reaper.Main_OnCommand(ReaticulateCommandId, 0)
    else
        reaper.ShowConsoleMsg("Invalid action " .. ReaticulateCommandId .. "\n")
    end
end

function ReaticulateState(show)
    local reaticulate_hwnd = reaper.JS_Window_Find("Reaticulate", true)

    -- check if reaticulate is visible
    if reaticulate_hwnd then
        if show then
            -- reaticulate is running but is hidden
            if reaper.HasExtState("ovaska", "reaticulate_invisible") then
                reaper.DeleteExtState("ovaska", "reaticulate_invisible", false)
                reaper.JS_Window_SetOpacity(reaticulate_hwnd, "ALPHA", 1)
            end
        else
            -- reaticulate is running but should be hidden
            Msg("Hiding reaticulate")
            reaper.SetExtState("ovaska", "reaticulate_invisible", "true", false)
            reaper.JS_Window_SetOpacity(reaticulate_hwnd, "ALPHA", 0)
        end
    else
        -- reaticulate is not open
        reaper.DeleteExtState("ovaska", "reaticulate_invisible", false)

        -- ensure midi editor is focused after reaticulate window pops up
        if show then
            Msg("Showing reaticulate..")
            ReaticulateMain()
            reaper.defer(reaper.SN_FocusMIDIEditor)
        end
    end
end

function EnsureMidiWindowVisible(hwnd)
    Msg(reaper.HasExtState("ovaska", "midi_invisible"))

    hwnd = hwnd or GetMidiEditorHwnd()

    if hwnd and reaper.HasExtState("ovaska", "midi_invisible") then
        reaper.DeleteExtState("ovaska", "midi_invisible", false)
        reaper.JS_Window_SetOpacity(hwnd, "ALPHA", 1)
    end
end

function HideMidiWindow(hwnd)
    reaper.SetExtState("ovaska", "midi_invisible", "true", false)
    reaper.JS_Window_SetOpacity(hwnd, "ALPHA", 0)
end

function Execute()
    local hwnd = GetMidiEditorHwnd()

    if hwnd then
        if hwnd == reaper.BR_Win32_GetForegroundWindow() then
            Msg("Is focused, hiding midi window")
            HideMidiWindow(hwnd)
            ReaticulateState(false)
            reaper.BR_Win32_SetFocus(reaper.GetMainHwnd())
        else
            Msg("Is open but not focused, focusing")
            EnsureMidiWindowVisible(hwnd)
            reaper.SN_FocusMIDIEditor()
            ReaticulateState(true)
        end
    else
        Msg("Not visible, opening midi editor")
        reaper.Main_OnCommand(40716, 0)
        ReaticulateState(true)
        reaper.defer(EnsureMidiWindowVisible)
    end
end

ReaticulateCommandId = nil
Execute()
