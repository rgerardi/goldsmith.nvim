local config = require 'goldsmith.config'
local log = require 'goldsmith.log'
local mod = require 'goldsmith.mod'
local fs = require 'goldsmith.fs'

local M = {}

function M.configure(client)
  local caps = client.resolved_capabilities
  local gofmt = not config.service_is_disabled 'gofmt'
  local gofumpt = not config.service_is_disabled 'gofumpt'

  if gofmt == true or gofumpt == true then
    if client.name == 'gopls' then
      -- turn off gopls doc formatting
      log.debug('Format', 'Turning off gopls formatting')
      caps.document_formatting = false
    elseif client.name == 'null-ls' then
      caps.document_formatting = true
    end
  end
end

M.mod_format = mod.format
M.make_comments = function()
  if fs.is_code_file(vim.fn.expand '%') or config.get('format', 'comments', 'test_files') then
    require('goldsmith.comment').make_comments(
      config.get('format', 'comments', 'template'),
      config.get('format', 'comments', 'private')
    )
  end
end

function M.lsp_format()
  vim.lsp.buf.formatting_seq_sync()
end

-- https://github.com/neovim/nvim-lspconfig/issues/115#issuecomment-902680058
function M.organize_imports(wait_ms)
  wait_ms = wait_ms or config.get('format', 'goimports', 'timeout')
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { 'source.organizeImports' } }
  local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, wait_ms)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit)
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end
end

-- taken from https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-imports
-- It is different in that this version supports multiple language servers (but only one will
-- be able to fulfill the request -- presumedly gopls).
-- This code is also similar to the codeAction handler defined at lua/vim/lsp/handlers.lua.
-- Probably shouldn't use. See:
-- https://github.com/neovim/nvim-lspconfig/issues/115
function M.goimports(timeout_ms)
  local context = { only = { 'source.organizeImports' } }
  -- local context = { source = { organizeImports = true } }
  vim.validate { context = { context, 't', true } }

  local params = vim.lsp.util.make_range_params()
  params.context = context

  -- See the implementation of the textDocument/codeAction callback
  -- (lua/vim/lsp/handler.lua) for how to do this properly.
  local results = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, timeout_ms)
  if not results or next(results) == nil then
    return
  end

  local actions = false
  for _, result in pairs(results) do
    if not vim.tbl_isempty(result) then
      actions = result.result
      if actions and not vim.tbl_isempty(actions) then
        break
      else
        actions = false
      end
    end
  end
  if not actions then
    return
  end
  local action = actions[1]

  -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
  -- is a CodeAction, it can have either an edit, a command or both. Edits
  -- should be executed first.
  if action.edit or type(action.command) == 'table' then
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if type(action.command) == 'table' then
      vim.lsp.buf.execute_command(action.command)
    end
  else
    vim.lsp.buf.execute_command(action)
  end
end

return M
