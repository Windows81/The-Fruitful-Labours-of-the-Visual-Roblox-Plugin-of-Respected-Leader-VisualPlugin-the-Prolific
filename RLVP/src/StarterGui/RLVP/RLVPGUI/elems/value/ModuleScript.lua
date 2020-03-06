return{
	display=function(n)
		if'number'~=typeof(n)then return end
		local l=3-math.floor(math.log10(math.max(1,math.abs(n))))..'f'
		script.Parent.ValueFrame.TextLabel.Text=string.format('%.'..l,n)
	end,
}