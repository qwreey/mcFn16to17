local export = {};

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
        elseif com == "as" then -- 에즈 셀렉터자
            local sel,_,endp = self.mcLibs.selector(str);
            str = str:sub(endp+1,-1);
            rt = rt .. " as " .. sel;
        elseif com == "positioned" then
            local nextM,nextN = str:match("( *([^ ]+) *)");
            if nextN == "as" then
                local sel,_,endp = self.mcLibs.selector(str);
                str = str:sub(endp+1,-1);
                rt = rt .. " positioned as " .. sel;
                --str = str:sub()
            else
                str = str:sub(#nextM + 1,-1);
                local posM,posN = str:match("( *([~%^%d%.]+ [~%^%d%.]+ [~%^%d%.]+) *)");
                str = str:sub(#posM + 1,-1);
                rt = rt .. " positioned " .. posN;
            end
        elseif com == "rotated" then
            local nextM,nextN = str:match("( *([^ ]+) *)");
            if nextN == "as" then
                local sel,_,endp = self.mcLibs.selector(str);
                str = str:sub(endp+1,-1);
                rt = rt .. " rotated as " .. sel;
                --str = str:sub()
            else
                str = str:sub(#nextM + 1,-1);
                local posM,posN = str:match("( *([~%^%d%.]+ [~%^%d%.]+) *)");
                str = str:sub(#posM + 1,-1);
                rt = rt .. " rotated " .. posN;
            end
        elseif com == "facing" then
            local nextM,nextN = str:match("( *([^ ]+) *)");
            if nextN == "entity" then
                local sel,_,endp = self.mcLibs.selector(str);
                str = str:sub(endp+1,-1);
                local toM,toN = str:match("( *([^ ]+) *)"); -- feet/eyes
                str = str:sub(#toM+1,-1);
                rt = rt .. " facing entity " .. sel .. " " .. toN;
            else
                str = str:sub(#nextM + 1,-1);
                local posM,posN = str:match("( *([~%^%d%.]+ [~%^%d%.]+ [~%^%d%.]+) *)");
                str = str:sub(#posM + 1,-1);
                rt = rt .. " facing " .. posN;
            end
        elseif com == "in" then
            local nextM,nextN = str:match("( *([^ ]+) *)");
            str = str:sub(#nextM + 1,-1);
            rt = rt .. " in " .. nextN;
        elseif com == "anchored" then
            local nextM,nextN = str:match("( *([^ ]+) *)");
            str = str:sub(#nextM + 1,-1);
            rt = rt .. " anchored " .. nextN;
        elseif com == "align" then
            local nextM,nextN = str:match("( *([^ ]+) *)");
            str = str:sub(#nextM + 1,-1);
            rt = rt .. " align " .. nextN;
        elseif com == "if" or com == "unless" then
            local nextM,nextN = str:match("( *([^ ]+) *)");
            str = str:sub(#nextM + 1,-1);
            local args = "";
            if nextN == "block" then
                local posM,posN = str:match("( *([~%^%d%.]+ [~%^%d%.]+ [~%^%d%.]+) *)");
                str = str:sub(#posM + 1,-1);
                args = args .. " " .. posN;
            elseif nextN == "blocks" then

            end
            rt = rt .. (" %s %s%s"):format(com,nextN,args);
        elseif com == "run" then -- 커맨드 익스커션
            return rt .. " run " .. self.compileCmd(str:match("^ *(.+)$"));
        else
            rt = rt .. " " .. com;
        end
    end
    return rt;
end

return export;