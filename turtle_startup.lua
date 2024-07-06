turtle.refuel()
local location = require("location")
local dir = require("direction")
local fuel = require("refuel")
local dump = require("dump")
local nav = require("navigation")
local protocol = require("mine_protocol")
local quarry = require("quarry")

local version = "0.0.4"

local status = "mine"
local quarry_location = nil

local function receive_message()
    while true do
        -- set a timeout so we keep checking for
        local id, mess = rednet.receive(protocol.name)
        if mess ~= nil then
            rednet.broadcast("New message: " .. mess, "monitor")
            if string.find(mess, "^" .. protocol.headers.spot_assignment) ~= nil then
                local spot, y = protocol.parse_spot_assignment(mess)
                quarry_location = {
                    spot = spot,
                    y = y
                }
            elseif string.find(mess, "^" .. protocol.headers.status_report) ~= nil then
                rednet.send(id, protocol.headers.status_report .. " " .. status)
            elseif string.find(mess, "^" .. protocol.headers.recall) ~= nil then
                status = "go_home"
            elseif string.find(mess, "^" .. protocol.headers.restart) ~= nil then
                status = "restart"
            else
                status = "mine"
            end
        end
    end
end

local function run_mine()
    while true do
        if status == "mine" and dump.need_dump() then
            status = "dump"
        elseif fuel.need_refuel() then
            status = "refuel"
        end
        if status ~= nil then
            print("status is " .. status)
            print("Have a location = " .. (quarry_location ~= nil))
            print("Have a coroutine = " .. quary_coroutine ~= nil)
        end
        if status == "go_home" then
            nav.goto_block(location.home)
            coroutine.yield()
        elseif status == "dump" then
            nav.goto_block(dump.location)
            dir.face(dir.NEG_Z)
            dump.dump()
            coroutine.yield()
        elseif status == "refuel" then
            nav.goto_block(fuel.location)
            dir.face(dir.NEG_Z)
            fuel.refuel()
            coroutine.yield()
        elseif status == "mine" then
            if quarry_location == nil then
                protocol.spot_request()
                if quary_coroutine ~= nil then
                    quary_coroutine = nil
                end
                coroutine.yield()
            elseif quarry_location ~= nil then
                local succ = quarry.quarry_level(quarry_location.spot, quarry_location.y)
                if status == succ then
                    if succ then
                        protocol.send_new_level(quarry_location.spot)
                    end
                    protocol.leave_spot(quarry_location.spot)
                    quarry_location = nil
                end
                coroutine.yield()
            end
        end
    end
end

local function main()
    print("Turtle starting up! Version " .. version)
    rednet.open("left")
    rednet.broadcast("Turtle starting up!", "monitor")
    parallel.waitForAll(receive_message, run_mine)
end

local function shutdown(err)
    if quarry_location ~= nil then
        protocol.leave_spot(quarry_location.spot)
    end
    print(err)
    rednet.close()
    nav.goto_block(location.home)
end
xpcall(main, shutdown)
