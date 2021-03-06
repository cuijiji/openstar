
local optl = require("optl")


local get_argsByName = optl.get_argsByName

local _action = get_argsByName("action")
local _host = get_argsByName("host")
local _id = get_argsByName("id")
local _value = get_argsByName("value")
local _value_type = get_argsByName("value_type")

local tmpdict = ngx.shared["host_dict"]



-- 用于host_dict操作接口  对ip列表进行增 删 改 查 操作

if _action == "add" then

	if _id == "state" then --- 添加host_Mod状态
		local host_state = tmpdict:get(_host)
		if host_state ~= nil then -- 已存在
			optl.sayHtml_ext({code="error",msg="host is existent"})
		end
		if _value ~= "on" then _value = "off" end
		host_state = _value
		local re = tmpdict:safe_add(_host,host_state,0)
		-- 非重复插入(lru不启用)
		optl.sayHtml_ext({code=re,id=_id,value=host_state})		
	end

	local host_state = tmpdict:get(_host)
	if host_state == nil then			
		optl.sayHtml_ext({code="error",msg="add host state first"})
	end
	
	if _value_type == "json" then
		_value = optl.stringTojson(_value)
		if type(_value) ~= "table" then
		optl.sayHtml_ext({code="error",msg="value to json error"})
		end
	end

	local host_mod = tmpdict:get(_host.."_HostMod")
	host_mod = optl.stringTojson(host_mod)

	local re
	if host_mod == nil then
		host_mod = {}
		table.insert(host_mod,_value)
		host_mod = optl.tableTojson(host_mod)
		re = tmpdict:safe_add(_host.."_HostMod",host_mod,0)
	else
		table.insert(host_mod,_value)
		host_mod = optl.tableTojson(host_mod)
		re = tmpdict:replace(_host.."_HostMod",host_mod)			
	end
	optl.sayHtml_ext({code=re,value=_value})
	
elseif _action == "del" then

	local host_state = tmpdict:get(_host)
	if host_state == nil then
		optl.sayHtml_ext({code="error",msg="host is Non-existent"})
	end

	local host_mod = tmpdict:get(_host.."_HostMod")
	host_mod = optl.stringTojson(host_mod) or {}

	_id = tonumber(_id)
	if _id == nil then
		optl.sayHtml_ext({code="error",msg="id is not number"})
	end

	local rr = table.remove(host_mod,_id)
	if rr == nil then
		optl.sayHtml_ext({code="error",msg="id is Non-existent"})
	else
		local re = tmpdict:replace(_host.."_HostMod",optl.tableTojson(host_mod))
		optl.sayHtml_ext({code=re,id=_id,value=rr})
	end

elseif _action == "set" then

	local host_state = tmpdict:get(_host)
	if host_state == nil then
		optl.sayHtml_ext({code="error",msg="host is Non-existent"})
	end

	if _id == "state" then
		if _value ~= "on" then _value = "off" end
		local re = tmpdict:replace(_host,_value)
		optl.sayHtml_ext({code=re,host=_host,state=_value})
	end

	_id = tonumber(_id)
	if _id == nil then
		optl.sayHtml_ext({code="error",msg="id is not number"})
	end

	if _value_type == "json" then
		_value = optl.stringTojson(_value)
		if type(_value) ~= "table" then
		optl.sayHtml_ext({code="error",msg="value to json error"})
		end
	end

	local host_mod = tmpdict:get(_host.."_HostMod")
	host_mod = optl.stringTojson(host_mod) or {}

	local old_host_id_mod = host_mod[_id]
	if old_host_id_mod == nil then
		optl.sayHtml_ext({code = "error",msg="id is Non-existent"})
	end

	host_mod[_id] = _value
	local re = tmpdict:replace(_host.."_HostMod",optl.tableTojson(host_mod))
	optl.sayHtml_ext({code=re,old_value=old_host_id_mod,new_value=_value})

elseif _action == "get" then

	if _host == "all" then
		local _tb,tb_all = tmpdict:get_keys(0),{}
		for i,v in ipairs(_tb) do
			tb_all[v] = tmpdict:get(v)
		end
		optl.sayHtml_ext(tb_all)
	elseif _host == "all_host" then
		local _tb,tb_all = tmpdict:get_keys(0),{}
		for i,v in ipairs(_tb) do
			local from , to = string.find(v, "_HostMod")
	        if from == nil then
	        	table.insert(tb_all,v)
	        end
		end
		optl.sayHtml_ext(tb_all)
	else
		local host_state = tmpdict:get(_host)
		if host_state == nil then
			optl.sayHtml_ext({code="error",msg="host is Non-existent"})
		end

		if _id == "" then
			local host_mod = tmpdict:get(_host.."_HostMod")
			host_mod = optl.stringTojson(host_mod)
			host_mod.state = host_state
			optl.sayHtml_ext(host_mod)
		elseif _id == "count_id" then
			local host_mod = tmpdict:get(_host.."_HostMod")
			host_mod = optl.stringTojson(host_mod)
			local cnt = table.maxn(host_mod)
			optl.sayHtml_ext({state=host_state,count=cnt})
		else
			local host_mod = tmpdict:get(_host.."_HostMod")
			host_mod = optl.stringTojson(host_mod)
			_id = tonumber(_id)
			if _id == nil then
				optl.sayHtml_ext({code="error",msg="id is not number"})
			end
			optl.sayHtml_ext({state=host_state,id = _id,value = host_mod[_id]})
		end
	end
	
else
	optl.sayHtml_ext({code="error",msg="action is error"})
end

