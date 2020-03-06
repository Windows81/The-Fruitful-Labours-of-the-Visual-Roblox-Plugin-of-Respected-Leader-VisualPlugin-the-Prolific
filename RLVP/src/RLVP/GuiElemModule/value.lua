local main=script.Parent.Parent
local format=require(main.FormatModule)

function display(card,n)
	if not n then n=0 elseif'number'~=typeof(n)then return end
	card.card.ValueFrame.TextLabel.Text=format.numOutput(n)
end

return{
	init=display,
	display=display,
}