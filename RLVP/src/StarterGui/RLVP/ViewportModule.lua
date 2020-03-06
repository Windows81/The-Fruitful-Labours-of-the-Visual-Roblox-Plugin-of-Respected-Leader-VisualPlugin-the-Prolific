return{
	size=function()
		
		--Repeats until the camera can be accessed.
		local cam repeat cam=game.Workspace.CurrentCamera until cam
		
		--Returns the viewport size.
		return cam.ViewportSize
	end,
}