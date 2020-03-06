local main=script.Parent
local enumM=require(main.EnumModeModule)

local t={
	{'rotIncr','K','rotate incr.'},
	{'latIncr','k','lateral incr.'},
	{'activeTick1','m','primary tick'},
	{'activeTick2','M','secondary tick'},
	
	{'1',Enum.KeyCode.One,'submode #1'},
	{'2',Enum.KeyCode.Two,'submode #2'},
	{'3',Enum.KeyCode.Three,'submode #3'},
	{'4',Enum.KeyCode.Four,'submode #4'},
	{'5',Enum.KeyCode.Five,'submode #5'},
	{'6',Enum.KeyCode.Six,'submode #6'},
	{'7',Enum.KeyCode.Seven,'submode #7'},
	{'8',Enum.KeyCode.Eight,'submode #8'},
	{'9',Enum.KeyCode.Nine,'submode #9'},
	{'0',Enum.KeyCode.Zero,'submode #10'},
}

for i,m in next,enumM do t[#t+1]={m
[1],m[2],'mode: '..m[1]}end return t