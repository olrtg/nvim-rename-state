# nvim-rename-state

Rename the getter and a setter of a state hook in react/solidjs at the same time using `:RenameState`.

```javascript
// Initial code
const [anchorEl, setAnchorEl] = useState(null)

// After renaming with `:RenameState` or `:RenameState anchor`
const [anchor, setAnchor] = useState(null)
```

## Features

- Leverages [Treesitter](https://tree-sitter.github.io/tree-sitter/) (requires [neovim](https://neovim.io/) >= 0.5.0).
- Supports Javascript and Typescript files.
- Supports [React](https://reactjs.org/) and [Solid](https://www.solidjs.com/) state hooks.

## Installation

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ "olrtg/nvim-rename-state" }
```

[packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { "olrtg/nvim-rename-state" }
```

[vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'olrtg/nvim-rename-state'
```

## Usage

Put your cursor in the row of the defined `useState` or `createSignal` hook and use:

```vim
:RenameState
```

Or if you want to pass the new name for the hook in advance:

```vim
:RenameState <new_name>
```

## Contributing

All contributions are welcomed! Just open a pull request or an issue.
