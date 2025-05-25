-- Long Lua file for testing purposes.
-- This script is syntactically valid, has no external dependencies,
-- and includes a mix of constructs to ensure it's parseable by Tree-sitter.

-- Utility functions
local function factorial(n)
	if n == 0 then
		return 1
	end
	return n * factorial(n - 1)
end

local function fib(n)
	if n < 2 then
		return n
	end
	return fib(n - 1) + fib(n - 2)
end

local function is_prime(n)
	if n < 2 then
		return false
	end
	for i = 2, math.floor(math.sqrt(n)) do
		if n % i == 0 then
			return false
		end
	end
	return true
end

-- Math utilities
local function gcd(a, b)
	while b ~= 0 do
		a, b = b, a % b
	end
	return a
end

local function lcm(a, b) return (a * b) // gcd(a, b) end

-- Coroutine example
local function coroutine_counter(max)
	return coroutine.create(function()
		for i = 1, max do
			coroutine.yield(i)
		end
	end)
end

local co = coroutine_counter(100)
while coroutine.status(co) ~= "dead" do
	local _, value = coroutine.resume(co)
end

-- Metatables and operator overloading
local Vector = {}
Vector.__index = Vector

function Vector.new(x, y) return setmetatable({ x = x, y = y }, Vector) end

function Vector.__add(a, b) return Vector.new(a.x + b.x, a.y + b.y) end

function Vector:__tostring() return "(" .. self.x .. ", " .. self.y .. ")" end

local v1 = Vector.new(1, 2)
local v2 = Vector.new(3, 4)
local v3 = v1 + v2

-- Table with self-reference and function fields
local node = {}
node.self = node
node.compute = function(x) return x * 42 end

-- Boolean expression stress test
local function logic(a, b, c) return not (a and b) or (c and not (a or c)) end

-- Closure example
local function make_counter()
	local count = 0
	return function()
		count = count + 1
		return count
	end
end

local counter = make_counter()
for _ = 1, 100 do
	counter()
end

-- Upvalue inspection
local function inspect(f)
	local i = 1
	while true do
		local name, val = debug.getupvalue(f, i)
		if not name then
			break
		end
		i = i + 1
	end
end
inspect(counter)

-- Lua pattern matching
local matches = {}
for i = 1, 100 do
	local s = "line: " .. i
	table.insert(matches, string.match(s, "line: (%d+)") or "none")
end

-- Using do-end blocks
local function scoped()
	local x = 10
	do
		local x = 20
		x = x + 1
	end
	return x
end

-- Repeat-until loop example
local function wait_until_even(n)
	repeat
		n = n + 1
	until n % 2 == 0
	return n
end

-- Generic for loop over pairs
local sum = 0
local t = { a = 1, b = 2, c = 3 }
for k, v in pairs(t) do
	sum = sum + v
end

-- Using multiple return values
local function swap(a, b) return b, a end
local a, b = swap(1, 2)

-- Weak table usage
local weak_meta = { __mode = "v" }
local weak_table = setmetatable({}, weak_meta)
weak_table[1] = { value = 42 }

-- Function with variable number of arguments
local function varargs(...)
	local args = { ... }
	local total = 0
	for i = 1, #args do
		total = total + args[i]
	end
	return total
end
varargs(1, 2, 3, 4, 5)

-- Function environments (Lua 5.1)
if _VERSION == "Lua 5.1" then
	local env = { print = print, x = 99 }
	setfenv(1, env)
end

-- More complex table manipulations and nested structures
local function create_nested_table(depth, width)
	local function build(current_depth)
		if current_depth > depth then
			return nil
		end
		local tbl = {}
		for i = 1, width do
			tbl["key" .. i] = build(current_depth + 1) or "value" .. current_depth .. "-" .. i
		end
		return tbl
	end
	return build(1)
end

local complex_data_structure = create_nested_table(5, 3)

-- Object-oriented style programming with Lua tables
local Person = {}
Person.__index = Person

function Person:new(name, age)
	local o = { name = name, age = age }
	setmetatable(o, self)
	return o
end

function Person:greet() return "Hello, my name is " .. self.name .. " and I am " .. self.age .. " years old." end

local Employee = {}
Employee.__index = Employee
setmetatable(Employee, Person) -- Inherit from Person

function Employee:new(name, age, position)
	local o = Person.new(self, name, age) -- Call parent constructor
	o.position = position
	setmetatable(o, self)
	return o
