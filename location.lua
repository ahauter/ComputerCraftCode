-- Get home location
local M = {}
local home_file_path = "home.txt"
local home_file = fs.open(home_file_path, "r")
M.home = vector.new(0, 0, 0)
if home_file == nil then
    print("Initial Startup => locating home")
    M.home = vector.new(
        gps.locate()
    )
    home_file = fs.open(home_file_path, "w")
    home_file.writeLine(M.home.x)
    home_file.writeLine(M.home.y)
    home_file.writeLine(M.home.z)
else
    M.home = vector.new(
        home_file.readLine(),
        home_file.readLine(),
        home_file.readLine()
    )
end

home_file.close()
function M.current()
    return vector.new(
        gps.locate()
    )
end

return M
