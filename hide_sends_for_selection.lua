local sel_track_count = reaper.CountSelectedTracks()
if sel_track_count > 0 then
  reaper.Undo_BeginBlock()
  for i=0, sel_track_count-1 do
    local sel_tr = reaper.GetSelectedTrack(0,i)
    reaper.SetMediaTrackInfo_Value(sel_tr, 'F_MCP_SENDRGN_SCALE', 0)
  end
  reaper.Undo_EndBlock('Hide mcp sends area of selected tracks', -1)
else
  reaper.defer(function () end)
end