end

function Employee:work() return self.name .. " is working as a " .. self.position .. "." end

local person1 = Person:new("Alice", 30)
local employee1 = Employee:new("Bob", 45, "Software Engineer")

-- Error handling with pcall and xpcall
local function risky_operation(should_error)
	if should_error then
		error("Something went wrong!")
	else
		return "Operation successful!"
	end
end

local success, result = pcall(risky_operation, false)
local success_err, result_err = pcall(risky_operation, true)

local function error_handler(msg)
	print("Custom error handler caught:", msg)
	return 1 -- return value indicates success to xpcall
end

local xp_success, xp_result = xpcall(risky_operation, error_handler, true)

-- Modules and package system (simplified)
local my_module = {}

function my_module.add(a, b) return a + b end

function my_module.subtract(a, b) return a - b end

-- Control flow complexity: deeply nested if/else and loops
local function complex_flow(x, y, z)
	if x > 0 then
		if y > 0 then
			for i = 1, z do
				if i % 2 == 0 then
					-- Do something for even numbers
					local temp = x * y * i
				else
					-- Do something for odd numbers
					local temp = x + y + i
				end
			end
		elseif y < 0 then
			while z > 0 do
				z = z - 1
				if z % 3 == 0 then
					-- More logic
					local another_temp = x - y - z
				end
			end
		else
			-- Handle y == 0
			local result = x * z
		end
	else
		-- Handle x <= 0
		local result = y + z
	end
end

complex_flow(10, 5, 20)
complex_flow(-1, 2, 3)

-- Extensive table creation and manipulation
local large_table = {}
for i = 1, 500 do
	large_table[i] = {
		id = i,
		name = "Item " .. i,
		status = (i % 2 == 0) and "active" or "inactive",
		data = {
			value1 = math.random(1, 100),
			value2 = math.random(1, 100),
			nested = {
				sub_value = math.random(1, 10),
				array_data = {},
			},
		},
	}
	for j = 1, 10 do
		table.insert(large_table[i].data.nested.array_data, math.random(100, 200))
	end
end

-- Simulating a simple state machine
local function create_state_machine()
	local state = "idle"
	local transitions = {
		idle = {
			start = "running",
			reset = "idle",
		},
		running = {
			pause = "paused",
			stop = "idle",
		},
		paused = {
			resume = "running",
			stop = "idle",
		},
	}

	local function dispatch(event)
		local next_state = transitions[state] and transitions[state][event]
		if next_state then
			state = next_state
		end
		return state
	end

	return {
		get_state = function() return state end,
		dispatch = dispatch,
	}
end

local sm = create_state_machine()
sm.dispatch("start")
sm.dispatch("pause")
sm.dispatch("resume")
sm.dispatch("stop")

-- Deeply nested function calls and recursion for testing call stack parsing
local function deep_recursion(n)
	if n == 0 then
		return 1
	end
	return deep_recursion(n - 1) + 1
end

deep_recursion(100)

-- More complex metatable example for custom object behavior
local ReadOnlyTable = {}
ReadOnlyTable.__index = ReadOnlyTable

function ReadOnlyTable.new(data)
	local o = setmetatable({}, ReadOnlyTable)
	for k, v in pairs(data) do
		rawset(o, k, v) -- Use rawset to bypass __newindex
	end
	return o
end

function ReadOnlyTable.__newindex(table, key, value) error("Attempt to modify a read-only table: " .. key, 2) end

local my_ro_table = ReadOnlyTable.new({ name = "immutable", value = 123 })
-- my_ro_table.value = 456 -- This would cause an error

-- Simulation of a game loop or event handling
local function simulate(steps)
	local entities = {}
	for i = 1, 10 do
		table.insert(entities, { x = i, y = i, dx = math.random() * 2 - 1, dy = math.random() * 2 - 1 })
	end

	for step = 1, steps do
		-- Update entity positions
		for _, entity in ipairs(entities) do
			entity.x = entity.x + entity.dx
			entity.y = entity.y + entity.dy

			-- Simple boundary check
			if entity.x < 0 or entity.x > 100 then
				entity.dx = -entity.dx
			end
			if entity.y < 0 or entity.y > 100 then
				entity.dy = -entity.dy
			end
		end

		-- Process interactions (placeholder)
		if step % 10 == 0 then
			-- print("Step", step, ": Entities updated.")
		end
	end
