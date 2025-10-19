--[[
    Services
    Naming convention: Ser_???
]]

--[[
    Modules
    Naming convention: ???Module
]]

local TextHelper = {}

--[[
    Tables
    Naming convention: Tab_???
]]
local SensitiveWords = {
	-- Profanity and Vulgarity
	"fuck",
	"ass",
	"cunt",
	"bitch",
	"shit",
	"asshole",
	"pussy",
	"penis",
	"vagina",
	"testicle", -- Your original list
	"damn",
	"hell",
	"bastard",
	"dick",
	"cock",
	"prick",
	"twat",
	"fart",
	"tits",
	"boob",
	"bollocks",
	"wank",
	"piss",
	"arse",
	"shag",
	"screw",
	"bugger",
	"crap",
	"douche",
	"jerk",
	"ss",

	-- Sexual Terms and Innuendos
	"slut",
	"whore",
	"skank",
	"cum",
	"jizz",
	"semen",
	"clit",
	"balls",
	"boner",
	"erection",
	"horny",
	"bang",
	"hump",
	"blowjob",
	"rimjob",
	"fingering",
	"masturbate",
	"orgasm",
	"sex",
	"nude",

	-- Slurs and Hate Speech (Broadly Offensive)
	"nigger",
	"fag",
	"faggot",
	"dyke",
	"tranny",
	"chink",
	"spic",
	"kike",
	"gook",
	"wetback",
	"retard",
	"cripple",
	"midget",
	"paki",
	"coon",
	"jap",
	"slope",
	"towelhead",
	"raghead",

	-- Drugs and Alcohol
	"weed",
	"pot",
	"coke",
	"crack",
	"meth",
	"heroin",
	"stoned",
	"high",
	"drunk",
	"booze",
	"lsd",
	"ecstasy",
	"smack",
	"dope",
	"bong",
	"hash",
	"kush",

	-- Violence and Threats
	"kill",
	"murder",
	"die",
	"stab",
	"shoot",
	"rape",
	"molest",
	"bomb",
	"gore",

	-- Harassment and Insults
	"loser",
	"idiot",
	"moron",
	"dumbass",
	"fatass",
	"suck",
	"noob",
	"trash",
	"lame",
	"freak",
}

--[[
    References & Parameters
]]

--[[
    Functions
]]

local function IsFontFamily(text)
	local pattern = "^rbxasset://fonts/families/[^/]+%.json$"
	return string.match(text, pattern) ~= nil
end

--- Return the string in bold
---@param str string A string to be Bold
---@return string The Bold string
function TextHelper.Bold(str)
	return "<b>" .. str .. "</b>"
end

--- Return the string in italics
---@param str string A string to be italicized
---@return string The italicized string
function TextHelper.Italicized(str)
	return "<i>" .. str .. "</i>"
end

--- Return the string in underline
---@param str string A string to be underlined
---@return string The underlined string
function TextHelper.Underlined(str)
	return "<u>" .. str .. "</u>"
end

--- Return the string in strikethrough
---@param str string A string to be strikethrough
---@return string The strikethrough string
function TextHelper.Strikethrough(str)
	return "<s>" .. str .. "</s>"
end

--- Return the string in color
---@param str string A string to be colored
---@param color string The color of the string
---@return string The colored string
function TextHelper.Colored(str, color)
	local R = math.floor(color.R * 255)
	local G = math.floor(color.G * 255)
	local B = math.floor(color.B * 255)
	color = "rgb(" .. R .. "," .. G .. "," .. B .. ")"

	return '<font color="' .. color .. '">' .. str .. "</font>"
end

--- Return the string in a certain size
---@param str string A string to be sized
---@param size number The size of the string
---@return string The sized string
function TextHelper.Sized(str, size)
	return '<font size="' .. size .. '">' .. str .. "</font>"
end

--- Return the string in a certain font face
---@param str string A string to be set in a certain font face
---@param fontFace string The font of the string
---@return string The sized string
function TextHelper.FontFaced(str, fontFace)
	return '<font face="' .. fontFace .. '">' .. str .. "</font>"
end

--- Return the string in a certain font family
---@param str string A string to be set in a certain font family
---@param fontFamily string The font of the string
---@return string The sized string
function TextHelper.FontFamily(str, fontFamily)
	if not IsFontFamily(fontFamily) then
		-- warn("FontFamily: " .. fontFamily .. " is not a valid font family")
		return str
	end

	return '<font family="' .. fontFamily .. '">' .. str .. "</font>"
end

--- Return the string in a certain font weight
---@param str string A string to be set in a certain font weight
---@param fontWeight string The font of the string
---@return string The sized string
function TextHelper.FontWeight(str, fontWeight)
	return '<font weight="' .. fontWeight .. '">' .. str .. "</font>"
