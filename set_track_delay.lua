if reaper.CountSelectedTracks2(0, false) == 0 then
    return
end

function FormatTrack(name, offset)
    return '  - ' .. name .. ' (' .. tostring(math.floor(offset * 1000)) .. 'ms)'
end

local tracksWithDelay = {}

for i = 1, reaper.CountSelectedTracks2(0, false) do
    local track = reaper.GetSelectedTrack2(0, i - 1, false)
    local hasOffset = reaper.GetMediaTrackInfo_Value(track, 'I_PLAY_OFFSET_FLAG')
    local offset = reaper.GetMediaTrackInfo_Value(track, 'D_PLAY_OFFSET')
    if hasOffset and offset ~= 0 then
        local ret, name = reaper.GetTrackName(track)
        if ret then
            table.insert(tracksWithDelay, FormatTrack(name, offset))
        else
            table.insert(tracksWithDelay, FormatTrack('Track ' .. tostring(i), offset))
        end
    end
end

if #tracksWithDelay ~= 0 then
    local result = reaper.ShowMessageBox(
        "One or more track(s) already have a delay:\n" .. table.concat(tracksWithDelay, '\n'),
        "Proceed?",
        1
    )

    if result == 2 then return end
end

local retval, retvals_csv = reaper.GetUserInputs(
    'Set negative offset for ' .. tonumber(reaper.CountSelectedTracks2(0, false)) .. ' track(s)',
    1,
    'milliseconds',
    0
)

if retval and tonumber(retvals_csv) then
    for i = 1, reaper.CountSelectedTracks2(0, false) do
        local track = reaper.GetSelectedTrack2(0, i - 1, false)
        reaper.SetMediaTrackInfo_Value(track, 'I_PLAY_OFFSET_FLAG', 0)
        reaper.SetMediaTrackInfo_Value(track, 'D_PLAY_OFFSET', -tonumber(retvals_csv) / 1000)
    end
end
