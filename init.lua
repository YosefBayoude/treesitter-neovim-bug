vim.keymap.set({ "n", "v" }, "x", function()
	local bug = require("bug")
	bug.node_incremental(bug.get_node_at_cursor())
end, { noremap = true, silent = true, desc = "Go window up" })

vim.api.nvim_command("set noswapfile")

local keys = "ddxujddxuhjddxujddxujddxujddxuj"
local i = 100000
local timer = vim.loop.new_timer()

timer:start(100, 30, vim.schedule_wrap(function()
	if i <= #keys then
		local key = keys:sub(i, i)
		vim.api.nvim_feedkeys(key, "m", false)
		i = i + 1
	else
		-- Press ":e<CR>" after the sequence finishes
		local cmd = vim.api.nvim_replace_termcodes(":e! ~/.config/treesitter-neovim-bug/test.lua<CR>:912<CR>", true,
			false, true)
		vim.api.nvim_feedkeys(cmd, "m", false)
		i = 0
		-- timer:stop()
		-- timer:close()
	end
end))
