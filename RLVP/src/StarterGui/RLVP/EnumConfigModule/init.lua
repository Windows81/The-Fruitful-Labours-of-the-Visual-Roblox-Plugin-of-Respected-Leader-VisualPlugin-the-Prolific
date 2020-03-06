local u=require(script.util)

return{
	debugLevel={
		value=2,
		check=function(v)
			local n=tonumber(v)
			return n and n%1==0 and n>=0 and n<=3
		end,
		format={'number',0},
	},
	resetShortcuts={
		value=true,
		check=u.isBool,
		format={'bool'},
	},
}