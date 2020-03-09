local SIZE_MIN = .05
local main = script.Parent.Parent
local plugin = main.Plugin.Value

function getMesh(p) return p:findFirstChildWhichIsA 'DataModelMesh' end

function getSize(p)
	local mesh = getMesh(p)
	local scale = mesh and mesh.Scale or Vector3.new(1, 1, 1)
	return scale * p.Size
end

function needsMesh(s)
	for i, a in next, Enum.Axis:GetEnumItems() do
		if math.abs(s[a.Name]) < SIZE_MIN then return true end
	end
end

function canMakeMesh(p)
	local cn = p.ClassName
	if cn == 'Part' then
		return true

	elseif cn == 'WedgePart' then
		return true

	elseif cn == 'CornerWedgePart' then
		return true
	end
end

function makeMesh(p)
	local cn, m = p.ClassName, nil

	if cn == 'Part' then
		local s = p.Shape.Name
		if s == 'Block' then
			m = Instance.new 'BlockMesh'
		elseif s == 'Cylinder' then
			m = Instance.new 'CylinderMesh'
		elseif s == 'Ball' then
			m = Instance.new 'SpecialMesh'
			m.MeshType = 'Sphere'
		end

	elseif cn == 'WedgePart' then
		m = Instance.new 'SpecialMesh'
		m.MeshType = 'Wedge'

	elseif cn == 'CornerWedgePart' then
		m = Instance.new 'SpecialMesh'
		m.MeshType = 'FileMesh'
		m.MeshId = 699163800
	end

	if m then
		m.Parent = p
		return m
	end
end

function scalePart(s)
	local t = {}
	for i, a in next, Enum.Axis:GetEnumItems() do
		t[i] = math.max(SIZE_MIN, math.abs(s[a.Name]))
	end
	return Vector3.new(unpack(t))
end

function scaleMesh(s)
	local t = {}
	for i, a in next, Enum.Axis:GetEnumItems() do
		t[i] = math.min(1, math.abs(s[a.Name]) / SIZE_MIN)
	end
	return Vector3.new(unpack(t))
end

function resize(p, f, d)
	local deltaV3 = f * f * d
	local newSize = getSize(p) + deltaV3
	p.Size = scalePart(newSize)

	local mesh = getMesh(p)
	if needsMesh(newSize) then
		if not mesh then mesh = makeMesh(p) end
		if mesh then mesh.Scale = scaleMesh(newSize) end

	else
		if mesh then mesh:Destroy() end
	end
end

function limit(p, tags, f)
	local face = Vector3.FromNormalId(f)
	local d = (face * getSize(p)).magnitude
	local ret = (canMakeMesh(p) and 0 or SIZE_MIN) - d
	return ret, nil
end

return {
	[{'resize', 'face'}] = {
		drag = function(isSet, p, tags, f, cD, pD)
			local d, face = cD - pD, Vector3.FromNormalId(f)
			local move = CFrame.new(face * d / 2)
			p.CFrame = p.CFrame * move
			resize(p, face, d)
		end,
		limit = limit,
		waypoint = 'Resize'
	},

	[{'resize', 'both'}] = {
		drag = function(isSet, p, tags, f, cD, pD)
			local d, face = cD - pD, Vector3.FromNormalId(f)
			resize(p, face, d)
		end,
		limit = limit,
		waypoint = 'Resize'
	}
}
