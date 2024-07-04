local max_mining_spots = 4
local mining_spots = {}
local function handle_register(turtle_id)
    local chosen_spot = 0
    for i = 1, max_mining_spots do
        if mining_spots[i] == nil then
            mining_spots[i] = {
                assigned_id = id,
                current_y = mine_values.y.max,
            }
        elseif mining_spots[i].assigned_id == nil then
            mining_spots[i].assigned_id = id
        end
    end
    rednet.send(id, "" .. i, "mine")
end
