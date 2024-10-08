function Main()
    local command_id = reaper.NamedCommandLookup("_aa6d8323e1608b428fa3a1c43cce7c6f")
    reaper.Main_OnCommand(command_id, 0)

    local arr = reaper.new_array({}, 8)
    reaper.JS_MIDIEditor_ArrayAll(arr)
    local adr = arr.table()

    for i = 1, #adr do
        if adr[i] then
            local hwnd = reaper.JS_Window_HandleFromAddress(adr[i])

            if hwnd then
                reaper.JS_Window_Destroy(hwnd)
            end
        end
    end

    local mixer_hwnd, _ = reaper.BR_Win32_GetMixerHwnd()
    if mixer_hwnd then
        reaper.JS_Window_Destroy(mixer_hwnd)
    end
end

Main()
