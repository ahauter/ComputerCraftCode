local base_url = "https://raw.githubusercontent.com/ahauter/ComputerCraftCode/main/"

local file_names = {
    "code_download.lua",
    "control_computer.lua",
    "direction.lua",
    "dump.lua",
    "location.lua",
    "mine_protocol.lua",
    "navigation.lua",
    "quarry.lua",
    "refuel.lua",
    "turtle_startup.lua"
}

for _, file_name in pairs(file_names) do
    shell.run("wget " .. base_url .. file_name .. " " .. "ccc/" .. file_name)
end
