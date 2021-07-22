-- @a[nbt={SelectedItem:{id:"minecraft:carrot_on_a_stick",tag:{CustomModelData:21001}}}] run tag @s add Hand
-- 다음과 같이 selector 로 시작하는 string 을 주면 selector 가 끝나는 지점의 좌표 (정확히 ] 가 완전히 닫히는 좌표) 를 던져줍니다

return function (str)
    local spos = str:find("@"); -- selector 의 start index 를 가져옵니다
    -- 중간에 r 이 들어가도, a 가 들어가도, s 가 들어가도 어차피 잘 작동하던 코드를 옮기는것이라면
    -- 별다른 손볼것이 없으니 중간은 만지지 않습니다
    if str:sub(spos+2,spos+2) == "[" then -- 만약 selector 의 구문이 열린 경우
        local state = 1; -- 열림 상태
        local strMode = false; -- 문자열
        local espMode = false; -- 이스캡
        for i = spos+3,#str do -- 각각 뜯어냄
            local this = str:sub(i,i); -- string array 에서 char 하나 때오기
            if strMode then -- 스탯이 str 모드이면
                if espMode then
                    if this == "\"" then -- str 모드 꺼짐
                        strMode = false;
                    elseif this == "\\" then -- 이스캐이프 문자
                        espMode = true;
                    end
                else
                    espMode = false; -- 이스캐이프 끄기
                end
            else
                if this == "\"" then -- str 모드 켜짐
                    strMode = true;
                elseif this == "[" then -- 열림 (확장)
                    state = state + 1;
                elseif this == "]" then -- 닫힘
                    state = state - 1;
                    if state == 0 then
                        return str:sub(spos,i),spos,i; -- 끝
                    end
                end
            end
        end
    else -- 안 열렸으면 그냥 구문이 끝남 (selector 가 2 글자로 끝남, 예 : @e)
        return str:sub(spos,spos+1),spos,spos + 1; -- @a 이면 a 까지의 좌표를 반환
    end
end;