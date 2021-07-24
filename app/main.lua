-- require from bin
local luvi = require('luvi');
local function loadModule(idf,path)
    luvi.bundle.register(idf,path);
    return require(idf);
end
_G.loadModule = loadModule;

-- load mc lib
local mcCommands = loadModule("mcCommands","gen/mcCommands.lua");
local mcLibs = loadModule("mcLibs","gen/mcLibs.lua");

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

local function log(...)
    for _,v in pairs({...}) do
        io.write(tostring(v));
    end
    io.write("\n");
end
env.log = log;

-- commandline command
local commands = {
    ["build"] = {
        options = {};
        help = (
            "rebuild build <file,file,file,...>\n" ..
            "    you can rebuild mc16's mcfunction files to mc17's mcfunction files\n" ..
            "    you should split files with ','\n" ..
            "    ex : rebuild MCFunction \"test.mcfunction,test2.mcfunction\"\n"
        );
        execute = function (self,args,options)
            local arg1 = args[1];
            if (not arg1) or (arg1 == "") then
                log("arg #1 was not given; this command requires arg #1, more information for rebuild help build");
                return;
            end
            for path in arg1:gmatch("[^,]+") do
                log("build : ",path);
                local file = io.open(path);
                local str = file:read("*a");
                file:close();
                local filew = io.open(path,"w+");

                local len,i = 0,1;
                str:gsub("[^\n]+",function() len = len + 1 end)
                str:gsub("[^\n]+",function(line)
                    filew:write(compileCmd(line) .. "\n");
                    i = i + 1;
                end);

                filew:close();
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
                log("arg #1 was not given; this command requires arg #1, more information for rebuild help command");
            else
                log(compileCmd(command));
            end
        end;
    };
};

commands.help.execute = function (self,args,options)
    if args[1] then
    else
        log("rebuild your minecraft 1.16's mcfunction to 1.17's mcfunction\nthis program replace 'replaceitem' to 'item', it will work same with old version!\nVERSION : 1.1\n\nlist of all commands:\n")
        for _,c in pairs(commands) do
            log(c.help);
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
    log(("Please set command to use this program!\nuse : rebuild <Command> [args/options]\nenter 'rebuild help' for more information!"):format(tostring(commandName)));
    return;
elseif not thisCommand then
    log(("Command '%s' not found!"):format(tostring(commandName)));
    return;
end
local pass,msg = pcall(thisCommand.execute,thisCommand,commandArg(args,thisCommand.options));
if not pass then
    log(("an error occured on running command, enter 'rebuild help %s' for more information"):format(commandName));
    log(msg);
    return;
end