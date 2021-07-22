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
                io.write("arg #1 was not given; this command requires arg #1, more information for rebuild help build\n");
                return;
            end
            for path in arg1:gmatch("[^,]+") do
                io.write("build : ",path,"\n");
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
            for _,str in ipairs(args) do
                command = command .. " " .. str;
            end
            if (not command) or command == "" then
                io.write("arg #1 was not given; this command requires arg #1, more information for rebuild help command\n");
            else
                io.write(tostring(compileCmd(command)),"\n");
            end
        end;
    };
};

commands.help.execute = function (self,args,options)
    if args[1] then
    else
        io.write("rebuild your minecraft 1.16's mcfunction to 1.17's mcfunction\nthis program replace 'replaceitem' to 'item', it will work same with old version!\nVERSION : 1.1\n\nlist of all commands:\n\n")
        for _,c in pairs(commands) do
            io.write(c.help,"\n");
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
    io.write(("Please set command to use this program!\nuse : rebuild <Command> [args/options]\nenter 'rebuild help' for more information!\n"):format(tostring(commandName)));
    return;
elseif not thisCommand then
    io.write(("Command '%s' not found!\n"):format(tostring(commandName)));
    return;
end
local pass,msg = pcall(thisCommand.execute,thisCommand,commandArg(args,thisCommand.options));
if not pass then
    io.write(("an error occured on running command, enter 'rebuild help %s' for more information\n"):format(commandName));
    io.write(msg,"\n");
    return;
end