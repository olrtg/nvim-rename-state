local M = {}

-- @deprecated setup function is no longer needed
M.setup = function()
  vim.notify("nvim-rename-state: setup function is now deprecated since is no longer needed", vim.log.levels.WARN)
end

M.rename_state = function(command_obj)
  if
    vim.bo.filetype ~= "javascript"
    and vim.bo.filetype ~= "javascriptreact"
    and vim.bo.filetype ~= "typescriptreact"
  then
    vim.notify("nvim-rename-state: only works with jsx/tsx files", vim.log.levels.ERROR)
    return
  end

  local query_string = [[
    ;;query
    (variable_declarator
      name: (array_pattern
        (identifier) @getter
        (identifier) @setter (#match? @setter "^set")
      )

      (call_expression
         function: (identifier) @hook (#match? @hook "useState|createSignal")
      )
    )
  ]]

  local parser = vim.treesitter.get_parser()
  local ok, query = pcall(vim.treesitter.query.parse, parser:lang(), query_string)

  if not ok then
    vim.notify("nvim-rename-state: error parsing query", vim.log.levels.ERROR)
    return
  end

  local tree = parser:parse()[1]
  local current_row = vim.api.nvim_win_get_cursor(0)[1]

  local new_getter_name = nil

  for capture, capture_node in query:iter_captures(tree:root(), 0, current_row - 1, current_row) do
    local capture_name = query.captures[capture]
    local start_row, start_col = capture_node:range()

    if capture_name == "getter" then
      vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })

      if command_obj.args == "" then
        local node = vim.treesitter.get_node()

        if node == nil then
          vim.notify("nvim-rename-state: could not get node at cursor", vim.log.levels.ERROR)
          return
        end

        local node_name = vim.treesitter.get_node_text(node, 0)
        local new_node_name = vim.fn.input({ prompt = "New name: ", default = node_name })
        new_getter_name = new_node_name
      else
        new_getter_name = command_obj.args
      end

      if new_getter_name == "" then
        return
      end

      local node_params = vim.lsp.util.make_position_params()
      node_params.newName = new_getter_name

      local clients = vim.lsp.buf_request_sync(0, "textDocument/rename", node_params)

      if clients == nil then
        return
      end

      for key, _ in pairs(clients) do
        local client = vim.lsp.get_client_by_id(key)

        if client == nil then
          vim.notify("nvim-rename-state: could not get client by id", vim.log.levels.ERROR)
          return
        end

        vim.lsp.util.apply_workspace_edit(clients[key].result, client.offset_encoding)
      end
    end

    if capture_name == "setter" then
      vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
      local utils = require("nvim-rename-state.utils")

      local node_params = vim.lsp.util.make_position_params()
      node_params.newName = "set" .. utils.upperfirst(new_getter_name)

      local clients = vim.lsp.buf_request_sync(0, "textDocument/rename", node_params)

      if clients == nil then
        return
      end

      for key, _ in pairs(clients) do
        local client = vim.lsp.get_client_by_id(key)

        if client == nil then
          vim.notify("nvim-rename-state: could not get client by id", vim.log.levels.ERROR)
          return
        end

        vim.lsp.util.apply_workspace_edit(clients[key].result, client.offset_encoding)
      end
    end
  end
end

return M
