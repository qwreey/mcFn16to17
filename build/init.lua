-- mcLibs 와 mcCommands 를 한 모듈로 부를 수 있게 핸들러를 빌드함 (=> app/gen/*.lua)

local buildPack = require "buildPack";

buildPack("app/mcLibs","app/gen/mcLibs.lua","mcLibs/");
buildPack("app/mcCommands","app/gen/mcCommands.lua","mcCommands/");

os.execute "build\\bin\\luvi.exe app -o ./rebuild.exe";