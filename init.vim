" nvim/neovide configuration created and maintained by DioDredd
" plugins list
call plug#begin('~/.nvim/plugin')
    Plug 'scrooloose/nerdtree'
    Plug 'gpanders/editorconfig.nvim' 
    Plug 'morhetz/gruvbox'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'elixir-lsp/coc-elixir', {'do': 'yarn install && yarn prepack'}
    Plug 'elixir-editors/vim-elixir'
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'nvim-lualine/lualine.nvim'
    " If you want to have icons in your statusline choose one of these
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'ryanoasis/vim-devicons'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
    Plug 'airblade/vim-gitgutter'
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'neovim/nvim-lspconfig'
    " Plug 'arcticicestudio/nord-vim'
    Plug 'shaunsingh/nord.nvim', { 'commit': '78f5f001709b5b321a35dcdc44549ef93185e024' }
call plug#end()

"<------- General configuraiton ------->
set number
set relativenumber
set clipboard=unnamed
set nowrap
set showmatch
set ignorecase
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=2

let g:nord_contrast = v:false
let g:nord_borders = v:true
let g:nord_disable_background = v:false
let g:nord_italic = v:false
let g:nord_uniform_diff_background = v:true
let g:nord_bold = v:false
let g:nord_cursorline_transparent = v:true

colorscheme nord
"colorscheme tokyonight-night
"colorscheme gruvbox

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

autocmd VimLeave * NERDTreeClose
autocmd VimLeave * call SaveSess()
autocmd VimEnter * nested call RestoreSess()
autocmd VimEnter * NERDTree

set sessionoptions-=options  " Don't save options

" <------- CoC general and autocomplete configuration ------->
" list of CoC extension that would be automatically installed on 1st sturtup
let g:coc_global_extensions = [
      \'coc-eslint',
      \'coc-tsserver',
      \'coc-rust-analyzer',
      \'coc-markdownlint',
      \'coc-highlight',
      \'coc-explorer',
      \'coc-json', 
      \'coc-git'
      \]

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <expr> <space> coc#pum#visible() ? coc#_select_confirm() : "\<space>"
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

" <------ NERDTree configuration ------>
let NERDTreeShowHidden=1
map <leader>r :NERDTreeFind<cr>

" <------ Neovide config section ------>
if exists("g:neovide")
    set guifont=Iosevka\ Custom:h15
    "let g:transparency = 0.9
    let g:neovide_scroll_animation_length = 0.3
    let g:neovide_transparency = 0.85
    let g:neovide_remember_window_size = v:true
endif

" <------ MacOS-specific settings section ------->
"let g:coc_node_path = '/Users/alestsvil/.nvm/versions/node/v16.13.2/bin/node'
"let g:coc_node_path = trim(system('which node'))

" <------ Lua script configuraiton until the EOF ------>
lua <<EOF
vim.opt.list = true

require'lspconfig'.tsserver.setup{}

require('nvim-treesitter.configs').setup {
  ensure_installed = { "c", "cpp", "lua", "rust", "javascript", "typescript" },
  highlight = { enable = true },
  indent = { enable = true }
}
 
require("indent_blankline").setup {
    use_treesitter = true,
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}

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
    theme = 'nord',
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
EOF
