local protocol = require("mine_protocol")

local turtles = {}
local function listen_for_status()
    while true do
        local id, mess = rednet.receive(protocol.name)
        if turtles[id] == nil then
            turtles[id] = {
                status = nil,
                error = nil
            }
        end
        if protocol.has_header(protocol.headers.status_report, mess) then
            local status = string.sub(mess, string.len(protocol.headers.status_report))
            turtles[id].status = status
        elseif protocol.has_header(protocol.headers.error_report, mess) then
            local err = string.sub(mess, string.len(protocol.headers.status_report))
            turtles[id].error = error
        end
    end
end

local function ask_for_status()
    while true do
        rednet.broadcast(
            protocol.headers.status_report,
            protocol.name
        )
        sleep(5)
    end
end

local function render()
    while true do
        term.clear()
        local line = 2
        term.setCursorPos(1, 1)
        term.write("Turtle Status")
        for id, info in pairs(turtles) do
            term.write("Turtle " .. id .. "Status ")
            local status = info.status
            if status == nil then
                status = "unknown"
            end
            term.write(status)
            if info.error ~= nil then
                term.setBackgroundColor(colors.red)
                term.write(" Error: " .. info.error)
                term.setBackgroundColor(colors.black)
            end
            line = line + 1
        end
        os.sleep(5)
    end
end
local function main()
    parallel.waitForAll(
        ask_for_status,
        listen_for_status,
        render
    )
end
main()
