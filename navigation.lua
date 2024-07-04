local location = require("location")
local dir = require("direction")

local function is_visited(visited, block)
    for _, b2 in pairs(visited) do
        if b2 == block then
            return true
        end
    end
    return false
end

local function dumb_goto(block, visited)
    local cur_loc = location.current()
    local delta = block - cur_loc
    if delta:length() == 0 then
        return true
    end

    local pos_dirs = {}
    local move_fn = function(direction, visited)
        direction:normalize()
        local cur_block = location.current()
        local new_block = cur_block + direction
        if is_visited(visited, new_block) then
            return function() return false end, function() end
        end
        if direction.y > 0 then
            return function() return turtle.up() end,
                function() return turtle.down() end
        elseif direction.y < 0 then
            return function() return turtle.down() end,
                function() return turtle.up() end
        end
        return function()
                dir.face(direction)
                return turtle.forward()
            end,
            function()
                dir.face(direction * -1)
                return turtle.forward()
            end
    end
    if delta.x > 0 then
        table.insert(
            pos_dirs,
            1,
            dir.POS_X
        )
        table.insert(
            pos_dirs, 4,
            dir.NEG_X
        )
    elseif delta.x < 0 then
        table.insert(
            pos_dirs, 1,
            dir.NEG_X
        )
        table.insert(
            pos_dirs, 4,
            dir.POS_X
        )
    else
        table.insert(
            pos_dirs, 4,
            dir.NEG_X
        )
        table.insert(
            pos_dirs, 7,
            dir.POS_X
        )
    end
    if delta.y > 0 then
        table.insert(
            pos_dirs, 2,
            vector.new(0, 1, 0)
        )
        table.insert(
            pos_dirs, 5,
            vector.new(0, -1, 0)
        )
    elseif delta.y < 0 then
        table.insert(
            pos_dirs, 2,
            vector.new(0, -1, 0)
        )
        table.insert(
            pos_dirs, 5,
            vector.new(0, 1, 0)
        )
    else
        table.insert(
            pos_dirs, 8,
            vector.new(0, -1, 0)
        )
        table.insert(
            pos_dirs, 5,
            vector.new(0, 1, 0)
        )
    end
    if delta.z > 0 then
        table.insert(
            pos_dirs,
            3,
            dir.POS_Z
        )
        table.insert(
            pos_dirs, 6,
            dir.NEG_Z
        )
    elseif delta.z < 0 then
        table.insert(
            pos_dirs, 3,
            dir.NEG_Z
        )
        table.insert(
            pos_dirs, 6,
            dir.POS_Z
        )
    else
        table.insert(
            pos_dirs, 6,
            dir.NEG_Z
        )
        table.insert(
            pos_dirs, 9,
            dir.POS_Z
        )
    end
    for i, direction in pairs(pos_dirs) do
        local forward, back = move_fn(direction, visited)
        local succ = forward()
        if succ then
            table.insert(visited, location.current())
            local reached_target = dumb_goto(
                block, visited
            )
            if reached_target then
                return true
            end
            back()
        end
    end
end

function M.goto_block(block)
    return dumb_goto(block, {})
end

return M
