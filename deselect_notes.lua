function deselectAllNotes()
    local editor = reaper.MIDIEditor_GetActive()
    if editor then
        local take = reaper.MIDIEditor_GetTake(editor)
        if take then
            local _, notes, _, ccs, texts, sysex = reaper.MIDI_CountEvts(take)
            for i = 0, notes - 1 do
                local _, selected, _, _, _, _, _, _ = reaper.MIDI_GetNote(take, i)
                if selected then
                    reaper.MIDI_SetNote(take, i, false)
                end
            end
            reaper.MIDI_Sort(take)
        end
    end
end

reaper.Undo_BeginBlock()
deselectAllNotes()
reaper.Undo_EndBlock("Deselect all MIDI notes", -1)
