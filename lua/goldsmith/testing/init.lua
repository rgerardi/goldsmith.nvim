local fs = require 'goldsmith.fs'
local go = require 'goldsmith.go'
local config = require 'goldsmith.config'
local log = require 'goldsmith.log'

local M = {}

goldsmith_test_complete = function(...)
  local _, c = ...
  return M.test_complete(c)
end

goldsmith_test_package_complete = function()
  return M.package_complete()
end

function M.package_complete()
  local ok, l = go.list(false, './...') -- potentially expensive?
  if not ok then
    log.error('Testing', 'Failed to find all packages for current module/project.')
  end
  local pkgs = {}
  for _, p in ipairs(l) do
    local d = vim.fn.fnamemodify(p.Dir, ':.')
    if d ~= vim.fn.getcwd() then
      table.insert(pkgs, fs.relative_to_cwd(d))
    end
  end
  table.sort(pkgs)
  table.insert(pkgs, './...')
  table.insert(pkgs, '.')
  return table.concat(pkgs, '\n')
end

function M.test_complete(c)
  local cp = fs.relative_to_cwd(vim.fn.expand '%')
  local ok, list = go.list(false, cp)
  if not ok then
    log.error('Testing', 'Failed to find all test files for current package.')
  end
  local test_files = list[1]['TestGoFiles'] or {}
  local dir = list[1]['Dir']
  local tests = {}
  for _, tf in ipairs(test_files) do
    local fp = dir .. '/' .. tf
    local f, err = io.open(dir .. '/' .. tf)
    if f == nil then
      log.warn('Testing', string.format("Cannot open file '%s' for reading: %s", fp, err))
    else
      for line in f:lines() do
        local fname
        if string.match(c, '^GoTestRun') ~= nil then
          fname = string.match(line, 'func%s+(Test.*)%(') or string.match(line, 'func%s+(Example.*)%(')
        elseif string.match(c, '^GoTestBRun') ~= nil then
          fname = string.match(line, 'func%s+(Benchmark.*)%(')
        elseif string.match(c, '^GoTestARun') ~= nil then
          fname = string.match(line, 'func%s+(Test.*)%(')
            or string.match(line, 'func%s+(Example.*)%(')
            or string.match(line, 'func%s+(Benchmark.*)%(')
        end
        table.insert(tests, fname)
      end
    end
  end
  table.sort(tests)
  return table.concat(tests, '\n')
end

function M.setup()
  if M['testing_module'] ~= nil then
    return
  end

  local mod_name = config.get('testing', 'runner')
  local mod_path = string.format('goldsmith.testing.%s', mod_name)
  local m = require(mod_path)
  if not m.has_requirements() then
    log.warn('Testing', string.format("Requirements for %s are not met. Setting testing to 'native'.", mod_name))
    mod_name = 'native'
    mod_path = string.format('goldsmith.testing.%s', mod_name)
    m = require(mod_path)
  end

  local _, f = pcall(require, mod_path)
  M.last = f.last
  M.nearest = f.nearest
  M.visit = f.visit
  M.suite = f.suite
  M.pkg = f.pkg

  M.testing_module = function()
    return m
  end

  m.create_commands()
end

return M
