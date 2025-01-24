-- General settings for auto-indentation and formatting
vim.cmd("set expandtab")      -- Use spaces instead of tabs
vim.cmd("set tabstop=2")      -- Set tab width to 2
vim.cmd("set softtabstop=2")  -- Soft tab stop for editing
vim.cmd("set shiftwidth=2")   -- Set indentation width to 2 spaces
vim.cmd("set number")         -- Show absolute line numbers
vim.cmd("set relativenumber") -- Show relative line numbers
vim.cmd("set autoindent")     -- Enable automatic indentation
vim.cmd("set smartindent")    -- Enable smart indentation
vim.cmd("set smarttab")       -- Enable smart tab for insertion
vim.cmd("set cindent")        -- Enable C-style indenting

-- Leader key setting
vim.g.mapleader = " " -- Set leader key to space

-- Clipboard Key Mappings for Ctrl+C and Ctrl+V
-- Use + register (system clipboard) to copy and paste
vim.api.nvim_set_keymap('n', '<C-c>', '"+y', { noremap = true, silent = true }) -- Ctrl+C to copy
vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true, silent = true }) -- Ctrl+C in visual mode to copy
vim.api.nvim_set_keymap('n', '<C-v>', '"+p', { noremap = true, silent = true }) -- Ctrl+V to paste
vim.api.nvim_set_keymap('v', '<C-v>', '"+p', { noremap = true, silent = true }) -- Ctrl+V in visual mode to paste

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
  { "catppuccin/nvim",                 name = "catppuccin", priority = 1000 },
  { "nvim-telescope/telescope.nvim",   tag = '0.1.8',       dependencies = { 'nvim-lua/plenary.nvim' } },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" }
  },
  { "nvim-lualine/lualine.nvim" },                                                     -- Lualine plugin
  { "dracula/vim",                       as = "dracula" },                             -- Dracula theme plugin
  { "williamboman/mason.nvim",           build = ":MasonUpdate" },                     -- Mason for LSP server management
  { "williamboman/mason-lspconfig.nvim", dependencies = { "neovim/nvim-lspconfig" } }, -- LSP config integration
  { "hrsh7th/nvim-cmp" },                                                              -- Completion plugin
  { "hrsh7th/cmp-nvim-lsp" },                                                          -- LSP completion source for nvim-cmp
  { "hrsh7th/cmp-buffer" },                                                            -- Buffer completion source for nvim-cmp
  { "hrsh7th/cmp-path" },                                                              -- Path completion source for nvim-cmp
  { "saadparwaiz1/cmp_luasnip" },                                                      -- Luasnip completion source
  { "L3MON4D3/LuaSnip" },                                                              -- Snippet engine
  { "phpactor/phpactor",                 run = 'composer install --no-dev --optimize-autoloader' }, -- PHP actor plugin
  { "jose-elias-alvarez/null-ls.nvim",   dependencies = { "nvim-lua/plenary.nvim" } }, -- For code formatting
}

-- Load plugins with Lazy.nvim
require("lazy").setup(plugins)

-- Mason Setup
require("mason").setup()

-- Mason-lspconfig setup for automatic LSP installation
require("mason-lspconfig").setup({
  ensure_installed = {
    "clangd",                    -- C/C++ LSP
    "gopls",                     -- Go LSP
    "html",                      -- HTML LSP
    "cssls",                     -- CSS LSP
    "phpactor",                  -- PHP LSP
    "pyright",                   -- Python LSP
    "sumneko_lua",               -- Lua LSP
  },
  automatic_installation = true, -- Automatically install the LSPs
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
}

lspconfig.pyright.setup {
  capabilities = capabilities
}

lspconfig.sumneko_lua.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }, -- Recognize `vim` as a global variable (for Neovim Lua API)
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true), -- Use Neovim runtime for Lua
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
      hide_dotfiles = false,  -- Show or hide dotfiles
      hide_gitignored = true, -- Hide git-ignored files
    },
  },
  window = {
    width = 30, -- Window width
  },
})

