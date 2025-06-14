Some explanation on this bug.

To reproduce this, simply clone the repo into your `.config` folder, and run :

```bash
NVIM_APPNAME=treesitter-neovim-bug nvim
```

Neovim will automatically open the file `test.lua` query a treesitter node, mutating the file, and then access the node. Nvim will either read uninitialized memory, or crash.

## before automation

```bash
NVIM_APPNAME=treesitter-neovim-bug nvim +912 -c "set noswapfile" ~/.config/treesitter-neovim-bug/test.lua
```

Once in this file, run the following vim commnds in quick succession: 

`ddxuj` several times (where `x` => increment select, keybind set by this config), press this enough times, and it should trigger the bug, causing nvim to close abruptly.

In my case, I had this bind to a single shortcut, that would run this 10 times, followed by a bunch of (`u`) undos, hence the `u`'s that appear in the demo.

Demo :

![treesitter-neovim-bug2](https://github.com/user-attachments/assets/6e04605d-7453-4fb8-8494-bef7bbff8ac4)


In trying to replicate this bug, I generated a large file, and tried all kinds selections using treesitter.
