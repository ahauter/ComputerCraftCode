local dir = require("direction")
local location = require("location")
M = {}

local loc = vector.new(
    398, 253, -305
)
M.location = loc
function M.need_refuel()
    local cur_loc = location.current()
    local diff = loc - cur_loc
    local fuel_level = turtle.getFuelLevel()
    local dist = math.abs(diff.x)
        + math.abs(diff.y)
        + math.abs(diff.z)
    return dist >= fuel_level + 50
end

function M.refuel()
    local cur_loc = vector.new(
        gps.locate()
    )
    if not loc:equals(
            cur_loc
        ) then
        error("Not at refueling station")
    end
    dir.face(dir.NEG_Z)
    local ind = 0
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0
        then
            ind = i
        end
    end
    if ind < 1 then
        error("No item slots available for refuel")
    end
    turtle.select(ind)
    turtle.suck()
    turtle.refuel()
end

return M
