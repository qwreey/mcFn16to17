local export = {};

local function pop(str)
    
    return;
end

-- 1.16 의 리플레이스 아이템을 1.17 의 item 커맨드로 다시 작성시킴
function export:comp(str)
    local rt = "execute";
    do
        local len,start = str:match("^( -([^ ]+))");
        str = str:sub(#len + 1,-1);

        if not start == "execute" then
            return str;
        end
    end

    while true do
        local com = str:match("( *[^ ]+)");
        if not com then
            break;
        end
        str = str:sub(#com+1,-1);
        com = com:match("^ *(.+)$"); -- 스타트포인터 / 띄어쓰기* / content+ / 엔드포인터

        if com == "at" then -- 엣 포인터자
            local sel,_,endp = self.mcLibs.selector(str);
            str = str:sub(endp+1,-1);
            rt = rt .. " at " .. sel;
        elseif com == "as" then
            local sel,_,endp = self.mcLibs.selector(str);
            str = str:sub(endp+1,-1);
            rt = rt .. " as " .. sel;
        elseif com == "run" then
            return rt .. " run " .. self.compileCmd(str:match("^ *(.+)$"));
        elseif com == "run" then
            return rt .. " run " .. self.compileCmd(str:match("^ *(.+)$"));
        else
            rt = rt .. " " .. com;
        end
    end
    return rt;
end

return export;