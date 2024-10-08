function Msg(param)
    if false then
        reaper.ShowConsoleMsg(tostring(param) .. "\n")
    end
end

function IsMixerFocused()
    local mixer_handle, docked = reaper.BR_Win32_GetMixerHwnd()

    if mixer_handle then
        if mixer_handle == reaper.BR_Win32_GetForegroundWindow() then
            Msg("Mixer is in foreground")
            return true -- Mixer window has focus (not docked)
        elseif reaper.BR_Win32_GetParent(reaper.BR_Win32_GetFocus()) == mixer_handle then
            Msg("Focused is child of mixer")
            return true -- focused window is child of docked Mixer
        else
            -- reaper.JS_Window_SetFocus(mixer_handle)
            reaper.BR_Win32_SetFocus(mixer_handle)
            return false
        end
    else
        reaper.Main_OnCommand(40078, 0) -- mixer not visible
        return false
    end

-- reaper.BR_Win32_GetWindowRect
-- reaper.BR_Win32_SetWindowPos(mixer_handle, 0,0,0,0,0, )
end

if IsMixerFocused() then
        reaper.Main_OnCommand(40078, 0) -- show mixer
end