end
simulate(500)

-- More function definitions with various argument types and return values
local function calculate_area(shape_type, ...)
	if shape_type == "circle" then
		local radius = select(1, ...)
		return math.pi * radius ^ 2
	elseif shape_type == "rectangle" then
		local width, height = select(1, ...), select(2, ...)
		return width * height
	elseif shape_type == "triangle" then
		local base, height = select(1, ...), select(2, ...)
		return 0.5 * base * height
	else
		error("Unknown shape type")
	end
end

calculate_area("circle", 5)
calculate_area("rectangle", 10, 20)

-- Generating a complex, deep table structure for memory stress
local deep_table = {}
local current = deep_table
for i = 1, 100 do
	current.next = { level = i, data = {} }
	for j = 1, 5 do
		current.next.data["item" .. j] = math.random(1000)
	end
	current = current.next
end

-- Simulating log generation with various levels
local function generate_logs(count)
	local log_levels = { "INFO", "WARN", "ERROR", "DEBUG" }
	for i = 1, count do
		local level_idx = (i % #log_levels) + 1
		local level = log_levels[level_idx]
		local message = string.format("[%s] This is log message %d, timestamp %d.", level, i, os.time())
		-- print(message) -- Commented out to avoid excessive console output during test
	end
end
generate_logs(1000)

-- Another recursive function for file system like tree creation
local function create_fs_tree(max_depth, current_depth)
	current_depth = current_depth or 0
	if current_depth >= max_depth then
		return nil
	end

	local node = {
		name = "dir" .. current_depth .. "_" .. math.random(100),
		type = "directory",
		children = {},
	}

	local num_children = math.random(2, 5)
	for i = 1, num_children do
		if math.random() > 0.7 and current_depth < max_depth - 1 then
			table.insert(node.children, create_fs_tree(max_depth, current_depth + 1))
		else
			table.insert(node.children, { name = "file" .. current_depth .. "_" .. i .. ".txt", type = "file", size = math.random(10, 1000) })
		end
	end
	return node
end

local fs_tree = create_fs_tree(4)

-- ### START OF ADDED CONTENT FOR EXTREME LENGTH ###

-- More complex "class" definitions and inheritance chains
local Shape = {}
Shape.__index = Shape

function Shape:new(x, y)
	local o = { x = x, y = y }
	setmetatable(o, self)
	return o
end

function Shape:move(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end

function Shape:get_position() return self.x, self.y end

local Circle = {}
Circle.__index = Circle
setmetatable(Circle, Shape)

function Circle:new(x, y, radius)
	local o = Shape.new(self, x, y)
	o.radius = radius
	setmetatable(o, self)
	return o
end

function Circle:get_area() return math.pi * self.radius ^ 2 end

local Rectangle = {}
Rectangle.__index = Rectangle
setmetatable(Rectangle, Shape)

function Rectangle:new(x, y, width, height)
	local o = Shape.new(self, x, y)
	o.width = width
	o.height = height
	setmetatable(o, self)
	return o
end

function Rectangle:get_area() return self.width * self.height end

local Square = {}
Square.__index = Square
setmetatable(Square, Rectangle)

function Square:new(x, y, side)
	local o = Rectangle.new(self, x, y, side, side)
	setmetatable(o, self)
	return o
end

local circle_obj = Circle:new(0, 0, 10)
local rect_obj = Rectangle:new(10, 10, 20, 30)
local square_obj = Square:new(5, 5, 15)

circle_obj:move(1, 1)
rect_obj:move(-5, 0)
square_obj:move(0, 0)

-- Extensive loop structures and data processing
local processed_data_set = {}
local data_points_count = 2000
for i = 1, data_points_count do
	local point = {
		id = i,
		val1 = math.random(1, 1000),
		val2 = math.random(1, 1000),
		val3 = math.random(1, 1000),
		category = "CAT" .. math.ceil(math.random() * 5),
		sub_data = {},
	}
	for j = 1, math.random(3, 7) do
		table.insert(point.sub_data, {
			sub_id = j,
			sub_val_a = math.random(1, 100),
			sub_val_b = math.random(1, 100),
			status = (j % 2 == 0) and "active" or "inactive",
		})
	end

	if point.val1 > 500 and point.val2 < 300 then
		point.status = "high_priority"
	elseif point.val3 % 7 == 0 then
		point.status = "seven_multiple"
	else
		point.status = "normal"
	end

	for k = 1, #point.sub_data do
		if point.sub_data[k].sub_val_a + point.sub_data[k].sub_val_b > 150 then
			point.sub_data[k].flagged = true
		else
			point.sub_data[k].flagged = false
		end
	end
	table.insert(processed_data_set, point)
end

-- More function definitions with varying complexity
local function process_dataset(dataset)
	local results = {}
	for i, data_item in ipairs(dataset) do
		local total_sub_val = 0
		for _, sub_item in ipairs(data_item.sub_data) do
			total_sub_val = total_sub_val + sub_item.sub_val_a + sub_item.sub_val_b
		end
		local average_val = (data_item.val1 + data_item.val2 + data_item.val3) / 3
		table.insert(results, {
			id = data_item.id,
			category = data_item.category,
			avg_main_vals = average_val,
			sum_sub_vals = total_sub_val,
			overall_status = data_item.status,
		})
	end
	return results
end

local analysis_results = process_dataset(processed_data_set)

-- String manipulation and pattern matching stress
local large_text_block = [[
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore
eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,
sunt in culpa qui officia deserunt mollit anim id est laborum.

Section 2: Data processing and analysis.
This section demonstrates various string operations. We will search for
keywords like "data", "processing", "analysis", and "report".
Line with numbers: 12345, 67890. Another line with more numbers: 987654321.
Email addresses: test@example.com, user.name@domain.co.uk.
URLs: https://www.example.com, http://sub.domain.org/path/to/resource.html.

Final Section: Conclusion and summary.
The quick brown fox jumps over the lazy dog. This sentence is a classic
pangram. Let's repeat it a few times to increase file size.
The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.
]]

-- Duplicate the text block multiple times to ensure extreme length
for _ = 1, 50 do
	large_text_block = large_text_block .. large_text_block
end

local found_keywords = {}
for keyword in large_text_block:gmatch("%f[%w]data%f[%w]") do
	table.insert(found_keywords, keyword)
end
for keyword in large_text_block:gmatch("%f[%w]processing%f[%w]") do
	table.insert(found_keywords, keyword)
end
for keyword in large_text_block:gmatch("%f[%w]analysis%f[%w]") do
	table.insert(found_keywords, keyword)
end

local numbers_found = {}
for num_str in large_text_block:gmatch("%d+") do
	table.insert(numbers_found, tonumber(num_str))
end

local emails_found = {}
for email_str in large_text_block:gmatch("[a-zA-Z0-9_.-]+@[a-zA-Z0-9_.-]+") do
	table.insert(emails_found, email_str)
end

-- More complex recursive data structure generation
local function generate_tree_with_properties(max_depth, current_depth, max_children)
	current_depth = current_depth or 0
	max_children = max_children or 5
	if current_depth >= max_depth then
		return nil
	end

	local node = {
		id = "node_" .. current_depth .. "_" .. math.random(10000),
		type = (current_depth == max_depth - 1) and "leaf" or "branch",
		value = math.random() * 100,
		timestamp = os.time(),
		metadata = {
			version = "1.0",
			created_by = "script_gen",
		},
		children = {},
	}

	local num_children = math.random(0, max_children)
	for i = 1, num_children do
		local child = generate_tree_with_properties(max_depth, current_depth + 1, max_children)
		if child then
			table.insert(node.children, child)
		end
	end
	return node
end

local deep_complex_tree = generate_tree_with_properties(7, 0, 4)

-- Additional complex control flow with flags and nested conditions
local function process_pipeline(input_value, config_flags)
	local result = input_value
	local status_message = "Initial"

	if config_flags.enable_step1 then
		result = result * 2
		status_message = status_message .. " -> Step1"
		if result > 100 then
			if config_flags.apply_filter then
				result = result - (result % 10) -- Snap to nearest ten
				status_message = status_message .. " (Filtered)"
			else
				result = result + 5
				status_message = status_message .. " (Adjusted)"
			end
		end
	end

	if config_flags.enable_step2 then
		local temp_res = 0
		for i = 1, math.floor(result / 10) do
			temp_res = temp_res + i
			if config_flags.debug_mode and i % 5 == 0 then
				-- print("  Debug: accumulated temp_res at iteration", i, ":", temp_res)
			end
		end
		result = result + temp_res
		status_message = status_message .. " -> Step2"
	end

	if config_flags.final_check then
		if result % 2 == 0 then
			status_message = status_message .. " (Even)"
		else
			status_message = status_message .. " (Odd)"
		end
	end

	return result, status_message
end

local pipeline_config_1 = { enable_step1 = true, apply_filter = false, enable_step2 = true, debug_mode = false, final_check = true }
local pipeline_config_2 = { enable_step1 = true, apply_filter = true, enable_step2 = false, debug_mode = true, final_check = false }

local res1, msg1 = process_pipeline(25, pipeline_config_1)
local res2, msg2 = process_pipeline(60, pipeline_config_2)

-- Long sequence of local variable declarations and assignments
local var_a = 10
local var_b = var_a + 5
local var_c = var_b * 2
local var_d, var_e = var_c / 3, var_a + var_c
local var_f = "string_value_" .. var_d
local var_g = { key1 = var_e, key2 = var_f }
local var_h = function(x) return x * var_a end
local var_i = var_h(var_b)
local var_j = var_g.key1 + var_i
local var_k = var_g.key2:len()
local var_l = (var_j > 100) and "large" or "small"
local var_m = { 1, 2, 3, var_a, var_b }
local var_n = var_m[4]
local var_o = var_m[var_n % 3 + 1]
local var_p = not (var_a == var_b and var_c ~= var_d)
local var_q = { ["dynamic_key" .. var_a] = var_b, fixed_key = var_c }
local var_r = var_q["dynamic_key" .. var_a]
local var_s = { table.unpack(var_m) }
local var_t = #var_s + var_k
local var_u = var_a .. "_" .. var_b .. "_" .. var_c
local var_v = string.upper(var_u)
local var_w = string.gsub(var_v, "_", "-")
local var_x = string.find(var_w, "A-")
local var_y = string.sub(var_w, 1, var_x + 1)
local var_z = math.abs(var_a - var_c)
local var_aa = math.min(var_d, var_e, var_f:len())
local var_bb = math.max(var_g.key1, var_g.key2:len())
local var_cc = math.floor(var_j / 7)
local var_dd = math.ceil(var_k / 3)
local var_ee = math.random() * 100
local var_ff = math.cos(var_a)
local var_gg = math.sin(var_b)
local var_hh = math.sqrt(var_c)
local var_ii = math.log(var_d)
local var_jj = math.exp(var_e / 10)
local var_kk = os.time() - 3600
local var_ll = os.date("%c", var_kk)
local var_mm = os.clock()
local var_nn = io.write
local var_oo = io.read
local var_pp = table.concat(var_m, "-")
local var_qq = table.insert
local var_rr = table.remove
local var_ss = table.sort
local var_tt = select("#", var_m)
local var_uu = select(2, var_d, var_e, var_f)
local var_vv = debug.traceback()
local var_ww = _G.print
local var_xx = _VERSION
local var_yy = load("return 1 + 2")()
local var_zz = assert(true, "This should not fail")
local var_aaa, var_bbb = pcall(function() error("pcall test") end)
local var_ccc = type(var_a)
local var_ddd = next(var_g)
local var_eee = setmetatable({}, {})
local var_fff = getmetatable(var_eee)
local var_ggg = collectgarbage("count")
local var_hhh = tonumber("123")
local var_iii = tostring(var_a)
local var_jjj = newproxy(true)
local var_kkk = rawequal(var_a, var_a)
local var_lll = rawlen(var_m)
local var_mmm = rawget(var_g, "key1")
local var_nnn = rawset(var_g, "key3", 999)
local var_ooo = xpcall(function() error("xpcall test") end, function() return "error handled" end)
local var_ppp = coroutine.running()
local var_qqq = coroutine.status(co)
local var_rrr = coroutine.yield
local var_sss_func = coroutine.create(function() coroutine.yield("hello") end)
local var_ttt, var_uuu = coroutine.resume(var_sss_func)

-- Repetitive function calls and complex expressions
for i = 1, 1000 do
	local temp_val_1 = (var_a * i + var_b) % (var_c + 1)
	local temp_val_2 = math.sqrt(temp_val_1 * var_d + var_e)
	local temp_val_3 = string.format("Loop_%d_Result_%.2f", i, temp_val_2)
	if i % 10 == 0 then
		-- print(temp_val_3)
	end
	if temp_val_2 > 10 then
		local complex_calc = (temp_val_2 ^ 1.5) / (var_f:len() + 1) * math.sin(temp_val_1)
		-- This is just to add complexity, not necessarily meaningful
	end
end

-- Long sequences of chained table accesses
local deeply_nested_config = {
	settings = {
		network = {
			timeout = 3000,
			retries = 5,
			protocols = {
				http = {
					port = 80,
					ssl = false,
				},
				https = {
					port = 443,
					ssl = true,
					cert_path = "/etc/ssl/certs/my_cert.pem",
				},
			},
		},
		database = {
			type = "SQL",
			host = "localhost",
			user = "admin",
			password_hash = "aksjdhf8237rhsdaj",
			tables = {
				users = {
					columns = { "id", "name", "email" },
					indices = { "id", "email" },
				},
				products = {
					columns = { "prod_id", "prod_name", "price", "stock" },
					indices = { "prod_id" },
				},
			},
		},
	},
	preferences = {
		theme = "dark",
		font_size = 14,
		editor = {
			auto_save = true,
			line_numbers = true,
			indent_size = 2,
			plugins = {
				linter = {
					enabled = true,
					rules = { "no_global", "strict_local" },
				},
				formatter = {
					enabled = true,
					style = "lua_style_guide",
				},
			},
		},
	},
	system_info = {
		os_name = "LuaOS",
		version = "1.0-alpha",
		build_date = "2023-10-27",
		modules_loaded = {
			"base",
			"math",
			"string",
			"table",
			"io",
			"os",
			"package",
			"debug",
			"coroutine",
		},
	},
}

local net_timeout = deeply_nested_config.settings.network.timeout
local https_port = deeply_nested_config.settings.network.protocols.https.port
local user_table_cols = deeply_nested_config.settings.database.tables.users.columns[2]
local editor_plugin_rule = deeply_nested_config.preferences.editor.plugins.linter.rules[1]
local system_build_date = deeply_nested_config.system_info.build_date

-- Even more functions with varied parameters and return values
local function process_queue_items(queue, processor_func, max_items)
	local processed_count = 0
	local results = {}
	for i = 1, math.min(#queue, max_items or #queue) do
		local item = queue[i]
		local success, processed_item = pcall(processor_func, item)
		if success then
			table.insert(results, processed_item)
			processed_count = processed_count + 1
		else
			-- print("Error processing item:", item, "Error:", processed_item)
		end
	end
	return results, processed_count
end

local my_queue = {}
for i = 1, 500 do
	table.insert(my_queue, { value = math.random(1, 100), type = (i % 3 == 0) and "error" or "normal" })
end

local function item_processor(item)
	if item.type == "error" then
		error("Simulated processing error for item with value " .. item.value)
	end
	return { original_value = item.value, processed_value = item.value * 2, timestamp = os.time() }
end

local processed_results, count = process_queue_items(my_queue, item_processor, 300)

-- Deeply nested loops for performance testing (Tree-sitter doesn't execute, just parses)
for i = 1, 10 do
	for j = 1, 10 do
		for k = 1, 10 do
			for l = 1, 10 do
				local result = (i * j) + (k / l)
				if result > 50 then
					local deep_val = result * math.sin(i) + math.cos(j)
					if deep_val < 0 then
						local another_deep_val = math.sqrt(math.abs(deep_val))
					end
				end
			end
		end
	end
end

-- Final summary print
print("Extra Lua features included: coroutine, metatables, closures, varargs, patterns, weak tables, inheritance, error handling, complex control flow, deep tables, state machine, recursion, file system simulation, comprehensive OOP, extensive data processing, string manipulation, deep configurations, pipeline processing, extreme loop nesting, and a very long list of local variables.")

-- Return to allow importing without side effects
return {
	factorial = factorial,
	fib = fib,
	is_prime = is_prime,
	gcd = gcd,
	lcm = lcm,
	Person = Person,
	simulate = simulate,
	deep_table = deep_table,
	generate_logs = generate_logs,
	create_fs_tree = create_fs_tree,
	state_machine = state_machine,
	Vector = Vector,
	logic = logic,
	make_counter = make_counter,
	scoped = scoped,
	wait_until_even = wait_until_even,
	swap = swap,
	varargs = varargs,
	calculate_area = calculate_area,
	Shape = Shape,
	Circle = Circle,
	Rectangle = Rectangle,
	Square = Square,
	process_dataset = process_dataset,
	generate_tree_with_properties = generate_tree_with_properties,
	process_pipeline = process_pipeline,
	process_queue_items = process_queue_items,
}
