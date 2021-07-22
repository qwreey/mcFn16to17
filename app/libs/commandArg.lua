--- 커맨드라인 arg 분석기

local strSub = string.sub;
local tableInsert = table.insert;
return function (t,optionList)
    local option = {};
    local arg = {};
    local lastOpt;

    for i,this in ipairs(t) do
        if i >= 1 then
            if lastOpt then -- set option
                option[lastOpt] = this;
                lastOpt = nil;
            elseif strSub(this,1,1) == "-" then -- this = option
                local optName = optionList[this];
                if not optName then
                    error("option %s was not found, -h for see info");
                end
                option[optName] = true;
                lastOpt = optName;
            else
                tableInsert(arg,this);
            end
        end
    end
    return arg,option;
end;