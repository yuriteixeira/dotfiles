require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

local servers = {
  "html",
  "cssls",
  "vtsls",
  "eslint",
  "graphql",
  "svelte",
  "bashls",
}

for _, lsp in ipairs(servers) do
  local options = {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }

  if lsp == "vtsls" then
    options.settings = {
      vtsls = {
        enableMoveToFileCodeAction = true,
        autoUseWorkspaceTsdk = true,
      },

      typescript = {
        suggest = {
          completeFunctionCalls = true,
        },
      },
    }
  end

  lspconfig[lsp].setup(options)
end