-- Key mappings for NeoTree and other functions
vim.keymap.set('n', '<C-1>', ':Neotree focus<CR>', {})       -- Focus on NeoTree
vim.keymap.set('n', '<C-2>', ':wincmd p<CR>', {})            -- Focus on the code window (editor)
vim.keymap.set('n', '<C-3>', ':lua FocusTerminal()<CR>', {}) -- Focus on the terminal window

-- Terminal opening and focusing
vim.api.nvim_set_keymap('n', '<leader>t', ':term<CR>', { noremap = true, silent = true })

-- Function to focus on the terminal window (if open)
function FocusTerminal()
  -- Iterate through all windows to find the terminal window
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local bufname = vim.api.nvim_buf_get_name(buf)
    -- Check if the buffer is a terminal buffer (bufname starts with 'term://')
    if bufname:match('^term://') then
      vim.api.nvim_set_current_win(win) -- Focus on the terminal window
      return
    end
  end
  -- If no terminal window is found, open a new terminal at the bottom
  vim.cmd('belowright 10 new') -- Open terminal at the bottom with height of 10 lines
  vim.cmd('term')              -- Open terminal
end

-- Treesitter configuration
local treesitter = require("nvim-treesitter.configs")
treesitter.setup({
  ensure_installed = { "lua", "c", "cpp", "go", "python", "html", "php", "css" },
  highlight = { enable = true },
  indent = { enable = true }, -- Enable automatic indentation
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
vim.cmd.colorscheme("dracula") -- Set Dracula as the colorscheme

-- Lualine setup with Dracula theme
require('lualine').setup {
  options = {
    theme = 'dracula',
    section_separators = { '', '' },
    component_separators = { '', '' },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
}

-- Code formatting with null-ls
local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    -- Formatters
    null_ls.builtins.formatting.prettier,     -- Prettier (for JS, HTML, CSS, etc.)
    null_ls.builtins.formatting.black,        -- Black (for Python)
    null_ls.builtins.formatting.clang_format, -- Clang-format (for C/C++)
    null_ls.builtins.formatting.lua_format,   -- Lua format
    -- Add more formatters as needed
  },
})

-- Auto-formatting and auto-indentation on save
vim.cmd([[
  augroup AutoFormat
    autocmd!
    autocmd BufWritePre * lua vim.lsp.buf.format({ async = true })
  augroup END
]])

-- Compile current file or run script using Ctrl + e
vim.api.nvim_set_keymap('n', '<C-e>', ':w<CR>:lua CompileCurrentFile()<CR>', { noremap = true, silent = true })

-- ** Add key mappings for Ctrl + P and Space + FG **

-- Ctrl + P for Telescope find_files (File Finder)
vim.api.nvim_set_keymap('n', '<C-p>', ':Telescope find_files<CR>', { noremap = true, silent = true })

-- Space + FG for Telescope live_grep (Search through files)
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })


-- Define CompileCurrentFile function for compilation or execution
function CompileCurrentFile()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:p')   -- Get the full path of the current file
  local basename = vim.fn.expand('%:r')   -- Get the base name (no extension) of the current file

  if filetype == 'python' then
    -- Python file: run the script
    vim.cmd('!python3 ' .. filename)
  elseif filetype == 'c' then
    -- C file: compile using gcc and run, no .out file
    vim.cmd('!gcc ' .. filename .. ' -o ' .. basename .. ' && ./' .. basename)
  elseif filetype == 'cpp' then
    -- C++ file: compile using g++ and run, no .out file
    vim.cmd('!g++ ' .. filename .. ' -o ' .. basename .. ' && ./' .. basename)
  elseif filetype == 'java' then
    -- Java file: compile and run using javac and java
    local class_name = vim.fn.expand('%:r')
    vim.cmd('!javac ' .. filename)
    vim.cmd('!java ' .. class_name)
  else
    print("No compiler configured for this file type.")
  end
end
