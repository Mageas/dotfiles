" plugins {{{

call plug#begin('~/.config/nvim/plugged')

"{{ file management }}
    Plug 'scrooloose/nerdtree'
"{{ tree }}
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
"{{ ui }}
    Plug 'dracula/vim'
    Plug 'itchyny/lightline.vim'
    Plug 'luochen1990/rainbow'
"{{ git }}
    Plug 'APZelos/blamer.nvim'
"{{ lsp }}
    Plug 'neovim/nvim-lspconfig'
"{{ completion }}
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-vsnip'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-buffer'
"{{ rust dev }}
    Plug 'simrat39/rust-tools.nvim'
"    Plug 'rust-lang/rust.vim'

call plug#end()

" }}}

" itchyny/lightline.vim {{{

let g:lightline = {
      \ 'colorscheme': 'dracula',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'readonly'], [ 'filename' ] ],
      \   'right': [ [ 'percent', 'lineinfo' ], [ 'fileencoding', 'fileformat' ] ],
      \ },
      \ 'subseparator': { 'left': '', 'right': '' },
      \ 'component': {
      \   'fileencoding': ' %{&fenc!=#""?&fenc:&enc}',
      \   'fileformat': '[%{&ff}] ',
      \   'percent': ' %p%%',
      \   'lineinfo': ' %l:%c',
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \ },
      \ 'component_expand': {
      \   'readonly': 'LightLineReadOnly',
      \ },
      \ 'component_type': {
      \   'readonly': 'error',
      \   'percent': 'raw',
      \   'fileencoding': 'raw',
      \   'fileformat': 'raw',
      \ },
      \ }

function! LightlineFilename()
  let modified = &modified ? '[+]' : ''
  let root = fnamemodify(get(b:, 'git_dir'), ':h')
  let path = expand('%:p')
  if path[:len(root)-1] ==# root
    return path[len(root)+1:] . modified
  endif
  return expand('%') . modified
endfunction

function! LightLineReadOnly()
  return &readonly ? 'RO' : ''
endfunction

set laststatus=2
set noshowmode

" }}}

" simrat39/rust-tools.nvim {{{

set completeopt=menuone,noinsert,noselect
set shortmess+=c

lua <<EOF
-- https://sharksforarms.dev/posts/neovim-rust/
local nvim_lsp = require'lspconfig'

local opts = {
    tools = { -- rust-tools options
        autoSetHints = true,
        hover_with_actions = true,
        inlay_hints = {
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },
    },

    server = {
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = {
                    command = "clippy"
                },
            }
        }
    },
}

require('rust-tools').setup(opts)
EOF

lua <<EOF
local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },

  -- Installed sources
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'buffer' },
  },
})
EOF

" }}}

" scrooloose/nerdtree {{{

map <C-n> :NERDTreeToggle<CR>
let g:NERDTreeDirArrowExpandable = '►'
let g:NERDTreeDirArrowCollapsible = '▼'
let NERDTreeShowLineNumbers=1
let NERDTreeShowHidden=1
let NERDTreeMinimalUI = 1
let g:NERDTreeWinSize=38

autocmd FileType nerdtree nmap l <Enter>

" }}}

" luochen1990/rainbow {{{

let g:rainbow_active = 1

" }}}

" APZelos/blamer.nvim {{{

let g:blamer_enabled = 1
let g:blamer_delay = 1500
let g:blamer_show_in_visual_modes = 0

" }}}

" colors {{{

syntax enable
filetype plugin on
set termguicolors
set background=dark
colorscheme dracula

" }}}

" general {{{

set clipboard=unnamedplus
set nobackup
set noswapfile

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

autocmd BufWritePre * %s/\s\+$//e

" }}}

" tabs {{{

set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab

" }}}

" files {{{

set path+=**
set wildmenu
set wildmode=longest:full,full
set hidden

" }}}

" split {{{

set splitbelow
set splitright

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" files {{{

set path+=**
set wildmenu
set wildmode=longest:full,full
set wildignorecase
set wildignore=*.git/*
set hidden

cnoremap <expr> / wildmenumode() ? "\<C-Y>" : "/"

" }}}

" search {{{

set incsearch
set nohlsearch

set scrolloff=10

nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

nnoremap S :%s//g<Left><Left>

"}}}

" ui {{{

set number
set relativenumber
set modelines=1
set showcmd
set cursorline
set showmatch
set signcolumn=yes
set updatetime=50
set shortmess+=c

" }}}

" remap {{{

:imap ii <Esc>

let mapleader = ","
let g:mapleader = ","

nnoremap x "_x
nnoremap d "_d
nnoremap D "_D
vnoremap d "_d
nnoremap c "_c
nnoremap C "_C

nnoremap <leader>d "+d
nnoremap <leader>D "+D
vnoremap <leader>d "+d
nnoremap <leader>c "+c
nnoremap <leader>C "+C

" }}}

" rust {{{

" autocmd BufRead,BufNewFile Cargo.toml,Cargo.lock,*.rs compiler cargo

" }}}
