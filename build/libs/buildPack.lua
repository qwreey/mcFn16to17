local fs = require "fs";
local function strPack(path,prefix)
    local luaStr = "local l=_G.loadModule;return{";
    for _,thing in pairs(fs.readdirSync(path)) do
        if thing:sub(-4,-1) == ".lua" then
            local this = thing:sub(1,-5);
            luaStr = luaStr .. ("%s=l(\"%s\",\"%s%s.lua\");"):format(this,this,prefix,this);
        end
    end
    return luaStr:sub(1,-2) .. "};";
end

local function buildPack(fin,fout,prefix)
    local outFile = io.open(fout,"w+");
    outFile:write(strPack(fin,prefix));
    outFile:close();
end

return buildPack;