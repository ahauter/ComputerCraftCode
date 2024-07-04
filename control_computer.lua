local protocol = require("mine_protocol")
local max_mining_spots = 4
local mining_spots = {}
local file_path = "mining_spot_database_super_secret.txt"
local function get_str()
    local str = ""
    for k, value in pairs(mining_spots) do
        str = str .. "Spot: " .. k .. " Y Level: " .. value.current_y
        if value.assigned ~= nil then
            str = str .. " Assigned to bot: " .. value.assigned_id
        end
        str = str .. "/n"
    end
    return str
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
                assigned_id = id,
                current_y = mine_values.y.max,
            }
            chosen_spot = i
        elseif mining_spots[i].assigned_id == nil then
            mining_spots[i].assigned_id = id
            chosen_spot = i
        end
    end
    rednet.broadcast("Assigning spot " .. chosen_spot, "monitor")
    protocol.assign_spot(chosen_spot, mining_spots[i].y)
end

local function unregister(spot, id)
    local spot_info = mining_spots[spot]
    if spot_info ~= nil and spot_info.assigned_id == id then
        mining_spots[spot].assigned_id = nil
    end
end

local function add_level(spot, id)
    local spot_info = mining_spots[spot]
    local y = spot_info.y
    if spot_info ~= nil and spot_info.assigned_id == id then
        mining_spots[spot].y = y - 1
    end
end

function main()
    load()
    rednet.open("top")
    protocol.host()
    while true do
        term.clear()
        term.write(get_str())
        local id, mess = rednet.receive(protocol.name)
        rednet.broadcast("Received message from computer " .. id, "monitor")
        if string.find(mess, "^" .. protocol.headers.spot_request) == nil then
            handle_register(id)
        elseif string.find(mess, "^" .. protocol.headers.leave) == nil then
            local spot_num = protocol.parse_leave_spot_message(mess)
            unregister(spot_num, id)
        elseif string.find(mess, "^" .. protocol.headers.new_level) == nil then
            local spot_num = protocol.parse_leave_spot_message(mess)
            add_level(spot_num, id)
        end
        save()
    end
end

main()
