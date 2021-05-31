local parsers = require'nvim-treesitter.parsers'
local util = require'nvim-treesitter.ts_utils'

-- tree sitter types for functions/methods
local FUNCTION_TYPES = {
  'function_declaration',
  'method_declaration'
}


local M = {}

local function find_all_functions(root, funcs)
  if root:child_count() == 0 then
    return
  end
  for node in root:iter_children() do
    local ntype = node:type()
    for _, valid in ipairs(FUNCTION_TYPES) do
      if ntype == valid then
        table.insert(funcs, node)
      end
    end
    find_all_functions(node, funcs)
  end
end

function M.cache_all_functions()
  local trees = parsers.get_parser():parse()
  local cache = {}
  find_all_functions(trees[1]:root(), cache)
  return cache
end

function M.goto_next_function()
  local funcs = M.cache_all_functions()
  local _, line = unpack(vim.fn.getpos('.'))
  for _, func in ipairs(funcs) do
    local x1 = util.get_node_range(func)
    if line < x1+1 then
      util.goto_node(func, false, false)
      break
    end
  end
end

function M.goto_prev_function()
  local funcs = M.cache_all_functions()
  local _, line = unpack(vim.fn.getpos('.'))
  local prev
  for _, func in ipairs(funcs) do
    local x1 = util.get_node_range(func)
    if line <= x1+1 then
      util.goto_node(prev or func, false, false)
      break
    end
    prev = func
  end
end

return M
