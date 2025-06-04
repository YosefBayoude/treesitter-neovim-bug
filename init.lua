vim.opt.swapfile = false
vim.api.nvim_command("filetype off")
vim.api.nvim_command("filetype plugin off")
vim.api.nvim_command("e! ~/.config/treesitter-neovim-bug/test.lua")

vim.schedule(function()
	-- First we get a TSTree from a lua file.
	local parser = vim.treesitter.get_parser(buf)
	local tree = parser:parse()[1]

	-- Then we create a copy of the tree. This will increase the refcount of the TSTree root to 2.
	tree:copy()

	-- Then, we get a reference to the first child of the root of the tree. TSNode will have a
	-- pointer to the tree, and a pointer to the firt child of the tree root, which is in the same
	-- allocation as the tree root. The TSNode in the LUA-side will have a reference to the TSTree,
	-- which will make the TSTree only be garbage colected after the node is no longer reachable.
	local node = tree:root():child()

	-- Then we edit the the buffer, which will eventually call TSTree:edit -> ts_tree_edit.
	-- ts_subtree_edit will internally call ts_subtree_make_mut on the tree root, which check if
	-- there is only one owner for the tree. If there is one, it will cast this single Subtree to a
	-- mutable Subtree. Otherwise it will clone the subtree, and replace the root of the tree by
	-- that subtree clone, and release the previous subtree, i.e. the previous root of the tree.
	--
	-- Because we copy the tree earlier, the refcount was 2, so it does the tree clone, and
	-- decrement the root of subtree refcount to 1.
	vim.api.nvim_buf_set_lines(0, 911, 912, false, {})

	-- (wait for nvim_buf_set_lines eventually trigger a call to TSTree:edit)
	vim.schedule(function()
		-- Then we run the LUA garbage collector. This will collect the copy of tree we made
		-- earlier. Because the root of that tree have a refcount of 1, its allocation will be
		-- freed.
		collectgarbage("collect")

		-- node:range() will call on the C-side node_range -> ts_node_end_point ->
		-- ts_node_subtree_size, where we try to read the subtree, whose memory was under its parent
		-- allocation, which have being freed. We trigger a user-after-free. If the memory-page
		-- under the old allocation was also free the program crash, or we otherwise read garbage
		-- memory.
		print(node:range())
	end)
end)
