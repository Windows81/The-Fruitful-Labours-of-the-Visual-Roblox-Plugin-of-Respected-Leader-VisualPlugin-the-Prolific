local tInfo=TweenInfo.new(.2)
return{
	wTime=tInfo.Time+tInfo.DelayTime,tInfo=tInfo,
	tween=function(o,p)local t=game.TweenService:Create(o,tInfo,p)t:Play()return t end,
	apply=function(o,p)for i,pr in next,p do o[i]=pr end end,
}