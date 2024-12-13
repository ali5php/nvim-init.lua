-- General settings
vim.cmd("set expandtab")           -- Use spaces instead of tabs
vim.cmd("set tabstop=2")           -- Set tab width to 2
vim.cmd("set softtabstop=2")       -- Soft tab stop for editing
vim.cmd("set shiftwidth=2")        -- Set indentation width to 2 spaces
vim.cmd("set number")              -- Show absolute line numbers
vim.cmd("set relativenumber")      -- Show relative line numbers

-- Leader key setting
vim.g.mapleader = " "             -- Set leader key to space

-- Lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin list
local plugins = {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "nvim-telescope/telescope.nvim", tag = '0.1.8', dependencies = { 'nvim-lua/plenary.nvim' } },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" }
  },
  { "nvim-lualine/lualine.nvim" },  -- Lualine plugin
  { "dracula/vim", as = "dracula" }, -- Dracula theme plugin
  { "williamboman/mason.nvim", build = ":MasonUpdate" }, -- Mason for LSP server management
  { "williamboman/mason-lspconfig.nvim", dependencies = { "neovim/nvim-lspconfig" } },  -- LSP config integration
  { "hrsh7th/nvim-cmp" }, -- Completion plugin
  { "hrsh7th/cmp-nvim-lsp" }, -- LSP completion source for nvim-cmp
  { "hrsh7th/cmp-buffer" }, -- Buffer completion source for nvim-cmp
  { "hrsh7th/cmp-path" }, -- Path completion source for nvim-cmp
  { "saadparwaiz1/cmp_luasnip" }, -- Luasnip completion source
  { "L3MON4D3/LuaSnip" }, -- Snippet engine
  { "phpactor/phpactor", run = 'composer install --no-dev --optimize-autoloader' }, -- PHP actor plugin
}

-- Load plugins with Lazy.nvim
require("lazy").setup(plugins)

-- Mason Setup
require("mason").setup()

-- Mason-lspconfig setup for automatic LSP installation
require("mason-lspconfig").setup({
  ensure_installed = {
    "clangd",       -- C/C++ LSP
    "gopls",        -- Go LSP
    "html",         -- HTML LSP
    "cssls",        -- CSS LSP
    "phpactor",     -- PHP LSP
    "pyright",      -- Python LSP
    "sumneko_lua",  -- Lua LSP
  },
  automatic_installation = true,  -- Automatically install the LSPs
})

-- Setup for specific LSPs
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- LSP Servers setup
lspconfig.clangd.setup {
  capabilities = capabilities
}

lspconfig.gopls.setup {
  capabilities = capabilities
}

lspconfig.html.setup {
  capabilities = capabilities
}

lspconfig.cssls.setup {
  capabilities = capabilities
}

-- PHP Setup (phpactor)
lspconfig.phpactor.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- Add PHP-specific settings if needed
  end
}

lspconfig.pyright.setup {
  capabilities = capabilities
}

lspconfig.sumneko_lua.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = {"vim"},  -- Recognize `vim` as a global variable (for Neovim Lua API)
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),  -- Use Neovim runtime for Lua
      },
    },
  },
}

-- Auto-completion setup (nvim-cmp)
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'luasnip' },
  },
})

-- Setup for Snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- NeoTree setup
require("neo-tree").setup({
  close_if_last_window = true,   -- Close NeoTree if it's the last window
  popup_border_style = "double", -- Style of popup border
  filesystem = {
    filtered_items = {
      visible = true,
      hide_dotfiles = false, -- Show or hide dotfiles
      hide_gitignored = true, -- Hide git-ignored files
    },
  },
  window = {
    width = 30,  -- Window width
  },
})

-- Key mappings for NeoTree
vim.keymap.set('n', '<C-t>', ':Neotree toggle<CR>', {})  -- Toggle NeoTree
vim.keymap.set('n', '<leader>t', ':Neotree reveal left<CR>', {})  -- Reveal left pane
-- Map <leader>t to open terminal at the bottom
vim.api.nvim_set_keymap('n', '<leader>t', ':belowright 7 split | terminal<CR>', { noremap = true, silent = true })


-- Telescope setup for live_grep
require("telescope").setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--ignore',
      '--vimgrep',
      '--no-heading',
      '--color=never',
      '--smart-case',
    },
  },
}

-- Key mappings for Telescope and NeoTree
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<C-t>', ':Neotree toggle<CR>', {})

-- Treesitter configuration
local treesitter = require("nvim-treesitter.configs")
treesitter.setup({
  ensure_installed = { "lua", "c", "cpp", "go", "python", "html", "php", "css" },
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<TAB>",
      node_decremental = "<S-TAB>",
      scope_incremental = "<C-Space>",
    },
  },
  autotag = { enable = true },
})

-- Use Dracula theme for Neovim and Lualine
vim.cmd.colorscheme("dracula")  -- Set Dracula as the colorscheme

-- Lualine setup with Dracula theme
require('lualine').setup {
  options = {
    theme = 'dracula',
    section_separators = {'', ''},
    component_separators = {'', ''},
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat'},
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
}

