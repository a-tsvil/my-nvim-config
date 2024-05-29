" nvim/neovide configuration created and maintained by DioDredd
" plugins list
call plug#begin('~/.nvim/plugin')
    Plug 'scrooloose/nerdtree'
    Plug 'gpanders/editorconfig.nvim' 
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " Plug 'elixir-lsp/coc-elixir', {'do': 'yarn install && yarn prepack'}
    Plug 'elixir-editors/vim-elixir'
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'nvim-lualine/lualine.nvim'
    " If you want to have icons in your statusline choose one of these
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'ryanoasis/vim-devicons'
    Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'airblade/vim-gitgutter'
    Plug 'folke/todo-comments.nvim'
    " Colorschemes plugins
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    " Plug 'shaunsingh/nord.nvim', { 'commit': '78f5f001709b5b321a35dcdc44549ef93185e024' }
    Plug 'morhetz/gruvbox'
    Plug 'EdenEast/nightfox.nvim'
    Plug 'arcticicestudio/nord-vim'
    Plug 'tpope/vim-fugitive'
    Plug 'chrisbra/Colorizer'
    Plug 'hashivim/vim-terraform'
    Plug 'tpope/vim-surround'
    Plug 'wellle/context.vim'
    Plug 'mg979/vim-visual-multi', {'branch': 'master'}
    " Plug 'wfxr/minimap.vim'
    Plug 'rust-lang/rust.vim'
    Plug 'prisma/vim-prisma'
    Plug 'bluz71/vim-nightfly-colors', { 'as': 'nightfly' }
    Plug 'overcache/NeoSolarized'
    Plug 'pmizio/typescript-tools.nvim' 
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
    Plug 'tpope/vim-commentary'
    " Plug 'goolord/alpha-nvim'
    Plug 'nvim-tree/nvim-web-devicons'
    " Plug 'startup-nvim/startup.nvim' 
    Plug 'gleam-lang/gleam.vim'
    Plug 'stevearc/conform.nvim'
    Plug 'udalov/kotlin-vim'
call plug#end()

"<------- General configuraiton ------->
set number
set relativenumber
set clipboard+=unnamedplus
set nowrap
set showmatch
set ignorecase
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=2
set cursorline
set list
" lead:⋅
set listchars=tab:›\ ,trail:⋅

" Color scheme settings
colorscheme terafox
let g:nord_contrast = v:false
let g:nord_borders = v:true
let g:nord_disable_background = v:false
let g:nord_italic = v:false
let g:nord_uniform_diff_background = v:true
let g:nord_bold = v:false
let g:nord_cursorline_transparent = v:true

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" File History open mapping
nmap <silent> <leader>m :History<CR>

" <------ Session restoration configuration ------->`
fu! SaveSess()
  execute 'mksession! ' . getcwd() . '/.session.vim'
endfunction

fu! RestoreSess()
  if filereadable(getcwd() . '/.session.vim')
    execute 'so ' . getcwd() . '/.session.vim'
    if bufexists(1)
      for l in range(1, bufnr('$'))
        if bufwinnr(l) == -1
          exec 'sbuffer ' . l
        endif
      endfor
    endif
  endif
endfunction

" <------- Auto Commands config section ------->
" autocmd VimLeave * NERDTreeClose
"autocmd VimLeave * call SaveSess()
"autocmd VimEnter * nested call RestoreSess()
"set sessionoptions-=options  " Don't save options
" autocmd VimEnter * NERDTree
" autocmd VimEnter * call timer_start(30, { tid -> execute('NERDTree')})
autocmd VimEnter * call timer_start(170, { tid -> execute(':vertical resize +15 | :wincmd b | :belowright split terminal | :resize 10 | :wincmd b | :term ')})

" NERDTree focus mapping
nnoremap <leader>nf :NERDTreeFind<CR>

" Prettier on save config
autocmd BufWritePre *.ts :Prettier
autocmd BufWritePre *.tsx :Prettier
autocmd BufWritePre *.css :Prettier

" <------- CoC general and autocomplete configuration ------->
" list of CoC extension that would be automatically installed on 1st sturtup
"      \'coc-highlight',
let g:coc_global_extensions = [
      \'coc-highlight',
      \'coc-eslint',
      \'coc-tsserver',
      \'coc-prettier',
      \'coc-rust-analyzer',
      \'coc-markdownlint',
      \'coc-explorer',
      \'coc-json', 
      \'coc-git',
      \'coc-prisma',
      \'coc-kotlin',
      \]

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<cr>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
let g:coc_snippet_next = '<tab>'
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" Insert <tab> when previous text is space, refresh completion if not.
inoremap <silent><expr> <TAB>
  \ coc#pum#visible() ? coc#pum#next(1):
  \ CheckBackspace() ? "\<Tab>" :
  \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif
command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" <------ NERDTree configuration ------>
let NERDTreeShowHidden=1
map <leader>r :NERDTreeFind<cr>

" <------ Neovide config section ------>
if exists("g:neovide")
    set guifont=Iosevka\ Custom:h14
    "let g:transparency = 0.9
    let g:neovide_scroll_animation_length = 0.35
    let g:neovide_transparency = 0.92
    let g:neovide_remember_window_size = v:true
    let g:neovide_refresh_rate = 2000
endif

" <------ MacOS-specific settings section ------->
" let g:coc_node_path = '/home/difodredd/.nvm/versions/node/v18.15.0/bin/node'
"let g:coc_node_path = trim(system('which node'))

