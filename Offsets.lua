local Source = "https://raw.githubusercontent.com/nrrkqq/SevereHelper/refs/heads/main/Offsets.hpp"

local Offsets = {}

local function ParseSource(Response)
	local Stack = {}
	local Current = nil

	local function Resolve()
		for Index = #Stack, 1, -1 do
			if Stack[Index]:lower() ~= "offsets" then
				return Stack[Index]
			end
		end
		return nil
	end

	for Line in Response:gmatch("[^\r\n]+") do
		local Namespace = Line:match("^%s*namespace%s+(%w+)%s*{")
		if Namespace then
			table.insert(Stack, Namespace)
			Current = Resolve()
			if Current then
				Offsets[Current] = Offsets[Current] or {}
			end
		end

		if Current then
			local Name, Hex = Line:match("inline%s+constexpr%s+uintptr_t%s+(%w+)%s*=%s*(0x%x+)")
			if Name and Hex and Offsets[Current][Name] == nil then
				Offsets[Current][Name] = tonumber(Hex)
			end
		end

		if Line:match("^%s*}") then
			table.remove(Stack)
			Current = Resolve()
		end
	end
end

local _, Response = pcall(function()
	return game:HttpGet(Source)
end)

ParseSource(Response)

return Offsets
