local cmp = require 'cmp'
local cmp_format = require('lsp-zero').cmp_format({ details = true })

cmp.setup({
  preselect = 'item',

  completion = {
    completeopt = 'menu,menuone,noinsert'
  },

  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  }),

  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },

  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),

    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),

  formatting = cmp_format,
})

local lsp_zero = require('lsp-zero')

local cmp_lsp_default_capabilities = require('cmp_nvim_lsp').default_capabilities()

require 'lspconfig.ui.windows'.default_options.border = 'single'

lsp_zero.extend_lspconfig({
  sign_text = true,
  capabilities = cmp_lsp_default_capabilities,
})

lsp_zero.ui({
  float_border = 'rounded',
  sign_text = {
    error = '✘',
    warn = '⚠',
    hint = '⚑',
    info = 'ℹ',
  },
})

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = {
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
})

-- https://github.com/neovim/neovim/issues/20784#issuecomment-1288085253

require 'lspconfig'.vtsls.setup {
  settings = {
    vtsls = {
      enableMoveToFileCodeAction = true,
    },
  }
}

require 'lspconfig'.eslint.setup {}

require 'lspconfig'.svelte.setup {}

require 'lspconfig'.graphql.setup {}

require 'lspconfig'.lua_ls.setup {}

require 'lspconfig'.cssls.setup {}

require 'fzf_lsp'.setup {
  override_ui_select = true
}

require 'nvim-tree'.setup {
  view = {
    width = 50,
  },
}

require 'lsp-file-operations'.setup {}
