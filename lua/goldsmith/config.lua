local M = {}

local _config = {}
local _defaults = {}

local autoconfig = true

local config_is_ok = nil

function M.turn_off_autoconfig()
  autoconfig = false
end

function M.autoconfig_is_on()
  return autoconfig
end

function M.config_is_ok()
  return config_is_ok
end

-- logging is not available until config is read and validated
local function log_error(label, msg)
  -- vim.api.nvim_err_writeln(string.format('Goldsmith: %s: %s', label, msg))
  vim.api.nvim_err_writeln(string.format('Goldsmith: %s: %s', label, msg))
end

-- once set to false it cannot go back to true
local function set_autoconfig(uc)
  local ac = uc['autoconfig']
  if ac ~= nil and type(ac) ~= 'boolean' then
    log_error('Config', "Key 'autoconfig' must be a boolean value.")
    return
  end
  if ac ~= nil and ac == false then
    autoconfig = false
  end
  uc['autoconfig'] = nil
end

local function is_type(allow_nil, ...)
  local types = { ... }
  return function(v)
    if allow_nil and v == nil then
      return true
    end
    for _, typ in ipairs(types) do
      if type(v) == typ then
        return true
      end
    end
    return false
  end
end

local function in_set(allow_nil, ...)
  local vals = { ... }
  return function(v)
    if allow_nil and v == nil then
      return true
    end
    return vim.tbl_contains(vals, v)
  end
end

local function is_positive(allow_nil)
  return function(v)
    if allow_nil and v == nil then
      return true
    end
    return type(v) == 'number' and v > 0
  end
end

local function service_defaults()
  return {
    { 'staticcheck', false },
    { 'golines', true },
    { 'golangci-lint', true },
    { 'revive', true },
    { 'gofmt', false },
    { 'gofumpt', false },
  }
end

local function valid_services()
  local services = {}
  for _, v in service_defaults() do
    table.insert(services, v[1])
  end
  return services
end

local function services()
  local svcs = {}
  for _, s in ipairs(service_defaults()) do
    svcs[s[1]] = { s[2], is_type(false, 'boolean', 'table'), 'either true/false or list of arguments' }
  end
  return svcs
end

function M.lsp_root_dir()
  local lrd = M.get('system', 'lsp_root_dir')
  if lrd == nil then
    return M .get('system', 'root_dir')
  end
  return lrd
end

local function window_validate(allow_nil, nil_default, focus)
  local function def(d)
    if nil_default then
      return nil
    else
      return d
    end
  end
  return {
    pos = {
      def 'right',
      in_set(allow_nil, 'top', 'bottom', 'left', 'right'),
      'valid position: top, bottom, left, right',
    },
    focus = { def(focus), 'b' },
    height = {
      def(20),
      is_positive(allow_nil),
      'positive integer',
    },
    width = {
      def(80),
      is_positive(allow_nil),
      'positive integer',
    },
  }
end

