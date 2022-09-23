local M = {}

M.setup = function()
  vim.api.nvim_create_user_command("RenameState", M.rename_state, {})
end

M.rename_state = function()
  local ts_utils = require("nvim-treesitter.ts_utils")

  local node = ts_utils.get_node_at_cursor()
  local node_name = vim.treesitter.query.get_node_text(node, 0)
  local new_node_name = vim.fn.input("New name: ")

  local node_params = vim.lsp.util.make_position_params()
  node_params.newName = new_node_name

  vim.lsp.buf_request(0, "textDocument/rename", node_params, function(err, result, ctx, config)
    local client = vim.lsp.get_client_by_id(ctx.client_id)

    vim.lsp.util.apply_workspace_edit(result, client.offset_encoding)

    local filetype = vim.api.nvim_buf_get_option(0, "filetype")
    local is_jsx_file = filetype == "javascriptreact" or filetype == "typescriptreact"

    if not is_jsx_file then
      return
    end

    local counterpart = ts_utils.get_next_node(node) or ts_utils.get_previous_node(node)
    local counterpart_name = vim.treesitter.query.get_node_text(counterpart, 0)
    local new_counterpart_name = ""

    ts_utils.goto_node(counterpart)

    local utils = require("nvim-rename-state.utils")

    if not utils.startswith(node_name, "set") and utils.startswith(counterpart_name, "set") then
      new_counterpart_name = "set" .. utils.upperfirst(new_node_name)
    elseif utils.startswith(node_name, "set") and not utils.startswith(counterpart_name, "set") then
      new_counterpart_name = utils.lowerfirst(utils.chopstart(new_node_name, "set"))
    else
      return
    end

    local counterpart_params = vim.lsp.util.make_position_params()
    counterpart_params.newName = new_counterpart_name

    vim.lsp.buf_request(0, "textDocument/rename", counterpart_params, function(cerr, cresult, cctx, cconfig)
      vim.lsp.util.apply_workspace_edit(cresult, client.offset_encoding)
    end)
  end)
end

return M
