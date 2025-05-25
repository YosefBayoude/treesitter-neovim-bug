vim.keymap.set({ "n", "v" }, "x", function()
	local bug = require("bug")
	bug.node_incremental(bug.get_node_at_cursor())
end, { noremap = true, silent = true, desc = "Go window up" })
