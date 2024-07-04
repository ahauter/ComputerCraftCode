local direction = require("direction")
local location = require("location")
M = {}
M.location = vector.new(400, 253, -305)
M.direction = direction.NEG_Z
function M.need_dump()
    local need_dump = true
    for i = 1, 16 do
        need_dump = need_dump and
            0 < turtle.getItemCount(i)
    end
    return need_dump
end

function M.dump()
    if
        location.current() ~= M.location and
        direction.current() ~= M.direction
    then
        error("Not at the proper dump location.")
    end
    for i = 1, 16 do
        turtle.select(i)
        turtle.drop()
    end
end

return M