let g:colorizer_auto_filetype='css,html,js,ts,svelte'

" <------ Temporary fix for the CoC breaking VIM's Visual Select Feature ------>
"inoremap <s-v> :CocDisable<s-v>:CocEnable
map rf :%! rustfmt <CR>

" <------ Minimap config ------>
" let g:minimap_width = 10
" let g:minimap_auto_start = 1

" <------ Commentary.vim ------>
filetype plugin indent on
map gc :Commentary <CR>
map gcc :Commentary <CR>

set conceallevel=2
" <------ Lua script configuraiton until the EOF ------>
lua <<EOF
on_attach = function(client, bufnr)
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true)
    end
end

vim.opt.fillchars = {eob = " "}
vim.opt.list = true

vim.diagnostic.config({
  virtual_lines = false,
})

require'lspconfig'.kotlin_language_server.setup{}
require'lspconfig'.gleam.setup{}
require'lspconfig'.terraformls.setup{}
require'lspconfig'.tsserver.setup {
  on_attach = on_attach,
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayVariableTypeHints = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayVariableTypeHints = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
}
require'lspconfig'.rust_analyzer.setup {}

require('nvim-treesitter.configs').setup {
  ensure_installed = { "lua", "rust", "javascript", "typescript", "yaml", "vim", "kotlin" },
  highlight = { enable = true, disable = { "vim", "txt" } },
  indent = { enable = true }
 }

vim.treesitter.language.add("gleam", { path = "/home/diodredd/tree-sitters/tree-sitter-gleam/gleam.so" })
-- vim.treesitter.language.add("kotlin", { path = "/home/diodredd/tree-sitters/tree-sitter-kotlin/kotlin.so" })

local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
    "CurrentScope",
}

local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
    vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
    vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
    vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
    vim.api.nvim_set_hl(0, "CurrentScope", { fg = "#A784DB" })
end)

require("ibl").setup({ 
  indent = { highlight = highlight },
  scope = { 
    enabled = true,
    include = { 
       node_type = { ["*"] = { "*" } },
    }
  },
})

local colors = {
  red = '#ca1243',
  grey = '#a0a1a7',
  black = '#383a42',
  white = '#f3f3f3',
  light_green = '#83a598',
  orange = '#fe8019',
  green = '#8ec07c',
}

local theme = {
  normal = {
    a = { fg = colors.white, bg = colors.black },
    b = { fg = colors.white, bg = colors.grey },
    c = { fg = colors.black, bg = colors.white },
    z = { fg = colors.white, bg = colors.black },
  },
  insert = { a = { fg = colors.black, bg = colors.light_green } },
  visual = { a = { fg = colors.black, bg = colors.orange } },
  replace = { a = { fg = colors.black, bg = colors.green } },
}

local empty = require('lualine.component'):extend()
function empty:draw(default_highlight)
  self.status = ''
  self.applied_separator = ''
  self:apply_highlights(default_highlight)
  self:apply_section_separators()
  return self.status
end

-- Put proper separators and gaps between components in sections
local function process_sections(sections)
  for name, section in pairs(sections) do
    local left = name:sub(9, 10) < 'x'
    for pos = 1, name ~= 'lualine_z' and #section or #section - 1 do
      table.insert(section, pos * 2, { empty, color = { fg = colors.white, bg = colors.white } })
    end
    for id, comp in ipairs(section) do
      if type(comp) ~= 'table' then
        comp = { comp }
        section[id] = comp
      end
      comp.separator = left and { right = '' } or { left = '' }
    end
  end
  return sections
end

local function search_result()
  if vim.v.hlsearch == 0 then
    return ''
  end
  local last_search = vim.fn.getreg('/')
  if not last_search or last_search == '' then
    return ''
  end
  local searchcount = vim.fn.searchcount { maxcount = 9999 }
  return last_search .. '(' .. searchcount.current .. '/' .. searchcount.total .. ')'
end

local function modified()
  if vim.bo.modified then
    return '+'
  elseif vim.bo.modifiable == false or vim.bo.readonly == true then
    return '-'
  end
  return ''
end

require('lualine').setup {
  options = {
    theme = 'terafox',
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = process_sections {
    lualine_a = { 'mode' },
    lualine_b = {
      'branch',
      'diff',
      {
        'diagnostics',
        source = { 'nvim' },
        sections = { 'error' },
        diagnostics_color = { error = { bg = colors.red, fg = colors.white } },
      },
      {
        'diagnostics',
        source = { 'nvim' },
        sections = { 'warn' },
        diagnostics_color = { warn = { bg = colors.orange, fg = colors.white } },
      },
      { 'filename', file_status = false, path = 1 },
      { modified, color = { bg = colors.red } },
      {
        '%w',
        cond = function()
          return vim.wo.previewwindow
        end,
      },
      {
        '%r',
        cond = function()
          return vim.bo.readonly
        end,
      },
      {
        '%q',
        cond = function()
          return vim.bo.buftype == 'quickfix'
        end,
      },
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = { search_result, 'filetype' },
    lualine_z = { '%l:%c', '%p%%/%L' },
  },
  inactive_sections = {
    lualine_c = { '%f %y %m' },
    lualine_x = {},
  },
}

require("todo-comments").setup {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
}

require("conform").setup({
  formatters_by_ft = {
    kotlin = { "ktlint" }
  },
  format_after_save = {
    -- These options will be passed to conform.format()
    async = true,
    lsp_fallback = true,
  },
})

EOF