local window_spec = window_validate(true, true, true)
local terminal_spec = window_validate(true, true, false)
local SPEC = {
  system = {
    debug = { false, 'b' },
    root_dir = { { '.git', 'go.mod', 'go.work' }, 't' },
    lsp_root_dir = { nil, 't' },
  },
  completion = {
    omni = { false, 'b' },
  },
  mappings = vim.tbl_deep_extend('error', { enable = { true, 'b' } }, {
    godef = { { 'gd', '<C-]>' }, 't' },
    hover = { { 'K' }, 't' },
    goimplementation = { { 'gi' }, 't' },
    sighelp = { { '<C-k>' }, 't' },
    ['add-ws-folder'] = { { '<leader>wa' }, 't' },
    ['rm-ws-folder'] = { { '<leader>wr' }, 't' },
    ['list-ws-folders'] = { { '<leader>wl' }, 't' },
    typedef = { { '<leader>D' }, 't' },
    rename = { { '<leader>rn' }, 't' },
    goref = { { 'gr' }, 't' },
    codeaction = { { '<leader>ca' }, 't' },
    showdiag = { { '<leader>e' }, 't' },
    prevdiag = { { '[d' }, 't' },
    nextdiag = { { ']d' }, 't' },
    setloclist = { { '<leader>q' }, 't' },
    format = { { '<leader>f' }, 't' },
    ['toggle-debug-console'] = { {}, 't' },
    ['test-close-window'] = { { '<leader>tc' }, 't' },
    ['test-last'] = { { '<leader>tl' }, 't' },
    ['test-nearest'] = { { '<leader>tn' }, 't' },
    ['test-visit'] = { { '<leader>tv' }, 't' },
    ['test-suite'] = { { '<leader>ts' }, 't' },
    ['test-pkg'] = { { '<leader>tp' }, 't' },
    ['alt-file'] = { {}, 't' },
    ['alt-file-force'] = { {}, 't' },
    ['fillstruct'] = { {}, 't' },
    ['codelens-on'] = { {}, 't' },
    ['codelens-off'] = { {}, 't' },
    ['codelens-run'] = { {}, 't' },
    ['sym-highlight-on'] = { {}, 't' },
    ['sym-highlight-off'] = { {}, 't' },
    ['sym-highlight'] = { {}, 't' },
  }),
  goimports = {
    run_on_save = { true, 'b' },
    timeout = { 1000, 'n' },
  },
  gobuild = terminal_spec,
  gorun = terminal_spec,
  goget = terminal_spec,
  goinstall = terminal_spec,
  godoc = window_spec,
  goalt = vim.tbl_deep_extend('error', window_spec, { use_current_window = { false, 'b' } }),
  gotestvisit = vim.tbl_deep_extend('error', window_spec, { use_current_window = { false, 'b' } }),
  jump = vim.tbl_deep_extend('error', window_spec, { use_current_window = { true, 'b' } }),
  terminal = window_validate(false, false, false),
  window = window_validate(false, false, true),
  tags = {
    default_tag = { 'json', 's' },
    transform = {
      'snakecase',
      in_set(false, 'snakecase', 'camelcase', 'lispcase', 'pascalcase', 'keep'),
      'valid transform: snakecase, camelcase, lispcase, pascalcase, keep',
    },
    skip_unexported = { false, 'b' },
  },
  ['golangci-lint'] = {
    config_file = { nil, 's' },
  },
  format = {
    max_line_length = {
      120,
      is_positive(false),
      'positive integer',
    },
    run_on_save = { true, 'b' },
  },
  highlight = {
    current_symbol = { true, 'b' },
  },
  codelens = {
    show = { true, 'b' },
  },
  revive = {
    config_file = { nil, 's' },
  },
  testing = vim.tbl_deep_extend('error', window_validate(false, false, false), {
    ['vim-test'] = { strategy = { 'neovim', 's' } },
    native = { strategy = { 'display', in_set(false, 'display', 'background'), 'valid strategies: display, background' } },
    runner = { 'native', in_set(false, 'native', 'vim-test'), 'valid testing.runner: native, vim-test' },
    arguments = { {}, 't' },
    template = { nil, 's' },
    template_dir = { nil, 's' },
    template_params_dir = { nil, 's' },
  }),
  gopls = {
    options = { { '-remote=auto' }, 't' },
    config = { nil, is_type(true, 'table', 'function'), 'expected table or function' },
  },
  null = vim.tbl_deep_extend(
    'error',
    { config = { nil, is_type(true, 'table', 'function'), 'expected table or function' } },
    { disabled = { false, 'b' } },
    services()
  ),
}

local function defaults(spec)
  if not vim.tbl_isempty(_defaults) then
    return _defaults
  end
  local d = {}
  for grp, val in pairs(spec) do
    d[grp] = {}
    for k, v in pairs(val) do
      if not vim.tbl_islist(v) then
        d[grp] = vim.tbl_deep_extend('force', d[grp] or {}, defaults { [k] = v })
      else
        d[grp][k] = v[1]
      end
    end
  end
  return d
end

local function check_only_valid_keys(allowed, keys)
  for _, k in ipairs(keys) do
    if not vim.tbl_contains(allowed, k) then
      return false, k
    end
  end
  return true
end

