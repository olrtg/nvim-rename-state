# nvim-rename-state

Rename the getter and a setter of a state hook in react/solidjs at the same time using `:RenameState`.

```javascript
// Initial code
const [anchorEl, setAnchorEl] = useState(null)

// If you rename `anchorEl` to `anchor`
// If you rename `setAnchorEl` to `setAnchor`
const [anchor, setAnchor] = useState(null)
```

## Getting started

### Prerequisites

To use `nvim-rename-state`, since it makes use of [Neovim](https://github.com/neovim/neovim)'s built-in LSP, you will need to have installed [Neovim v0.5.0](https://github.com/neovim/neovim/releases/tag/v0.5.0) or [newer](https://github.com/neovim/neovim/releases/latest).

### Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'olrtg/nvim-rename-state',
  branch = 'master'
}
```

Using [vim-plug](https://github.com/junegunn/vim-plug):

```viml
Plug 'olrtg/nvim-rename-state', { 'branch': 'master' }
```

## Contributing

All contributions are welcome! Just open a pull request or an issue.
