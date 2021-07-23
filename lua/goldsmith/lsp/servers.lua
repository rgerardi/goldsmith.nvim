local tools = require 'goldsmith.tools'
local plugins = require 'goldsmith.plugins'

local M = {}

function M.check()
  local names = M.names()
  return tools.check(names)
end

function M.is_server(name)
    for _, sn in pairs(M.names()) do
      local sni = M.info(sn)
      for _, pn in ipairs({ sn, sni.name, sni.lspconfig_name, sni.lspinstall_name }) do
        if name == pn then
          return true, sn
        end
      end
    end
    return false
end

function M.lsp_plugin_name(server)
  if plugins.is_installed('lspinstall') then
    return M.info(server).lspinstall_name
  elseif plugins.is_installed('lspconfig') then
    return M.info(server).lspconfig_name
  end
end

function M.names()
  return tools.names { server = true }
end

function M.is_required(server)
  return tools.is_required(server)
end

function M.is_installed(server)
  return tools.is_installed(server)
end

function M.info(server)
  return tools.info(server)
end

function M.dump()
  tools.dump()
end

return M
