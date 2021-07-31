local parsers = require 'nvim-treesitter.parsers'
local ts_utils = require 'nvim-treesitter.ts_utils'

local M = {}

local function find_all_functions(root, funcs)
  if root:child_count() == 0 then
    return
  end
  for node in root:iter_children() do
    local ntype = node:type()
    if ntype == 'function_declaration' or ntype == 'method_declaration' then
      table.insert(funcs, (ts_utils.get_node_text(node:child(1)))[1])
    end
    find_all_functions(node, funcs)
  end
end

function M.get_all_functions()
  local trees = parsers.get_parser():parse()
  local funcs = {}
  find_all_functions(trees[1]:root(), funcs)
  return funcs
end

local function find_all_modules(root, mods)
  if root:child_count() == 0 then
    return
  end
  for node in root:iter_children() do
    local ntype = node:type()
    local ptype = node:parent():type()
    if ntype == 'module_path' and ptype == 'require_spec' then
      table.insert(mods, (ts_utils.get_node_text(node))[1])
    end
    find_all_modules(node, mods)
  end
end

function M.get_all_modules()
  local trees = parsers.get_parser():parse()
  local mods = {}
  find_all_modules(trees[1]:root(), mods)
  return mods
end

function M.get_module_at_cursor()
  local cnode = ts_utils.get_node_at_cursor()
  if not cnode then
    return
  end

  local parent = cnode:parent()
  if parent ~= nil and parent:type() == 'require_spec' then
    local mod, v
    for node in parent:iter_children() do
      if node:type() == 'module_path' then
        mod = (ts_utils.get_node_text(node))[1]
      end
      if node:type() == 'version' then
        v = (ts_utils.get_node_text(node))[1]
      end
    end
    return { name = mod, version = v }
  end
end

function M.get_current_function_name()
  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then
    return
  end
  local expr = current_node

  while expr do
    if expr:type() == 'function_declaration' or expr:type() == 'method_declaration' then
      break
    end
    expr = expr:parent()
  end

  if not expr then
    return
  end

  return (ts_utils.get_node_text(expr:child(1)))[1]
end

return M
