-- Side control for the AI tactical reflexes (Overclock, Pylum, field works, portal warden).
--
-- side.controller is synced in live games, but replays keep the starting controller:
-- a [change_controller] (":droid N full", a replaced player) is not stored in replays.
-- Branching synced code on the live controller therefore desyncs replays. Instead, each
-- side's AI status is fixed once at prestart in a side variable, which saves and replays
-- keep. Trade-off: a side that changes controller mid-game keeps its prestart status.

local side_control = {}

local FLAG = "liun_ai"

-- Called from the prestart era event: records whether each side starts as an AI.
function side_control.on_prestart()
    for idx, side in ipairs(wesnoth.sides) do
        side.variables[FLAG] = (side.controller == "ai")
    end
end

-- True if the side was AI-controlled at scenario start.
function side_control.is_ai_side(side_num)
    local side = wesnoth.sides[side_num]
    return side ~= nil and side.variables[FLAG] == true
end

return side_control
