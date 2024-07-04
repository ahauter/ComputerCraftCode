local protocol = require("mine_protocol")
local max_mining_spots = 4
local mining_spots = {}
local file_path = "mining_spot_database_super_secret.txt"
local max_y = 253
local function render()
    term.clear()
    local line = 1
    for k, value in pairs(mining_spots) do
        term.setCursorPos(1, line)
        term.write("Spot: " .. k)
        term.setCursorPos(15, line)
        term.write(" Y Level: " .. value.current_y)
        local str = "Not assigned"
        local color = colors.red
        if value.assigned_id ~= nil then
            color = colors.green
            str = " Assigned to bot: " .. value.assigned_id
        end
        term.setBackgroundColor(color)
        term.setCursorPos(30, line)
        term.write(str)
        term.setBackgroundColor(colors.black)
        line = line + 1
    end
end
local function save()
    local file = io.open(file_path, "w")
    if file == nil then error("Could not open file") end
    for k, value in pairs(mining_spots) do
        file:write("" .. value.current_y .. "\n")
    end
    file:close()
end
local function load()
    local file = io.open(file_path, "r")
    if file == nil then return end
    for line in file:lines() do
        table.insert(mining_spots, {
            assigned_id = nil,
            current_y = tonumber(line)
        })
    end
end
local function handle_register(turtle_id)
    local chosen_spot = 0
    for i = 1, max_mining_spots do
        if mining_spots[i] == nil then
            mining_spots[i] = {
                assigned_id = turtle_id,
                current_y = max_y
            }
            chosen_spot = i
            break
        elseif mining_spots[i].assigned_id == nil then
            mining_spots[i].assigned_id = turtle_id
            chosen_spot = i
            break
        end
    end
    rednet.broadcast("Assigning spot " .. chosen_spot, "monitor")
    protocol.assign_spot(turtle_id, chosen_spot, mining_spots[chosen_spot].current_y)
end

local function unregister(spot, id)
    local spot_info = mining_spots[spot]
    if spot_info ~= nil and spot_info.assigned_id == id then
        mining_spots[spot].assigned_id = nil
    end
end

local function add_level(spot, id)
    local spot_info = mining_spots[spot]
    local y = spot_info.current_y
    if spot_info ~= nil and spot_info.assigned_id == id then
        mining_spots[spot].current_y = y - 1
    end
end

function main()
    load()
    rednet.open("top")
    protocol.host()
    while true do
        render()
        local id, mess = rednet.receive(protocol.name)
        rednet.broadcast("Received message from computer " .. id, "monitor")
        if string.find(mess, "^" .. protocol.headers.spot_request) ~= nil then
            handle_register(id)
        elseif string.find(mess, "^" .. protocol.headers.leave) ~= nil then
            local spot_num = protocol.parse_leave_spot_message(mess)
            unregister(spot_num, id)
        elseif string.find(mess, "^" .. protocol.headers.new_level) ~= nil then
            local spot_num = protocol.parse_new_level_message(mess)
            add_level(spot_num, id)
        end
        save()
    end
end

local function handle_err(err)
    save()
    term.clear()
    protocol.recall()
    print(err)
end

xpcall(main, handle_err)
