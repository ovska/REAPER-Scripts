local project = reaper.EnumProjects(-1)

local instTrack = reaper.GetSelectedTrack2(project, 0, false)

if instTrack == nil then
    reaper.ShowConsoleMsg('CREATE SEND/MIDI: No track selected')
    return
end

local outputs = reaper.GetMediaTrackInfo_Value(instTrack, "I_NCHAN")

if outputs < 2 or outputs > 32 or outputs % 2 ~= 0 then
    reaper.ShowConsoleMsg('CREATE SEND/MIDI: Invalid amount of output channels: ' .. tostring(outputs))
    return
end

local retval, trackName = reaper.GetTrackName(instTrack)

if not retval then
    reaper.ShowConsoleMsg('CREATE SEND/MIDI: Could not get selected track name')
    return
end

-- if track name ends in INST, use the prefix as name base, e.g. "CSS INST" -> "CSS BUS", "CSS MIDI1" etc
if trackName:match(" INST$") then
    local trimmed = string.sub(trackName, 0, -6)
    if trimmed.len ~= 0 then trackName = trimmed end
end

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

local nextMidiTrackIndex = reaper.GetMediaTrackInfo_Value(instTrack, "IP_TRACKNUMBER")
local midiTrackCount = 0

while midiTrackCount < outputs / 2 do
    reaper.InsertTrackAtIndex(nextMidiTrackIndex, false)
    local midiTrack = reaper.GetTrack(project, nextMidiTrackIndex)

    reaper.GetSetMediaTrackInfo_String(midiTrack, "P_NAME", trackName .. " MIDI " .. tostring(midiTrackCount + 1), true)
    reaper.SetMediaTrackInfo_Value(midiTrack, "B_MAINSEND", 0)
    reaper.SetMediaTrackInfo_Value(midiTrack, "B_SHOWINMIXER", 0)
    reaper.SetMediaTrackInfo_Value(midiTrack, "I_RECMON", 1)

    -- create midi send to inst, set midi channel and disable audio
    local sendIndex = reaper.CreateTrackSend(midiTrack, instTrack)
    reaper.BR_GetSetTrackSendInfo(midiTrack, 0, sendIndex, "I_MIDI_DSTCHAN", true, midiTrackCount + 1)
    reaper.BR_GetSetTrackSendInfo(midiTrack, 0, sendIndex, "I_SRCCHAN", true, -1)

    nextMidiTrackIndex = nextMidiTrackIndex + 1
    midiTrackCount = midiTrackCount + 1
end

reaper.InsertTrackAtIndex(nextMidiTrackIndex, false)
local busTrack = reaper.GetTrack(project, nextMidiTrackIndex)
reaper.GetSetMediaTrackInfo_String(busTrack, "P_NAME", trackName .. " BUS", true)
reaper.SetMediaTrackInfo_Value(busTrack, "B_SHOWINTCP", 0)
reaper.SetMediaTrackInfo_Value(busTrack, "I_RECMON", 0)

local nextStereoIndex = nextMidiTrackIndex + 1
local stereoCount = 0

while stereoCount < outputs / 2 do
    reaper.InsertTrackAtIndex(nextStereoIndex, false)
    local stereoTrack = reaper.GetTrack(project, nextStereoIndex)

    reaper.GetSetMediaTrackInfo_String(stereoTrack, "P_NAME", trackName .. " OUT " .. tostring(stereoCount + 1), true)
    reaper.SetMediaTrackInfo_Value(stereoTrack, "B_MAINSEND", 0)
    reaper.SetMediaTrackInfo_Value(stereoTrack, "B_SHOWINTCP", 0)
    reaper.SetMediaTrackInfo_Value(stereoTrack, "I_RECMON", 0)

    -- create audio receive from inst
    local receiveIndex = reaper.CreateTrackSend(instTrack, stereoTrack)
    reaper.BR_GetSetTrackSendInfo(instTrack, 0, receiveIndex, "I_SRCCHAN", true, stereoCount * 2)
    reaper.BR_GetSetTrackSendInfo(instTrack, 0, receiveIndex, "I_MIDI_DSTCHAN", true, -1)

    -- create audio send to bus
    local sendIndex = reaper.CreateTrackSend(stereoTrack, busTrack)
    reaper.BR_GetSetTrackSendInfo(stereoTrack, 0, sendIndex, "I_MIDI_DSTCHAN", true, -1)

    nextStereoIndex = nextStereoIndex + 1
    stereoCount = stereoCount + 1
end

-- disable instrument track send to master and hide it from mixer
reaper.SetMediaTrackInfo_Value(instTrack, "B_MAINSEND", 0)
reaper.SetMediaTrackInfo_Value(instTrack, "B_SHOWINMIXER", 0)

reaper.Undo_EndBlock("Create MIDI/SEND Tracks", 1)

reaper.PreventUIRefresh(-1)
reaper.TrackList_AdjustWindows(false)
