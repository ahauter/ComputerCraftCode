turtle.refuel()
local location = require("location_utils")
local dir = require("direction")
local fuel = require("refuel")
local dump = require("dump")
local nav = require("navigation")
local control = rednet.lookup(
    "mine", 
    "control_center"
)
rednet.open("left")
print(fuel.need_refuel())
print(dump.need_dump())
rednet.send(control, "register", "mine")
local current_y = 252
local mine_values = {}
local function quarry_level(mx, mz)
    while 
        not fuel.need_refuel()
        and not dump.need_dump() 
        and mx > location.current().x
    do
        local i = 0
        while 
            not fuel.need_refuel() and
            not dump.need_dump()
            and mz > location.current().z
        do
            dir.face(dir.POS_Z)
            turtle.dig()
            turtle.forward()
            i = i + 1
        end
        while i > 0 do 
            turtle.back()
            i = i - 1
        end 
        dir.face(dir.POS_X)
        turtle.dig()
        turtle.forward()   
    end
    while
        not fuel.need_refuel()
        and not dump.need_dump()
        and mz > location.current().z
    do
        dir.face(dir.POS_Z)
        turtle.dig()
        turtle.forward()
    end 
    return not dump.need_dump()
    and not fuel.need_refuel()
end 
local function run_mine()
    local id, mes = rednet.receive("mine")
    mes = tonumber(mes)
    local quarry_info = mine_values[mes]
    while current_y > -64 do
        local cur_start = vector.new(
            quarry_info.x.min,
            current_y + 1,
            quarry_info.z.min
        )
        nav.goto(cur_start)
        turtle.digDown()
        turtle.down()
        local succ = quarry_level(
            quarry_info.x.max,
            quarry_info.z.max
        )
        if not succ then
            local at_dump = nav.goto(dump.location)
            dir.face(dir.NEG_Z)
            if not at_dump then
                error("Could not dump")
            end
            dump.dump()
            local at_refuel = nav.goto(fuel.location)
            if not at_refuel then 
                error("Could not navigate to refuel location")
            end
            dir.face(dir.NEG_Z)
            fuel.refuel()
        else
            current_y =  current_y - 1
        end
    end     
end
 
local function shutdown(err)
    print("Shutting down!")
    print(err)
    nav.goto(location.home)
    rednet.send(control, "unregister", "mine")
    rednet.close()
end
xpcall(run_mine, shutdown)