if SERVER then
    include("config.lua")
    include("sv_flips.lua")

    AddCSLuaFile("cl_flips.lua")
    AddCSLuaFile("config.lua")
else
    resource.AddFile("resource/fonts/Inter-Light.ttf")
    resource.AddFile("resource/fonts/Inter-Regular.ttf")
    resource.AddFile("resource/fonts/Inter-Bold.ttf")
    resource.AddFile("resource/fonts/Inter-Black.ttf")

    include("config.lua")
    include("cl_flips.lua")
end