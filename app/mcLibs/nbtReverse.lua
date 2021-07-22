-- 역행으로 nbt 태그를 읽음 (맨 뒤에 있는 nbt 읽음)
-- give @s stick{test:"test"}
-- 이런 태그 읽는 용으로 쓸 수 있음

return function (str)
    local nbt = ""; -- nbt,nbtLen init
    if str:sub(-1,-1) == "}" then -- nbt 가 있음이 확인됨
        nbt = "}";
        local stats = 1; -- 괄호 상태 (열림 닫힘)
        local instr = false; -- "" 안에 들어가 있는지 확인 (무시모드 켜기 - 끄기)
        local esp = false; -- 이스캐이프 모드인지 확인 (" 이스캐이프를 위해 사용되었는지 확인)
        for n = #str-1,1,-1 do -- 역행 읽기
            local this = str:sub(n,n); -- n 번째 char
            if instr then
                if (not esp) and this == "\"" then
                    instr = false;
                end
                if this == "\\" then;
                    esp = true;
                else
                    esp = false;
                end
            else
                if this == "}" then -- 맨 마지막으로 닫혔는가를 보고 앞에서 열림이 필요함을 stats 에 저장
                    stats = stats + 1; -- add stats
                elseif this == "{" then -- 태그 하나 빠져나감
                    stats = stats - 1; -- rm stats
                elseif this == "\"" then
                    instr = true;
                end
            end
            if stats == 0 then -- 다 빠져나옴
                nbt = str:sub(n,-1);
                break;
            end
        end
    end
    return nbt;
end;