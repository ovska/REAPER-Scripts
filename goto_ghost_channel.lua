local function getMIDINoteUnderMouse()
    local editor = reaper.MIDIEditor_GetActive()
    if editor then
        local _, _, _, _, _, _, _, _, noteRow = reaper.BR_GetMouseCursorContext_MIDI()
        return noteRow
    end
    return -1 -- Return -1 if no MIDI editor or no note under the mouse
end

local noteRow = getMIDINoteUnderMouse()

if noteRow >= 0 then
    reaper.ShowConsoleMsg("MIDI note under the mouse: " .. noteRow .. "\n")
else
    reaper.ShowConsoleMsg("No MIDI note under the mouse.\n")
end