end

--- Return the string with stroke
---@param str string A string to be stroked
---@param thickness number The thickness of the stroke
---@param color string The color of the stroke
---@param transparency number The transparency of the stroke
---@return string The stroked string
function TextHelper.Stroked(str, thickness, color, transparency)
	local R = math.floor(color.R * 255)
	local G = math.floor(color.G * 255)
	local B = math.floor(color.B * 255)
	color = "rgb(" .. R .. "," .. G .. "," .. B .. ")"

	return '<stroke color="'
		.. color
		.. '" thickness="'
		.. thickness
		.. '" transparency="'
		.. transparency
		.. '">'
		.. str
		.. "</stroke>"
end

--- Return the string with transparency
---@param str string A string to be transparent
---@param transparency number The transparency of the string
---@return string The transparent string
function TextHelper.Transparency(str, transparency)
	return '<font transparency="' .. transparency .. '">' .. str .. "</t>"
end

--- Return a string that divide the string into part when
---@param str any
---@return any
function TextHelper.CamelStyleStringSplit(str)
	return str:gsub("([A-Z])", " %1"):sub(2)
end

--- Removes all characters from the string that are not alphanumeric (0-9, A-Z, a-z)
---@param str string The string to remove invalid characters from
---@return string _ The string with all non-alphanumeric characters removed
function TextHelper.RemoveSpecialCharacters(str)
	return str:gsub("[^0-9A-Za-z ]", "") -- This line uses a pattern to match any character that is not alphanumeric and replaces it with an empty string, effectively removing it
end

function TextHelper.GetWordsWithoutSpecialChar(str)
	if string.gsub(str, "[ ]", "") == "" then
		return nil
	end
	-- 先去除特殊符号，只保留字母、数字和空格，并将字母转换为小写
	local cleanStr = str:gsub("[^%w%s]", ""):lower()

	-- 使用空格分割字符串
	local words = {}
	for word in cleanStr:gmatch("%S+") do
		if not table.find(words, word) then
			table.insert(words, word)
		end
	end

	return words
end

-- New function to remove spaces and special characters
function TextHelper.StripNonAlphanumeric(text)
	-- Replace anything that's not a letter or number with an empty string
	return text:gsub("[^%w]", "")
end

--- Precompile patterns into a lookup table for efficiency
---@param text any
---@return boolean
function TextHelper.CensorImproperWords(text)
	-- Convert the input text to lowercase to ensure case-insensitive comparison
	text = text:lower()

	-- Remove spaces and non-alphanumeric characters from the text to simplify the comparison
	text = TextHelper.StripNonAlphanumeric(text)

	-- Iterate through the list of sensitive words to check if any are present in the text
	for _, word in SensitiveWords do
		-- Use string.gmatch to search for the word in the text
		if string.gmatch(text, word)() then
			-- If a sensitive word is found, return false indicating the text is not suitable
			return false
		end
	end

	-- If no sensitive words are found, return true indicating the text is suitable
	return true
end

--- Function to add commas as thousand separators
---@param number number The number
---@return string The number with commas
function TextHelper.FormatNumberWithCommas(number)
	-- Convert number to string
	local formatted = tostring(number)
	-- Use pattern matching to insert commas every three digits from the right
	formatted = formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	-- Remove leading comma if it exists
	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end
	return formatted
end

--- Function to convert a string with commas back to a number
---@param str string The string with commas
---@return number The number
function TextHelper.ParseNumberWithCommas(str)
	str = string.gsub(str, ",", "")

	-- Remove commas and convert to number
	return tonumber(str)
end

--- Convert a number to a compact form (e.g., 1000 -> 1k)
---@param num number
---@return string
function TextHelper.ShortenNumber(num)
	if type(num) ~= "number" then
		return tostring(num)
	end

	local absNum = math.abs(num)
	if absNum < 1000 then
		if num == math.floor(num) then
			return tostring(num)
		else
			local s = string.format("%.2f", num)
			s = s:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
			return s
		end
	end

	local suffixes = { "", "k", "m", "b", "t", "qa", "qi", "sx", "sp", "oc", "no", "dc" }
	local idx = 1
	local val = num

	while math.abs(val) >= 1000 and idx < #suffixes do
		val = val / 1000
		idx += 1
	end

	local rounded = math.floor(val * 10 + 0.5) / 10
	if math.abs(rounded) >= 1000 and idx < #suffixes then
		rounded = rounded / 1000
		idx += 1
	end

	local formatted = string.format("%.1f", rounded):gsub("%.0$", "")
	return formatted .. suffixes[idx]
end

return TextHelper