local function build_validation(spec, uc)
  local validate = {}
  for grp, val in pairs(spec) do
    validate[grp] = function()
      local ok, bad = check_only_valid_keys(vim.tbl_keys(spec[grp]), vim.tbl_keys(uc[grp]))
      if not ok then
        log_error('Config', string.format("Unknown name '%s' in configuration group '%s'", bad, grp))
        return false
      end
      return true
    end
    for k, v in pairs(val) do
      if not vim.tbl_islist(v) then
        local key = grp .. '.' .. k
        validate = vim.tbl_deep_extend('force', validate, build_validation({ [key] = v }, { [key] = uc[grp][k] or {} }))
      else
        local vkey = grp .. '.' .. k
        local default = v[1]
        local value = uc[grp][k] or default
        local check = v[2]
        if type(check) == 'function' then
          validate[vkey] = { value, check, v[3] }
        else
          if default == nil then
            validate[vkey] = { value, check, true }
          else
            validate[vkey] = { value, check }
          end
        end
      end
    end
  end
  return validate
end

local function validate(v)
  local type_map = { s = 'string', b = 'boolean', t = 'table', f = 'function', n = 'number' }
  for key, spec in pairs(v) do
    if type(spec) == 'function' then
      if not spec() then
        return false
      end
    else
      local default = spec[1]
      if type(spec[2]) == 'function' then
        local f = spec[2]
        local msg = spec[3]
        local ok, got = f(default)
        if not ok then
          if msg == nil then
            log_error('Config', string.format("Key '%s' has invalid value '%s'", key, got or default))
            return false
          else
            log_error('Config', string.format("Key '%s' has invalid value '%s', expected %s", key, got or default, msg))
            return false
          end
        end
      else
        local type_sym = spec[2]
        local nil_ok = spec[3] or false
        if default == nil then
          if not nil_ok then
            log_error('Config', string.format("Key '%s' may not be nil.", key))
            return false
          end
        elseif not (type(default) == type_map[type_sym]) then
          log_error(
            'Config',
            string.format("Key '%s' must be of type '%s', got '%s'", key, type_map[type_sym], default)
          )
          return false
        end
      end
    end
  end
  return true
end

local function post_validate()
  local c = _config
  if c.null.gofmt == true and c.null.gofumpt == true then
    log_error('Config', 'null.gofmt and null.gofumpt should not both be turned on. Turning off gofmt.')
    M.set('null', 'gofmt', false)
  end
  return true
end

local function all_config_keys()
  return vim.tbl_keys(defaults(SPEC))
end

local function validate_config()
  local ok, bad = check_only_valid_keys(all_config_keys(), vim.tbl_keys(_config))
  if not ok then
    log_error('Config', string.format("Unknown name '%s' in configuration.", bad))
    return
  end

  config_is_ok = validate(build_validation(SPEC, _config))
  if M.config_is_ok() then
    config_is_ok = post_validate()
  end
  return config_is_ok
end

function M.window_opts(grp, ...)
  return vim.tbl_deep_extend('force', M.get 'window', grp and M.get(grp) or {}, ...)
end

function M.terminal_opts(grp, ...)
  return vim.tbl_deep_extend('force', M.get 'terminal', grp and M.get(grp) or {}, { terminal = true }, ...)
end

function M.service_is_disabled(name)
  return not M.get('null', name)
end

function M.setup(user_config)
  -- if config.is_ok is nil it means
  -- the config hasn't been read yet
  if M.config_is_ok() ~= nil then
    return M.config_is_ok()
  end
  user_config = user_config or {}
  set_autoconfig(user_config)
  _defaults = defaults(SPEC)
  _config = vim.tbl_deep_extend('force', defaults(SPEC), user_config)
  return validate_config()
end

function M.get(grp, key, other)
  if key == nil then
    return _config[grp]
  elseif other == nil then
    return _config[grp][key]
  else
    return _config[grp][key][other]
  end
end

function M.set(grp, key, val)
  _config[grp][key] = val
end

function M.dump()
  require('goldsmith.log').debug('config', function()
    return 'defaults: ' .. vim.inspect(defaults(SPEC))
  end)
  require('goldsmith.log').debug('config', function()
    return 'config: ' .. vim.inspect(_config)
  end)
end

return M
