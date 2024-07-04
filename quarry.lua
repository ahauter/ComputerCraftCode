local location = require("location")
local dir = require("direction")
local nav = require("navigation")
local fuel = require("refuel")
local dump = require("dump")

local mine_values = {
    mine_start = vector.new(368, 250, -320),
    mine_end = vector.new(375, -63, -313)
}

local function get_start_mining_coords(spot)
    local increment = nil
    local base = mine_values.mine_start
    if spot == 1 then
        increment = vector.new(0, 0, 0)
        return base + increment
    elseif spot == 2 then
        increment = vector.new(-8, 0, 0)
        return base + increment
    elseif spot == 3 then
        increment = vector.new(0, 0, 8)
        return base + increment
    elseif spot == 4 then
        increment = vector.new(-8, 0, 8)
        return base + increment
    end
    error("Unknown Spot")
end

local function get_end_mining_coords(spot)
    local increment = nil
    local base = mine_values.mine_end
    if spot == 1 then
        increment = vector.new(0, 0, 0)
        return base + increment
    elseif spot == 2 then
        increment = vector.new(-8, 0, 0)
        return base + increment
    elseif spot == 3 then
        increment = vector.new(0, 0, 8)
        return base + increment
    elseif spot == 4 then
        increment = vector.new(-8, 0, 8)
        return base + increment
    end
    error("Unknown Spot")
end

local function need_break()
    return fuel.need_refuel() or
        dump.need_dump()
end

local function at_end(dir, min_z, max_z)
    if dir.z > 0 then
        return location.current().z == max_z
    else
        return location.current().z == min_z
    end
end

function quarry_level(spot, y)
    local cur_start = get_start_mining_coords(spot)
    cur_start.y = y
    local end_coords = get_end_mining_coords(spot)
    nav.goto_block(cur_start)
    local succ = turtle.digDown()
    succ = turtle.down()
    local z_dir = dir.POS_Z
    if not succ then
        error("Could not reach quarry level")
    end
    while
        not need_break()
        and end_coords.x ~= location.current().x
    do
        while
            not need_break()
            or at_end(z_dir, cur_start.z, end_coords.z)
        do
            dir.face(z_dir)
            turtle.dig()
            succ = turtle.forward()
            if not succ then error("Failed to move forward!") end
        end
        dir.face(dir.POS_X)
        z_dir = z_dir * -1
        turtle.dig()
        succ = turtle.forward()
        if not succ then error("Failed to move forward!") end
    end
    while
        not need_break()
        or at_end(z_dir, cur_start.z, end_coords.z)
    do
        dir.face(dir.POS_Z)
        turtle.dig()
        succ = turtle.forward()
        if not succ then error("Failed to move forward!") end
    end
    return not dump.need_dump()
        and not fuel.need_refuel()
end

return {
    quarry_level = quarry_level
}
