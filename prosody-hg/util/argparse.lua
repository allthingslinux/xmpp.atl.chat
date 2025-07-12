local function parse(arg, config)
	local short_params = config and config.short_params or {};
	local value_params = config and config.value_params or {};
	local array_params = config and config.array_params or {};
	local bool_params = config and (config.bool_params or config.kv_params) or {}; -- COMPAT: kv_params in 13.0 and earlier
	local strict = config and config.strict;
	local stop_on_positional = not config or config.stop_on_positional ~= false;

	local parsed_opts = {};

	if #arg == 0 then
		return parsed_opts;
	end
	while true do
		local raw_param = arg[1];
		if not raw_param then
			break;
		end

		local prefix = raw_param:match("^%-%-?");
		if not prefix and stop_on_positional then
			break;
		elseif prefix == "--" and raw_param == "--" then
			table.remove(arg, 1);
			break;
		end

		if prefix then
			local param = table.remove(arg, 1):sub(#prefix+1);
			if #param == 1 and short_params then
				param = short_params[param];
			end

			if not param then
				return nil, "param-not-found", raw_param;
			end

			local uparam = param:match("^[^=]*"):gsub("%-", "_");

			local param_k, param_v;
			if value_params[uparam] or array_params[uparam] then
				param_k = uparam;
				param_v = param:match("^=(.*)$", #uparam+1);
				if not param_v then
					param_v = table.remove(arg, 1);
					if not param_v then
						return nil, "missing-value", raw_param;
					end
				end
			else
				if param:match("^no%-") then
					param_k, param_v = param:sub(4), false;
				else
					param_k, param_v = param, true;
				end
				param_k = param_k:gsub("%-", "_");
				if strict and not bool_params[param_k] then
					return nil, "param-not-found", raw_param;
				end
			end
			if array_params[uparam] then
				if parsed_opts[param_k] then
					table.insert(parsed_opts[param_k], param_v);
				else
					parsed_opts[param_k] = { param_v };
				end
			else
				parsed_opts[param_k] = param_v;
			end
		elseif not stop_on_positional then
			table.insert(parsed_opts, table.remove(arg, 1));
		end
	end

	if stop_on_positional then
		for i = 1, #arg do
			parsed_opts[i] = arg[i];
		end
	end

	return parsed_opts;
end

return {
	parse = parse;
}
