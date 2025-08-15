local xplr = xplr

local function clamp(min_, val, max_)
	return math.max(min_, math.min(max_, val))
end

local function round(val)
	local floor = math.floor(val)
	if val - floor < 0.5 then
		return floor
	else
		return floor + 1
	end
end

local function curve_func(percent)
	-- I know that these look like magic numbers.  That's because they are.
	-- according to ansi standard, the 255 color code is white, and 232 is black.
	return 232 + round(23 * percent)
end

local start_time = os.time()

local function time_curve(secs)
	return (secs - start_time) / (os.time() - start_time)
end

local function setup(args)
	args = args or {}

	local curve_func_ = args.color_func or curve_func
	local time_curve_ = args.time_curve or time_curve
	local absolutes = {
		round(curve_func_(1.0)),
		round(curve_func_(0.0))
	}
	local format = args.format or "%a %b %d %X %Y"
	local length = args.length or 24
	local unedited_transparent = args.unedited_transparent or 0.04
	local column = args.column or 5

	xplr.config.general.table.col_widths[column] = { Length = length }


	local foreback = string.char(27) .. '[38;5;%d;48;5;%dm'
	local only_fore = string.char(27) .. '[38;5;%dm'

	xplr.fn.builtin.fmt_general_table_row_cols_4 = function(m)
		local secs = m.last_modified / 1000000000
		local str = tostring(os.date(format, secs))
		-- 1.0 = has been modified recently
		-- 0.0 = has not been modified since startup
		local percent = clamp(0, time_curve_(secs), 1)
		local fore = absolutes[1 + round(percent)]
		if percent < unedited_transparent then
			return only_fore:format(fore) .. str .. "\x1b[0m"
		end
		local back = 232 + round(curve_func_(percent))
		return foreback:format(fore, back) .. str .. "\x1b[0m"
	end
end

return {
	setup = setup
}
