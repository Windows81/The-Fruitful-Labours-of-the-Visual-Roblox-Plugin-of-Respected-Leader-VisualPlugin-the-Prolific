return{
	order=function(w,...)
		local t,done={...},nil
		spawn(function()
			local l=#t
			for i=1,l do
				t[i]:Wait()
			end
			done=true
		end)
		wait(w)
		return done
	end,
}