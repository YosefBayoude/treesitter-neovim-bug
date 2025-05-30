vim.opt.swapfile = false

local timer = vim.loop.new_timer()
local i = 0
local nodes = nil
timer:start(100, 30, vim.schedule_wrap(function()
	if i == 0 then
		-- open the test file at 912
		local cmd = vim.api.nvim_replace_termcodes(":e! ~/.config/treesitter-neovim-bug/test.lua<CR>:912<CR>", true,
			false, true)
		vim.api.nvim_feedkeys(cmd, "m", false)
		i = 1
	elseif i == 1 then
		-- get a node from the tree, save it in nodes, edit the parse tree
		local parser = vim.treesitter.get_parser(buf)
		local root = parser:parse()[1]:root()
		local node = root:named_descendant_for_range(912, 0, 912, 0)
		nodes = { [1] = node }
		vim.api.nvim_buf_set_lines(0, 911, 912, false, {})
		i = 2
	else
		-- run the garbage collector, and try to access node:range()
		--
		-- the garbage collector will call tree_gc on a TSTree, which will
		-- eventually free a Subtree.
		--
		-- node:range() will call on the C-side node_range -> ts_node_end_point
		-- -> ts_node_subtree_size, where we try to access the freed Subtree, and crash.
		collectgarbage("collect")
		local node = nodes[#nodes]
		node:range()
		i = 1
	end
end))
