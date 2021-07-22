local export = {};

-- 1.16 의 리플레이스 아이템을 1.17 의 item 커맨드로 다시 작성시킴
function export:comp(str)
    -- 예 : replaceitem entity @a[tag=ItemRemove] weapon.offhand minecraft:air
    -- 우선 replaceitem 을 item replace 으로 변환함

    str = str:gsub("^ -replaceitem +","item replace "); -- replaceitem => item replace
    str = str:gsub(" +$",""); -- 뒷단 공백 없에기

    local count = str:match(" %d-$") or ''; -- 뒤에 있는 숫자 (갯수) 읽어오기
    str = str:sub(1,-#count - 1); -- 숫자부분 잘라 없엠

    local nbt = self.mcLibs.nbtReverse(str);
    str = str:sub(1,-#nbt-1); -- nbt 를 뺌
    str = str:gsub("[^ ]+$",function (this) -- 뒷단에서 하나 잘라서 (아이템 부분) with 을 붇임
        return "with " .. this;
    end);

    return str .. nbt .. count; -- 다시 nbt 랑 count 를 붇임
end

return export;