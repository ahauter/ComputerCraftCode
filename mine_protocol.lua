local mine_protocol = {}
local name = "mine"
local host_name = "host"

local function host()
    rednet.host(name, host_name)
end

local function host_id()
    local control = rednet.lookup(
        name,
        host_name
    )
    return control
end
local headers = {
    new_level = "new_level: ",
    leave = "leaving_spot: ",
    spot_request = "requesting_spot",
    spot_assignment = "spot_assigned: "
}
local function send_new_level(spot)
    rednet.send(host_id(), headers.new_level .. spot, name)
end

local function parse_new_level_message(mess)
    if string.find(mess, "^" .. headers.new_level) == nil then
        error("Not a properly formatted message for spot assignment")
    end
    mess = string.sub(mess, string.len(headers.new_level))
    return tonumber(mess)
end

local function send_leave_spot(spot)
    rednet.send(host_id(), headers.leave .. spot, name)
end

local function parse_leave_spot_message(mess)
    if string.find(mess, "^" .. headers.leave) == nil then
        error("Not a properly formatted message for spot assignment")
    end
    mess = string.sub(mess, string.len(headers.leave))
    return tonumber(mess)
end

local function spot_request()
    rednet.send(host_id(), headers.spot_request, name)
end

local function assign_spot(id, spot, y)
    rednet.send(id, headers.spot_assignment .. spot .. ", " .. y, name)
end

local function parse_spot_assignment(mess)
    if string.find(mess, "^" .. headers.spot_assignment) == nil then
        error("Not a properly formatted message for spot assignment")
    end
    mess = string.sub(mess, string.len(headers.spot_assignment))
    local tbl = {}
    for k, v in string.gmatch(mess, "([^" .. ", " .. "]+)") do
        table.insert(tbl, v)
    end
    local spot = tbl[1]
    local y = tbl[2]
    return tonumber(spot), tonumber(y)
end

mine_protocol = {
    assign_spot = assign_spot,
    spot_request = spot_request,
    send_new_level = send_new_level,
    leave_spot = send_leave_spot,
    host = host,
    parse_new_level_message = parse_new_level_message,
    parse_spot_assignment = parse_spot_assignment,
    parse_leave_spot_message = parse_leave_spot_message,
    name = name
}

mine_protocol.headers = headers
return mine_protocol
