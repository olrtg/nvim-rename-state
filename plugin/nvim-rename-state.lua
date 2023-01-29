vim.api.nvim_create_user_command("RenameState", require("nvim-rename-state").rename_state, { nargs = "?" })
