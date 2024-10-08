Last_state = true

-- Function to check if MIDI editor is still open
function CheckMIDIEditor()
    -- Get the active MIDI editor (returns nil if no editor is active)
    local midiEditor = reaper.MIDIEditor_GetActive()

    -- If the MIDI editor is closed (no active MIDI editor), perform action
    if midiEditor == nil then
        if Last_state then
            -- turn off 
            local command_id = reaper.NamedCommandLookup("_RSbe259504561f6a52557d2d1c64e52ef13527bf17")
            reaper.Main_OnCommand(command_id, 0)
        end
    else
        -- is now open, wasnt last time
        if not Last_state then
            local command_id = reaper.NamedCommandLookup("_RSbe259504561f6a52557d2d1c64e52ef13527bf17")
            reaper.Main_OnCommand(command_id, 0)
            reaper.BR_Win32_SetFocus(midiEditor)
        end
    end

    Last_state = midiEditor ~= nil
end

local CALLS_TO_SKIP = 10
local x_counter = CALLS_TO_SKIP

local function main()
    x_counter = x_counter - 1
    if x_counter < 0 then
        CheckMIDIEditor()
        x_counter = CALLS_TO_SKIP
    end
    reaper.defer(main)
end

reaper.defer(main)
