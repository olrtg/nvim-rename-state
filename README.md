# nvim-rename-state

Rename the getter and a setter of a state hook in react/solid at the same time using `:RenameState`.

```javascript
// Initial code
const [anchorEl, setAnchorEl] = useState(null)

// If you rename `anchorEl` to `anchor`
// If you rename `setAnchorEl` to `setAnchor`
const [anchor, setAnchor] = useState(null)
```
