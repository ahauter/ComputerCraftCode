shell.run("rm quarry_program/*")
local code_paths = {
    main = "LaJ4Wa1y",
    location = "XWZE0bQN",
    direction = "RiSRjcp4",
    refuel = "LrX6CfgL",
    dump = "aYUDje2x",
    navigation = "SQUctkuG",
    mine_protocol = "vjLZZ62U",
    quarry = "2tNw1b1y",
}
for key, value in pairs(code_paths) do
    shell.run(
        "pastebin get "
        .. value ..
        " quarry_program/"
        .. key
    )
end
shell.run("quarry_program/main")
