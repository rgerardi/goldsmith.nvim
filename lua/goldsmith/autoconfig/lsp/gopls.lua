-- see https://github.com/golang/tools/blob/master/gopls/doc/settings.md
-- for all settings for the most recent version of gopls;
-- see https://github.com/golang/tools/releases for a changelog
local util = require 'lspconfig.util'
local servers = require 'goldsmith.lsp.servers'
local plugins = require 'goldsmith.plugins'
local tools = require 'goldsmith.tools'

local M = {}

local SETTINGS = {
  gopls = {
    gofumpt = true,
    staticcheck = true,
    usePlaceholders = true,
    codelenses = {
      gc_details = true,
    },
  },
}

local SETTINGS_DIFF = {
  experimentalDiagnosticsDelay = { '500ms', '0.6.0', '0.6.11' },
  diagnosticsDelay = { '500ms', '0.7.0', nil },
  experimentalPostfixCompletions = { true, '0.6.10', nil },
  experimentalUseInvalidMetadata = { true, '0.7.1', nil },
}

local FILETYPES = { 'go', 'gomod' }

local FLAGS = {
  debounce_text_changes = 500,
}

-- -1 lhs is more recent
-- 0 same
-- 1 rhs is more recent
-- dunno (should never happen)
local function version_cmp(lhs, rhs)
  if rhs == nil then
    return 1
  end
  if lhs == rhs then
    return 0
  end
  local lmajor, lminor, lpatch = string.match(lhs, '^(%d+)%.(%d+)%.(%d+)')
  local rmajor, rminor, rpatch = string.match(rhs, '^(%d+)%.(%d+)%.(%d+)')
  if lmajor > rmajor then
    return -1
  elseif lmajor < rmajor then
    return 1
  elseif lminor > rminor then
    return -1
  elseif lminor < rminor then
    return 1
  elseif lpatch > rpatch then
    return -1
  elseif lpatch < rpatch then
    return 1
  end
  return nil
end

local function get_versioned_server_settings()
  local settings = {}
  local v = tools.info('gopls').version
  for var, m in pairs(SETTINGS_DIFF) do
    local cmp1 = version_cmp(v, m[2])
    local cmp2 = version_cmp(v, m[3])

    if cmp1 <= 0 and cmp2 >= 0 then
      settings[var] = m[1]
    end
  end
  return settings
end

local function set_server_settings(settings)
  return vim.tbl_deep_extend('keep', get_versioned_server_settings(), settings, SETTINGS)
end

local function set_flags(flags)
  return vim.tbl_deep_extend('keep', flags, FLAGS)
end

local set_root_dir = function()
  return util.root_pattern('go.mod', '.git')
end

local function set_default_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- if the user wants to use postfixCompletions this is REQUIRED
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return capabilities
end

-- debug options:
-- '-logfile=auto',
-- '-rpc.trace'
local function set_command()
  return { servers.info('gopls').cmd, '-remote=auto' }
end

local function set_filetypes(ft)
  for _, filetype in ipairs(FILETYPES) do
    if not vim.tbl_contains(ft, filetype) then
      table.insert(ft, filetype)
    end
  end
  return ft
end

local function correct_server_conf_key()
  return servers.lsp_plugin_name 'gopls'
end

function M.is_minimum_version()
  local v = tools.info('gopls').version
  local m = tools.info('gopls').minimum_version
  if version_cmp(v, m) == 1 then
    return false
  end
  return true
end

function M.has_requirements()
  if plugins.is_installed 'lspconfig' then
    return true
  end
  return false
end

function M.setup(cf)
  local conf = {}
  conf['filetypes'] = set_filetypes(cf['filetypes'] or {})
  conf['flags'] = set_flags(cf['flags'] or {})
  conf['settings'] = set_server_settings(cf['settings'] or {})
  if conf['cmd'] == nil then
    conf['cmd'] = set_command()
  end
  if conf['root_dir'] == nil then
    conf['root_dir'] = set_root_dir()
  end
  if conf['capabilities'] == nil then
    conf['capabilities'] = set_default_capabilities()
  end
  local server = correct_server_conf_key()
  require('lspconfig')[server].setup(conf)
end

return M