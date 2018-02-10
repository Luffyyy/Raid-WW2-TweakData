--Just run this code any way you can and wait for it to create the SavedTweakData.lua file in the root directory of the game
--this should, in theory, work with pd2 as well.

--Instead of returning Color(a * (r,g,b)).
function Color:__tostring()
	local argb = {self.a, self.r, self.g, self.b}
	for i, c in pairs(argb) do
		argb[i] = tostring(math.round_with_precision(c, 3))
	end
    if self.a ~= 1 then
        return string.format("Color(%s, %s, %s, %s)", argb[1], argb[2], argb[3], argb[4])
    else
        return string.format("Color(%s, %s, %s)", argb[2], argb[3], argb[4])
    end
end

--Making sure we don't get things like 1 = x or 1x = 1 which are not valid in lua.
local function correct_key(key)
	local t = type(key)
    if t == "number" then
        return '['..key..']'
    elseif t == "string" and (key:find("%(%)%.%%%+%-%*%?%[%^%$") or key:find("^%d")) then --if string starts with a digit or character except underscore
        return '["'..key..'"]'
	else
		--there are table keys for some reason
        return tostring(key)
    end
end

--Making sure we don't get invalid value, adds quotation marks to string or square brackets to multiline strings and etc.
local function correct_value(value)
	local t = type_name(value)
	if t == "string" then
		if value:find("\n") then
			return '[['..value..']]'			
		else
			return '"'..value..'"'
		end
	elseif t == "Idstring" then
		return tostring(value):gsub("@", "\"")
	elseif t == "Timer" then
		return "TimerObject"
	elseif t == "ChildTimer" then
		return "ChildTimerObject"
	else
        return tostring(value)
    end
end

--Open a file to dump all of the code to.
local file = io.open("SavedTweakData.lua", "w")

local function dump_table_to_file(tbl, key, tab)
	local first = tab == nil
	tab = tab or 0
	local tabs = string.rep('	', tab)
    local fixed = type(tbl) == "userdata" and getmetatable(tbl) or tbl or {}
	file:write((not first and "\n" or "") .. tabs .. correct_key(key) .. " = {")
    local vtabs = string.rep('	', tab+1)
	local has_values = false
	for k,v in pairs(fixed) do
		if k ~= "_reload_clbks" then
			local t = type(v)
			if t == "table" then
				dump_table_to_file(v, k, tab+1)
				has_values = true
			elseif t ~= "function" then
				file:write("\n" .. (string.format(vtabs.."%s = %s,", correct_key(k), correct_value(v))))
				has_values = true
			end
		end
	end
	if first then
		file:write("\n" .. tabs .. "}")
	else
		if has_values then
			file:write("\n" .. tabs.."},")
		else
			file:write("},")
		end
	end
end

dump_table_to_file(tweak_data, "tweak_data")
file:close()
log("Done!")