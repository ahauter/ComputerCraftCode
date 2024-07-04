local location = require("location_utils")
local dir = require("direction")
local nav = require("navigation")
pr

local mine_values = {
    mine_start = vector.new(368, 250, -320),
    mine_end = vector.new(375, -63, -313)
}

local function get_mining_coords(spot)
    local increment = vector.new(-8, 0, 8)
    return mine_values.mine_start + (increment * spot)
end

local function quarry_level(spot, y)
    local cur_start = get_mining_coords(spot)
    cur_start.y = y
    nav.goto_block(cur_start)
    local succ = turtle.digDown()
    succ = turtle.down()
    if not succ then error("Could not reach quarry level")
    local succ = quarry_level(
        quarry_info.x.max,
        quarry_info.z.max
    )
end
