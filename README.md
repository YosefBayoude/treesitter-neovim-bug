Some explanation on this bug.

To reproduce this, simply clone the repo into your `.config` folder, and run :

```bash
NVIM_APPNAME=treesitter-neovim-bug nvim +912 -c "set noswapfile" ~/.config/treesitter-neovim-bug/test.lua
```


Once in this file, run the following vim commnds in quick succession: 

`ddxuj` several times (where `x` => increment select, keybind set by this config), press this enough times, and it should trigger the bug, causing nvim to close abruptly.

In my case, I had this bind to a single shortcut, that would run this 10 times, followed by a bunch of (`u`) undos, hence the `u`'s that appear in the demo.

Demo :
![treesitter-neovim-bug](https://github.com/user-attachments/assets/e2196183-0675-4ec9-9d78-b99e67e4e33a)


In trying to replicate this bug, I generated a large file, and tried all kinds selections using treesitter.
