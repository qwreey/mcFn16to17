-- require from bin
local luvi = require('luvi');
_G.loadModule = function (idf,path)
    idf = idf:match("%.?([^%.]+)$");
    luvi.bundle.register(idf,path);
    return require(idf);
end;

-- load mc lib
local mcCommands = loadModule("app.gen.mcCommands","gen/mcCommands.lua");
local mcLibs = loadModule("app.gen.mcLibs","gen/mcLibs.lua");
local fs = require("fs");

-- set env for compiler
local env = {
    mcLibs = mcLibs;
    mcCommands = mcCommands;
};

-- compile function
local function compileCmd(cmdstr)
    local command = mcCommands[cmdstr:match(" -([^ ]+)")];
    if command then
        return command.comp(env,cmdstr);
    else
        return cmdstr;
    end
end
env.compileCmd = compileCmd;

local console = {};
function console.log(...)
    for _,v in pairs({...}) do
        io.write(tostring(v));
    end
end
function console.rewrite(...) -- line rewrite
    console.log("\27[2K\r",...);
end
local globalProcessSize = 24;
function console.drawProgress(per,size)
    local front = math.floor(per * size + 0.5);
    return string.rep("=",front) .. string.rep("-",size-front);
end
env.console = console;
_G.console = console;

local function compileFile(path)
    console.log("build : ",path,"\n");
    local file = io.open(path);
    if not file then
        io.write(("file '%s' was not found!\n\n"):format(path));
        return;
    end
    console.log("progress : " .. console.drawProgress(0,globalProcessSize));
    local str = file:read("*a");
    local nstr = "";

    local len,i = 1,1;
    str:gsub("\n",function() len = len + 1 end);
    file:seek("set",0);
    for line in file:lines() do
        console.rewrite("progress : " .. console.drawProgress(i/len,globalProcessSize));
        nstr = nstr .. (compileCmd(line) .. "\n");
        i = i + 1;
    end
    console.log("\n\n");

    file:close();
    local filew = io.open(path,"w+");
    filew:write(nstr);
    filew:close();
end
local function testread(path)
    return fs.readdirSync(path);
end
local function compileScan(path)
    local pass,results = pcall(testread,path);
    if pass then
        for _,npath in pairs(results) do
            compileScan(path .. "/" .. npath); -- Recursive
        end
    elseif path:sub(-11,-1) == ".mcfunction" then
        local compPass,compResults = pcall(compileFile,path);
        if not compPass then
            console.log(("\n\27[31man error occured on compile!\27[0m\nERROR : '%s'\n\n"):format(compResults));
        end
    end
end

-- commandline command
local commands = {
    ["file"] = {
        options = {};
        help = (
            "rebuild file <file,file,file,...>\n" ..
            "    you can rebuild mc16's mcfunction files to mc17's mcfunction files\n" ..
            "    you should split files with ','\n" ..
            "    ex : rebuild MCFunction \"test.mcfunction,test2.mcfunction\"\n"
        );
        execute = function (self,args,options)
            local arg1 = args[1];
            if (not arg1) or (arg1 == "") then
                console.log("arg #1 was not given; this command requires arg #1, more information for rebuild help build\n");
                return;
            end
            for path in arg1:gmatch("[^,]+") do
                compileFile(path);
            end
        end;
    };
    ["help"] = {
        options = {};
        help = (
            "rebuild help [commandName]\n" ..
            "    show this message, and you can get information of command with args\n"
        );
        execute = nil;
    };
    ["command"] = {
        options = {};
        help = (
            "rebuild command <Command>\n" ..
            "    you can rebuild mc16's command to mc17's command\n"
        );
        execute = function (self,args,options)
            local command = "";
            for i,str in ipairs(args) do
                command = command .. (i ~= 1 and " " or "") .. str;
            end
            if (not command) or command == "" then
                console.log("arg #1 was not given; this command requires arg #1, more information for rebuild help command\n");
            else
                console.log(compileCmd(command),"\n");
            end
        end;
    };
    ["scan"] = {
        options = {};
        help = (
            "rebuild scan <folders,folders,folders,...>\n" ..
            "    you can rebuild mc16's mcfunction files to mc17's mcfunction files\n" ..
            "    you should split files with ','\n" ..
            "    ex : rebuild MCFunction \"test.mcfunction,test2.mcfunction\"\n"
        );
        execute = function (self,args,options)
            local arg1 = args[1];
            if (not arg1) or (arg1 == "") then
                console.log("arg #1 was not given; this command requires arg #1, more information for rebuild help build\n");
                return;
            end
            for path in arg1:gmatch("[^,]+") do
                compileScan(path);
            end
        end;
    };
};

commands.help.execute = function (self,args,options)
    if args[1] then
    else
        console.log("rebuild your minecraft 1.16's mcfunction to 1.17's mcfunction\nthis program replace 'replaceitem' to 'item', it will work same with old version!\nVERSION : 1.1\n\nlist of all commands:\n\n")
        for _,c in pairs(commands) do
            console.log(c.help,"\n");
        end
    end
end

-- execute cmd
local commandName = args[1];
table.remove(args,0);
table.remove(args,1);
local commandArg = loadModule("commandArg","libs/commandArg.lua");
local thisCommand = commands[commandName];
if not commandName then
    console.log(("Please set command to use this program!\nuse : rebuild <Command> [args/options]\nenter 'rebuild help' for more information!\n"):format(tostring(commandName)));
    os.exit(1);
elseif not thisCommand then
    console.log(("Command '%s' not found!\n"):format(tostring(commandName)));
    os.exit(2);
end
local pass,msg = pcall(thisCommand.execute,thisCommand,commandArg(args,thisCommand.options));
if not pass then
    console.log(("\27[31man error occured on running command, enter 'rebuild help %s' for more information\27[0m\n"):format(commandName));
    console.log(msg,"\n");
    os.exit(3);
end
os.exit(0);