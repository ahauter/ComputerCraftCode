M = {
    POS_X = vector.new(1, 0, 0),
    POS_Z = vector.new(0, 0, 1),
    NEG_X = vector.new(-1, 0, 0),
    NEG_Z = vector.new(0, 0, -1)
}
local function get_cur_dir()
    local cur_pos = vector.new(
        gps.locate()
    )
    local succ = turtle.forward()
    if not succ then
        error("Could not determine direction")
    end
    local new_pos = vector.new(
        gps.locate()
    )
    turtle.back()
    return new_pos - cur_pos
end

local cur_dir = get_cur_dir()

function M.current()
    return vector.new(
        cur_dir.x,
        cur_dir.y,
        cur_dir.z
    )
end

local function right()
    turtle.turnRight()
    local right_vector = vector.new(0, 1, 0)
    cur_dir = cur_dir:cross(
        right_vector
    )
end

M.right = right

local function left()
    turtle.turnLeft()
    local left_vector = vector.new(0, -1, 0)
    cur_dir = cur_dir:cross(
        left_vector
    )
end

M.left = left
local valid_dirs = {
    vector.new(1, 0, 0),
    vector.new(-1, 0, 0),
    vector.new(0, 0, 1),
    vector.new(0, 0, -1)
}
function M.face(vect)
    local not_err = false
    for _, valid_dir
    in pairs(valid_dirs)
    do
        not_err = not_err or
            valid_dir:equals(vect)
    end
    if not not_err then
        error("Not a valid direction")
    end
    while not vect:equals(cur_dir) do
        left()
    end
end

return M
