local globals={}
local locals={}

return{
	bindGlobal=function(i,fF,lF)
		local gT={[true]={fF,lF}}
		for tb in next,locals do
			gT[tb]={
			tb.Focused:connect(fF),
			tb.FocusLost:connect(lF)}
		end
		globals[i]=gT
	end,
	
	bindTextBox=function(tb,fF,lF)
		local lT={}
		locals[tb]=lT
		if fF then lT[#lT+1]=tb.Focused:connect(fF)end
		if lF then lT[#lT+1]=tb.FocusLost:connect(lF)end
		for i,gT in next,globals do
			local f,l=unpack(gT[true])
			gT[tb]={
			tb.Focused:connect(f),
			tb.FocusLost:connect(l)}
		end
	end,
	
	unbindGlobal=function(i)
		for _,c in next,globals
		[i] do c:Disconnect()
		end globals[i]=nil
	end,
}