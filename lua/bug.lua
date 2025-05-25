local vim = vim
local api = vim.api

local M = {}

---@type table<integer, table<TSNode|nil>>
local selections = {}

-- Utility function to get the range of the current visual selection
---@return integer, integer, integer, integer
local function visual_selection_range()
	local _, csrow, cscol, _ = unpack(vim.fn.getpos("v")) ---@type integer, integer, integer, integer
	local _, cerow, cecol, _ = unpack(vim.fn.getpos(".")) ---@type integer, integer, integer, integer

	local start_row, start_col, end_row, end_col ---@type integer, integer, integer, integer

	if csrow < cerow or (csrow == cerow and cscol <= cecol) then
		start_row = csrow
		start_col = cscol
		end_row = cerow
		end_col = cecol
	else
		start_row = cerow
		start_col = cecol
		end_row = csrow
		end_col = cscol
	end

	return start_row, start_col, end_row, end_col
end

---@param node TSNode
---@return boolean
local function range_matches(node)
	local csrow, cscol, cerow, cecol = visual_selection_range()
	local srow, scol, erow, ecol = M.get_vim_range({ node:range() })
	return srow == csrow and scol == cscol and erow == cerow and ecol == cecol
end

-- Get a compatible vim range (1 index based) from a TS node range.
---@param range integer[]
---@return integer, integer, integer, integer
function M.get_vim_range(range)
	---@type integer, integer, integer, integer
	local srow, scol, erow, ecol = unpack(range)
	srow = srow + 1
	scol = scol + 1
	erow = erow + 1

	if ecol == 0 then
		-- Use the value of the last col of the previous row instead.
		erow = erow - 1
		ecol = vim.fn.col({ erow, "$" }) - 1
		ecol = math.max(ecol, 1)
	end
	return srow, scol, erow, ecol
end

-- Set visual selection to node
function M.update_selection(buf, node)
	local start_row, start_col, end_row, end_col = M.get_vim_range({ vim.treesitter.get_node_range(node) }, buf)

	-- enter visual mode if not in visual mode
	local mode = api.nvim_get_mode()
	if mode.mode ~= "v" then
		api.nvim_cmd({ cmd = "normal", bang = true, args = { "v" } }, {})
	end

	api.nvim_win_set_cursor(0, { start_row, start_col - 1 })
	vim.cmd("normal! o")
	api.nvim_win_set_cursor(0, { end_row, end_col - 1 })
end

-- Get the node at current cursor position
function M.get_node_at_cursor()
	local cursor = api.nvim_win_get_cursor(0)
	local cursor_range = { cursor[1] - 1, cursor[2] }

	local buf = vim.api.nvim_get_current_buf()
	local parser = vim.treesitter.get_parser(buf)
	if not parser then
		return nil
	end

	local root = parser:parse()[1]:root()
	if not root then
		return nil
	end

	return root:named_descendant_for_range(cursor_range[1], cursor_range[2], cursor_range[1], cursor_range[2])
end

function M.init_selection()
	local buf = api.nvim_get_current_buf()
	local node = M.get_node_at_cursor()
	selections[buf] = { [1] = node }
	M.update_selection(buf, node)
end

function M.node_incremental()
	local buf = api.nvim_get_current_buf()
	local nodes = selections[buf]

	local csrow, cscol, cerow, cecol = visual_selection_range()
	-- Initialize incremental selection with current selection
	if not nodes or #nodes == 0 or not range_matches(nodes[#nodes]) then
		local parser = vim.treesitter.get_parser()
		local node = parser:named_node_for_range({ csrow - 1, cscol - 1, cerow - 1, cecol }, { ignore_injections = false })
		M.update_selection(buf, node)
		if nodes and #nodes > 0 then
			table.insert(selections[buf], node)
		else
			selections[buf] = { [1] = node }
		end
		return
	end

	-- Find a node that changes the current selection.
	local node = nodes[#nodes] ---@type TSNode
	while true do
		local parent = node:parent() or node
		if parent == node then
			-- Keep searching in the parent tree
			local root_parser = vim.treesitter.get_parser()
			root_parser:parse()
			local current_parser = root_parser:language_for_range({ csrow - 1, cscol - 1, cerow - 1, cecol })
			if root_parser == current_parser then
				node = root_parser:named_node_for_range({ csrow - 1, cscol - 1, cerow - 1, cecol })
				M.update_selection(buf, node)
				return
			end
			local parent_parser = current_parser:parent()
			parent = parent_parser:named_node_for_range({ csrow - 1, cscol - 1, cerow - 1, cecol })
		end
		node = parent
		local srow, scol, erow, ecol = M.get_vim_range({ node:range() })
		local same_range = (srow == csrow and scol == cscol and erow == cerow and ecol == cecol)
		if not same_range then
			table.insert(selections[buf], node)
			if node ~= nodes[#nodes] then
				table.insert(nodes, node)
			end
			M.update_selection(buf, node)
			return
		end
	end
end

function M.node_decremental()
	local buf = api.nvim_get_current_buf()
	local nodes = selections[buf]
	if not nodes or #nodes < 2 then
		return
	end

	table.remove(selections[buf])
	local node = nodes[#nodes] ---@type TSNode
	M.update_selection(buf, node)
end

return M
