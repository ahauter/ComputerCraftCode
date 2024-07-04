turtle.refuel()
local location = require("location")
local dir = require("direction")
local fuel = require("refuel")
local dump = require("dump")
local nav = require("navigation")
local protocol = require("mine_protocol")
local quarry = require("quarry")

local function receive_message()
    local id, mess = rednet.receive(protocol.name, 1)
    if mess ~= nil then
        rednet.broadcast("New message: " .. mess, "monitor")
    end
    if mess ~= nil and string.find(mess, "^" .. protocol.headers.spot_assignment) ~= nil then
        return "quarry", mess
    elseif dump.need_dump() then
        return "dump", ""
    elseif fuel.need_refuel() then
        return "refuel", ""
    else
        return "new spot"
    end
end
local current_spot = nil
local function run_mine()
    rednet.open("left")
    rednet.broadcast("Turtle starting up!", "monitor")
    while true do
        local command, res = receive_message()
        rednet.broadcast("Current Status: " .. command, "monitor")
        if command == "quarry" then
            local spot, y = protocol.parse_spot_assignment(res)
            current_spot = spot
            local need_breack = quarry.quarry_level(spot, y)
            if not need_breack then
                protocol.send_new_level(spot)
            end
            y = y - 1
            protocol.leave_spot(spot)
            current_spot = nil
        elseif command == "go_home" then
            nav.goto_block(location.home)
        elseif command == "dump" then
            nav.goto_block(dump.location)
            dir.face(dir.NEG_Z)
            dump.dump()
        elseif command == "refuel" then
            nav.goto_block(fuel.location)
            dir.face(dir.NEG_Z)
            fuel.refuel()
        elseif "new spot" then
            protocol.spot_request()
        end
    end
end

local function shutdown(err)
    if current_spot ~= nil then
        protocol.leave_spot(current_spot)
    end
    print(err)
    rednet.close()
    nav.goto_block(location.home)
end
xpcall(run_mine, shutdown)
