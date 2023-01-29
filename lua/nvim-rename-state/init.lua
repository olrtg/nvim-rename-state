local M = {}

-- @deprecated setup function is no longer needed
M.setup = function()
  vim.notify("nvim-rename-state: setup function is now deprecated since is no longer needed", vim.log.levels.WARN)
end

M.rename_state = function(command_obj)
  local ts_utils = require("nvim-treesitter.ts_utils")

  local query_string = [[
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

  local parser = vim.treesitter.get_parser(0, "typescript")
  local ok, query = pcall(vim.treesitter.query.parse_query, parser:lang(), query_string)

  if not ok then
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
        local node = ts_utils.get_node_at_cursor()
        local node_name = vim.treesitter.query.get_node_text(node, 0)
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
        vim.lsp.util.apply_workspace_edit(clients[key].result, client.offset_encoding)
      end
    end
  end
end

return M
