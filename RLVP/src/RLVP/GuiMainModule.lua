local gui,t=script.Parent.RLVPGUI,{}
return{
	show=function()gui.Parent=game.CoreGui end,
	hide=function()gui.Parent=script end,
	get=function(o)return gui[o] end,
	add=function(o)t[o],o.Parent=o,gui end,
	remove=function(o)t[o],o.Parent=nil,nil end
}